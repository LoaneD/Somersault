function [XX] = forward_kinematics_MB2(model, q)

import casadi.*

for i= 1:model.NB
    [XJ, S{i}] = jcalc(model.jtype{i}, q(i));
    Xup{i} = XJ*model.Xtree{i};
    RT{i} = pluho(Xup{i});
    iRT{i} = invR(RT{i}, 0);
end

XX = SX.zeros(4*model.NB,4);

for i = model.NB:-1:1
    j=i;
    XXup{i} = iRT{j};
    parent = model.parent(j);
    
    while parent > model.dof.Twist
        XXup{i} = iRT{parent}*XXup{i};
        j = parent;
        parent = model.parent(j);
    end
    if i <= model.dof.Twist, XXup{i} = SX.eye(4);end
    for k=1:4
        for l=1:4
            XX((i-1)*4+l,k) = XXup{i}(l,k);
        end
    end
end
end

        