function obj = filterOptimalSol(obj)

obj.opt.listOpt = [];
for i=1:obj.repDone
    if strcmpi(obj.opt.stat.returnStat{i}, 'Solve_succeeded')
        obj.opt.listOpt = [obj.opt.listOpt i];
    end
end
end