function mosaic = stitch(im1, im2, A)

Ai = inv(A);

%% Calculation the coordinates of image2 corners in image 1 plane

cornerbox2 = [1  size(im2,2) size(im2,2)  1 ;
        1  1           size(im2,1)  size(im2,1) ;
        1  1           1            1 ] ;
cornerbox2_ = A * cornerbox2 ;
cornerbox2_(1,:) = cornerbox2_(1,:) ./ cornerbox2_(3,:) ;
cornerbox2_(2,:) = cornerbox2_(2,:) ./ cornerbox2_(3,:) ;
ur = min([1 cornerbox2_(1,:)]):max([size(im1,2) cornerbox2_(1,:)]) ;
vr = min([1 cornerbox2_(2,:)]):max([size(im1,1) cornerbox2_(2,:)]) ;
[u,v] = meshgrid(ur,vr);

%% Merging Image 1 and Image 2

im1_ = vl_imwbackward(im2double(im1),u,v);
z_ = Ai(3,1) * u + Ai(3,2) * v + Ai(3,3) ;
u_ = (Ai(1,1) * u + Ai(1,2) * v + Ai(1,3)) ./ z_ ;
v_ = (Ai(2,1) * u + Ai(2,2) * v + Ai(2,3)) ./ z_ ;
im2_ = vl_imwbackward(im2double(im2),u_,v_); % Image2 coordinates in Image 1 plane 

%% Averaging the image pixel values

mass = ~isnan(im1_) + ~isnan(im2_) ;
im1_(isnan(im1_)) = 0 ;
im2_(isnan(im2_)) = 0 ;
mosaic = (im1_ + im2_) ./ mass ;

end