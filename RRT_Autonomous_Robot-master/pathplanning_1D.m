function P = pathplanning ( obst, p_start, p_goal)
P = [];
rrt = {};
rrt = AddNode(rrt,p_start,0);
iter = 1;
imin = 1;
while iter <= 10000
    
%     if mod(iter,50) == 0
%         blah=0;
%     end
    p = 0;
    p = rand(2,1)*200; % random p
%     p = rrt{length(rrt)}.p + (p*5);
  
    for i=1:length(rrt)
        dist = norm(rrt{i}.p - p);
        if (i==1) || (dist < mindist)
            mindist = dist;
            imin = i;
            l = rrt{i}.p;
        end
    end
    flag = is_polygon_intersect(obst,p, rrt{imin}.p );
%     p(2,1) = rrt(length(rrt)).p(2,1) + (p(2,1)*20);
  if flag == 1 % skip to next iteration
        iter = iter + 1;
        continue
  end   
    
  
    rrt = AddNode(rrt,p,imin); % add p to T with parent l
    dist = norm(p-p_goal);
    %display(iter,dist,length(rrt))
    fprintf('Nodes:   %d, Distance: %.1f, Iterations: %d/1000\n',length(rrt),dist,iter)

    %     circle(p(1,1),p(2,1),rob.ballradius,'b');
%     circle(p(1,1),p(2,1),0.1,'b');

figure(1);plot([p(1,1);rrt{imin}.p(1,1)],[p(2,1);rrt{imin}.p(2,1)],'m','LineWidth',1);
    plot([p(1,1);rrt{imin}.p(1,1)],[p(2,1);rrt{imin}.p(2,1)]);
    if (dist < 150)
        flag = is_polygon_intersect(obst,p,p_goal); %check for valid edge
        if flag == 1 % skip to next iteration if not valid edge
            iter = iter + 1;
            continue 
        end
     
        iterations = iter;
        % add qgoal to T with parent q and exit with success
        rrt = AddNode(rrt,p_goal,length(rrt));
        % construct Q here:
        i = length(rrt);
        
        P(:,1) = rrt{i}.p;
        while 1
            i = rrt{i}.iPrev;
            if i == 0
                return
            end
            P = [rrt{i}.p P];
        end
    end

    iter = iter + 1;
end
return