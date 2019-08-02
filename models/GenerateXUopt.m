function [tgrid, q_opt, v_opt, u_opt, t_int, q_int, v_int] = GenerateXUopt(model, data, w_opt, plotOption)

%separate time constant or decreasing
if isfield(data, 'Duration')
    tgrid = getTimeScale(model, data);
else
    data.Duration = w_opt(1);
    tgrid = getTimeScale(model, data);
    w_opt = w_opt(2:end);
end
    
if isfield(data, 'collocMethod')
    u_opt = nan(model.nu, data.Nint+1); 
else
    u_opt = nan(model.nu, data.Nint); 
end
q_opt = nan(model.NB,data.Nint+1);
v_opt = nan(model.NB,data.Nint+1);


q_opt(:,1)=data.x0(model.idx_q);
v_opt(:,1)=data.x0(model.idx_v);

for i=1:model.nu
    if strcmpi(data.degree, 'quadratic'), u_opt(i,:) = w_opt(i:model.nx*2+model.nu:end)';
    else, u_opt(i,:) = w_opt(i:model.nx+model.nu:end)';
    end
end

for i=1:model.nq
    if strcmpi(data.degree, 'quadratic')
        q_opt(i,2:end) = w_opt(i+model.nu:model.nx+model.nu:end)';
        v_opt(i,2:end) = w_opt(i+model.nu+model.nq:model.nx+model.nu:end)';
    else
        q_opt(i,2:end) = w_opt(i+model.nu:model.nx+model.nu:end)';
        v_opt(i,2:end) = w_opt(i+model.nu+model.nq:model.nx+model.nu:end)';
    end
end
if ~isfield(data, 'collocMethod'), u_opt = [u_opt nan(model.nu,1)]; end

if nargin>3
    
    a = ceil(sqrt(model.nq+1)); 
    b = ceil((model.nq+1) / a); 
    
    for i=1:model.nq
        subplot(a,b,i), 
        yyaxis left,  plot(tgrid, q_opt(i,:)'*model.Unitcoef(i), '.--')
        ylabel(model.Unitname{i})
        hold on
        if i>6
            yyaxis right, stairs(tgrid, u_opt(i-6,:)', '-.')   
        end
        hold off
        
        yyaxis right, plot(tgrid, v_opt(i,:)'*model.Unitcoef(i), '.-')

        title(model.DOFname{i})
    end
    xlabel('t')
    legend('q','u','v')
    
    subplot(a,b,i+1), stairs(tgrid, u_opt', '-')   
    legend(model.DOFname{7:end})
    
end


if nargout>4

    t_int = [];
    q_int = [];
    v_int = []; 
    for i=1:data.Nint
      t_int = [t_int, tgrid(i) tgrid(i+1) tgrid(i+1)];
      Fk = model.odeF('x0', [q_opt(:,i);v_opt(:,i)], 'p', u_opt(:,i)); 
    %   disp(Fk.xf)
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

