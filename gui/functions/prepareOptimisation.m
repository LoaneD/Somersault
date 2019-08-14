function prepareOptimisation(~, ~)

import casadi.*

obj = getOBJ(true, false);
if ~obj.firstLaunch
    obj = initialise(obj, 'iniResult');
    obj = onAndOffResults(obj, 'off');
end
obj = initialise(obj, 'optStart');
obj.opt.rep = str2double(obj.fig.rep.String);

% for now only two models possibilities : 8DoF (only arm elevation) or
% 10DoF (arm elevation + arm rotation)
error = false;
obj.data.Duration = str2double(obj.fig.duration.String);
if obj.fig.armR.Value == 1
    obj.model.name = '10';
    if obj.fig.nlp.Value == 1
        obj.data.timeL = 0.95;
        obj.data.timeU = 1.05;
        obj.fig.duration.String = 'free';
        if str2double(obj.fig.int.String) < 85
            answer = questdlg('You should increase the intervals number for the optimisation to work..', ...
                'Possible problem detected','Modify', ...
                'Continue as it is','Modify');
            if strcmpi(answer, 'Modify')
                error = true;
            end
        end
    end
end
if obj.fig.nlp.Value == 2 
    obj.data.NLPMethod = 'Collocation';
    if obj.fig.colloc.Value == 1
        obj.data.collocMethod = 'Trapezoidal';
    elseif obj.fig.colloc.Value == 2
        obj.data.collocMethod = 'Hermite';
    else
        obj.data.collocMethod = 'Legendre';
        obj.data.collocDegree = str2double(obj.fig.collocDegree.String);
    end
else
    obj.data.NLPMethod = 'MultipleShooting';    
end

obj.data.Nint = str2double(obj.fig.int.String);
[obj.model, obj.data] = GenerateModel(obj.model.name,obj.data);

% generate model and change initial values accroding to user choices

[out, val, obj] = checkValues(obj);
if out.values || error
    stop = false;
    % if height contraint on landing, either Vzi or tf might need changing
    if val.value
        [obj,stop] = handleHeightLanding(obj, val);
    end
    if stop || error
        set(obj.fig.STOP, 'Visible', 'off');
        set(obj.fig.GO, 'Enable', 'on');
        set(obj.fig.reini, 'Enable', 'on');
        setOBJ(obj);
    else
        set(obj.fig.hpanelBar, 'Visible', 'on');
        set(obj.fig.labelWait, 'String', 'Creating model...');
        pos = get(obj.fig.hpanelBarIn, 'Position');
        set(obj.fig.hpanelBarIn, 'Position', [pos(1) pos(2) 0 0]);
        
        if obj.fig.wsomerTOfree.Value == 1, obj.data.freeSomerSpeed = 'true'; end
        
        % change the objective function - needs to be worked on
        s = obj.fig.obj;
        if strcmpi(obj.fig.obj.Visible, 'off'), s = obj.fig.obj2; end
        if s.Value == 1
            obj.data.obj = 'twist';
            obj.fig.results.String = {'BEST', '> 95%', 'ALL'};
        elseif s.Value == 2
            obj.data.obj = 'trajectory';
            obj.fig.results.String = {'BEST', '< 105%', 'ALL'};
%             obj.model.xmax(obj.model.dof.Twist) = -1;%twisting negative cause back somersault
        elseif s.Value == 3
            obj.data.obj = 'torque';
            obj.fig.results.String = {'BEST', '< 105%', 'ALL'};
        elseif s.Value == 4
            obj.data.obj = 'twistPond';
            obj.fig.results.String = {'BEST', '> 95%', 'ALL'};
        elseif s.Value == 5
            obj.data.freeSomerSpeed = 'pond';
            obj.data.obj = 'twistPond';
            obj.fig.results.String = {'BEST', '> 95%', 'ALL'};
        end
        
        obj.model = GenerateODE(obj.model,obj.data);
        if strcmpi(obj.model.name,'10'), obj.model = GenerateTranspersionConstraints(obj.model);end
        
        %implement chosen constraints to NLP solver
        %if +/- inf chosen = no constraint
        var = [];
        c = [];
        %to see how we deal with the Tz landing position : depends of the initial
        %speed values
        if obj.fig.heightRL.Value ~= 1
            var = [var obj.model.dof.Tz];
            c = [c;createConstraint(str2double(obj.fig.heightL.String)*(1/obj.model.Unitcoef(obj.model.dof.Tz)),...
                obj.menu.height(obj.fig.heightRL.Value))];
        end
        if obj.fig.somerRL.Value ~= 1
            var = [var obj.model.dof.Somer];
            c = [c;createConstraint(str2double(obj.fig.somerL.String)*(1/obj.model.Unitcoef(obj.model.dof.Somer)),...
                obj.menu.rad(obj.fig.somerRL.Value))];
        end
        if obj.fig.twistRL.Value ~= 1
            var = [var obj.model.dof.Twist];
            % number of twist written positive but must be negative in calculs cause back somer
            c = [c;createConstraint(-str2double(obj.fig.twistL.String)*(1/obj.model.Unitcoef(obj.model.dof.Twist)),...
                obj.menu.rev(obj.fig.twistRL.Value)*(1/obj.model.Unitcoef(obj.model.dof.Twist)))];
        end
        if obj.fig.tiltRL.Value ~= 1
            var = [var obj.model.dof.Tilt];
            c = [c;createConstraint(str2double(obj.fig.tiltL.String),...
                obj.menu.deg(obj.fig.tiltRL.Value)*(1/obj.model.Unitcoef(obj.model.dof.Tilt)))];
        end
        % to add : ability to change objective function
        % if obj.fig.obj.Value == 1
        [obj.opt.prob, obj.opt.lbw, obj.opt.ubw, obj.opt.lbg, obj.opt.ubg] =...
            GenerateNLP(obj.model, obj.data, var, c);
        % end
        %set options and create solver
        options = struct;
        options.ipopt.max_cpu_time = 5000;
        if obj.fig.nlp.Value == 1
            options.ipopt.max_iter = 6000;
        else
            options.ipopt.max_iter = 2000;
        end
        options.ipopt.max_iter = 2000;
        obj.opt.solver  = nlpsol('solver', 'ipopt', obj.opt.prob, options);
        %     if obj.term == 2 || obj.term == 1
        %         waitbar(0, obj.opt.h, 'Stopping model creation and optimisation');
        %         pause(0.5)
        %         delete(obj.opt.h)
        %     else
        n = obj.opt.rep;
        setOBJ(obj);
        if ~strcmpi(obj.fig.STOP.Enable,'inactive')
            t = timer('StartDelay', 0.001,...
                'TimerFcn', @(src, event,nbRep)optimisation(src, event,n), 'BusyMode', 'queue');
            t.start();
        else
            set(obj.fig.STOP, 'Enable', 'on');
            set(obj.fig.STOP, 'Visible', 'off');
            set(obj.fig.GO, 'Enable', 'on');
            set(obj.fig.reini, 'Enable', 'on');
            setOBJ(obj);
        end
        %     end
        %     msgOutput(obj);
        %     if obj.repDone ~= 0
        %         obj = resultsOptimisation(obj);
        %     end
        %     obj = initialise(obj, 'optDone');
    end
else
    obj = initialise(obj, 'error'); 
    setOBJ(obj);
end

end