function model = GenerateODE_mex(model, data)

import casadi.*

tau_base = SX.zeros(6,1);
forDyn = @(x,u)[  x(model.idx_v)
    FDab_Casadi( model, x(model.idx_q), x(model.idx_v), vertcat(tau_base ,u)  )];
x = SX.sym('x', model.nx,1);
u = SX.sym('u', model.nu,1);
xu = vertcat(x, u);

xdot = forDyn(x,u);         % Model equations
f = Function('fun',{xu},{xdot});
opts = struct('main', true, 'mex', true);

if strcmpi(model.name, '8') 
    if ~isfile('ForDynC8.mexw64')
        C = CodeGenerator('ForDynC8.c', opts);
        C.add(f);
        C.add(f.jacobian); %ligne importante pour que la fonction de jac soit bien écrite
        C.generate();
        mex ForDynC8.c -largeArrayDims
    end
    funImporter = Importer('ForDynC8.mexw64', 'dll');
else
    if ~isfile('ForDynC10.mexw64')
        C = CodeGenerator('ForDynC10.c', opts);
        C.add(f);
        C.add(f.jacobian); %ligne importante pour que la fonction de jac soit bien écrite
        C.generate();
        mex ForDynC10.c -largeArrayDims
    end
    funImporter = Importer('ForDynC10.mexw64', 'dll');
end

funImporter.has_function('fun')      % 1
funImporter.has_function('jac_fun')  % 1

importedFun = external('fun', funImporter);
importedFun.print_dimensions % Input 0 ("i0"): 2x1, Output 0 ("o0"): 2x2

importedJac = external('jac_fun', funImporter);
importedJac.print_dimensions % Input 0 ("i0"): 2x1, Output 0 ("o0"): 4x2

x = MX.sym('x', model.nx,1);
q = SX.sym('q', model.nq,1);
u = MX.sym('u', model.nu,1);
xu = vertcat(x,u);
qdot = importedFun(xu);

fk = @(x)(forward_kinematics_MB(model,q));
model.ForKin = Function('ForKin',{q},{fk(x)},{'q'},{'Tags'});

fk2 = @(x)(forward_kinematics_MB2(model,q));
model.ForKin2 = Function('ForKin2',{q,},{fk2(x)},{'q'},{'Tags'});

switch data.obj
    case 'twist', L = 0.5* (u'*u); 
    case 'twistPond'
        if strcmpi(model.name, '10'), L = 10*(u([1 3])'*u([1 3]))+0.01*(u([2 4])'*u([2 4]));   
        else, L = 0.01*(u'*u);  
        end
    case 'torque', L = 0.5* (u'*u);  
    case 'trajectory', L = 0.5* (qdot(7:end,1)'*qdot(7:end,1));  
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
    f = Function('f', {x, u}, {importedFun(xu), L});
    
    X0 = MX.sym('X0', model.nx,1);
    Xi = MX.sym('Xi', model.nx,5);
    Xi(:,1) = X0;
   
    U =  MX.sym('U',  model.nu,1);
    X = X0;
    Q = 0;
    
    for j=1:M
       [k1, k1_q] = f(X, U);
       [k2, k2_q] = f(X + DT/M/2 * k1, U);
       [k3, k3_q] = f(X + DT/M/2 * k2, U);
       [k4, k4_q] = f(X + DT/M * k3, U);
        
        Xi(:,j+1) = Xi(:,j) + DT/6*(k1 +2*k2 +2*k3 +k4);
        
        X=X+DT/6*(k1 +2*k2 +2*k3 +k4);
        Q = Q + DT/6*(k1_q + 2*k2_q + 2*k3_q + k4_q);
    end
    if isfield(data, 'Duration')
%         model.odeF = Function('odeF', {X0, U}, {X, Q, Xi}, {'x0','p'}, {'xf', 'qf','x4'});
        model.odeF = Function('odeF', {X0, U}, {X, Q}, {'x0','p'}, {'xf', 'qf'});
    else
%         model.odeF = Function('odeF', {X0, U, t}, {X, Q, Xi}, {'x0','p', 't'}, {'xf', 'qf','x4'});
        model.odeF = Function('odeF', {X0, U, t}, {X, Q}, {'x0','p', 't'}, {'xf', 'qf'});
    end    
elseif isfield(data,'dt')
   % Fixed step Runge-Kutta 4 integrator
   M = 4; % RK4 steps per interval
   DT = SX.sym('DT', 1);%MICK
   
   f = Function('f', {x, u}, {importedFun(xu), L});
   X0 = MX.sym('X0', model.nx);
   Xi = MX.sym('Xi', model.nx,5);
   Xi(:,1) = X0;
   
   U =  MX.sym('U',  model.nu);   
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

   model.odeF = Function('odeF', {X0, U, DT}, {X, Q}, {'x0','p', 'DT'}, {'xf', 'qf'});
%    model.odeF = Function('odeF', {X0, U, DT}, {X, Q, Xi}, {'x0','p', 'DT'}, {'xf', 'qf','x4'});
 
end

end