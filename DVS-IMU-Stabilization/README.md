# DVS-IMU-Stabilization
C++ code to stabilize Dynamic Vision Sensor data using IMU

IMU Tool -  rosrun imu_filter_madgwick imu_filter_node _use_mag:=false

DVS Renderer - roslaunch dvs_renderer davis_mono.launch

Stabilization - rosrun stabilizer stabilizer_test
