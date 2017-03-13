function [labels, A, T, E] = fixation_segmentation(im, edgeGrad, fix_x, fix_y, opt)


%% Energy fucntion parameters

% Binary weights
k = 20;                                                                     % Binary weight and expontent parameter
% Unary weights
D  = 10;                                                                    % Fixation point unary weight
foreground = 2;                                                             % Object
background = 1;                                                             % Background

%% Image parameters
[y, x] = size(edgeGrad);
no_Pix = x*y;

E = edges4connected(y,x);                                                   % Indices of adjacent pixels (Potts model)
I_pq = edgeGrad(E(:,1))+edgeGrad(E(:,2)) / 2;                               % Average edge probability at adjacent edges
V = zeros(size(E,1),1);                                                     % Weights
V(I_pq ~= 0) = exp( -k*( I_pq(I_pq ~= 0) ));                                % Edge where at least one of the pixels belongs to the edge map
V(I_pq == 0) = k;                                                           % Edges where none of the pixels belong to the edge map

% Calculate the distance of each edge from the fixation point
[y_p, x_p] = ind2sub([y, x], E(:,1));                                       % Calculate midpoint of each edge
[y_q, x_q] = ind2sub([y, x], E(:,2));
x_mid = (x_p + x_q) / 2 - fix_x(1);
y_mid = (y_p + y_q) / 2 - fix_y(1);
r = sqrt(x_mid.^2 + y_mid.^2);

% Weights are the inverse of the distance from the fixation point
W = 1./r;                                                                   % Weights are the inverse of the distance from the fixation point
W = W/max(W);                                                               % Normalize the weights to have maximum of 1
V = V.*W;

A = sparse(E(:,1),E(:,2),V,no_Pix,no_Pix,4*no_Pix);

%% Construct unary weights for image boundary and fixation point 
T_ = zeros(numel(edgeGrad),2);
T_(1:y,background) = D;                                                     % Left column
T_(end-y+1:end,background) = D;                                             % Right column
T_((0:x-1)*y+1,background) =D;                                              % Top row
T_((1:x)*y,background) =D;                                                  % Bottom row
T_(sub2ind([y, x], fix_y(1), fix_x(1)), foreground) = D;                    % Fixation point
T_(sub2ind([y, x], fix_y(2:end), fix_x(2:end)), foreground) = D;            % Fixation point
T = sparse(T_);

%% Perform min-cut


[~, labels] = maxflow(A,T);
labels = reshape(labels, [y, x]);


labels = reshape(labels, [y, x]);


 
 end
