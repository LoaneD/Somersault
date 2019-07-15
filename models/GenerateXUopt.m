function [tgrid, q_opt, v_opt, u_opt, t_int, q_int, v_int] = GenerateXUopt(model, data, w_opt, plotOption)

%separate time constant or decreasing
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
    elseif strcmpi(data.collocMethod, 'hermite')
        nint = nint + data.Nint;
        tgrid = getTimeScale(model, data);
    end
end
u_opt = nan(model.nu, nint);
q_opt = nan(model.NB,nint);
v_opt = nan(model.NB,nint);

if strcmpi(data.NLPMethod, 'Collocation') && strcmpi(data.collocMethod, 'hermite')
    q_opt(:,1)=data.x0(model.idx_q);
    v_opt(:,1)=data.x0(model.idx_v);
    u_opt(:,1) = w_opt(1:model.nu);
    for i=1:data.Nint
        u_opt(:,i*2) = (w_opt((model.nu+model.nx*2)*i+1:(model.nu+model.nx*2)*i+model.nu)+w_opt((model.nu+model.nx*2)*(i-1)+1:(model.nu+model.nx*2)*(i-1)+model.nu))/2;        
        q_opt(:,i*2) = w_opt((model.nu+model.nx*2)*(i-1)+model.nu+1:(model.nu+model.nx*2)*(i-1)+model.nu+model.nq);
        v_opt(:,i*2) = w_opt((model.nu+model.nx*2)*(i-1)+model.nu+1+model.nq:(model.nu+model.nx*2)*(i-1)+model.nu+model.nx);
        
        u_opt(:,i*2+1) = w_opt((model.nu+model.nx*2)*(i-1)+1:(model.nu+model.nx*2)*(i-1)+model.nu);
        q_opt(:,i*2+1) = w_opt((model.nu+model.nx*2)*(i-1)+model.nu+model.nx+1:(model.nu+model.nx*2)*(i-1)+model.nu+model.nx+model.nq);
        v_opt(:,i*2+1) = w_opt((model.nu+model.nx*2)*(i-1)+model.nu+model.nx+1+model.nq:(model.nu+model.nx*2)*(i-1)+model.nu+model.nx+model.nx);
    end
else
    if size(w_opt(1+model.nu:model.nx+model.nu:end)) < nint
        q_opt(:,1)=data.x0(model.idx_q);
        v_opt(:,1)=data.x0(model.idx_v);
    end
    for i=1:model.nu
        if strcmpi(data.NLPMethod, 'Collocation'), u_opt(i,:) = w_opt(i:model.nx+model.nu:end)';
        else, u_opt(i,1:end-1) = w_opt(i:model.nx+model.nu:end)';
        end
    end
    
    for i=1:model.nq
        if size(w_opt(1+model.nu:model.nx+model.nu:end)) < nint
            q_opt(i,2:end) = w_opt(i+model.nu:model.nx+model.nu:end)';
            v_opt(i,2:end) = w_opt(i+model.nu+model.nq:model.nx+model.nu:end)';
        else
            q_opt(i,:) = w_opt(i+model.nu:model.nx+model.nu:end)';
            v_opt(i,:) = w_opt(i+model.nu+model.nq:model.nx+model.nu:end)';
        end
    end
end

if nargin>3
    
    a = ceil(sqrt(model.nq+1)); 
    b = ceil((model.nq+1) / a); 
    
    for i=1:model.nq
        subplot(a,b,i), 
        yyaxis left,  plot(tgrid, q_opt(i,:)'*model.Unitcoef(i), '.--', 'DisplayName', 'q')
        ylabel(model.Unitname{i})
        hold on
        if i>6
            yyaxis right, stairs(tgrid, u_opt(i-6,:)', '-.', 'DisplayName', 'u')
        end
        
        yyaxis right, plot(tgrid, v_opt(i,:)'*model.Unitcoef(i), '.-', 'DisplayName', 'v')
        hold off

        title(model.DOFname{i})
    end
    xlabel('t')
    legend('q','u','v')
    
%     subplot(a,b,i+1), stairs(tgrid, u_opt', '-')   
    legend(model.DOFname{7:end})
    
end


if nargout>4

    t_int = [];
    q_int = [];
    v_int = []; 
    for i=1:nint
      t_int = [t_int, tgrid(i) tgrid(i+1) tgrid(i+1)];
      Fk = model.odeF('x0', [q_opt(:,i);v_opt(:,i)], 'p', u_opt(:,i)); 
      xf = full(Fk.xf);

      q_int = [q_int, q_opt(:,i),  xf(model.idx_q), nan(model.nq,1)];
      v_int = [v_int, v_opt(:,i),  xf(model.idx_v), nan(model.nq,1)];
    end
    if nargin>3 
        for i=1:model.nq
            subplot(a,b,i)
            yyaxis left,
            hold on
            plot(t_int, q_int(i,:)*model.Unitcoef(i),'b-')
            hold off
            
           
            yyaxis right,  
            hold on
            plot(t_int, v_int(i,:)*model.Unitcoef(i),'r-')
            hold off
        end
            legend('q','u','v', 'q_{int}', 'v_{int}')

    end
end

