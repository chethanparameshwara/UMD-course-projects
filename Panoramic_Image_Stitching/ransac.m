function  H = ransac( N, f, matches) 

i=1;
ac = zeros(N,7);

%% Randomly pick three matching points

for t = 1:N
subset1 = matches( randi([1,size(matches,1)],1), 1:4);
subset2 = matches( randi([1,size(matches,1)],1), 1:4);
subset3 = matches( randi([1,size(matches,1)],1), 1:4);
x2_1 = [subset1(1, 1:2)' subset2(1, 1:2)' subset3(1, 1:2)'] ; 
x1_1 = [subset1(1, 3:4)' subset2(1, 3:4)' subset3(1, 3:4)'] ;
[A,a] = affine_transformation(x2_1, x1_1);


% initialization
count= 0;
p= zeros(3,1);
q= zeros(3,1);
euclid_dis = 0;
%% Apply A to all points in image 2.
    for t2 =1:size(f,1)
    p = [f(t2,1:2)';1];% point on image 2

        for t1 =1:size(f,1)
        q = [f(t1,3:4)';1]; %point on image 1
        qa = A*p;
        euclid_dis = sqrt(sum(((qa/qa(3,1)) - q) .^ 2)); % ssd
        if (euclid_dis < 2)
        count = count+1; 
        end
        end
    end
ac(i,:) = [a count];
i= i+1;
end
%% Final A value
AC = sortrows(ac,7);
ab = AC(N , 1:6);
H = [ab(1,1) ab(1,2) ab(1,3);
     ab(1,4) ab(1,5) ab(1,6);
       0   0   1];
end