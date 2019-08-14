function plotKinetics(~, ~, dof)

obj = getOBJ(true, false);
w = getW_opt(obj.results.QVU, obj.model, obj.data, obj.results.sim);
if isfield(obj.data, 'time')
    plotKin(dof, obj.model, obj.data, w, obj.fig.axes, obj.results.t_opt(obj.results.sim,1));
else
    plotKin(dof, obj.model, obj.data, w, obj.fig.axes);
end
title(obj.fig.axes, obj.model.DOFname{dof});

setOBJ(obj);

end