#ifndef STABILIZER_H
#define STABILIZER_H

#include <algorithm>
#include <deque>
#include <ros/ros.h>
#include <ros/time.h>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <sensor_msgs/Image.h>


using namespace std;
using namespace cv;

class Stabilizer
{
public:

  ros::NodeHandle nh_;
  ros::Subscriber image_sub_;
  ros::Subscriber imu_sub_;
  // image_transport::Publisher display_pub_;



  Mat frame_;
  Mat gray_;
  Mat display_;
  Mat snapshot_frame_;
  Point init_corner_;
  Rect init_wnd_;
  Rect track_wnd_;
  float confidence_;
  Mat curr_;
  Mat prev_;

  deque<sensor_msgs::Image> image_cache_;



  Stabilizer(string image_topic);
  virtual ~Stabilizer() {}

  // void hand_callback(const hand_tracker_2d::HandBBox msgs_hand);
  void image_callback(const sensor_msgs::Image& msgs_image);


  void updateImageCache(const sensor_msgs::Image& msgs_image);
  // sensor_msgs::Image& getImageByStamp(const ros::Time stamp);
  // void restartTrackingFromCache();

  // void spin();
};

#endif  // STABILIZER_H
