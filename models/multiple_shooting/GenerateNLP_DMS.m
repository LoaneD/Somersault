function [prob, lbw, ubw, lbg, ubg] = GenerateNLP_DMS(model,data, variables, constraints)

import casadi.*
% Start with an empty NLP
w={};
lbw = [];
ubw = [];
J = 0;
g={};
lbg = [];
ubg = [];
Xk={};
if ~isfield(data, 'Duration')
    t = MX.sym('t',1);
    w = {w{:}, t};
    if isfield(data, 'timeL')
        lbw = [lbw; data.timeL];
        ubw = [ubw; data.timeU];
    else
        lbw = [lbw; 0.85];
        ubw = [ubw; 1.15];
    end
end

% Formulate the NLP
% Xk = data.x0;
Xk = MX.sym(['X_' '0'], model.nx);
w = {w{:}, Xk};
Xk0 = Xk;
lbw = [lbw; model.xmin];
ubw = [ubw; model.xmax];
g = [g, {Xk}];
cStartl = [];
cStartu = [];
for i=1:model.nx
    if i ~= model.dof.Somer+model.nq || ~isfield(data, 'freeSomerSpeed')
        cStartl = [cStartl; data.x0(i)];
        cStartu = [cStartu; data.x0(i)];
    else
        cStartl = [cStartl; model.xmin(i)];
        cStartu = [cStartu; model.xmax(i)];
    end
end
lbg = [lbg; cStartl];
ubg = [ubg; cStartu];

for k=0:data.Nint-1
    
    % New NLP variable for the control
    Uk = MX.sym(['U_' num2str(k)], model.nu);
    w = {w{:}, Uk};
    
    lbw = [lbw; model.umin];
    ubw = [ubw; model.umax];
    
    if strcmpi(data.odeMethod, 'rk4_dt')
        tgrid = getTimeScale(model, data);
        if strcmpi(data.dt,'log'), DT = tgrid(k+2)-tgrid(k+1);%-log((k+1)/(data.Nint+1))/data.Nint*data.Duration;
        elseif strcmpi(data.dt,'a'), DT = (0.005+1/data.Nint*(1-fix(k*10/data.Nint)/data.Nint))*data.Duration;
        end
        Fk = model.odeF('x0', Xk, 'p', Uk, 'DT', DT);
    else
        if isfield(data, 'Duration')
            Fk = model.odeF('x0', Xk, 'p', Uk);
        else
            Fk = model.odeF('x0', Xk, 'p', Uk, 't', t);
        end
    end
    
    % Integrate till the end of the interval
    Xk_end = Fk.xf;
    J=J+Fk.qf;
    
    % New NLP variable for state at end of interval
    Xk = MX.sym(['X_' num2str(k+1)], model.nx);
    w = [w, {Xk}];
    lbw = [lbw; model.xmin];
    ubw = [ubw; model.xmax];
    
    % Add equality constraint
    if isfield(model, 'colD')
        dist = model.colD('Q',Xk_end);
        g = [g, {Xk_end-Xk}, {dist.d}];
        lbg = [lbg; zeros(model.nx,1); model.markers.dmin+0.01];
        ubg = [ubg; zeros(model.nx,1); 1000*ones(size(model.markers.dmin,1),1)];
    else
        g = [g, {Xk_end-Xk}];
        lbg = [lbg; zeros(model.nx,1)];
        ubg = [ubg; zeros(model.nx,1)];
    end
end

% add end constraints
if nargin > 2
    g = [g, {Xk([model.dof.RighArmY model.dof.LeftArmY])}];
    lbg = [lbg; -inf;  120/180*pi];
    ubg = [ubg; -120/180*pi; inf];
    if size(variables > 0)
        g = [g, {Xk(variables)}];
        lbg = [lbg; constraints(:,1)];
        ubg = [ubg; constraints(:,2)];
    end
else
    g = [g, {Xk([model.dof.Tilt model.dof.Somer model.dof.RighArmY model.dof.LeftArmY])}  ];% model.dof.RighArmY model.dof.LeftArmY
    lbg = [lbg; -15/180*pi; 2*pi-5*pi/180;  -inf;  120/180*pi];%;  -inf;  120/180*pi
    ubg = [ubg;  15/180*pi; 2*pi+5*pi/180; -120/180*pi; inf];%; -120/180*pi; inf
end

% create solver
if strcmpi(data.obj, 'twist')
    o = Xk(model.dof.Twist)/(2*pi); 
elseif strcmpi(data.obj, 'twistPond')
    if isfield(data, 'freeSomerSpeed') && strcmpi(data.freeSomerSpeed, 'pond')
        o = 1000*Xk(model.dof.Twist) + J + 0.01*Xk0(model.dof.Somer);
    else
        o = 1000*Xk(model.dof.Twist) + J;
    end
elseif strcmpi(data.obj, 'trajectory')
    if nargin <= 2 || (nargin > 2 && ~ismember(model.dof.Twist,variables))
        g = [g, {Xk([model.dof.Twist])}  ];
        lbg = [lbg; -Inf];
        ubg = [ubg; -4*pi+0.5*pi];
    end
    o = J;
elseif strcmpi(data.obj, 'torque')
    if nargin <= 2 || (nargin > 2 && ~ismember(model.dof.Twist,variables))
        g = [g, {Xk([model.dof.Twist])}  ];
        % back somersault so twist in opposite sens
        lbg = [lbg; -Inf];
        ubg = [ubg; -4*pi+0.5*pi];
    end
    o = J;
end
prob = struct('f', o, ...
    'x', vertcat(w{:}), 'g', vertcat(g{:}));
end



