function unfilled_pixels = getUnfilledPixels(filled_map)
SE = strel('square', 3);
dilated_map = imdilate(filled_map, SE);
diff_image = dilated_map - filled_map;
unfilled_pixels = find(diff_image)'; 