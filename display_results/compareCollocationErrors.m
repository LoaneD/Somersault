function compareCollocationErrors(str, outIntegrate, type, fig, nonOpt)
% plot for each model the errors at the end of each intervals between
% integrated solution and optimal

color = [0.635 0.078 0.184;0.301 0.745 0.933;0.466 0.674 0.188;...
    0.85 0.325 0.098;0 0.447 0.74;0.25 0.25 0.25];

dofnb = str(1).model.nq;
values = struct;
% get the sum of errors for each repetition of each model
for i=1:size(str, 2)
    optRep = [];
    repnb(i) = size(outIntegrate(i).errors,3);
    values(i).tgrid = linspace(0, str(i).data.Duration, str(i).data.Nint+1);
    for j=1:repnb(i)
        if strcmpi(str(i).stat.returnStat{j}, 'Solve_Succeeded') ||...
                strcmpi(str(i).stat.returnStat{j}, 'Solved_To_Acceptable_Level')
            optRep = [optRep j];
        end
    end
    values(i).optRep = optRep;
    if str(i).model.nq > dofnb, dofnb = str(i).model.nq; end
    for j=1:str(i).data.Nint+1
        for k=1:str(i).model.nx
            if nonOpt
                values(i).meanErrorsInt(k ,j) = mean(outIntegrate(i).errors(k,j,:));
            else
                values(i).meanErrorsInt(k ,j) = mean(outIntegrate(i).errors(k,j,values(i).optRep));
            end
        end
    end
    for k=1:str(i).model.nx
        meanV = [];
        for j=1:repnb(i)
            meanV = [meanV mean(outIntegrate(i).errors(k,:,j))];
        end
        values(i).meanErrorsRep(k,:) = meanV;
    end
end

switch type
    case 'ErrorsRep'
        clf(fig)
        figure(fig);
        a = ceil(sqrt(dofnb+1));
        b = ceil((dofnb+1)/a);
        for i=1:dofnb
            subplot(a,b,i);
            for j=1:size(str, 2)
                if str(j).model.nq >= i
                    hold on
                    yyaxis left,  plot(1:repnb(j), values(j).meanErrorsRep(i,:)'*str(j).model.Unitcoef(i), 'Color', color(j,:), 'LineStyle', '-', 'DisplayName', strcat('q-', str(j).name));
                    if ~nonOpt, plot(values(j).optRep, values(j).meanErrorsRep(i,values(j).optRep)'*str(j).model.Unitcoef(i), 'ko', 'DisplayName', 'Optimal'); end
                    ylabel(str(j).model.Unitname{i})
                    yyaxis right, plot(1:repnb(j), values(j).meanErrorsRep(i+str(j).model.nq,:)'*str(j).model.Unitcoef(i), 'Color', color(j,:), 'LineStyle', ':', 'DisplayName', strcat('v-', str(j).name));
                    ylabel(strcat(str(j).model.Unitname{i},'/s'))
                    title(str(j).model.DOFname{i})
                end
            end
            xlabel('Repetition');
            hold off
        end
        sgtitle(fig, 'Mean of errors (integration Vs. optimal solution) over all time intervals')
        legend show
        leg = findobj(gcf, 'Type', 'Legend');
        set(leg, 'Interpreter', 'none');
    case 'ErrorsInt'
        clf(fig)
        figure(fig);
        a = ceil(sqrt(dofnb+1));
        b = ceil((dofnb+1)/a);
        for i=1:dofnb
            subplot(a,b,i);
            for j=1:size(str, 2)
                if str(j).model.nq >= i
                    hold on
                    yyaxis left,  plot(values(j).tgrid, values(j).meanErrorsInt(i,:)'*str(j).model.Unitcoef(i), 'Color', color(j,:), 'LineStyle', '-', 'DisplayName', strcat('q-', str(j).name));
                    ylabel(str(j).model.Unitname{i})
                    yyaxis right, plot(values(j).tgrid, values(j).meanErrorsInt(i+str(j).model.nq,:)'*str(j).model.Unitcoef(i), 'Color', color(j,:), 'LineStyle', ':', 'DisplayName', strcat('v-', str(j).name));
                    ylabel(strcat(str(j).model.Unitname{i},'/s'))
                    hold off
                    title(str(j).model.DOFname{i})
                end
            end
            xlabel('Time (s)');
        end
        if nonOpt, sgtitle(fig, 'Mean of errors (integration Vs. optimal solution) over all repetitions');
        else, sgtitle(fig, 'Mean of errors (integration Vs. optimal solution) over optimal repetitions');
        end
        legend show
        leg = findobj(gcf, 'Type', 'Legend');
        set(leg, 'Interpreter', 'none');
end


end