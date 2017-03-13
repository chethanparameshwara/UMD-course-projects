function A100 = top100matches(matches)

A = sortrows(matches,5);
A100 = A (1:100, :);

end