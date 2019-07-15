function [xp] = forward_kinematics_MB(model, q)%, plt)

import casadi.*

for i= 1:model.NB
    [XJ, S{i}] = jcalc(model.jtype{i}, q(i));
    Xup{i} = XJ*model.Xtree{i};
    RT{i} = pluho(Xup{i});
    iRT{i} = invR(RT{i}, 0);
    %inverse RT
%     fprintf('\nDoF %d iRT: ', i);
%     disp(iRT{i});
%      Xup{i} = model.Xtree{i}*XJ;
end

for i = model.NB:-1:1
    j=i;
    XXup{i} = iRT{j};
    parent = model.parent(j);
    
    while parent > 0
        XXup{i} = iRT{parent}*XXup{i};
%         XXup{i} = XXup{i}*iRT{parent};
        j = parent;
        parent = model.parent(j);
    end
%     fprintf('\nDoF %d XXup: ', i);
%     disp(XXup{i});
end

 xp = SX.zeros(3,length(model.markers.parent));

for i=1:length(model.markers.parent)
    parent = model.markers.parent(i);
%     disp(model.markers.coordinates(:,i))
%     xp(:,i) = Xpt(XXup{parent}, model.markers.coordinates(:,i));
    p = [model.markers.coordinates(:,i); 1];
    pdep = XXup{parent}*p;
    xp(:,i) = pdep(1:3,:);
%     fprintf('\nParent : %d -- ',parent);
%     disp(xp(:,i));
end

% 
% if plt
%     X = full(xp);
%     disp(X);
%     figure;
%     plot3(X(1,:),X(2,:),X(3,:),'.-','LineWidth',2);
%     text(X(1,:),X(2,:),X(3,:),model.markers.name);
% end

        