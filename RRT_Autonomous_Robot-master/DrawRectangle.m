function  Pr = DrawRectangle(param)

% if (nargin <1),
%     error('Please see help for INPUT DATA.');
% elseif (nargin==1)
%     style='b-';
% end;
[m,n] = size(param);
% if(m ~= 1 || n ~= 5)
%     error('param should be an 1x5 array.');
% end
% if(param(3) <=0 || param(4) <=0)
%     error('width and height must be positive values.');
% end
a = param(1);
b = param(2);
w = 30;
h = 10;
theta = param(3);
X = [-w/2 w/2 w/2 -w/2 -w/2];
Y = [h/2 h/2 -h/2 -h/2 h/2];
P = [X;Y];
ct = cos(theta);
st = sin(theta);
R = [ct -st;st ct];
Pr = [R * P];
Pr(1,:) = Pr(1,:)+a;
Pr(2,:) = Pr(2,:)+b;
%  h=plot(Pr(1,:),Pr(2,:),'r');
axis equal;
end