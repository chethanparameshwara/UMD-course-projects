function output_image = GrowImage(input_image, output_rows, output_cols, window_size)

half_window = floor(window_size / 2);
seed_size = 5;
[num_rows, num_cols, num_channels] = size(input_image);

%% Generation of Seed Image
% seed from the input image.
[output_image, filled_map] = seed_image(input_image, seed_size, output_rows, output_cols);

%% Padding Output Image

padded_output_image = padarray(output_image, [half_window half_window]);
padded_filled_map = padarray(filled_map, [half_window half_window]);

error_threshold = 0.1;
max_error_threshold = 0.3;

num_horiz_sample = num_rows - window_size + 1;
num_vert_sample = num_cols - window_size + 1;

SampleImage = zeros(window_size^2, num_horiz_sample * num_vert_sample, num_channels);

% For all the 3 channels
for channel = 1:num_channels
    SampleImage(:,:,channel) = im2col(input_image(:,:,channel), [window_size window_size], 'sliding');
end
permuted_SampleImage = permute(SampleImage,[1 3 2]);
stacked_SampleImage_channels = reshape(permuted_SampleImage,[],size(SampleImage,2),1);

%% Texture Synthesis
while ~all(all(filled_map))
    
    % Keeps track of whether we have found a matching pixel in this
    % iteration, or not.
    found_match = logical(0);
    
    % Get a list (column vector) of all unfilled pixels
    unfilled_pixels = getUnfilledPixels(filled_map);
    
    for pixel = unfilled_pixels
        [pix_row, pix_col] = ind2sub(size(filled_map), pixel);
        
        
%% Get Neighbourhood 
        % Find the neighbourhood around the current pixel to be filled,
        [Template, mask] = getNeighbourhood(padded_output_image, padded_filled_map, pix_row, pix_col, window_size);
       
%% Find Best Matches

        [BestMatches, Error] = FindMatches(Template, mask, SampleImage, stacked_SampleImage_channels); 
%% Check for error threshold

        if Error < max_error_threshold
           [matched_row, matched_col] = ind2sub([(num_rows-window_size+1) (num_cols-window_size+1)], BestMatches);
           matched_row = matched_row + half_window;
           matched_col = matched_col + half_window;
           
           % Copy the pixel in the middle of the matched sampleImage into the
           % pixel location
           output_image(pix_row, pix_col, :) = input_image(matched_row, matched_col, :);
           filled_map(pix_row, pix_col) = 1;
           found_match = logical(1);
        end
    end
    
    imshow(output_image);
    
    % Countinous update
    padded_output_image(half_window+1:half_window+output_rows, half_window+1:half_window+output_cols,:) = output_image;
    padded_filled_map(half_window+1:half_window+output_rows, half_window+1:half_window+output_cols) = filled_map;
    
    % If no match for any unfilled pixel, we need error threshold higher
    if ~found_match
        max_error_threshold = max_error_threshold * 1.1;
    end
end
