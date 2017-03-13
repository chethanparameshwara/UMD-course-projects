mex -largeArrayDims maxflowmex.cpp maxflow-v3.0/graph.cpp maxflow-v3.0/maxflow.cpp % Mex
close all

%% Prepare image

% Read image
imName = '11';
im = imread(['Images/', imName, '.png']);
im = im2double(im);
[M, N] = size(im);

% Choose fixation point
fig_select_fixation = figure;
imshow(im);
title('Select a fixation point inside the object');
[fix_x, fix_y] = ginput(1);
fix_x = round(fix_x);
fix_y = round(fix_y);
close(fig_select_fixation);

%% Segment
                                              
load(['Images/', imName '_grad.mat']);                                      % Use precomputed Berkeley edges
[labels, A, T, E] = fixation_segmentation(im, edgeGrad, fix_x, fix_y);                       % Segment

%% Show segmentation results
segBoundary = bwmorph(labels==1, 'remove');                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
segBoundary = bwmorph(segBoundary, 'dilate');
segOrig     = imRegionHighlight(im, segBoundary == 1, 'g');

figure;
imshow(segOrig);
title('Segmented image');