function out = getIntegratedSolution(str)

model = str.model;
data = str.data;
QVU = str.QVU;

import casadi.*

% create integrative function
tau_base = SX.zeros(6,1);
x = SX.sym('x', model.nx,1);
u = SX.sym('u', model.nu,1);
forDyn = @(x,u)[  x(model.idx_v)
    FDab_Casadi( model, x(model.idx_q), x(model.idx_v), vertcat(tau_base ,u)  )];
f = Function('f', {x, u}, {forDyn(x,u)});

% integrate collocation optimal solutions over each intervals
tgrid = getTimeScale(model,data);

errors = [];
xint = [];
for rep=1:size(QVU,3)
    xt1(:, 1, rep) = QVU(1:model.nx, 1, rep);
    xint_prop(:, 1, rep) = QVU(1:model.nx, 1, rep);
    xint_ = [];
    errors(:, 1, rep) = zeros(model.nx, 1);
    for i=1:size(QVU,2)-1
        xt = QVU(1:model.nx, i, rep);
        ut = QVU(model.nx+1:end, i, rep);
        DT = tgrid(i+1)-tgrid(i);
%         Fk = model.odeF('x0', xt, 'p', ut);
%         Fk_prop = model.odeF('x0', xt1(:,i,rep), 'p', ut);
%         xf = full(Fk.xf);
%         xf_prop = full(Fk_prop.xf);
        Fk = f(xt, ut);
        Fk_prop = f(xt1(:,i,rep), ut);
        xf = xt+full(Fk)*DT;
        xf_prop = xt1(:,i,rep)+full(Fk_prop)*DT;
        
        xint_ = [xint_ QVU(1:model.nx, i, rep),  xf(1:model.nx), nan(model.nx,1)];
        xt1(:, i+1, rep) = xf;
        xint_prop(:, i+1, rep) = xf_prop;
        errors(:, i+1, rep) = abs(xf-QVU(1:model.nx, i+1, rep));
    end
    xint(:,:,rep) = xint_;
end
out = struct;
out.xt1 = xt1;
out.xint = xint;
out.xint_prop = xint_prop;
out.errors = errors;

end