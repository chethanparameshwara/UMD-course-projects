#include <ros/ros.h>
#include <image_transport/image_transport.h>
#include <opencv2/highgui/highgui.hpp>
#include <cv_bridge/cv_bridge.h>
#include <iostream>
#include <fstream>
#include <sstream>
#include <ros/ros.h>
#include <ros/time.h>
#include <sensor_msgs/Image.h>
#include <opencv2/core/core.hpp>
#include "stabilizer/stabilizer.h"

const int HORIZONTAL_BORDER_CROP = 20;



Stabilizer::Stabilizer(string image_topic) :
nh_()
// is_tracking_(false),
// is_drawing_wnd_(false),
// init_tracker_(false),
// HOG(true),
// FIXEDWINDOW(false),
// MULTISCALE(true),
// SILENT(true),
// LAB(false),
// object_tag_(""),
{
  image_cache_.clear();

  const char * imu_topic = "/imu/data";
  
  image_sub_ = nh_.subscribe(image_topic, 1, &Stabilizer::image_callback, this);
  // imu_sub_ = nh_.subscribe(imu_topic, 1, &Stabilizer::imu_callback, this);

  image_transport::ImageTransport it(nh_);
  // display_pub_ = it.advertise("tracking_display", 1);
  // bbox_pub_ = nh_.advertise<hand_tracker_2d::HandBBox>("/interact/tracking_bbox", 1);

  ROS_INFO("Ready to stabilize, waiting for imu data");
}


void Stabilizer::image_callback(const sensor_msgs::Image& msgs_image)
{
  ROS_INFO("call back");
  try {
    cv_bridge::CvImagePtr cv_ptr = cv_bridge::toCvCopy(msgs_image, sensor_msgs::image_encodings::BGR8);
    curr_ = cv_ptr->image;
  }
  catch (cv_bridge::Exception& e) {
    ROS_ERROR("cv_bridge exception: %s", e.what());
    return;
  }

  if (image_cache_.size() > 0){
    sensor_msgs::Image image_tmp = image_cache_.front();
    cv_bridge::CvImagePtr cv_ptr = cv_bridge::toCvCopy(image_tmp, sensor_msgs::image_encodings::BGR8);
    prev_ = cv_ptr->image;

    Mat T;
    T = Mat(2,3,CV_64F);

    T.at<double>(0,0) = cos(0.41);
    T.at<double>(0,1) = -sin(0.71);
    T.at<double>(1,0) = sin(0.41);
    T.at<double>(1,1) = cos(0.71);
    T.at<double>(0,2) = 0.2;
    T.at<double>(1,2) = 0.2;

    Mat cur2;
    int vert_border = HORIZONTAL_BORDER_CROP * prev_.rows / prev_.cols;
    
    warpAffine(curr_, cur2, T, curr_.size());

     cur2 = cur2(Range(vert_border, cur2.rows-vert_border), Range(HORIZONTAL_BORDER_CROP, cur2.cols-HORIZONTAL_BORDER_CROP));

    // Resize cur2 back to cur size, for better side by side comparison
    resize(cur2, cur2, curr_.size());

    // Now draw the original and stablised side by side for coolness
    Mat canvas = Mat::zeros(curr_.rows, curr_.cols*2+10, curr_.type());

    curr_.copyTo(canvas(Range::all(), Range(0, cur2.cols)));
    cur2.copyTo(canvas(Range::all(), Range(cur2.cols+10, cur2.cols*2+10)));

    // If too big to fit on the screen, then scale it down by 2, hopefully it'll fit :)
    if(canvas.cols > 1920) {
      resize(canvas, canvas, Size(canvas.cols/2, canvas.rows/2));
    }
    //outputVideo<<canvas;
    imshow("before and after", canvas);

    waitKey(10);


  }
  updateImageCache(msgs_image);
}

void Stabilizer::updateImageCache(const sensor_msgs::Image& msgs_image) {
  image_cache_.push_back(msgs_image);
  cout << "Image Cache size: " << image_cache_.size()
       << endl;
}


// void imageCallback(const sensor_msgs::ImageConstPtr& msg)
// {
//   try
//   {
//     cv::imshow("view", cv_bridge::toCvShare(msg, "bgr8")->image);
//     cv::waitKey(30);
//   }
//   catch (cv_bridge::Exception& e)
//   {
//     ROS_ERROR("Could not convert from '%s' to 'bgr8'.", msg->encoding.c_str());
//   }


// }


int main(int argc, char **argv)
{
   ros::init(argc, argv, "image_listener");
  // ros::NodeHandle nh;
  // cv::namedWindow("view");
  // cv::startWindowThread();
  const char * image_topic = "/dvs/image_raw";
  Stabilizer imustabilizer(image_topic);
  ros::spin();
}