function enableSimChoice(src, ~)
% create the simulation list to fill the pop up menu 
obj = getOBJ(true, false);
obj = initialise(obj, 'clearFig');
if src == obj.fig.showNO
    if obj.fig.showNO.Value == 1
        if obj.fig.results.Value == 2, obj.fig.sim.String = obj.results.listSim95NO;
        elseif obj.fig.results.Value == 3, obj.fig.sim.String = obj.results.listSimAllNO; 
        end
    else
        if obj.fig.results.Value == 2, obj.fig.sim.String = obj.results.listSim95;
        elseif obj.fig.results.Value == 3, obj.fig.sim.String = obj.results.listSimAll;
        end
    end
end
% change sim list value depending on what results in set on
if obj.fig.results.Value == 2
    if obj.fig.showNO.Value == 1, obj.fig.sim.String = obj.results.listSim95NO;
    else, obj.fig.sim.String = obj.results.listSim95;
    end
elseif obj.fig.results.Value == 3
    if obj.fig.showNO.Value == 1, obj.fig.sim.String = obj.results.listSimAllNO;
    else, obj.fig.sim.String = obj.results.listSimAll;
    end   
end

if obj.fig.results.Value == 1
    if size(obj.opt.listOpt, 2) ~= 0 || obj.fig.showNO.Value == 1
        obj = onAndOffResults(obj, 'on', 'best');
        if ~ismember(obj.results.sim, obj.opt.listOpt)
            set(obj.fig.labelShowNO, 'Visible', 'on');
            obj.fig.labelShowNO.String = obj.opt.stat{obj.results.sim};
        end
    else
        obj.fig.sim.String = {'Simulation'};
        obj = onAndOffResults(obj, 'off', 'best');
    end
else
    obj = onAndOffResults(obj, 'off', 'sim');
    obj = onAndOffResults(obj, 'on', 'list');
    if size(obj.opt.listOpt, 2) == 0 && obj.fig.showNO.Value == 0
        obj = onAndOffResults(obj, 'off', 'best');
    end
end

setOBJ(obj);

end