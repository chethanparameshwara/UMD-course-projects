function X = poly2poly(P1, P2)
% function X = poly2poly(P1, P2)
% Intersection of two 2D polygons P1 and P2.
%
% INPUTS:
%   P1 and P2 are two-row arrays, each column is a vertice
%   They might or might not be wrapped around
% OUTPUT:
%   X is two-row array, each column is an intersecting point
%
% Author: Bruno Luong <brunoluong@yahoo.com>
% History:
%     Original 20-May-2010

% Wrap around: Pad the first point to the end if necessary
if ~isequal(P1(:,1),P1(:,end))
    P1 = [P1 P1(:,1)];
end
if ~isequal(P2(:,1),P2(:,end))
    P2 = [P2 P2(:,1)];
end

% swap P1 P2 so that we loop on a smaller one
if size(P1,2) > size(P2,2)
    [P1 P2] = deal(P2, P1);
end

% We increment the intermediate results by this amount
increment = 10;
% Empty buffer
X = zeros(2,0);
filled = 0;
sizec = 0;
% Loop over segments of P1
for n=2:size(P1,2)
    cn = seg2poly(P1(:,n-1:n), P2);
    m = size(cn,2);
    filled = filled+m;
    % Buffer too small
    if sizec < filled
        sizec = filled+increment;
        X(2,sizec) = 0;
    end
    % Store the result
    X(:,filled+(-m+1:0)) = cn;
end
% remove the tail
X(:,filled+1:end) = [];

end % poly2poly

%%
function X = seg2poly(s1, P)
% function X = seg2poly(s1, P)
% Check if a line segment s1 intersects with a polygon P.
% INPUTS:
%   s is (2 x 2) where
%     s(:,1) is the first point
%     s(:,2) is the the second point of the segment.
%   P is (2 x n) array, each column is a vertices
% OUTPUT
%   X is (2 x m) array, each column is an intersecting point
%
%   Author: Bruno Luong <brunoluong@yahoo.com>
%   History:
%       Original 20-May-2010

% Translate so that first point is origin
a = s1(:,1);
M = bsxfun(@minus, P, a);
b = s1(:,2)-a;
% Check if the points are on the left/right side
x = [b(2) -b(1)]*M;
sx = sign(x);
% x -coordinates has opposite signs
ind = sx(1:end-1).*sx(2:end) <= 0;
if any(ind)
    ind = find(ind);
    % cross point to the y-axis (along the segment)
    x1 = x(ind);
    x2 = x(ind+1);
    d = b.'/(b(1)^2+b(2)^2);
    y1 = d*M(:,ind);
    y2 = d*M(:,ind+1);
    dx = x2-x1;
    % We won't bother with the degenerate case of dx=0 and x1=0
    y = (y1.*x2-y2.*x1)./dx;
    % Check if the cross point is inside the segment
    ind = y>=0 & y<1;
    if any(ind)
        X = bsxfun(@plus, a, b*y(ind));
    else
        X = zeros(2,0);
    end
else
    X = zeros(2,0);
end

end % seg2poly