function obj = onAndOffResults(obj, on_off, display)

if strcmpi(on_off, 'on')
    set(obj.fig.results, 'Enable', 'on');
    if nargin > 2
        if strcmpi(display, 'best')
            obj.fig.sim.Value = 1;
            obj.fig.sim.String = obj.results.bestSimStr;
            obj.fig.score.String = obj.results.bestScore;
            obj.fig.percent.String = obj.results.bestPercent;
            obj.results.sim = obj.results.bestSim;
            obj.fig.animPart.Value = 1;
            obj.fig.anim.Value = 1;
            set(obj.fig.sim, 'Enable', 'inactive');
            set(obj.fig.score, 'Enable', 'on');
            set(obj.fig.percent, 'Enable', 'on');
            set(obj.fig.anim, 'Enable', 'on');
            set(obj.fig.animPart, 'Enable', 'on');
            if isfield(obj.data, 'time')
                t = sprintf('%d s', obj.results.t_opt(obj.results.sim,1));
                set(obj.fig.freeTime, 'Visible', 'on', 'String', t);
            end
        elseif strcmpi(display, 'list')
            set(obj.fig.sim, 'Enable', 'on');
            obj.fig.sim.Value = 1;
        else
            set(obj.fig.score, 'Enable', 'on');
            set(obj.fig.percent, 'Enable', 'on');
            set(obj.fig.anim, 'Enable', 'on');
            set(obj.fig.animPart, 'Enable', 'on');
            if isfield(obj.data, 'time')
                t = sprintf('%d s', obj.results.t_opt(obj.results.sim,1));
                set(obj.fig.freeTime, 'Visible', 'on', 'String', t);
            end
        end
    end
else
    if nargin > 2
        if strcmpi(display, 'sim')
            obj.fig.score.String = 'Score';
            obj.fig.percent.String = '%';
            obj.fig.animPart.Value = 1;
            obj.fig.anim.Value = 1;
            set(obj.fig.anim, 'Enable', 'off');
            set(obj.fig.animPart, 'Enable', 'off');
        elseif strcmpi(display, 'best')
            obj.fig.score.String = 'Score';
            obj.fig.percent.String = '%';
            obj.fig.animPart.Value = 1;
            obj.fig.anim.Value = 1;
            set(obj.fig.score, 'Enable', 'off');
            set(obj.fig.percent, 'Enable', 'off');
            set(obj.fig.sim, 'Enable', 'off');
            set(obj.fig.results, 'Enable', 'off');
            obj.fig.results.Value = 1;
            set(obj.fig.labelShowNO, 'Visible', 'off');
        else
            obj.fig.score.String = 'Score';
            obj.fig.percent.String = '%';
            obj.fig.freeTime.Visible = 'off';
            obj.fig.sim.Value = 1;
            obj.fig.animPart.Value = 1;
            obj.fig.anim.Value = 1;
        end
    else
        obj.fig.score.Enable = 'off';
        obj.fig.percent.Enable = 'off';
        set(obj.fig.showNO, 'Value', 0);
        set(obj.fig.showNO, 'Enable', 'off');
        set(obj.fig.results, 'Value', 1);
        set(obj.fig.sim, 'Value', 1);
        set(obj.fig.sim, 'Enable', 'off');
        set(obj.fig.results, 'Enable', 'off');
    end
    set(obj.fig.labelShowNO, 'Visible', 'off');
    set(obj.fig.anim, 'Enable', 'off');
    set(obj.fig.animPart, 'Enable', 'off');
    set(obj.fig.display, 'Enable', 'off');
    set(obj.fig.freeTime, 'Visible', 'off');
end


end