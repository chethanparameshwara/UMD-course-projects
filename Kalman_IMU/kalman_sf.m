function [x1]  = kalman_sf(x_acc, gyro)
P = [1 0; 0 1];
R_angle = 0.3;
Q_angle = 0.05;
Q_gyro = 0.5;
Q = [Q_angle 0; 0 Q_gyro];
A = [0 -1; 0 0];
q_bias = mean(gyro(1:20, 1)); % Initialize gyro bias/offset
angle = sum(gyro(1:20, 1)); % Initialize gyro angle
q_m = 0;

x1 = zeros(size(gyro));
x2 = zeros(size(gyro));
X = [x1; x2];
size(gyro)
for i=2:length(x1),
%   dt = t(i) - t(i-1);
  dt = 1/1000;
    
 % **************** Gyro update *******************
 %q_m = q_m + gyro(i)*dt; % Compute pitch angle from gyro
 q_m = gyro(i);

 q = q_m - q_bias; % /* Pitch gyro measurement */

 Pdot = A*P + P*A' + Q;
 Pdot2 = dt.*Pdot;
 rate = q;
 angle = angle + q.*dt;
 P = P + (Pdot2);
 % ************ Kalman (Accelerometer) update *****

 % C = [ d(angle_m)/d(angle) d(angle_m)/d(gyro_bias) ]
 C = [1 0];
 angle_err = x_acc(i)-angle;

 E = C*P*C' + R_angle;
 
 K = P*C'*inv(E);
 P = P - K*C*P;
 X = X + K * angle_err;
 x1(i) = X(1);
 x2(i) = X(2);
 angle = x1(i);
 q_bias = x2(i);
end
% Plot the result using kalman filter
% xlswrite('done2.xls', [gyro x1])
plot([x1]);
xlabel('time(s)');
ylabel('x(t)');
legend('kalman');