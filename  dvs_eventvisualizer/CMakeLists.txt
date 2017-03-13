cmake_minimum_required(VERSION 2.8.3)
project(dvs_eventvisualizer)

## Find catkin macros and libraries
## if COMPONENTS list like find_package(catkin REQUIRED COMPONENTS xyz)
## is used, also find other catkin packages

set(CMAKE_CXX_FLAGS "-std=c++11 ${CMAKE_CXX_FLAGS}")

find_package(catkin REQUIRED COMPONENTS
	roscpp
	dvs_msgs
	std_msgs
	sensor_msgs
	image_transport
	cv_bridge
	pcl_ros
	)
find_package(Boost REQUIRED)
find_package(OpenCV REQUIRED)

find_package(PCL 1.7 REQUIRED)
include_directories(${PCL_INCLUDE_DIRS})
link_directories(${PCL_LIBRARY_DIRS})
add_definitions(${PCL_DEFINITIONS})

catkin_package(

	CATKIN_DEPENDS
		roscpp
		image_transport
		cv_bridge
		dvs_msgs
		sensor_msgs
		pcl_ros
	DEPENDS
		OpenCV
		boost
	)

include_directories(
	include
	${catkin_INCLUDE_DIRS}
	${OpenCV_INCLUDE_DIRS}
	${Boost_INCLUDE_DIRS}
	)

# add_executable(talker src/talker.cpp)
# target_link_libraries(talker ${catkin_LIBRARIES})
# add_dependencies(talker ${catkin_EXPORTED_TARGETS})


# add_executable(listener src/listener.cpp)
# target_link_libraries(listener ${catkin_LIBRARIES})
# add_dependencies(listener  ${catkin_EXPORTED_TARGETS})


add_executable(event_visualizer src/event_visualizer.cpp )
target_link_libraries(event_visualizer ${catkin_LIBRARIES} ${PCL_COMMON_LIBRARIES} ${PCL_IO_LIBRARIES})
add_dependencies(event_visualizer ${catkin_EXPORTED_TARGETS} )
