function b = isintersect(P1, P2)
c = poly2poly(P1, P2);
if isempty(c)
    b = inpolygon(P2(1,1),P2(2,1),P1(1,:),P1(2,:)) || ...
        inpolygon(P1(1,1),P1(2,1),P2(1,:),P2(2,:));
else
    b = true;
end

end 

