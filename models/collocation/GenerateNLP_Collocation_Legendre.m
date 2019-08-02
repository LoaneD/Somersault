function [prob, lbw, ubw, lbg, ubg] = GenerateNLP_Collocation_Legendre(model,data, variables, constraints)
%variables, contraints used for GUI

import casadi.*

d = data.degree;% 3

% Get collocation points
tau_root = [0 collocation_points(d, 'legendre')];

% Coefficients of the collocation equation
C = zeros(d+1,d+1);

% Coefficients of the continuity equation
D = zeros(d+1, 1);

% Coefficients of the quadrature function
B = zeros(d+1, 1);

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

% Construct polynomial basis
for j=1:d+1
    % Construct Lagrange polynomials to get the polynomial basis at the collocation point
    coeff = 1;
    for r=1:d+1
        if r ~= j
            coeff = conv(coeff, [1, -tau_root(r)]);
            coeff = coeff / (tau_root(j)-tau_root(r));
        end
    end
    % Evaluate the polynomial at the final time to get the coefficients of the continuity equation
    D(j) = polyval(coeff, 1.0);
    
    % Evaluate the time derivative of the polynomial at all collocation points to get the coefficients of the continuity equation
    pder = polyder(coeff);
    for r=1:d+1
        C(j,r) = polyval(pder, tau_root(r));
    end
    
    % Evaluate the integral of the polynomial to get the coefficients of the quadrature function
    pint = polyint(coeff);
    B(j) = polyval(pint, 1.0);
end

% Start with an empty NLP
w={};
w0 = [];
lbw = [];
ubw = [];
J = 0;
g={};
lbg = [];
ubg = [];


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
if ~isfield(data, 'dt'), h = T/N; end
tgrid = getTimeScale(model,data,T);

% Formulate the NLP
for k=0:N-1
    if isfield(data, 'dt'), h = tgrid(k+2)-tgrid(k+1); end
    % New NLP variable for the control
    Uk = MX.sym(['U_' num2str(k)], model.nu);
    w = {w{:}, Uk};
    lbw = [lbw; model.umin];
    ubw = [ubw; model.umax];
    % State at collocation points
    Xkj = {};
    for j=1:d
        Xkj{j} = MX.sym(['X_' num2str(k) '_' num2str(j)], model.nx);
        w = [w, {Xkj{j}}];
        lbw = [lbw; model.xmin];
        ubw = [ubw; model.xmax];
    end
    
    % Loop over collocation points
    Xk_end = D(1)*Xk;
    for j=1:d
        % Expression for the state derivative at the collocation point
        xp = C(1,j+1)*Xk;
        for r=1:d
            xp = xp + C(r+1,j+1)*Xkj{r};
        end
        
        % Append collocation equations
        [fj, qj] = f(Xkj{j},Uk);
        g = {g{:}, h*fj - xp};
        lbg = [lbg; zeros(model.nx,1)];
        ubg = [ubg; zeros(model.nx,1)];
        
        % Add contribution to the end state
        Xk_end = Xk_end + D(j+1)*Xkj{j};
        
        % Add contribution to quadrature function
        J = J + B(j+1)*qj*h;
    end
    
    % New NLP variable for state at end of interval
    Xk = MX.sym(['X_' num2str(k+1)], model.nx);
    w = [w, {Xk}];
    lbw = [lbw; model.xmin];
    ubw = [ubw; model.xmax];
    % Add equality constraint
    if strcmpi(model.name,'10')
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
    g = [g, {Xk([model.dof.Tilt model.dof.RighArmY model.dof.LeftArmY model.dof.Somer])}  ];% model.dof.Twist])}  ];
    lbg = [lbg; -15/180*pi;  -inf;  120/180*pi; 2*pi-5*pi/180];%; -Inf];
    ubg = [ubg;  15/180*pi; -120/180*pi; inf; 2*pi+5*pi/180];%; -pi*3];
end

% Create an NLP solver
if strcmpi(data.obj, 'twist')
    o = Xk(model.dof.Twist)/(2*pi); 
elseif strcmpi(data.obj, 'twistPond') 
    if isfield(data.freeSomerSpeed, 'pond')
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
