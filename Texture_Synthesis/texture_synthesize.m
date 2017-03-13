%% Window Size 7
input_image = im2double(imread('Capture2.PNG'));

output_image = GrowImage(input_image, 128,128, 7);

imwrite(output_image, 'result.png');
%% Window Size 9
input_image = im2double(imread('Capture2.PNG'));

output_image = GrowImage(input_image, 128,128, 9);

imwrite(output_image, 'result.png');
%% Window Size 11
input_image = im2double(imread('Capture2.PNG'));

output_image = GrowImage(input_image, 128,128, 11);

imwrite(output_image, 'result.png');
%% Window Size 13
input_image = im2double(imread('Capture2.PNG'));

output_image = GrowImage(input_image, 128,128, 13);

imwrite(output_image, 'result.png');

%% Window Size 15
input_image = im2double(imread('Capture2.PNG'));

output_image = GrowImage(input_image, 128,128, 15);

imwrite(output_image, 'result.png');

%% Window Size 17
input_image = im2double(imread('Capture2.PNG'));

output_image = GrowImage(input_image, 128,128, 17);

imwrite(output_image, 'result.png');