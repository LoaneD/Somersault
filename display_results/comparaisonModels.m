function comparaisonModels(str, type, fig, nonOpt, varargin)
clf(fig)
% compare number model simulations
% if for one of the model no optimal was found, indicate it

% not working if data structure don't have same form


color = [0.9 0.098 0.294;0.235 0.7058 0.294;0 0.509 0.784;0.96 0.509 0.188;0.98 0.745 0.745;1 0.882 0.980];

s.meanArm = [];
s.stdArmU = [];
s.stdArmD = [];
s.meanTwist = [];
s.stdTwistU = [];
s.stdTwistD = [];
s.armsDoF = [];
s.t = [];
s.optRep = [];
store = repmat(s, 1, size(str, 2));

sizeDoF = str(1).model.NB-6;
sim10 = 0;
listOutputs = {'Solve_Succeeded', 'Infeasible_Problem_Detected',...
    'Maximum_Iterations_Exceeded', 'Solved_To_Acceptable_Level', 'Other'};

outputValues = zeros(size(str,2), 5);
for i=1:size(str,2)
    optRepN = [];
    rep_number(i) = size(str(i).QVU,3);
    for j=1:rep_number(i)
        if strcmpi(str(i).stat.returnStat{j}, 'Solve_Succeeded')
            outputValues(i,1) = outputValues(i,1) + 1;
        elseif strcmpi(str(i).stat.returnStat{j}, 'Infeasible_Problem_Detected')
            outputValues(i,2) = outputValues(i,2) + 1;
        elseif strcmpi(str(i).stat.returnStat{j}, 'Maximum_Iterations_Exceeded')
            outputValues(i,3) = outputValues(i,3) + 1;
        elseif strcmpi(str(i).stat.returnStat{j}, 'Solved_To_Acceptable_Level')
            outputValues(i,4) = outputValues(i,4) + 1;
        else
            outputValues(i,5) = outputValues(i,5) + 1;
        end
        if strcmpi(str(i).stat.returnStat{j}, 'Solve_Succeeded') ||...
                    strcmpi(str(i).stat.returnStat{j}, 'Solved_To_Acceptable_Level')
        	optRepN = [optRepN j];
        end
    end
    optRepBound = [];
    if nargin > 8
        for k=1:size(optRepN, 2)
            if -str(i).QVU(str(i).model.dof.Twist,end,optRepN(k))*str(i).model.Unitcoef(str(i).model.dof.Twist)...
                    > varargin{1}
                optRepBound = [optRepBound optRepN(k)];
            end
        end
        store(i).optRep = optRepBound;
    else
        store(i).optRep = optRepN;
    end
    outputValues(i,:) = outputValues(i,:)*100/rep_number(i);
    if str(i).data.Duration == 0, store(i).t = getTimeScale(str(i).model, str(i).data, mean(str(i).time));
    else, store(i).t = getTimeScale(str(i).model, str(i).data);
    end
    dof10(i) = 0;
    if strcmpi(str(i).model.name,'10')
        dof10(i) = 1; 
        sizeDoF = str(i).model.NB-6;
        sim10 = i;
    end
    store(i).armsDoF = (str(i).model.dof.RighArmY-dof10(i)):str(i).model.dof.LeftArmY;
end 

% for now intuite that only 10 DoF models are compared
switch type
    case 'ComparaisonTwist'
        % create arrays with arm position mean values over time
        for i=1:size(str,2)
            for j=1:str(i).data.Nint+1
                coefTwist = str(i).model.Unitcoef(str(i).model.dof.Twist);
                if nonOpt
                    store(i).meanTwist(j) = -mean(str(i).QVU(str(i).model.dof.Twist, j, :)*coefTwist);
                    store(i).stdTwistU(j) = store(i).meanTwist(j) + std(str(i).QVU(str(i).model.dof.Twist, j, :)*coefTwist);
                    store(i).stdTwistD(j) = store(i).meanTwist(j) - std(str(i).QVU(str(i).model.dof.Twist, j, :)*coefTwist);
                else
                    store(i).meanTwist(j) = -mean(str(i).QVU(str(i).model.dof.Twist, j, store(i).optRep)*coefTwist);
                    store(i).stdTwistU(j) = store(i).meanTwist(j) + std(str(i).QVU(str(i).model.dof.Twist, j, store(i).optRep)*coefTwist);
                    store(i).stdTwistD(j) = store(i).meanTwist(j) - std(str(i).QVU(str(i).model.dof.Twist, j, store(i).optRep)*coefTwist);
                end
            end
        end
        figure(fig);
        hold on
        xlabel('Time (s)');
        ylabel(str(1).model.Unitname(str(1).model.dof.Twist));
        for j=1:size(str,2)
            plot(store(j).t, store(j).meanTwist,'Color', color(j,:), 'LineStyle', '-', 'DisplayName', str(j).name);
            plot(store(j).t, store(j).stdTwistU,'Color', color(j,:), 'LineStyle', ':', 'HandleVisibility', 'off');
            plot(store(j).t, store(j).stdTwistD,'Color', color(j,:), 'LineStyle', ':', 'DisplayName', 'Standard Deviation');
        end
        hold off
        if ~nonOpt, txt = ' - only Optimal Solutions';
        else, txt = ''; end
        sgtitle(fig, strcat('Mean of twisting evolution over repetitions', txt));
        legend show
        leg = findobj(gcf, 'Type', 'Legend');
        set(leg, 'Interpreter', 'none');
       
    case 'ComparaisonArm'
        % create arrays with arm position mean values over time
        for i=1:size(str,2)
            for j=1:str(i).data.Nint+1
                for k=1:size(store(i).armsDoF,2)
                    if nonOpt
                        store(i).meanArm(k,j) = mean(str(i).QVU(store(i).armsDoF(k), j, :)*str(i).model.Unitcoef(store(i).armsDoF(k)));
                        store(i).stdArmU(k,j) = store(i).meanArm(k,j) + std(str(i).QVU(store(i).armsDoF(k), j, :)*str(i).model.Unitcoef(store(i).armsDoF(k)));
                        store(i).stdArmD(k,j) = store(i).meanArm(k,j) - std(str(i).QVU(store(i).armsDoF(k), j, :)*str(i).model.Unitcoef(store(i).armsDoF(k)));
                    else
                        store(i).meanArm(k,j) = mean(str(i).QVU(store(i).armsDoF(k), j, store(i).optRep)*str(i).model.Unitcoef(store(i).armsDoF(k)));
                        store(i).stdArmU(k,j) = store(i).meanArm(k,j) + std(str(i).QVU(store(i).armsDoF(k), j, store(i).optRep)*str(i).model.Unitcoef(store(i).armsDoF(k)));
                        store(i).stdArmD(k,j) = store(i).meanArm(k,j) - std(str(i).QVU(store(i).armsDoF(k), j, store(i).optRep)*str(i).model.Unitcoef(store(i).armsDoF(k)));
                    end
                end
            end
        end
        for i=1:sizeDoF
            figure(fig);
            subplot(2,sizeDoF/2,i);
            hold on
            xlabel('Time (s)');
            ylabel(str(max(1, sim10)).model.Unitname(store(max(1, sim10)).armsDoF(i)));
            title(str(max(1, sim10)).model.DOFname(store(max(1, sim10)).armsDoF(i)));
            for j=1:size(str,2)
                if size(store(j).armsDoF,2) == sizeDoF || i == 2 || i == 4
                    if size(store(j).armsDoF,2) ~= sizeDoF, i=i/2; end
                    plot(store(j).t, store(j).meanArm(i,:),'Color', color(j,:), 'LineStyle', '-', 'DisplayName', str(j).name);
                    plot(store(j).t, store(j).stdArmU(i,:), 'Color', color(j,:), 'LineStyle', ':', 'HandleVisibility', 'off');
                    plot(store(j).t,store(j).stdArmD(i,:), 'Color', color(j,:), 'LineStyle', ':', 'DisplayName', 'Standard Deviation');
                end
            end
            hold off
        end
        if ~nonOpt, txt = ' - only Optimal Solutions';
        else, txt = ''; end
        sgtitle(fig, strcat('Mean of arm position over repetitions', txt));
        legend show
        leg = findobj(gcf, 'Type', 'Legend');
        set(leg, 'Interpreter', 'none');
        
    case 'SolStat'
        figure(fig);
%         cat = categorical(listOutputs);
        b = bar(outputValues');
        set(gca,'xticklabel',listOutputs);
        ylabel('Percentage');
        title('Outputs of all simulations for each model');
        legend(b, str.name);
        leg = findobj(gcf, 'Type', 'Legend');
        set(leg, 'Interpreter', 'none');
end

end