function optimisation(~,~,nbRep)

tic;
import casadi.*

for rep=1:nbRep
    obj = getOBJ(true, false);
    if obj.fig.STOP.Value == 1
        rep = rep-1;
        obj.term = 2;
        obj = initialise(obj, 'optDone');
        break;
    end
    % put Ry speed at 0 when 10 DoF
    if strcmpi(obj.model.name, '10') && strcmpi(obj.data.NLPMethod, 'MultipleShooting') && obj.data.Nint < 80
        type = 'vRy0';
    else
        type = 'x';
    end
    text = sprintf('Optimising... Repetition number %d/%d', rep, obj.opt.rep);
    set(obj.fig.labelWait, 'String', text);
    pos = get(obj.fig.hpanelBarIn, 'Position');
    set(obj.fig.hpanelBarIn, 'Position', [pos(1) pos(2) rep/obj.opt.rep-1/obj.opt.rep/2 1]);
    
    if rep == 1
        if isfield(obj.data, 'Duration')
            [obj.results.w0, obj.results.QVU, obj.opt.stat, obj.results.feasible, obj.results.t_opt, obj.opt.sol(rep)] = optim(obj.model, obj.data,...
                rep, obj.results.QVU, obj.opt.solver, obj.opt.lbw, obj.opt.ubw, obj.opt.lbg, obj.opt.ubg, [], [], [], struct, type);
        else
            [obj.results.w0, obj.results.QVU, obj.opt.stat, obj.results.feasible, ~, obj.opt.sol(rep)] = optim(obj.model, obj.data,...
                rep, obj.results.QVU, obj.opt.solver, obj.opt.lbw, obj.opt.ubw, obj.opt.lbg, obj.opt.ubg, 1, [], [], struct, type);
        end
    else
        if isfield(obj.data, 'Duration')
            [obj.results.w0, obj.results.QVU, obj.opt.stat, obj.results.feasible, obj.results.t_opt, obj.opt.sol(rep)] = optim(obj.model, obj.data,...
                rep, obj.results.QVU, obj.opt.solver, obj.opt.lbw, obj.opt.ubw, obj.opt.lbg, obj.opt.ubg, obj.results.t_opt, obj.results.w0, obj.results.feasible, obj.opt.stat, type);
        else
            [obj.results.w0, obj.results.QVU, obj.opt.stat, obj.results.feasible, ~, obj.opt.sol(rep)] = optim(obj.model, obj.data,...
                rep, obj.results.QVU, obj.opt.solver, obj.opt.lbw, obj.opt.ubw, obj.opt.lbg, obj.opt.ubg, 1, obj.results.w0, obj.results.feasible, obj.opt.stat, type);
        end
    end
    set(obj.fig.hpanelBarIn, 'Position', [pos(1) pos(2) rep/obj.opt.rep 1]);
    t = toc;
    if rep~=nbRep
        setOBJ(obj);
    end
    if t > str2double(obj.fig.time.String)*60
        obj.term = 1;
        break;
    end
end

obj.repDone = rep; %repetition up to which optimisation was done
msgOutput(obj);
if obj.repDone ~= 0
    obj = resultsOptimisation(obj);
end
obj = initialise(obj, 'optDone');
setOBJ(obj);

end