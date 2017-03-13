/*
Thanks Nghia Ho for his excellent code.
And,I modified the smooth step using a simple kalman filter .
So,It can processes live video streaming.
modified by chen jia.
email:chenjia2013@foxmail.com

Modification (PMM) by Peter Maersk-Moller 2016.
Contact through discussion forum for the Snowmix Project.
See https://sourceforge.net/projects/snowmix/
Modifications:
 1. last_T needs initalization in case first frame has no good features to track.
 2. calcOpticalFlowPyrLK() can throw an exceptions. Needs catching and handling.
 3. estimateRigidTransform() can throw an exceptions. Needs catching and handling.

Compile on Linux: g++ -ggdb `pkg-config --cflags opencv` -o opencvtest opencvtest.cpp `pkg-config --libs opencv`
*/

#include <opencv2/opencv.hpp>
#include <iostream>
#include <cassert>
#include <cmath>
#include <fstream>

using namespace std;
using namespace cv;

// This video stablisation smooths the global trajectory using a sliding average window

//const int SMOOTHING_RADIUS = 15; // In frames. The larger the more stable the video, but less reactive to sudden panning
const int HORIZONTAL_BORDER_CROP = 20; // In pixels. Crops the border to reduce the black borders from stabilisation being too noticeable.

// 1. Get previous to current frame transformation (dx, dy, da) for all frames
// 2. Accumulate the transformations to get the image trajectory
// 3. Smooth out the trajectory using an averaging window
// 4. Generate new set of previous to current transform, such that the trajectory ends up being the same as the smoothed trajectory
// 5. Apply the new transformation to the video

struct TransformParam
{
    TransformParam() {}
    TransformParam(double _dx, double _dy, double _da) {
        dx = _dx;
        dy = _dy;
        da = _da;
    }

    double dx;
    double dy;
    double da; // angle
};

struct Trajectory
{
    Trajectory() {}
    Trajectory(double _x, double _y, double _a) {
        x = _x;
        y = _y;
        a = _a;
    }
	// "+"
	friend Trajectory operator+(const Trajectory &c1,const Trajectory  &c2){
		return Trajectory(c1.x+c2.x,c1.y+c2.y,c1.a+c2.a);
	}
	//"-"
	friend Trajectory operator-(const Trajectory &c1,const Trajectory  &c2){
		return Trajectory(c1.x-c2.x,c1.y-c2.y,c1.a-c2.a);
	}
	//"*"
	friend Trajectory operator*(const Trajectory &c1,const Trajectory  &c2){
		return Trajectory(c1.x*c2.x,c1.y*c2.y,c1.a*c2.a);
	}
	//"/"
	friend Trajectory operator/(const Trajectory &c1,const Trajectory  &c2){
		return Trajectory(c1.x/c2.x,c1.y/c2.y,c1.a/c2.a);
	}
	//"="
	Trajectory operator =(const Trajectory &rx){
		x = rx.x;
		y = rx.y;
		a = rx.a;
		return Trajectory(x,y,a);
	}

    double x;
    double y;
    double a; // angle
};
//
int main(int argc, char **argv)
{
	if(argc < 2) {
		//cerr << "./VideoStab [video.avi]" << endl;
		// PMM. We know the name of the program. Let's use that
		cerr << argv[0] << " <video file>" << endl;
		return 0;
	}
	// For further analysis
	ofstream out_transform("prev_to_cur_transformation.txt");
	ofstream out_trajectory("trajectory.txt");
	ofstream out_smoothed_trajectory("smoothed_trajectory.txt");
	ofstream out_new_transform("new_prev_to_cur_transformation.txt");

	VideoCapture cap(argv[1]);
	assert(cap.isOpened());

	Mat cur, cur_grey;
	Mat prev, prev_grey;

	cap >> prev;//get the first frame.ch
	cvtColor(prev, prev_grey, COLOR_BGR2GRAY);
	
	// Step 1 - Get previous to current frame transformation (dx, dy, da) for all frames
//	vector <TransformParam> prev_to_cur_transform; // previous to current
	// Accumulated frame to frame transform
	double a = 0;
	double x = 0;
	double y = 0;
	// Step 2 - Accumulate the transformations to get the image trajectory
	vector <Trajectory> trajectory; // trajectory at all frames
	//
	// Step 3 - Smooth out the trajectory using an averaging window
//	vector <Trajectory> smoothed_trajectory; // trajectory at all frames
	Trajectory X;//posteriori state estimate
	Trajectory	X_;//priori estimate
	Trajectory P;// posteriori estimate error covariance
	Trajectory P_;// priori estimate error covariance
	Trajectory K;//gain
	Trajectory	z;//actual measurement
	double pstd = 4e-3;//can be changed
	double cstd = 0.25;//can be changed
	Trajectory Q(pstd,pstd,pstd);// process noise covariance
	Trajectory R(cstd,cstd,cstd);// measurement noise covariance 
	// Step 4 - Generate new set of previous to current transform, such that the trajectory ends up being the same as the smoothed trajectory
//	vector <TransformParam> new_prev_to_cur_transform;
	//
	// Step 5 - Apply the new transformation to the video
	//cap.set(CV_CAP_PROP_POS_FRAMES, 0);
	Mat T;
	T = Mat(2,3,CV_64F);

	int vert_border = HORIZONTAL_BORDER_CROP * prev.rows / prev.cols; // get the aspect ratio correct
	VideoWriter outputVideo; 
	//outputVideo.open("compare.avi" , CV_FOURCC('X','V','I','D'), 24,cvSize(cur.rows, cur.cols*2+10), true);  
	//
	int k=1;
	int max_frames = cap.get(CV_CAP_PROP_FRAME_COUNT);
	Mat last_T;
	Mat prev_grey_,cur_grey_;

	// PMM. We need to initialize last_T in case first frame has no good features to track
	last_T = Mat(2, 3, CV_64F);
	last_T.at<double>(0,0) = 1.0;
	last_T.at<double>(0,1) = 0.0;
	last_T.at<double>(0,2) = 0.0;
	last_T.at<double>(1,0) = 0.0;
	last_T.at<double>(1,1) = 1.0;
	last_T.at<double>(1,2) = 0.0;
	 
	while(true) {
		// PMM Comment out if you want frame count printed
		cerr << "Frame " << k <<endl;

		cap >> cur;
		if(cur.data == NULL) {
			break;
		}

		cvtColor(cur, cur_grey, COLOR_BGR2GRAY);

		// vector from prev to cur
		vector <Point2f> prev_corner, cur_corner;
		vector <Point2f> prev_corner2, cur_corner2;
		vector <uchar> status;
		vector <float> err;

		goodFeaturesToTrack(prev_grey, prev_corner, 200, 0.01, 30);

		int new_transformation_found = 1;

		// PMM. calcOpticalFlowPyrLK throws an exception if no good features are found
		try {
			calcOpticalFlowPyrLK(prev_grey, cur_grey, prev_corner, cur_corner, status, err);
		} catch (Exception& e) {
			cerr << "EXCEPTION calcOpticalFlowPyrLK (Frame " << k << ": " << e.msg << endl;
			new_transformation_found = 0;
		}

		if (new_transformation_found) {
			// weed out bad matches
			for(size_t i=0; i < status.size(); i++) {
				if(status[i]) {
					prev_corner2.push_back(prev_corner[i]);
					cur_corner2.push_back(cur_corner[i]);
				}
			}

			// translation + rotation only.
			// PMM. Original code was generating a new matrix with the same name. Let's use that.
			// We also need to catch the thrown exception
			// if the function fails to find a transformation.
			try {
				//Mat T = estimateRigidTransform(prev_corner2, cur_corner2, false); // false = rigid transform, no scaling/shearing
				T = estimateRigidTransform(prev_corner2, cur_corner2, false); // false = rigid transform, no scaling/shearing
			} catch (Exception& e) {
				cerr << "EXCEPTION estimateRigidTransform (Frame " << k << ": " << e.msg << endl;
				last_T.copyTo(T);
			}
		} else {
			last_T.copyTo(T);
		}

		// in rare cases no transform is found. We'll just use the last known good transform.
		if(T.data == NULL) {
			last_T.copyTo(T);
		}

		T.copyTo(last_T);

		// decompose T
		double dx = T.at<double>(0,2);
		double dy = T.at<double>(1,2);
		double da = atan2(T.at<double>(1,0), T.at<double>(0,0));
		//
		//prev_to_cur_transform.push_back(TransformParam(dx, dy, da));

		out_transform << k << " " << dx << " " << dy << " " << da << endl;
		//
		// Accumulated frame to frame transform
		x += dx;
		y += dy;
		a += da;
		//trajectory.push_back(Trajectory(x,y,a));
		//
		out_trajectory << k << " " << x << " " << y << " " << a << endl;
		//
		z = Trajectory(x,y,a);
		//
		if(k==1){
			// intial guesses
			X = Trajectory(0,0,0); //Initial estimate,  set 0
			P =Trajectory(1,1,1); //set error variance,set 1
		}
		else
		{
			//time update£¨prediction£©
			X_ = X; //X_(k) = X(k-1);
			P_ = P+Q; //P_(k) = P(k-1)+Q;
			// measurement update£¨correction£©
			K = P_/( P_+R ); //gain;K(k) = P_(k)/( P_(k)+R );
			X = X_+K*(z-X_); //z-X_ is residual,X(k) = X_(k)+K(k)*(z(k)-X_(k)); 
			P = (Trajectory(1,1,1)-K)*P_; //P(k) = (1-K(k))*P_(k);
		}
		//smoothed_trajectory.push_back(X);
		out_smoothed_trajectory << k << " " << X.x << " " << X.y << " " << X.a << endl;
		//-
		// target - current
		double diff_x = X.x - x;//
		double diff_y = X.y - y;
		double diff_a = X.a - a;

		dx = dx + diff_x;
		dy = dy + diff_y;
		da = da + diff_a;

		//new_prev_to_cur_transform.push_back(TransformParam(dx, dy, da));
		//
		out_new_transform << k << " " << dx << " " << dy << " " << da << endl;
		//
		T.at<double>(0,0) = cos(da);
		T.at<double>(0,1) = -sin(da);
		T.at<double>(1,0) = sin(da);
		T.at<double>(1,1) = cos(da);

		T.at<double>(0,2) = dx;
		T.at<double>(1,2) = dy;

		Mat cur2;
		
		warpAffine(prev, cur2, T, cur.size());

		cur2 = cur2(Range(vert_border, cur2.rows-vert_border), Range(HORIZONTAL_BORDER_CROP, cur2.cols-HORIZONTAL_BORDER_CROP));

		// Resize cur2 back to cur size, for better side by side comparison
		resize(cur2, cur2, cur.size());

		// Now draw the original and stablised side by side for coolness
		Mat canvas = Mat::zeros(cur.rows, cur.cols*2+10, cur.type());

		prev.copyTo(canvas(Range::all(), Range(0, cur2.cols)));
		cur2.copyTo(canvas(Range::all(), Range(cur2.cols+10, cur2.cols*2+10)));

		// If too big to fit on the screen, then scale it down by 2, hopefully it'll fit :)
		if(canvas.cols > 1920) {
			resize(canvas, canvas, Size(canvas.cols/2, canvas.rows/2));
		}
		//outputVideo<<canvas;
		imshow("before and after", canvas);

		waitKey(10);
		//
		prev = cur.clone();//cur.copyTo(prev);
		cur_grey.copyTo(prev_grey);

		cerr << "Frame: " << k << "/" << max_frames << " - good optical flow: " << prev_corner2.size() << endl;
		k++;

	}
	return 0;
}

