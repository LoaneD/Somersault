function obj = initialise(obj, target)

if strcmpi(target, 'start') || strcmpi(target, 'optDone') || strcmpi(target, 'optStart') || strcmpi(target, 'error')
    obj.lock = true;
    set(obj.fig.hpanelBar, 'Visible', 'off');
    obj.stop = 0;
    
    obj.opt.rep = str2double(obj.fig.rep.String);
    if strcmpi(target, 'optStart')
%         set(obj.fig.STOP, 'Visible', 'on');
        set(obj.fig.GO, 'Enable', 'off');
        obj.fig.reini.Enable = 'off';
        obj.fig.results.Value = 1;
    elseif strcmpi(target, 'error')
        set(obj.fig.STOP, 'Visible', 'off');
        set(obj.fig.GO, 'Enable', 'on');
        uiwait(msgbox('Take-off or landing values uncorrect', 'Error', 'modal'));
    else
        obj.fig.GO.Enable = 'on';
        obj.fig.STOP.String = 'STOP';
        obj.fig.reini.Enable = 'on';
        set(obj.fig.STOP, 'Visible', 'off');
        set(obj.fig.STOP, 'Enable', 'on');
        obj.fig.STOP.Value = 0;
    end
    if strcmpi(target, 'optStart') || strcmpi(target, 'start')
        set(obj.fig.vvTOfree, 'Visible', 'off');
        set(obj.fig.durfree, 'Visible', 'off');
        obj.data = struct;
        obj.model = struct;
        obj.data.Nint = 30;
        obj.data.odeMethod = 'rk4';
        obj.epsilon = 1e-12;
        obj.model.name = '8';
        set(obj.fig.labelRepDone, 'Visible', 'off');
        set(obj.fig.labelStopReason, 'Visible', 'off');
        obj.opt.rep = 0;
        obj.repDone = 0;
        obj.fig.duration.String = '1';
        
        obj.results.QVU = [];
        obj.results.feasible = [];
        obj.results.w0 = [];
        obj.term = 0;
        
        set(obj.fig.heightTO, 'ForegroundColor', 'k');
        set(obj.fig.somerTO, 'ForegroundColor', 'k');
        set(obj.fig.twistTO, 'ForegroundColor', 'k');
        set(obj.fig.vvTO, 'ForegroundColor', 'k');
        set(obj.fig.vhTO, 'ForegroundColor', 'k');
        set(obj.fig.wsomerTO, 'ForegroundColor', 'k');
        set(obj.fig.wtwistTO, 'ForegroundColor', 'k');
        set(obj.fig.tiltL, 'ForegroundColor', 'k');
        set(obj.fig.tiltRL, 'ForegroundColor', 'k');
        set(obj.fig.twistL, 'ForegroundColor', 'k');
        set(obj.fig.twistRL, 'ForegroundColor', 'k');
        set(obj.fig.somerL, 'ForegroundColor', 'k');
        set(obj.fig.somerRL, 'ForegroundColor', 'k');
        set(obj.fig.duration, 'ForegroundColor', 'k');
    elseif strcmpi(target, 'optDone')
        obj.firstLaunch = false;
        if obj.term == 1 || obj.term == 3
            set(obj.fig.labelStopReason, 'Visible', 'on');
            set(obj.fig.labelStopReason, 'String', 'Time max exceeded');
        end
    end
elseif strcmpi(target, 'iniResult')
    set(obj.fig.labelStopReason, 'Visible', 'off');
    obj.fig.sim.String = {'Simulation'};
    obj.fig.sim.Value = 1;
    obj.fig.score.String = 'Score';
    obj.fig.percent.String = '%';
    obj.fig.animPart.Value = 1;
    obj.fig.anim.Value = 1;
    obj.fig.display.Enable = 'off';
    obj.fig.labelShowNO.Visible = 'off';
    set(obj.fig.freeTime, 'Visible', 'off');
%     set(obj.fig.showNO, 'Value', 0);
    obj = createToolBar(obj, 'off', false);
    cla(obj.fig.axes, 'reset');
    for i=1:obj.model.NB
        set(obj.fig.buttonDOF(i), 'Visible', 'off');
    end
elseif strcmpi(target, 'clearFig')
    obj = createToolBar(obj, 'off', false);
    cla(obj.fig.axes, 'reset');
    for i=1:obj.model.NB
        set(obj.fig.buttonDOF(i), 'Visible', 'off');
    end
end
   
end