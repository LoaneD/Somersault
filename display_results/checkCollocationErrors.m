function checkCollocationErrors(str, outIntegrate, fig, sim)

model = str.model;
data = str.data;
QVU = str.QVU;
name = str.name;

xt1 = outIntegrate.xt1;
xint = outIntegrate.xint;
xint_prop = outIntegrate.xint_prop;
errors = outIntegrate.errors;

if data.Duration ~= 0, tgrid = getTimeScale(model, data);
else, tgrid = getTimeScale(model, data, str.time(sim));
end
tint = [];
for i=1:size(QVU,2)-1
    tint = [tint, tgrid(i) tgrid(i+1) tgrid(i+1)];
end
a = ceil(sqrt(model.nq+1));
b = ceil((model.nq+1)/a);

if nargin < 7
    for rep=1:size(QVU,3)
        display(model, xt1, xint, xint_prop, errors, QVU, rep, tgrid, tint, a, b, fig, name);
        if nargin < 7 && rep~=size(QVU,3), pause; end
    end
else
    display(model, xt1, xint, xint_prop, errors, QVU, sim, tgrid, tint, a, b, fig, name);
end


end

function display(model, xt1, xint, xint_prop, errors, QVU, rep, tgrid, tint, a, b, fig, name)

clf(fig(1));
clf(fig(2));
clf(fig(3));

for i=1:model.nq
    % display optimal collocation solutions and integrated solutions (on each intervals
    % or propagated through all) without showing difference of value at end of each interval
    figure(fig(1));
    subplot(a,b,i);
    yyaxis left,  plot(tgrid, QVU(i,:,rep)'*model.Unitcoef(i), 'r-', 'DisplayName', 'q Collocation');
    hold on
    yyaxis left,  plot(tgrid, xt1(i,:,rep)'*model.Unitcoef(i), 'g-', 'DisplayName', 'q Integration');
    yyaxis left,  plot(tgrid, xint_prop(i,:,rep)'*model.Unitcoef(i), 'b-', 'DisplayName', 'q Integration Propagated');
    ylabel(model.Unitname{i})
    yyaxis right, plot(tgrid, QVU(i+model.nq,:,rep)'*model.Unitcoef(i), 'r:', 'DisplayName', 'v Collocation');
    yyaxis right, plot(tgrid, xt1(i+model.nq,:,rep)'*model.Unitcoef(i), 'g:', 'DisplayName', 'v Integration');
    yyaxis right,  plot(tgrid, xint_prop(i+model.nq,:,rep)'*model.Unitcoef(i), 'b:', 'DisplayName', 'v Integration Propagated');
    ylabel(strcat(model.Unitname{i},'/s'));
    hold off
    title(model.DOFname{i})
end
xlabel('t')
legend show
sgtitle(fig(1),strcat(name, sprintf(' - Rep n°%d', rep)));
for i=1:model.nq
    % display integrated solutions arrival points at end of interval n and
    % start points of interval n+1
    figure(fig(2));
    set(fig(2),'defaultAxesColorOrder',[[0 0 1]; [1 0 0]]);
    subplot(a,b,i);
    hold on
    yyaxis left,  plot(tint, xint(i,:,rep)'*model.Unitcoef(i), 'b-', 'DisplayName', 'q Integration');  
    yyaxis left,  plot(tgrid, QVU(i,:,rep)'*model.Unitcoef(i), 'b:', 'DisplayName', 'q Optimal');  
    ylabel(model.Unitname{i})
    yyaxis right, plot(tint, xint(i+model.nq,:,rep)'*model.Unitcoef(i), 'r-', 'DisplayName', 'v Integration');
    yyaxis right,  plot(tgrid, QVU(i+model.nq,:,rep)'*model.Unitcoef(i), 'r:', 'DisplayName', 'v Optimal');  
    ylabel(strcat(model.Unitname{i},'/s'));
    hold off
    title(model.DOFname{i})   
end
xlabel('t')
sgtitle(fig(2),strcat(name, sprintf(' - Rep n°%d', rep)));
legend show
for i=1:model.nq   
    % plot errors between interval n state arrival after integration and
    % initial state of interval n+1
    figure(fig(3));
    set(fig(3),'defaultAxesColorOrder',[[0 0 1]; [1 0 0]]);
    subplot(a,b,i);
    hold on
    yyaxis left,  plot(tgrid, errors(i,:,rep)'*model.Unitcoef(i),'b-', 'DisplayName', 'q Error');  
    ylabel(model.Unitname{i})
    yyaxis right, plot(tgrid, errors(i+model.nq,:,rep)'*model.Unitcoef(i), 'r-', 'DisplayName', 'v Error');  
    ylabel(strcat(model.Unitname{i},'/s'));
    hold off
    title(model.DOFname{i})    
end
xlabel('t')
sgtitle(fig(3),strcat(name, sprintf(' - Rep n°%d', rep)));
legend show
end