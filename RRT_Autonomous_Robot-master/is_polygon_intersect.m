function flag = is_polygon_intersect(obst,p, p_pr)

 P = DrawRectangle([p.p(1),p.p(2), p.config]);
 P_pr = DrawRectangle([p_pr.p(1),p_pr.p(2), p_pr.config]);

for i = 1:4:45
    if(isintersect( [p.p p_pr.p] , obst(: , i:3+i)) == 1)
      flag = 1;
    break;
    else
        flag = 0;
    end
end
 if( flag == 1);
 return;
 end
for i = 1:4:45
    if (isintersect( P , obst(: , i:3+i)) ==1)
%     if( inpolygon(P(1,1), P(2,1), obst(1 , i:3+i), obst(2,i:3+i))|| inpolygon(P(1,2), P(2,2), obst(1 , i:3+i), obst(2,i:3+i))|| inpolygon(P(1,3), P(2,3), obst(1 , i:3+i), obst(2,i:3+i))||inpolygon(P(1,4), P(2,4), obst(1 , i:3+i), obst(2,i:3+i))==1 )
        flag = 1;
        break;
    else
        flag = 0;
    end
end
if( flag == 1);
 return;
end
for i = 1:4:45
     if (isintersect( P_pr , obst(: , i:3+i)) ==1)
%     if( inpolygon(P_pr(1,1), P_pr(2,1), obst(1 , i:3+i), obst(2,i:3+i))|| inpolygon(P_pr(1,2), P_pr(2,2), obst(1 , i:3+i), obst(2,i:3+i))|| inpolygon(P_pr(1,3), P_pr(2,3), obst(1 , i:3+i), obst(2,i:3+i))||inpolygon(P_pr(1,4), P_pr(2,4), obst(1 , i:3+i), obst(2,i:3+i))==1 )
        flag = 1;
        break;
    else
        flag = 0;
    end
end
if( flag == 1);
 return;
end
for i = 1:4:45
    if (pathintersect(obst(: , i:3+i), p,p_pr) ==1)
        flag = 1;
        break;  
    else
        flag = 0;
    end
end
if( flag == 1);
 return;
end
        
%     elseif ((isintersect([P_pr(:,4), P(:,4), P(:,2), P_pr(:,2)], obst(: , i:3+i)) ==1) || (isintersect( [P_pr(:,2), P(:,2), P(:,4), P_pr(:,4)], obst(: , i:3+i)) ==1 )||( isintersect( [P(:,2), P_pr(:,2), P_pr(:,4), P(:,4)], obst(: , i:3+i)) ==1) ||( isintersect( [P(:,4), P_pr(:,4), P_pr(:,2), P(:,2)], obst(: , i:3+i)) ==1))
%         flag = 1;
%         break;    
%     elseif ((isintersect([P_pr(:,3), P(:,3), P(:,1), P_pr(:,1)], obst(: , i:3+i)) ==1) || (isintersect( [P_pr(:,1), P(:,1), P(:,3), P_pr(:,3)], obst(: , i:3+i)) ==1 )||( isintersect( [P(:,1), P_pr(:,1), P_pr(:,3), P(:,3)], obst(: , i:3+i)) ==1) ||( isintersect( [P(:,3), P_pr(:,3), P_pr(:,1), P(:,1)], obst(: , i:3+i)) ==1))
%         flag = 1;
%         break;        
%     elseif (inpolygon(p.p(1,1), p.p(2,1), obst(1 , i:3+i), obst(2,i:3+i))==1)
%         flag = 1;
%         break;
%     else 
% %         Pr = DrawRectangle(p(1,1), p(2,1), p.
% %         if ( 
%         flag = 0;
%     end
end

function intersect = pathintersect (obst, p, p_pr)
        itera = ceil((norm(p.p-p_pr.p))/10);
      for i=1:itera;
          stepsize = (i/itera);
      Ps = DrawRectangle([ (p_pr.p(1)+(p.p(1) - p_pr.p(1))*stepsize), (p_pr.p(2)+(p.p(2) - p_pr.p(2))*stepsize), (p_pr.config+ (p.config - p_pr.config)*stepsize)]);
     
       if(isintersect( Ps , obst) == 1)
%         if( inpolygon(Ps(1,1), Ps(2,1), obst(1 , 1:4), obst(2,1:4))|| inpolygon(Ps(1,2), Ps(2,2), obst(1 , 1:4), obst(2,1:4))|| inpolygon(Ps(1,3), Ps(2,3), obst(1 , 1:4), obst(2,1:4))||inpolygon(Ps(1,4), Ps(2,4), obst(1 , 1:4), obst(2,1:4))==1 )
            intersect = 1;
            break;
        else
            intersect = 0;
        end
    end
    end
