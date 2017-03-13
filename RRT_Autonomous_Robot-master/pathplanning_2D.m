function P = pathplanning_2D ( obst, p_start, p_goal)
P = [];
rrt = {};
rrt = AddNode(rrt,p_start,0);
iter = 1;
imin = 1;
while iter <= 10000
    
    
    p.p = 0;
    y = rand;
    if y < .55
    p.p = rand(2,1)*200;
    p.config = rand(1,1)*(3.1416/(2));
    elseif (0.55 < y < 0.85)
    p.p(1) = (190-70).*rand(1,1) + 70;
    p.p(2) = rand(1,1)*200;
    p.config = rand(1,1)*(3.1416/(2)); 
    else
%     p.p(1) = (190-70).*rand(1,1) + 70;
%     p.p(2) = (190-10).*rand(1,1) + 10;
     p.p = [160; 50];
    p.config = 3.1416/2;
    end
    
%     p = rrt{length(rrt)}.p + (p*5);
  
    for i=1:length(rrt)
        dist = norm(rrt{i}.p.p - p.p);
        if (i==1) || (dist < mindist)
            mindist = dist;
            imin = i;
            l = rrt{i}.p.p;
        end
    end
    [flag] = is_polygon_intersect(obst,p, rrt{imin}.p );
%     p(2,1) = rrt(length(rrt)).p(2,1) + (p(2,1)*20);
  if flag == 1 % skip to next iteration
        iter = iter + 1;
        continue
  end   
    
  
    rrt = AddNode(rrt,p,imin); % add p to T with parent l
    dist = norm(p.p-p_goal.p);
    %display(iter,dist,length(rrt))
    fprintf('Nodes:   %d, Distance: %.1f, Iterations: %d/10000\n',length(rrt),dist,iter)

    %     circle(p(1,1),p(2,1),rob.ballradius,'b');
%     circle(p(1,1),p(2,1),0.1,'b');

figure(1);plot([p.p(1,1);rrt{imin}.p.p(1,1)],[p.p(2,1);rrt{imin}.p.p(2,1)],'m','LineWidth',1);
 plot([p.p(1,1);rrt{imin}.p.p(1,1)],[p.p(2,1);rrt{imin}.p.p(2,1)]);
 drawnow
    if (dist < 100)
        flag = is_polygon_intersect(obst, p, p_goal); %check for valid edge
        if flag == 1 % skip to next iteration if not valid edge
            iter = iter + 1;
            continue 
        end
     
        iterations = iter;
        
        rrt = AddNode(rrt,p_goal,length(rrt));
        i = length(rrt);
        
        P.p(:,1) = rrt{i}.p.p;
        P.config = rrt{i}.p.config
        while 1
            i = rrt{i}.iPrev;
            if i == 0
                return
            end
            P.p = [rrt{i}.p.p P.p];
            P.config = [rrt{i}.p.config P.config];
        end
    end

    iter = iter + 1;
end
return