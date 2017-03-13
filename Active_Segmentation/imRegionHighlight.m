function im = imRegionHighlight(im, mask, colour)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Highlight an area in the image by the specified colour.
% 
% Input:
%   im,         input image (colour or grayscale)
%   mask,       the mask of the region that needs to be highlighted
%   colour,     a triplet representing the RGB values of highlight colour.
%               Each channel value is in [0,1].
%               Accepted character values are 'r', 'g', 'b' corresponding
%               to the primary colours.
%
% Output:
%   im,         highlighted image
%
% If input mask is logical - the masked areas are filled with solid colour,
% If input mask is real [0,1] - the colour of the masked areas is a linear
% combination of the original colour and input colour.
%
% ----------------
% Aleksandrs Ecins
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Check that input image is double
if ~isa(im, 'double')
    error('Input image must be of type double.');
end

%% Check that input colour is correct
if ischar(colour)
    switch colour
        case 'r'
            colour = [1 0 0];
            
        case 'g'
            colour = [0 1 0];
            
        case 'b'
            colour = [0 0 1];
        case 'w'
            colour = [1 1 1];
            
        otherwise
            error('Colour is an unknown character')
    end
else
    if ~numel(colour) == 3
        error('Colour parameter must have 3 values representing desired RGB values');
    end
end

%% If image is grayscale convert it to colour image
if size(im, 3) == 1
    im = cat(3, im, im, im);
end

%% If mask is logical
if isa(mask, 'logical')
    for c=1:3
        imC = im(:,:,c);
        imC(mask) = colour(c);
        im(:,:,c) = imC;
    end
    
%% If mask is double in [0,1] range
elseif isa(mask, 'double') && max(mask(:) <= 1) && max(mask(:) >= 0)
    for c=1:3
        im(:,:,c) = im(:,:,c) .* (1-mask) + mask * colour(c);
    end
else
    
%% If mask is double in [0,1] range    
    error('Mask must be either of type logical or double in range [0, 1].');
end



%% Create mask for all 3 channels
