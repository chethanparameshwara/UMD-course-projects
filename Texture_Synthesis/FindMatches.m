function [BestMatches, Error] = FindMatches(Template, mask, SampleImage, stacked_SampleImage_channels)         

        error_threshold = 0.1;
        max_error_threshold = 0.3;

        % Reshape the Template and mask into a column vector.
        Template_vec = reshape(Template, [], 1);
        mask_vec = reshape(mask, [], 1);
        % Create a matrix where every column is the neighbourhood
        Template_rep = repmat(Template_vec, 1, size(SampleImage, 2));
        mask_vec = repmat(mask_vec, size(SampleImage, 3), 1);
        
        %Normalized Mask
        weight = sum(mask_vec );
        mask = (( mask_vec) / weight)';
        
        % Compute the distances between the current neighbourhood and all
        % of the sample image
        SSD = mask * ((stacked_SampleImage_channels - Template_rep) .^ 2);
        
        min_value = min(SSD);
        min_threshold = min_value * (1 + error_threshold);       
        min_positions = find(SSD <= min_threshold);
        
        % Select a patch at random from all the patches with minimum 
        % distances.
        random_col = randi(length(min_positions));
        BestMatches = min_positions(random_col);
        Error = SSD(BestMatches);

end
