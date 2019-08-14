function simulationChosen(~,~)
% display score and percentage max of chosen simulation

obj = getOBJ(true, false);
obj.fig.labelShowNO.Visible = 'off';
obj.fig.freeTime.Visible = 'off';
if obj.fig.sim.Value ~=1
    if obj.fig.showNO.Value == 1
        index = regexp(obj.fig.sim.String(obj.fig.sim.Value), '\d+', 'match');
        obj.results.sim = str2double(index{1});
    else
        obj.results.sim = str2double(obj.fig.sim.String(obj.fig.sim.Value));
    end
    index = find(obj.results.listValues(:,1) == obj.results.sim);
    if ~ismember(obj.results.sim, obj.opt.listOpt)
        set(obj.fig.labelShowNO, 'Visible', 'on');
        obj.fig.labelShowNO.String = obj.opt.stat{obj.results.sim};
    end
    obj.fig.score.String = num2str(obj.results.listValues(index, 2));
    obj.fig.percent.String = num2str(obj.results.listValues(index, 3));
    obj = onAndOffResults(obj, 'on', 'sim');
else
    obj.fig.score.String = 'Score';
    obj.fig.percent.String = '%';
    obj = onAndOffResults(obj, 'off', 'sim');
end

setOBJ(obj);

end