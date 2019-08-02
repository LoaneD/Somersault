function [w0, QVU, stat, feasible, t_opt, obj] = optim(model, data, rep, QVU, solver, lbw, ubw, lbg, ubg, t_opt, w0, feasible, stat, type, varargin)
% If type = interpol the initial guesses are interpolated through dynamics
% for Tz and somersault
% If type = vRy0 initial guesses random and speed Ry equals 0

epsilon = 1e-12;
if nargin > 15
    QVUb = varargin{1}; modelb = varargin{2}; datab = varargin{3};
    if size(QVUb,3) > 1
        q_opt = QVUb(1:modelb.nq,:,rep);
        v_opt = QVUb(modelb.nq+1:modelb.nx,:,rep);
        u_opt = QVUb(modelb.nx+1:modelb.nx+modelb.nu,:,rep);
        q0 = zeros(model.nq, datab.Nint+1);
        v0 = zeros(model.nq, datab.Nint+1);
        u0 = zeros(model.nu, datab.Nint+1);
    else
        q_opt = QVUb(1:modelb.nq,:,1);
        v_opt = QVUb(modelb.nq+1:modelb.nx,:,1);
        u_opt = QVUb(modelb.nx+1:modelb.nx+modelb.nu,:,1);
        q0 = zeros(model.nq, datab.Nint+1);
        v0 = zeros(model.nq, datab.Nint+1);
        u0 = zeros(model.nu, datab.Nint+1);
    end
    if model.nx == modelb.nx
        q0 = q_opt;
        v0 = v_opt;
        u0 = u_opt;
    else
        q0([1:6 8 10],:) = q_opt;
        v0([1:6 8 10],:) = v_opt;
        u0([2 4],:) = u_opt;
    end
    data.x0 = [q0;v0]; data.u0 = u0;
    w0(:,rep) = GenerateW0(modelb,data,0, QVUb, type);
elseif nargin == 15
    w0(:,rep) = varargin{1};
    if strcmpi(type, 'vRy0')
        for i=0:data.Nint-1
            w0(i*(model.nx+model.nu)+model.nu+model.nq+model.dof.RighArmY,rep)=0;
            w0(i*(model.nx+model.nu)+model.nu+model.nq+model.dof.LeftArmY,rep)=0;
        end
    end
else
    w0(:,rep) = GenerateW0(model,data,rep, QVU, type);
    if rep > 1
        if strcmpi(type, 'vRy0')
            for i=0:data.Nint-1
                w0(i*(model.nx+model.nu)+model.nu+model.nq+model.dof.RighArmY,rep)=0;
                w0(i*(model.nx+model.nu)+model.nu+model.nq+model.dof.LeftArmY,rep)=0;
            end
        end
    end
end
sol{rep} = solver('x0', w0(:,rep), 'lbx', lbw, 'ubx', ubw,...
    'lbg', lbg, 'ubg', ubg);
stat.returnStat{rep} = solver.stats().return_status;
stat.iter(rep) = solver.stats().iter_count;
obj = full(sol{rep}.f);
w_opt = full(sol{rep}.x);
solt = sol{rep};
save('C:\\Users\p1238838\Documents\MATLAB\spatial_v2\workspaces\results\sol.mat',...
    'solt')
if ~isfield(data, 'Duration')
    t_opt(rep) = w_opt(1);
end
[tgrid, q_opt, v_opt, u_opt] = ...
    GenerateXUopt(model, data, w_opt);
QVU(:,:,rep) = [q_opt; v_opt; u_opt];
g = full(sol{rep}.g);
feasible(:,:,rep) = [g <= ubg+epsilon , g >= lbg-epsilon];


end