function  model = GenerateODE(model, data)

import casadi.*

tau_base = SX.zeros(6,1);
% forDyn = @(x,u)[  x(model.idx_v)
%     FDab_Casadi( model, x(model.idx_q).*model.Scaling.q, x(model.idx_v).*model.Scaling.v, vertcat(tau_base ,u.* model.Scaling.u)  )];
forDyn = @(x,u)[  x(model.idx_v)
    FDab_Casadi( model, x(model.idx_q), x(model.idx_v), vertcat(tau_base ,u)  )];


forDyn2 = @(x,u)[  x(model.idx_v)
    FDcrb_Casadi( model, x(model.idx_q), x(model.idx_v), vertcat(tau_base ,u)  )];

x = SX.sym('x', model.nx,1);
q = SX.sym('x', model.nq,1);
u = SX.sym('u', model.nu,1);
xu = vertcat(x,u);

fk = @(x)(forward_kinematics_MB(model,q));
model.ForKin = Function('ForKin',{q},{fk(x)},{'q'},{'Tags'});

fk2 = @(x)(forward_kinematics_MB2(model,q));
model.ForKin2 = Function('ForKin2',{q,},{fk2(x)},{'q'},{'Tags'});



% opts = struct('mex', true);
% f2 = Function('f2',{x,u},{forDyn2(x,u)},{'x','u'},{'xdot'});
% f2.generate('gen_ForDyn_crb.c', opts);
% type('gen_ForDyn_crb.c')
% 
% f1 = Function('f1',{x,u},{forDyn(x,u)},{'x','u'},{'xdot'});
% f1.generate('gen_ForDyn_aba.c', opts);
% type('gen_ForDyn_aba.c')
% 
% 
% 
% q = SX.sym('q', model.nq,1);
% v = SX.sym('v', model.nq,1);
% u = SX.sym('tau',model.nq-6,1);
% a = FDab_Casadi( model, q,v,vertcat(tau_base, u));
% a2 = FDcrb_Casadi( model, q,v,vertcat(tau_base, u));


% disp(forDyn(x0,u0))
% [H, C] = HandC( model, q0, v0 )   
% qdd = FDab_Casadi( model, q0, v0, tau0)

qdot = forDyn(x,u);         % Model equations

% Objective term
switch data.obj
    case 'twist', L = 0.5* (u'*u);  
    case 'torque', L = 0.5* (u'*u);  
    case 'trajectory', L = 0.5* (qdot(7:end,1)'*qdot(7:end,1));  
%     case 'u2', L = 0.5* (u'*u);  
%     case 'u2', L = 0.5* (u'*u);  
end


if strcmpi(data.odeMethod,'sundials')
   % CVODES from the SUNDIALS suite
   dae = struct('x',x,'p',u,'ode',forDyn(x,u),'quad',L);
   opts = struct('tf',data.Duration/data.Nint);
   model.odeF = integrator('F', 'cvodes', dae, opts);
elseif strcmpi(data.odeMethod,'rk4')
    % Fixed step Runge-Kutta 4 integrator
    M = 4; % RK4 steps per interval
    if isfield(data, 'Duration')
        DT = data.Duration/data.Nint/M;
    else
        t = SX.sym('t', 1);
        DT = t/data.Nint/M;
    end
    f = Function('f', {x, u}, {forDyn(x,u), L});
    %    f = Function('f', {x, u}, {forDyn2(x,u), L}); %for test
    X0 = SX.sym('X0', model.nx);
    Xi = SX.sym('Xi', model.nx,5);
    %    ki = SX.sym('ki', 4);%test
    Xi(:,1) = X0;
   
    U =  SX.sym('U',  model.nu);
    X = X0;
    Q = 0;
    
    for j=1:M
        [k1, k1_q] = f(X, U);
        [k2, k2_q] = f(X + DT/2 * k1, U);
        [k3, k3_q] = f(X + DT/2 * k2, U);
        [k4, k4_q] = f(X + DT * k3, U);
        
        Xi(:,j+1) = Xi(:,j) + DT/6*(k1 +2*k2 +2*k3 +k4);
        
        X=X+DT/6*(k1 +2*k2 +2*k3 +k4);
        Q = Q + DT/6*(k1_q + 2*k2_q + 2*k3_q + k4_q);
    end
    if isfield(data, 'Duration')
        model.odeF = Function('odeF', {X0, U}, {X, Q, Xi}, {'x0','p'}, {'xf', 'qf','x4'});
    else
        model.odeF = Function('odeF', {X0, U, t}, {X, Q, Xi}, {'x0','p', 't'}, {'xf', 'qf','x4'});
    end    
elseif strcmpi(data.odeMethod,'rk4_dt')
   % Fixed step Runge-Kutta 4 integrator
   M = 4; % RK4 steps per interval
   DT = SX.sym('DT', 1);%MICK
   f = Function('f', {x, u}, {forDyn(x,u), L});
%    f = Function('f', {x, u}, {forDyn2(x,u), L}); %for test
   X0 = SX.sym('X0', model.nx);
   Xi = SX.sym('Xi', model.nx,5);
   Xi(:,1) = X0;
   
   U =  SX.sym('U',  model.nu);   
   X = X0;
   Q = 0;
   for j=1:M
       [k1, k1_q] = f(X, U);
       [k2, k2_q] = f(X + DT/M/2 * k1, U);
       [k3, k3_q] = f(X + DT/M/2 * k2, U);
       [k4, k4_q] = f(X + DT/M * k3, U);
       
       Xi(:,j+1) = Xi(:,j) + DT/M/6*(k1 +2*k2 +2*k3 +k4);
       
       X=X+DT/M/6*(k1 +2*k2 +2*k3 +k4);
       Q = Q + DT/M/6*(k1_q + 2*k2_q + 2*k3_q + k4_q);
   end

   model.odeF = Function('odeF', {X0, U, DT}, {X, Q, Xi}, {'x0','p', 'DT'}, {'xf', 'qf','x4'});
 
end