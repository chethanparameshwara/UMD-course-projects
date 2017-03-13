l1 = 3 % length of link 1
l2 = 3 % length of link 2
l3 = 2 % length of link 3
 X = 4  % length of X Coordinate
 Y = 6  % length of Y Coordinate
 % Nonlinear constraints
[c, ceq] = confun(theta) 
c = [theta(1)-(3*pi/4);
        theta(1) - theta(2) - (3*pi/4);
        theta(2) - theta(3)-(pi/4)];
ceq = [];
%Initial Position
x0 = [-1,2,0.5];
%Object Function
f = objfun(theta)
f = ((X-(cos(theta(1))*l1)- (cos(theta(2))*l2)-(cos(theta(3))*l3))+(Y-(sin(theta(1))*l1)- (sin(theta(2))*l2)-(sin(theta(3))*l3)));
options = optimoptions(@fmincon,'Algorithm','sqp');
%Optimization 
[theta, fval] = fmincon(@objfun,x0,[],[],[],[],[],[],@confun,options);
theta1 = theta(1)
theta2 = theta(2)
theta3 = theta(3)