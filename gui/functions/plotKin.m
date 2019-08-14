function plotKin(dof, model, data, w_opt, f, t)

if isfield(data, 'Duration')
    tgrid = getTimeScale(model, data);
else
    data.Duration = w_opt(1);
    tgrid = getTimeScale(model, data);
    w_opt = w_opt(2:end);
end
    
nint = data.Nint+1;
if strcmpi(data.NLPMethod, 'Collocation')
    if strcmpi(data.collocMethod, 'legendre')
        nint = nint + data.Nint*data.degree;
    end
end
u_opt = nan(model.nu, nint);
q_opt = nan(model.NB,nint);
v_opt = nan(model.NB,nint);

if size(w_opt(1+model.nu:model.nx+model.nu:end)) < nint
    q_opt(:,1)=data.x0(model.idx_q);
    v_opt(:,1)=data.x0(model.idx_v);
    st = 2;
else
    st = 1;
end
if strcmpi(data.NLPMethod, 'Collocation') && strcmpi(data.collocMethod, 'legendre')
    for i=0:data.Nint-1
        u_opt(:,1+(1+data.degree)*i) = w_opt(1+i*(model.nu+model.nx*(data.degree+1)):model.nu+i*(model.nu+model.nx*(data.degree+1)),1);
        for j=1:data.degree
            u_opt(:,1+(1+data.degree)*i+j) = w_opt(1+i*(model.nu+model.nx*(data.degree+1)):model.nu+i*(model.nu+model.nx*(data.degree+1)),1);
        end
    end
else
    for i=1:model.nu
        if strcmpi(data.NLPMethod, 'Collocation')
            u_opt(i,:) = w_opt(i:model.nx+model.nu:end)';
        else, u_opt(i,1:end-1) = w_opt(i:model.nx+model.nu:end)';
        end
    end
end

for i=1:model.nq
    if strcmpi(data.NLPMethod, 'Collocation') && strcmpi(data.collocMethod, 'legendre')
        for j=0:data.Nint-1
            q_opt(i,st+j*(data.degree+1)) = w_opt(i+model.nu+j*(model.nx*(data.degree+1)),1);
            v_opt(i,st+j*(data.degree+1)) = w_opt(i+model.nu+model.nq+j*(model.nx*(data.degree+1)),1);
            for k=1:data.degree
                q_opt(i,st+k+j*(data.degree+1)) = w_opt(i+model.nu+model.nx*k,1);
                v_opt(i,st+k+j*(data.degree+1)) = w_opt(i+model.nu+model.nq+model.nx*k,1);
            end
        end
    else
        q_opt(i,st:end) = w_opt(i+model.nu:model.nx+model.nu:end)';
        v_opt(i,st:end) = w_opt(i+model.nu+model.nq:model.nx+model.nu:end)';
    end
end

yyaxis left,  plot(f, tgrid, q_opt(dof,:)'*model.Unitcoef(dof), '.--')
ylabel(model.Unitname{dof})
hold on
if dof>6
    yyaxis right, stairs(f, tgrid, u_opt(dof-6,:)', '-.')
end
hold off

yyaxis right, plot(f, tgrid, v_opt(dof,:)'*model.Unitcoef(dof), '.-')
xlabel('t')
legend('q','u','v')
% title(model.DOFname{dof})
end