function matches = match (f2, d2, f1, d1)

% size of descriptor matrix
[m2, n2] = size(d2);
[m1, n1] = size(d1);

%size of matches
matches = zeros([n2, 5]);
for n_2 = 1:n2
    first_closest_match = Inf;
    second_closest_match = Inf;
    best_match = 0;
    for n_1 = 1:n1 
         sum_squared_distance = sum((d2(: , n_2) - d1(: , n_1)).^2);% SSD
        if (sum_squared_distance < first_closest_match)
            second_closest_match = first_closest_match;
            first_closest_match = sum_squared_distance;
            best_match = f1(1:2, n_1);
        end
    end
    if (first_closest_match < second_closest_match & best_match ~= 0)% Choose Best Match
        matches(n_2 , 1:2)=transpose(f2(1:2, n_2));
        matches(n_2 , 3:4) = transpose(best_match);
        matches(n_2,5) = first_closest_match;
    end
end
end