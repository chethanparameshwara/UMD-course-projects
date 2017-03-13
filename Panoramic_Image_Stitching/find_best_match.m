function [best_match, second_best, third_best] = find_best_match (matches)
A = sortrows(matches,5);
best_match = A(1,:);
second_best = A(2,:);
third_best = A(3,:);
end