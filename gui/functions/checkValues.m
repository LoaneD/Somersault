function [out, val, obj] = checkValues(obj)

out.values = true;
val.value = false;
nq = obj.model.nq;

if obj.fig.somerTO_u.Value == 1
    somer = str2double(obj.fig.somerTO.String)/obj.model.Unitcoef(obj.model.dof.Somer);
elseif obj.fig.somerTO_u.Value == 2
    somer = str2double(obj.fig.somerTO.String)*pi/180;
else
    somer = str2double(obj.fig.somerTO.String);
end
if obj.fig.twistTO_u.Value == 1
    twist = str2double(obj.fig.twistTO.String)/obj.model.Unitcoef(obj.model.dof.Twist);
elseif obj.fig.somerTO_u.Value == 2
    twist = str2double(obj.fig.twistTO.String)*pi/180;
else
    twist = str2double(obj.fig.twistTO.String);
end
if obj.fig.wsomerTO_u.Value == 1
    wsomer = str2double(obj.fig.wsomerTO.String);
elseif obj.fig.somerTO_u.Value == 2
    wsomer = str2double(obj.fig.wsomerTO.String)*pi/180;
else
    wsomer = str2double(obj.fig.wsomerTO.String)/obj.model.Unitcoef(obj.model.dof.Somer);
end
if obj.fig.twistTO_u.Value == 1
    wtwist = str2double(obj.fig.twistTO.String);
elseif obj.fig.somerTO_u.Value == 2
    wtwist = str2double(obj.fig.twistTO.String)*pi/180;
else
    wtwist = str2double(obj.fig.twistTO.String)/obj.model.Unitcoef(obj.model.dof.Twist);
end

if str2double(obj.fig.heightTO.String) >= obj.model.xmin(obj.model.dof.Tz,1) && ...
        str2double(obj.fig.heightTO.String) <= obj.model.xmax(obj.model.dof.Tz,1)
    obj.data.x0(obj.model.dof.Tz,1) = str2double(obj.fig.heightTO.String); %height initial value
else
    set(obj.fig.heightTO, 'ForegroundColor', 'red');
    out.values = false;
end
if somer >= obj.model.xmin(obj.model.dof.Somer,1) && somer <= obj.model.xmax(obj.model.dof.Somer,1)
    obj.data.x0(obj.model.dof.Somer,1) = somer; %somersault initial value
else
    set(obj.fig.somerTO, 'ForegroundColor', 'red');
    out.values = false;
end
if twist >= obj.model.xmin(obj.model.dof.Twist,1) && twist <= obj.model.xmax(obj.model.dof.Twist,1)
    obj.data.x0(obj.model.dof.Twist,1) = twist; %twist initial value
else
    set(obj.fig.twistTO, 'ForegroundColor', 'red');
    out.values = false;
end
if str2double(obj.fig.vvTO.String) >= obj.model.xmin(nq+obj.model.dof.Tz,1) && ...
        str2double(obj.fig.vvTO.String) <= obj.model.xmax(nq+obj.model.dof.Tz,1)
    obj.data.x0(nq+obj.model.dof.Tz,1) = str2double(obj.fig.vvTO.String); %vertical speed initial value
else
    set(obj.fig.vvTO, 'ForegroundColor', 'red');
    out.values = false;
end
if str2double(obj.fig.vhTO.String) >= obj.model.xmin(nq+1,1) && ...
        str2double(obj.fig.vhTO.String) <= obj.model.xmax(nq+1,1)
    obj.data.x0(nq+1,1) = str2double(obj.fig.vhTO.String); %horizontal speed initial value
else
    set(obj.fig.vhTO, 'ForegroundColor', 'red');
    out.values = false;
end
if wsomer >= obj.model.xmin(nq+obj.model.dof.Somer,1) && wsomer <= obj.model.xmax(nq+obj.model.dof.Somer,1)
    obj.data.x0(nq+obj.model.dof.Somer,1) = wsomer; %somersault speed initial value
else
    set(obj.fig.wsomerTO, 'ForegroundColor', 'red');
    out.values = false;
end
if wtwist >= obj.model.xmin(nq+obj.model.dof.Twist,1) && wtwist <= obj.model.xmax(nq+obj.model.dof.Twist,1)
    obj.data.x0(nq+obj.model.dof.Twist,1) = wtwist; %twist speed initial value
else
    set(obj.fig.wtwistTO, 'ForegroundColor', 'red');
    out.values = false;
end
if ~checkRange(str2double(obj.fig.somerL.String)*(1/obj.model.Unitcoef(obj.model.dof.Somer)), ...
        obj.menu.rad(obj.fig.somerRL.Value), obj.model.xmin(obj.model.dof.Somer,1),...
        obj.model.xmax(obj.model.dof.Somer,1))
    set(obj.fig.somerL, 'ForegroundColor', 'red');
    set(obj.fig.somerRL, 'ForegroundColor', 'red');
    out.values = false;
end
if ~checkRange(str2double(obj.fig.twistL.String)*(1/obj.model.Unitcoef(obj.model.dof.Twist)), ...
        obj.menu.rev(obj.fig.twistRL.Value)*(1/obj.model.Unitcoef(obj.model.dof.Twist)), obj.model.xmin(obj.model.dof.Twist,1),...
        obj.model.xmax(obj.model.dof.Twist,1))
    set(obj.fig.twistL, 'ForegroundColor', 'red');
    set(obj.fig.twistRL, 'ForegroundColor', 'red');
    out.values = false;
end
if ~checkRange(str2double(obj.fig.tiltL.String), obj.menu.deg(obj.fig.tiltRL.Value)*...
        (1/obj.model.Unitcoef(obj.model.dof.Tilt)), obj.model.xmin(obj.model.dof.Tilt,1),...
        obj.model.xmax(obj.model.dof.Tilt,1))
    set(obj.fig.tiltL, 'ForegroundColor', 'red');
    set(obj.fig.tiltRL, 'ForegroundColor', 'red');
    out.values = false;
end
if obj.fig.heightRL.Value ~= 1
    hfUp = str2double(obj.fig.heightL.String) + obj.menu.height(obj.fig.heightRL.Value);
    hfDown = str2double(obj.fig.heightL.String) - obj.menu.height(obj.fig.heightRL.Value);
    [tUp, V] = freeFallEq(str2double(obj.fig.vvTO.String), str2double(obj.fig.heightTO.String), hfUp, 1);
    [tDown, ~] = freeFallEq(V, str2double(obj.fig.heightTO.String), hfDown, 1);
    val.tUp = tUp; val.tDown = tDown; val.V = V;  
    if isfield(obj.data, 'Duration'), dur = obj.data.Duration;
    else, dur = (obj.data.timeL + obj.data.timeU)/2; end
    [VzUp, ~] = freeFallEq(dur, str2double(obj.fig.heightTO.String), hfUp, 0);
    [VzDown, t] = freeFallEq(dur, str2double(obj.fig.heightTO.String), hfDown, 0);
    val.VzUp = VzUp; val.VzDown = VzDown; val.t = t; 
    val.value = true;
end
        
end

function [t_Vz, Vz_t] = freeFallEq(Vz_t, h0, hf, fixe)

% Vzi is fixed, find tf
step = Vz_t/10;
if fixe == 1
    while Vz_t*Vz_t+2*9.81*(h0-hf) < 0
        Vz_t = Vz_t + step;
    end
    t_Vz = -(-Vz_t - sqrt(Vz_t*Vz_t+2*9.81*(h0-hf)))/9.81;
% tf is fixed, find Vzi
else
    % probably need to change condition : max speed feasible or only going
    % up?
    while 0.5*9.81*Vz_t+(hf-h0)/Vz_t < 0
        Vz_t = Vz_t + step;
    end
    t_Vz = 0.5*9.81*Vz_t+(hf-h0)/Vz_t;
end

end