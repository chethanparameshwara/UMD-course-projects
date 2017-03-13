% function RRT_final = RRTpathplanner
%  
obst = zeros(2,48);
%obstacles 
obst = obstacles;

% start and goal 
p_start.p = [30; 160];
p_start.config = 3.14/2;
p_goal.p = [160; 30];
p_goal.config = 0;

P_Start = DrawRectangle([ p_start.p(1), p_start.p(2), p_start.config])
patch( P_Start(1,:),P_Start(2,:),'yellow')
P_Goal = DrawRectangle([ p_goal.p(1), p_goal.p(2), p_goal.config])
patch( P_Goal(1,:),P_Goal(2,:),'yellow')
% Path planning
P = pathplanning_2D ( obst, p_start, p_goal);
for q=2:length(P.p)
  figure(1);plot([P.p(1,q);P.p(1,q-1)],[P.p(2,q);P.p(2,q-1)],'linestyle','--','linewidth',1);
  itera = ceil((norm(P.p(:,q)-P.p(:,q-1)))/10);
  for i=1:itera;
      stepsize = (i/itera);
  Ps = DrawRectangle([ (P.p(1,q-1)+(P.p(1,q) - P.p(1,q-1))*stepsize), (P.p(2,q-1)+(P.p(2,q) - P.p(2,q-1))*stepsize), (P.config(q-1)+(P.config(q) - P.config(q-1))*stepsize)]);
% Ps = DrawRectangle([ P.p(1,q), P.p(2,q), (P.config(q))]);
patch( Ps(1,:),Ps(2,:),'green');
  hold on;
  drawnow
  end
end


% end

