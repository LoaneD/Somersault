function displayAllResults(str, rep, fig)
% Display results for all DoF

QVU = str.QVU(:,:,rep);
model = str.model;
data = str.data;
time = str.time(rep);
name = str.name;
stat = str.stat;

clf(fig);
a = ceil(sqrt(model.nq+1));
b = ceil((model.nq+1) / a);
q_opt = QVU(model.idx_q,:);
v_opt = QVU(model.idx_v,:);
u_opt = QVU(model.nx+1:end,:);
tgrid = getTimeScale(model, data, time);

figure(fig);
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
hold off
legend('q','u','v')

subplot(a,b,i+1), stairs(tgrid, u_opt', '-')
legend(model.DOFname{7:end})
if data.Duration ~=0, sgtitle(fig, strcat(name, sprintf(' - rep n°%d - ',rep), stat.returnStat{rep}), 'Interpreter', 'none');
else, sgtitle(fig, strcat(name, sprintf(' t = %.4f s - rep n°%d - ',time, rep), stat.returnStat{rep}), 'Interpreter', 'none');
end
end