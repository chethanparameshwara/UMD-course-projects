clear;
clc;
clear all;
%% Image Initialization 
I11 =  rgb2gray(imread('IMG_0628.jpg'));
I22 =  rgb2gray(imread('IMG_0629.jpg'));
I33 =  rgb2gray(imread('IMG_0630.jpg'));
% imshow(I1)
 I1 =  single(I11);
 I2 =  single(I22);
 I3 =  single(I33);
%% Problem 3
[f1, d1] = vl_sift(I1) ;
[f2, d2] = vl_sift(I2) ;
[f2, d3] = vl_sift(I3) ;

%% Problem 4
matches = match(f2,d2,f1,d1); % Set of feature matching points 
[mm mn] = size(matches);
[f_m, s_m, t_m]= find_best_match (matches); % Gives the top 3 best matching points


%% Problem 5 - Affine Transformation
x2 = [f_m(1, 1:2)' s_m(1, 1:2)' t_m(1, 1:2)']  
x1 = [f_m(1, 3:4)' s_m(1, 3:4)' t_m(1, 3:4)'] 
[A a] = affine_transformation(x2,x1);


%% Problem 6 - Ransac
f = top100matches(matches); % Select top 100 matches for the estimating A
AC_final = ransac( 1000, f, matches);

%% Problem 7, 8 and 9
I_OUT = stitch(I11, I22, AC_final);
I = stitch(I_OUT, I33, AC_final);
imshow(I)
