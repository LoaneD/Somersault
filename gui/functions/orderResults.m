function obj = orderResults(obj)
% order results from simulations from the best to the worst and store it in
% obj.results.listSimAll and obj.results.listSim95

% get all results sorted from best to worst
list = [];
for i = 1:obj.repDone
    if strcmpi(obj.data.obj, 'twistPond'), objective = obj.results.QVU(obj.model.dof.Twist, end,i)*obj.model.Unitcoef(obj.model.dof.Twist);
    else,objective = obj.opt.sol(i);
    end
    list(i,:) = [i, objective];
end
sorted = sortrows(list, 2, 'ascend');
i = 1;
% get the best objective value removing simulation that didn't converged
best = sorted(1,2);
while i < (obj.repDone+1) && ~ismember(sorted(i,1), obj.opt.listOpt)
    i = i+1;
    if i > obj.repDone
        best = Inf;
    else
        best = sorted(i,2);
    end
end
% means that there is at least one simulation with optimal found
if best ~= Inf
    obj = createListOrdered(obj, list, best);
else
    obj = createListOrdered(obj, list, sorted(1,2));
end

end