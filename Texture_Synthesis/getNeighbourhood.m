function [neighbourhood, mask] = getNeighbourhood(padded_output_image, padded_filled_map, pix_row, pix_col, window_size)

half_window = floor(window_size / 2);

pix_row = pix_row + half_window;
pix_col = pix_col + half_window;

neighbourhood = padded_output_image(pix_row-half_window:pix_row+half_window, pix_col-half_window:pix_col+half_window, :);
mask = padded_filled_map(pix_row-half_window:pix_row+half_window, pix_col-half_window:pix_col+half_window, :);