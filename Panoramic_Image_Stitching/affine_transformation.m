function [A, a] = affine_transformation( x, xp)

X = [x(1,1) x(2,1) 1  0  0  0;
      0  0 0 x(1,1) x(2,1)  1;
      x(1,2) x(2,2) 1 0  0  0;
      0  0 0 x(1,2) x(2,2)  1;
      x(1,3) x(2,3) 1 0  0  0;
      0  0 0 x(1,3) x(2,3)  1;];
  
x_prime = [xp(1,1);xp(2,1);xp(1,2);xp(2,2);xp(1,3);xp(2,3)];
a = x_prime' / X';

A = [a(1,1) a(1,2) a(1,3);
     a(1,4) a(1,5) a(1,6);
       0   0   1];

end