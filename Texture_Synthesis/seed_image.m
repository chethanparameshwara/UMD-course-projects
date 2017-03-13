function [output_image, filled_map] = seed_image(input_image, seed_size, output_rows, output_cols)

[input_rows input_cols channels] = size(input_image);


margin = seed_size - 1;

rand_row = randi([1, input_rows - margin]);
rand_col = randi([1, input_cols - margin]);
seed_patch = input_image(rand_row:rand_row+margin, rand_col:rand_col+margin, :);

% Puts the seed patch in the centre of the output image.
output_image = zeros(output_rows, output_cols, channels);
center_row = floor(output_rows / 2);
center_col = floor(output_cols / 2);
half_seed_size = floor(seed_size / 2);
output_image(center_row-half_seed_size:center_row+half_seed_size, center_col - half_seed_size:center_col+half_seed_size, :) = seed_patch;

% Makes the seed patch positions equal to 1 in the filled map.
filled_map = false(output_rows, output_cols);
filled_map(center_row-half_seed_size:center_row+half_seed_size, center_col - half_seed_size:center_col+half_seed_size, :) = 1;