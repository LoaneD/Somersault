function [prob, lbw, ubw, lbg, ubg] = GenerateNLP_Collocation_Hermite(model, data, variables, constraints)

import casadi.*

% % Get dynamic equations
tau_base = SX.zeros(6,1);
forDyn = @(x,u)[  x(model.idx_v)
    FDab_Casadi( model, x(model.idx_q), x(model.idx_v), vertcat(tau_base ,u)  )];
x = SX.sym('x', model.nx,1);
u = SX.sym('u', model.nu,1);
qdot = forDyn(x,u);
switch data.obj
    case 'twist', L = 0.5* (u'*u);
    case 'torque', L = 0.5* (u'*u);
    case 'trajectory', L = 0.5* (qdot(7:end,1)'*qdot(7:end,1));
end
f = Function('f', {x, u}, {forDyn(x,u), L});

% % Start with an empty NLP
w={};
w0 = [];
lbw = [];
ubw = [];
J = 0;
g={};
lbg = [];
ubg = [];
tgrid = getTimeScale(model, data);

N = data.Nint; % number of control intervals
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
    T = full(t);
else
    T = data.Duration;
end
h = T/N;

% Formulate the NLP
Xk = data.x0;
Uk = MX.sym(['U_' num2str(0)], model.nu);
w = {w{:}, Uk};
lbw = [lbw; model.umin];
ubw = [ubw; model.umax];
for k=0:N-1
    [fk, qk] = f(Xk,Uk);
    
    Xk12 = MX.sym(['X_' num2str(k) '_2'], model.nx);
    w = [w, {Xk12}];
    lbw = [lbw; model.xmin];
    ubw = [ubw; model.xmax];
    
    Uk1 = MX.sym(['U_' num2str(k+1)], model.nu);
    Xk1 = MX.sym(['X_' num2str(k+1)], model.nx);
    [fk1, qk1] = f(Xk1,Uk1);

    x12 = 0.5*(Xk + Xk1) + h*(fk - fk1)/8;
    u12 = 0.5*(Uk + Uk1);
    [fk12, qk12] = f(Xk12,u12);
    
    Xkend = Xk+h*(fk + 4*fk12 +fk1)/6;
    xd12 = -1.5*(Xk - Xkend)/h - 0.25*(fk + fk1);
    J = J + h*(qk + 4*qk12 +qk1)/6;
    
    w = [w, {Xk1}];
    lbw = [lbw; model.xmin];
    ubw = [ubw; model.xmax];
    
    w = {w{:}, Uk1};
    lbw = [lbw; model.umin];
    ubw = [ubw; model.umax];
    
    Xk = Xk1;
    Uk = Uk1;
    % % Inequality constraint to reduce  
    g = {g{:}, x12 - Xk12, abs(xd12-fk12), Xkend - Xk};
    lbg = [lbg; zeros(model.nx,1); zeros(model.nx,1); zeros(model.nx,1)];
    ubg = [ubg; zeros(model.nx,1); 0.005*ones(model.nx,1); zeros(model.nx,1)];
    
    % % Add equality constraint
    if strcmpi(model.name,'10')
        dist = model.colD('Q',Xkend);
        g = [g, {dist.d}];
        lbg = [lbg; model.markers.dmin+0.01];
        ubg = [ubg; 1000*ones(size(model.markers.dmin,1),1)];
    end
    
end

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
    g = [g, {Xk([model.dof.Tilt model.dof.RighArmY model.dof.LeftArmY model.dof.Somer])}  ];
    lbg = [lbg; -15/180*pi;  -inf;  120/180*pi; 2*pi-5*pi/180];
    ubg = [ubg;  15/180*pi; -120/180*pi; inf; 2*pi+5*pi/180];
end

% Create an NLP solver
if strcmpi(data.obj, 'twist')
    prob = struct('f', Xk(model.dof.Twist)/(2*pi), ...
        'x', vertcat(w{:}), 'g', vertcat(g{:}));
elseif strcmpi(data.obj, 'trajectory')
    if nargin <= 2 || (nargin > 2 && ~ismember(model.dof.Twist,variables))
        g = [g, {Xk([model.dof.Twist])}  ];
        lbg = [lbg; -4*pi-0.5*pi];
        ubg = [ubg; -4*pi+0.5*pi];
    end
    prob = struct('f', J, ...
        'x', vertcat(w{:}), 'g', vertcat(g{:}));
elseif strcmpi(data.obj, 'torque')
    if nargin <= 2 || (nargin > 2 && ~ismember(model.dof.Twist,variables))
        g = [g, {Xk([model.dof.Twist])}  ];
        % back somersault so twist in opposite sens
        lbg = [lbg; -Inf];
        ubg = [ubg; -3*pi];
    end
    prob = struct('f', J, ...
        'x', vertcat(w{:}), 'g', vertcat(g{:}));
end

end