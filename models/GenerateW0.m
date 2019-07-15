function w0 = GenerateW0(model, data, rep, QVU)

import casadi.*
umin = model.umin;
umax = model.umax;

xmin = model.xmin;
xmax = model.xmax;

tau_base = SX.zeros(6,1);
forDyn = @(x,u)[  x(model.idx_v)
    FDab_Casadi( model, x(model.idx_q), x(model.idx_v), vertcat(tau_base ,u)  )];
x = SX.sym('x', model.nx,1);
q = SX.sym('x', model.nq,1);
u = SX.sym('u', model.nu,1);
qdot = forDyn(x,u);
switch data.obj
    case 'twist', L = 0.5* (u'*u);  
    case 'torque', L = 0.5* (u'*u);  
    case 'trajectory', L = 0.5* (qdot(7:end,1)'*qdot(7:end,1));  
end
f = Function('f', {x, u}, {forDyn(x,u), L});

w0=[];
if numel(rep)>1
    w0_old = QVU;
    wh = isinf(umax);  umax(wh) = sign(umax(wh))*1000;
    wh = isinf(umin);  umax(wh) = sign(umax(wh))*1000;
    
    for k=0:data.Nint-1
        w0 = [w0; (model.umin+(model.umax-model.umin).*rand(size(model.umin)))];
        w0 = [w0; (xmin+(xmax-xmin).*rand(size(xmin)))];
    end
    
    w0_old(rep) = w0(rep);
    w0 = w0_old;
end
if strcmpi(data.NLPMethod, 'Collocation'), w0 = generateColl(model, data, rep, QVU, w0,f);
else, w0 = generateDMS(model, data, rep, QVU, w0);
end

end

% Generate initial guesses for Direct Multiple Shooting methods
function w0 = generateDMS(model, data, rep, QVU, w0)

if rep == 0 %w0 10 DoF taken from 8 DoF optimal solutions
    for k=0:data.Nint-1
        w0 = [w0;  data.u0(:,k+1)];
        w0 = [w0;  data.x0(:,k+2)];
    end
    if isfield(data,'timeL')
        t=data.timeL+(data.timeU-data.timeL)*rand(1);
        w0 = [t;w0];
    end
elseif rep==1
    for k=0:data.Nint-1
        w0 = [w0;  data.u0];
        w0 = [w0;  data.x0];
    end
    
    if ~isfield(data,'Duration')
        if isfield(data, 'timeL'), t=data.timeL+(data.timeU-data.timeL)*rand(1);
        else, t=0.9+0.2*rand(1); end
        w0 = [t;w0];
    end
else
    if ~isfield(data,'Duration')
        if isfield(data, 'timeL'), t=data.timeL+(data.timeU-data.timeL)*rand(1);
        else, t=0.9+0.2*rand(1); end
        w0 = [t;w0];
    end
    for k=0:data.Nint-1
        w0 = [w0;(model.umin+(model.umax-model.umin).*rand(size(model.umin)))];
        if ~isfield(data,'Duration'), w0 = [w0;generateCheck(model, data, QVU, k, w0u)];
        else, w0 = [w0;generateCheck(model, data, QVU, k, w0u, t)]; end
    end    
end

end

% Generate initial guesses for Direct Collocation Methods
function w0 = generateColl(model, data, rep, QVU, w0,f)

if rep==1
    for k=0:data.Nint-1
        w0 = [w0;  data.u0];
        if strcmpi(data.collocMethod, 'legendre')
            for i=1:data.degree
                w0 = [w0;  data.x0];
                w0 = [w0;  data.u0];
            end
        elseif strcmpi(data.collocMethod, 'hermite')
            w0 = [w0;  data.x0];
%             w0 = [w0;  data.u0];
        end
        w0 = [w0;  data.x0];
    end
    w0 = [w0;  data.u0];
    
    if ~isfield(data,'Duration')
        if isfield(data, 'timeL'), t=data.timeL+(data.timeU-data.timeL)*rand(1);
        else, t=0.9+0.2*rand(1); end
        w0 = [t;w0];
    end
else
    w0u1 = (model.umin+(model.umax-model.umin).*rand(size(model.umin)));
    for k=0:data.Nint-1
        w0u = w0u1;
        w0u1 = (model.umin+(model.umax-model.umin).*rand(size(model.umin)));
        if strcmpi(data.collocMethod, 'legendre')
            w0 = [w0;w0u];
            for i=1:data.degree
                w0 = [w0;generate(model, QVU, k)];
                w0 = [w0;(model.umin+(model.umax-model.umin).*rand(size(model.umin)))];
            end
        elseif strcmpi(data.collocMethod, 'hermite')
            w0 = [w0;w0u];
            w0 = [w0;  generate(model, QVU, k, 2)];
%             [w, w0u1] = generateH(model, QVU, k, w0u, w0u1,f);
%             w0 = [w0;w0u;w];
        else
            w0 = [w0;w0u];
        end
        w0 = [w0;  generate(model, QVU, k)];
    end
    w0 = [w0;w0u1];
    
    if ~isfield(data,'Duration')
        if isfield(data, 'timeL'), t=data.timeL+(data.timeU-data.timeL)*rand(1);
        else, t=0.9+0.2*rand(1); end
        w0 = [t;w0];
    end
end

end

function [w0_, w0u1] = generateH(model, QVU, k, w0u, w0u1,f)

w0_ = (model.xmin+(model.xmax-model.xmin).*rand(size(model.xmin)));

w0_(1:6)      = QVU(1:6   ,k+1,1)+randn(6,1);
w0_([1:6]+model.nq) = QVU([1:6]+model.nq,k+1,1)+randn(6,1);

wh0 = w0_< model.xmin;
w0_(wh0) = model.xmin(wh0);

wh0 = w0_ > model.xmax;
w0_(wh0) = model.xmax(wh0);

[x,L] = f(w0_, (w0u+w0u1)/2);
x = full(x);
disp(x);
while size(find(or(abs(x)>10000,isnan(x)))) > 0
    w0_ = (model.xmin+(model.xmax-model.xmin).*rand(size(model.xmin)));
    w0u1 = (model.umin+(model.umax-model.umin).*rand(size(model.umin)));
    
    w0_(1:6)      = QVU(1:6   ,k+1,1)+randn(6,1);
    w0_([1:6]+model.nq) = QVU([1:6]+model.nq,k+1,1)+randn(6,1);
    
    wh0 = w0_< model.xmin;
    w0_(wh0) = model.xmin(wh0);
    
    wh0 = w0_ > model.xmax;
    w0_(wh0) = model.xmax(wh0);
    
    [x,L] = f(w0_, (w0u+w0u1)/2);
    x = full(x);
end


end

function w0_ = generate(model, QVU, k, int)

w0_ = (model.xmin+(model.xmax-model.xmin).*rand(size(model.xmin)));

if nargin > 3
    w0_(1:6)      = QVU(1:6   ,(k+1)*2+1,1)+randn(6,1);
    w0_([1:6]+model.nq) = QVU([1:6]+model.nq,(k+1)*2+1,1)+randn(6,1);
else
    w0_(1:6)      = QVU(1:6   ,(k+1)*2,1)+randn(6,1);
    w0_([1:6]+model.nq) = QVU([1:6]+model.nq,(k+1)*2,1)+randn(6,1);
    
end

wh0 = w0_< model.xmin;
w0_(wh0) = model.xmin(wh0);

wh0 = w0_ > model.xmax;
w0_(wh0) = model.xmax(wh0);
end

% Function to generate initial guesses that do not lead to ODE divergence
% Only for Direct Multiple Shooting
function w0_ = generateCheck(model, data, QVU, k, w0u, t)
w0_ = (model.xmin+(model.xmax-model.xmin).*rand(size(model.xmin)));

w0_(1:6)      = QVU(1:6   ,k+1,1)+randn(6,1);
w0_([1:6]+model.nq) = QVU([1:6]+model.nq,k+1,1)+randn(6,1);

wh0 = w0_< model.xmin;
w0_(wh0) = model.xmin(wh0);

wh0 = w0_ > model.xmax;
w0_(wh0) = model.xmax(wh0);

if ~strcmpi(data.odeMethod, 'sundials')
    if isfield(data,'dt')
        if strcmpi(data.dt,'log')
            DT = (0.005+1/data.Nint*(1-fix(k*10/data.Nint)/data.Nint))*data.Duration;
        else
            DT = -log((k+1)/(data.Nint+1))/data.Nint*data.Duration;
        end
        [xi,~,~]= model.odeF(w0_,w0u,DT);
    elseif isfield(data, 'Duration')
        [xi,~,~]= model.odeF(w0_,w0u);
    else
        [xi,~,~]= model.odeF(w0_,w0u,t);
    end
    xi = full(xi);
    
    while size(find(or(abs(xi)>10000,isnan(xi)))) > 0
        w0u = (model.umin+(model.umax-model.umin).*rand(size(model.umin)));
        w0_ = (model.xmin+(model.xmax-model.xmin).*rand(size(model.xmin)));
        w0_(1:6)      = QVU(1:6   ,k+1,1)+randn(6,1);
        w0_([1:6]+model.nq) = QVU([1:6]+model.nq,k+1,1)+randn(6,1);
        
        wh0 = w0_< model.xmin;
        w0_(wh0) = model.xmin(wh0);
        wh0 = w0_ > model.xmax;
        w0_(wh0) = model.xmax(wh0);
        if isfield(data,'dt')
            if strcmpi(data.dt,'log')
                DT = (0.005+1/data.Nint*(1-fix(k*10/data.Nint)/data.Nint))*data.Duration;
            else
                DT = -log((k+1)/(data.Nint+1))/data.Nint*data.Duration;
            end
            [xi,~,~]= model.odeF(w0_,w0u,DT);
        elseif isfield(data, 'Duration')
            [xi,~,~]= model.odeF(w0_,w0u);
        else
            [xi,~,~]= model.odeF(w0_,w0u,t);
        end
        xi = full(xi);
    end
end
end
