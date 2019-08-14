function [obj,stop] = handleHeightLanding(obj, val)

Vz = (val.VzUp + val.VzDown)/2;
VzR = val.VzUp - Vz;
tf = (val.tUp + val.tDown)/2;
tfR = abs(val.tUp - tf);
if isfield(obj.data, 'Duration'), dur = obj.data.Duration;
else, dur = (obj.data.timeL + obj.data.timeU)/2; end
duration = sprintf('Duration fixed %g s', dur);
prompt = true;
if val.V ~= str2double(obj.fig.vvTO.String) || ...
        val.t ~= dur
    % height never reached with the initial speed
    txt = sprintf('Problems with height upon landing constraints (to achieve %g ± %g m):\n- with initial vertical speed = %g m/s max height never reached -- not useable\n- with initial vertical speed = %g m/s: duration = %g ± %g m/s\n- with duration = %g s: initial speed = %g ± %g m/s\n\nChoose one variable to keep fixed and one to set free in appropriate interval.', ...
        str2double(obj.fig.heightL.String), obj.menu.height(obj.fig.heightRL.Value),...
    	str2double(obj.fig.vvTO.String), val.V, tf, tfR, dur, Vz, VzR);
    s = 'new';
    speed = sprintf('Initial Speed fixed %g m/s', val.V);
else
    if (val.VzUp > str2double(obj.fig.vvTO.String) && val.VzDown < str2double(obj.fig.vvTO.String))...
            || (val.tUp > dur && val.tDown < dur)
        % leaving speed and duration as they are can arrive to solution
        % for now no pop up window shown, maybe change it later
        prompt = false;
    else
        % one of the variable will need to be set free
        txt = sprintf('Problems with height upon landing constraints (to achieve %g ± %g m):\n- if initial vertical speed = %g m/s: duration = %g ± %g s\n- if duration = %g s: initial speed = %g ± %g m/s\n\nChoose one variable to keep fixed and one to set free in appropriate interval.', ...
            str2num(obj.fig.heightL.String), obj.menu.height(obj.fig.heightRL.Value),...
            str2num(obj.fig.vvTO.String), tf, tfR,dur, Vz, VzR);
        s = 'ini';
        speed = sprintf('Initial Speed fixed %g m/s', str2double(obj.fig.vvTO.String));
    end
end
if prompt
    promptMessage = txt;
    titleBarCaption = 'Height upon landing causing problems';
    button = questdlg(promptMessage, titleBarCaption, speed, duration, 'Back', 'Back');
    if strcmpi(button, speed)
        stop = false;
        if strcmpi(s,'new')
            obj.data.x0(obj.model.nq+obj.model.dof.Tz) = val.V;
            set(obj.fig.vvTO, 'String', val.V, 'ForegroundColor', [0 0.4470 0.7410]);
        end
        obj.data.timeL = round(min(val.tUp,val.tDown), 2, 'significant');
        obj.data.timeU = round(max(val.tUp,val.tDown), 2, 'significant');
        v = sprintf('FREE [%g-%g] s', obj.data.timeL, obj.data.timeU);
        set(obj.fig.durfree, 'Visible', 'on', 'String', v);
    elseif strcmpi(button, duration)
        stop = false;
        vd = round(val.VzDown, 2, 'significant');
        vu = round(val.VzUp, 2, 'significant');
        obj.data.x0(obj.model.nq+obj.model.dof.Tz) = vd+(vu-vd)*rand(1);
        v = sprintf('FREE [%g-%g] m/s', vd, vu);
        set(obj.fig.vvTOfree, 'Visible', 'on', 'String', v);
    elseif strcmpi(button, 'Back')
        stop = true;
    end
else 
    stop = false;
end
end