cmake_minimum_required(VERSION 2.8.3)
project(stabilizer)
add_definitions("-std=c++0x -Dlinux -O3")
## Find catkin macros and libraries
## if COMPONENTS list like find_package(catkin REQUIRED COMPONENTS xyz)
## is used, also find other catkin packages
find_package(catkin REQUIRED COMPONENTS
  roscpp
  std_msgs
  cv_bridge
  image_transport
#  tf_conversions
#  hand_tracker_2d
#  jsoncpp
)



find_package(OpenCV REQUIRED)
find_package(PCL 1.8.0 EXACT REQUIRED)
include_directories(.)
#include_directories(${Jsoncpp_INCLUDE_DIR})

add_message_files(
  FILES
  IMUtstamp.msg
)

add_definitions("-std=c++0x -Dlinux -O3")

SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fopenmp")
SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fopenmp")
SET(CMAKE_BUILD_TYPE Release)

#set(SISYPHUS_LIBS sisyphus_graph_utilities sisyphus_transform_utilities sisyphus_sift_engine sisyphus_box_detection sisyphus_pointcloud_utilities #sisyphus_misc_utilities sisyphus_siftrgbdslam)

catkin_package(
 INCLUDE_DIRS include 
 LIBRARIES stabilizer
 CATKIN_DEPENDS roscpp std_msgs cv_bridge image_transport #jsoncpp
 DEPENDS PCL
)


include_directories(
  include
  ${catkin_INCLUDE_DIRS}
)

include_directories(${PCL_INCLUDE_DIRS})
link_directories(${PCL_LIBRARY_DIRS})
add_definitions(${PCL_DEFINITIONS})


add_library(stabilizer src/main.cpp
)

target_link_libraries(stabilizer ${catkin_LIBRARIES} ${OpenCV_LIBRARIES} ${PCL_LIBRARIES}
  )

add_executable(stabilizer_test src/main.cpp
)

target_link_libraries(stabilizer_test ${catkin_LIBRARIES} ${OpenCV_LIBRARIES} ${PCL_LIBRARIES}
 )

