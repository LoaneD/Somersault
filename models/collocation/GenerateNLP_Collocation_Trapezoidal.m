function [prob, lbw, ubw, lbg, ubg] = GenerateNLP_Collocation_Trapezoidal(model, data, variables, constraints)

import casadi.*

% % Get dynamics equations
tau_base = SX.zeros(6,1);
forDyn = @(x,u)[  x(model.idx_v)
    FDab_Casadi( model, x(model.idx_q), x(model.idx_v), vertcat(tau_base ,u)  )];
x = SX.sym('x', model.nx,1);
u = SX.sym('u', model.nu,1);
qdot = forDyn(x,u);
switch data.obj
    case 'twist', L = 0.5* (u'*u); 
    case 'twistPond'
        if strcmpi(model.name, '10'), L = 10*(u([1 3])'*u([1 3]))+0.01*(u([2 4])'*u([2 4]));   
        else, L = 0.01*(u'*u);  
        end
    case 'torque', L = 0.5* (u'*u);  
    case 'trajectory', L = 0.5* (qdot(7:end,1)'*qdot(7:end,1));  
end
f = Function('f', {x, u}, {forDyn(x,u), L});

% Start with an empty NLP
w={};
w0 = [];
lbw = [];
ubw = [];
J = 0;
g={};
lbg = [];
ubg = [];

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

Uk = MX.sym(['U_' num2str(0)], model.nu);
w = {w{:}, Uk};
lbw = [lbw; model.umin];
ubw = [ubw; model.umax];
for k=0:N-1
    [fk, qk] = f(Xk,Uk);
    
    Uk = MX.sym(['U_' num2str(k+1)], model.nu);
    
    Xk1 = MX.sym(['X_' num2str(k+1)], model.nx);
    w = [w, {Xk1}];
    lbw = [lbw; model.xmin];
    ubw = [ubw; model.xmax];
    
    [fk1, qk1] = f(Xk1,Uk);
    Xkend = Xk+0.5*h*(fk1+fk);
    J = J + 0.5*h*(qk1+qk);
    
    Xk = Xk1;
    g = {g{:}, Xkend - Xk};
    lbg = [lbg; zeros(model.nx,1)];
    ubg = [ubg; zeros(model.nx,1)];
    
    w = {w{:}, Uk};
    lbw = [lbw; model.umin];
    ubw = [ubw; model.umax];
    
    % Add equality constraint
    if strcmpi(model.name,'10') && isfield(model, 'colD')
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
    o = Xk(model.dof.Twist)/(2*pi); 
elseif strcmpi(data.obj, 'twistPond') 
    if isfield(data, 'freeSomerSpeed') && isa(data.freeSomerSpeed, 'double')
        o = 1000*Xk(model.dof.Twist) + J + data.freeSomerSpeed*Xk0(model.dof.Somer+model.nq);
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
prob = struct('f', o, 'x', vertcat(w{:}), 'g', vertcat(g{:}));

end