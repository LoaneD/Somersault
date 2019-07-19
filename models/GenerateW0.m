function w0 = GenerateW0(model, data, rep, QVU, option)
% Generate initial guesses : 
% - if 1st simulation take initial values for each intervals step
% Then two options (random or interpolate in options input)
% - after take small variation of 1st solution for root values and random
% values within ranges for remaining DoF
% - take small variation of 1st solution for root values except Tz and
% somersault which are interpolated according to dynamics and random values
% within ranges for remaining DoF

% For DMS check whether the values choosen will lead to integration failing
% and select values that avoid it

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
if strcmpi(data.NLPMethod, 'Collocation'), w0 = generateColl(model, data, rep, QVU, w0, option);
else, w0 = generateDMS(model, data, rep, QVU, w0, option);
end

end

% Generate initial guesses for Direct Multiple Shooting methods
function w0 = generateDMS(model, data, rep, QVU, w0, option)

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
        else, t=0.95+0.1*rand(1); end
        w0 = [t;w0];
    end
else
    if ~isfield(data,'Duration')
        if isfield(data, 'timeL'), t=data.timeL+(data.timeU-data.timeL)*rand(1);
        else, t=0.95+0.1*rand(1); end
        w0 = [t;w0];
    end
    for k=0:data.Nint-1
        w0u = (model.umin+(model.umax-model.umin).*rand(size(model.umin)));
        w0 = [w0;w0u];
        if isfield(data,'Duration'), w0 = [w0;generateCheck(model, data, QVU, k, w0u, option)];
        else, w0 = [w0;generateCheck(model, data, QVU, k, w0u, option, t)]; end
    end    
end

end

% Generate initial guesses for Direct Collocation Methods
function w0 = generateColl(model, data, rep, QVU, w0, option)

if rep==1
    for k=0:data.Nint-1
        w0 = [w0;  data.u0];
        if strcmpi(data.collocMethod, 'legendre')
            for i=1:data.degree
                w0 = [w0;  data.x0];
                w0 = [w0;  data.u0];
            end
%         elseif strcmpi(data.collocMethod, 'hermite')
%             w0 = [w0;  data.x0];
%             w0 = [w0;  data.u0];
        end
        w0 = [w0;  data.x0];
    end
    w0 = [w0;  data.u0];
    
    if ~isfield(data,'Duration')
        if isfield(data, 'timeL'), t=data.timeL+(data.timeU-data.timeL)*rand(1);
        else, t=0.95+0.1*rand(1); end
        w0 = [t;w0];
    end
else
    if ~isfield(data,'Duration')
        if isfield(data, 'timeL'), t=data.timeL+(data.timeU-data.timeL)*rand(1);
        else, t=0.95+0.1*rand(1); end
        w0 = [t;w0];
        tg = getTimeScale(model,data,t);
    else
        tg = getTimeScale(model,data);
    end
    w0u1 = (model.umin+(model.umax-model.umin).*rand(size(model.umin)));
    for k=0:data.Nint-1
        w0u = w0u1;
        w0u1 = (model.umin+(model.umax-model.umin).*rand(size(model.umin)));
        if strcmpi(data.collocMethod, 'legendre')
            w0 = [w0;w0u];
            for i=1:data.degree
                w0 = [w0;generate(model, QVU, k*(1+data.degree)+i, option,tg)];
                w0 = [w0;(model.umin+(model.umax-model.umin).*rand(size(model.umin)))];
            end
            w0 = [w0;  generate(model, QVU, (k+1)*(1+data.degree), option,tg)];
%         elseif strcmpi(data.collocMethod, 'hermite')
%             w0 = [w0;w0u];
%             w0 = [w0;  generate(model, QVU, k*2+1, option,tg)];
%             w0 = [w0;  generate(model, QVU, 2*(k+1), option,tg)];
        else
            w0 = [w0;w0u];
            w0 = [w0;  generate(model, QVU, k+1, option,tg)];
        end
    end
    w0 = [w0;w0u1];
end

end

function w0_ = generate(model, QVU, k, option,tgrid)

w0_ = (model.xmin+(model.xmax-model.xmin).*rand(size(model.xmin)));
w0_(1:6)      = QVU(1:6   ,k+1,1)+randn(6,1);
w0_([1:6]+model.nq) = QVU([1:6]+model.nq,k+1,1)+randn(6,1);

% Interpolate initial guesses for vertical position and speed
if strcmpi(option, 'interpol')
    xzt = -0.5*9.81*tgrid(k+1)+QVU(model.dof.Tz+model.nq,1,1)*tgrid(k+1)+QVU(model.dof.Tz,1,1);
    vzt = -9.81*tgrid(k+1)+QVU(model.dof.Tz+model.nq,1,1);
    wsmt = QVU(model.dof.Twist+model.nq,1,1)*tgrid(k+1);
    w0_(model.dof.Tz) = xzt;
    w0_(model.dof.Tz+model.nq) = vzt;
    w0_(model.dof.Twist) = wsmt;
end
    
wh0 = w0_< model.xmin;
w0_(wh0) = model.xmin(wh0);

wh0 = w0_ > model.xmax;
w0_(wh0) = model.xmax(wh0);

end

% Function to generate initial guesses that do not lead to ODE divergence
% Only for Direct Multiple Shooting
function w0_ = generateCheck(model, data, QVU, k, w0u, option, t)

if isfield(data, 'Duration')
    tgrid = getTimeScale(model,data);
else
    tgrid = getTimeScale(model,data,t);
end

w0_ = generate(model, QVU, k, option,tgrid);

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
        w0_ = generate(model, QVU, k, option,tgrid);
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
