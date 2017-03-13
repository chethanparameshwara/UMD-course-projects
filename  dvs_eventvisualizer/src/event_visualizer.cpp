#include <iostream>
#include <cstdlib>

// ROS
#include <ros/ros.h>
#include <sensor_msgs/PointCloud2.h>

// PCL
#include <pcl/ros/conversions.h>
#include <pcl/point_cloud.h>
#include <pcl/point_types.h>
#include <pcl/filters/voxel_grid.h>
#include <pcl/visualization/pcl_visualizer.h>

#include <pcl_conversions/pcl_conversions.h>
#include <pcl/PCLPointCloud2.h>
#include <pcl/conversions.h>
#include <pcl_ros/transforms.h>

boost::shared_ptr<pcl::visualization::PCLVisualizer> visor;
pcl::PointCloud<pcl::PointXYZRGB>::Ptr ptCloud (new pcl::PointCloud<pcl::PointXYZRGB>);
sensor_msgs::PointCloud2 cloud;

boost::shared_ptr<pcl::visualization::PCLVisualizer> createVis ()
{
  // --------------------------------------------
  // -----Open 3D viewer and add properties-----
  // --------------------------------------------
  boost::shared_ptr<pcl::visualization::PCLVisualizer> viewer (new pcl::visualization::PCLVisualizer ("3D Viewer"));
  viewer->setBackgroundColor (0, 0, 0);
  viewer->addCoordinateSystem (1.0);
  viewer->initCameraParameters ();
  return viewer;
}

void updateVis(boost::shared_ptr<pcl::visualization::PCLVisualizer> viewer, pcl::PointCloud<pcl::PointXYZRGB>::ConstPtr cloud){
  pcl::visualization::PointCloudColorHandlerRGBField<pcl::PointXYZRGB> rgb(cloud);
  viewer->removePointCloud();
  viewer->addPointCloud<pcl::PointXYZRGB> (cloud, rgb);
  viewer->spinOnce();
}

//(sensor_msgs::PointCloud2 points)

void showPCL(const boost::shared_ptr<const sensor_msgs::PointCloud2>& input){
  
  pcl::PCLPointCloud2 pcl_pc2;
  pcl_conversions::toPCL(*input,pcl_pc2); 
  pcl::fromPCLPointCloud2(pcl_pc2, *ptCloud);
  updateVis(visor, ptCloud);
}

/** 
 */
int main(int argc, char **argv) {
  using namespace ros;

  visor = createVis();

  init(argc,argv,"kinQual");
  NodeHandle nh;
  Subscriber subDepth = nh.subscribe<>("event_loader/events",1000,showPCL);
  while(!visor->wasStopped()){
   sleep(1);
   spin();

  }

  return 0;
}