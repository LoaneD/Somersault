function results(str, type, fig, nonOpt, replist)
% display different results for several repetitions of a model simulation

QVU = str.QVU;
model = str.model;
data = str.data;
stat = str.stat;
name = str.name;

if nargin == 5
    rep_vect = replist;
    rep_number = size(replist,2); 
else
    rep_number = size(QVU,3); 
    rep_vect=1:rep_number;
end
if data.Duration ~= 0
    t=[];
    for i=1:rep_number
        t = [t;getTimeScale(model, data)];
    end
else
    t=[];
    for i=1:rep_number
        t = [t;getTimeScale(model, data, str.time(rep_vect(i)))];
    end
end
% get list of repetition where optimal solution was found
optRep = [];
listOutputs = {'Solve_Succeeded', 'Infeasible_Problem_Detected',...
    'Maximum_Iterations_Exceeded', 'Solved_To_Acceptable_Level'};
for i=1:rep_number
    if strcmpi(stat.returnStat{rep_vect(i)}, 'Solve_Succeeded') ||...
            strcmpi(stat.returnStat{rep_vect(i)}, 'Solved_To_Acceptable_Level')
        optRep = [optRep rep_vect(i)];
    end
end

if size(optRep, 2) > 0 || nonOpt
    clf(fig)
    coefTwist = model.Unitcoef(model.dof.Twist);
    coefSomer = model.Unitcoef(model.dof.Somer);
    coefLeftAY = model.Unitcoef(model.dof.LeftArmY);
    coefRightAY = model.Unitcoef(model.dof.RighArmY);
    
    meanArmPosYL = []; meanArmPosYR = [];
    dof10 = 0;
    if strcmpi(model.name, '10')
        dofLeftArmZ = model.dof.LeftArmY-1;
        dofRighArmZ = model.dof.RighArmY-1;
        coefLeftAZ = model.Unitcoef(dofLeftArmZ);
        coefRighAZ = model.Unitcoef(dofRighArmZ);
        meanArmPosZL = [];
        meanArmPosZR = [];
        dof10 = 1;
    end
    % get mean values
    % dependent on the order of arms dof in the model
    for i=1:size(QVU, 2)
        if nonOpt
            meanArmPosYL = [meanArmPosYL;mean(QVU(model.dof.LeftArmY,i,:))*coefLeftAY];
            meanArmPosYR = [meanArmPosYR;mean(QVU(model.dof.RighArmY,i,:))*coefRightAY];
            if dof10
                meanArmPosZL = [meanArmPosZL;mean(QVU(dofLeftArmZ,i,:))*coefLeftAZ];
                meanArmPosZR = [meanArmPosZR;mean(QVU(dofRighArmZ,i,:))*coefRighAZ];
            end
        else
            meanArmPosYL = [meanArmPosYL;mean(QVU(model.dof.LeftArmY,i,optRep))*coefLeftAY];
            meanArmPosYR = [meanArmPosYR;mean(QVU(model.dof.RighArmY,i,optRep))*coefRightAY];
            if dof10
                meanArmPosZL = [meanArmPosZL;mean(QVU(dofLeftArmZ,i,optRep))*coefLeftAZ];
                meanArmPosZR = [meanArmPosZR;mean(QVU(dofRighArmZ,i,optRep))*coefRighAZ];
            end
        end
    end
    if dof10
        meanArmPos = [meanArmPosZR meanArmPosYR meanArmPosZL meanArmPosYL];
        coefArm = [coefRighAZ coefRightAY coefLeftAZ coefLeftAY];
    else
        meanArmPos = [meanArmPosYR meanArmPosYL];
        coefArm = [coefRightAY coefLeftAY];
    end
    
    meanTwist = mean(QVU(model.dof.Twist,size(QVU,2),:))*coefTwist*ones(1, rep_number);
    meanSomer = mean(QVU(model.dof.Somer,size(QVU,2),:))*coefSomer*ones(1, rep_number);
    
    meanTwistOpt = mean(QVU(model.dof.Twist,size(QVU,2),optRep))*coefTwist*ones(1, rep_number);
    meanSomerOpt = mean(QVU(model.dof.Somer,size(QVU,2),optRep))*coefSomer*ones(1, rep_number);
    
    
    switch type
        % display all arm movements along the mean of position through time
        case 'ArmMovement'
            armsDoF = model.dof.RighArmY-dof10:model.dof.LeftArmY;
            figure(fig);
            for i = 1:rep_number
                if ismember(rep_vect(i), optRep) || nonOpt
                    for j = 1:size(armsDoF,2)
                        if strcmpi(stat.returnStat{rep_vect(i)},'Solve_Succeeded') || ...
                                strcmpi(stat.returnStat{rep_vect(i)},'Solved_To_Acceptable_Level'), sol = 'Optimal';
                        else, sol = 'Non Optimal';
                        end
                        subplot(2,dof10+1,j)
                        plot(t(i,:), QVU(armsDoF(j), :, rep_vect(i))*coefArm(j), 'DisplayName', strcat(sprintf('rep n°%d - twist = %f - ',rep_vect(i), -QVU(model.dof.Twist, end, rep_vect(i))*coefTwist), sol));
                        hold on
                        xlabel('Time (s)');
                        ylabel(model.Unitname(armsDoF(j)));
                        title(model.DOFname(armsDoF(j)));
                    end
                end
            end
            for j = 1:size(armsDoF,2)
                subplot(2,dof10+1,j)
                if nonOpt, plot(t(i,:), meanArmPos(:,j)', 'k:', 'DisplayName', sprintf('Mean Movement - Twist Mean = %f', -meanTwist(end)));
                else, plot(t(i,:), meanArmPos(:,j)', 'k:', 'DisplayName', sprintf('Mean Movement - Twist Mean = %f', -meanTwistOpt(end)));
                end
            end
            hold off
            sgtitle(fig, name, 'Interpreter', 'none');
            legend show
            leg = findobj(gcf, 'Type', 'Legend');
            set(leg, 'Interpreter', 'none');
            % display twist value at end of simulation for all repetition
        case 'TwistNumber'
            figure(fig);
            twist = [];
            for i=1:rep_number
                twist = [twist -QVU(model.dof.Twist, size(QVU,2), rep_vect(i))*coefTwist];
            end
            plot(rep_vect, twist, 'k-', 'DisplayName', 'Twist');
            hold on
            plot(rep_vect, -meanTwist, 'r:', 'DisplayName', 'Mean');
            plot(rep_vect, -meanTwistOpt, 'g:', 'DisplayName', 'Mean Optimal');
            xlabel('Repetitions');
            ylabel(model.Unitname(model.dof.Twist));
            title(strcat('Number of twist at the end of simulation - ', name));
            plot(optRep, twist(1,optRep), 'ko', 'DisplayName', 'Optimal');
            hold off
            legend show
            leg = findobj(gcf, 'Type', 'Legend');
            set(leg, 'Interpreter', 'none');
            % display somersault value at end of simulation for all repetition
        case 'SomerNumber'
            figure(fig);
            somer = [];
            for i=1:rep_number
                somer = [somer QVU(model.dof.Somer, size(QVU,2), rep_vect(i))*coefSomer];
            end
            plot(rep_vect, somer, 'k-', 'DisplayName', 'Somersault');
            hold on
            plot(rep_vect, meanSomer, 'r:', 'DisplayName', 'Mean');
            plot(rep_vect, meanSomerOpt, 'g:', 'DisplayName', 'Mean Optimal');
            xlabel('Repetitions');
            ylabel(model.Unitname(model.dof.Somer));
            title(strcat('Number of twist at the end of simulation - ', name));
            plot(optRep, somer(1,optRep), 'ko', 'DisplayName', 'Optimal');
            hold off
            legend show
            leg = findobj(gcf, 'Type', 'Legend');
            set(leg, 'Interpreter', 'none');
            % display return status for all simulations
        case 'SolStat'
            figure(fig);
            s = categorical(stat.returnStat,listOutputs);
            histogram(s,'Categories', listOutputs);
            xlabel('Return Status');
            ylabel('Number of Simulations');
            title(sprintf('Outputs of all simulations - %d percent optimal solution found - %s', ...
                size(optRep, 2)*100/rep_number, name));
            % display twist evolution through time
        case 'Twisting'
            figure(fig);
            meanAll = [];
            meanOpt = [];
            for j=1:size(QVU,2)
                meanAll = [meanAll mean(QVU(model.dof.Twist,j,:))*coefTwist];
                meanOpt = [meanOpt mean(QVU(model.dof.Twist,j,optRep))*coefTwist];
            end
            for i=1:rep_number
                hold on
                if nonOpt || ismember(rep_vect(i), optRep)
                    plot(t(rep_vect(i),:), -QVU(model.dof.Twist, :, rep_vect(i))*coefTwist, 'DisplayName', strcat(sprintf('Rep n°%d - ', rep_vect(i)),stat.returnStat{rep_vect(i)}));
%                 else
%                     plot(t(i,:), -QVU(model.dof.Twist, :, i)*coefTwist, 'DisplayName', strcat(sprintf('Rep n°%d - ', i),stat.returnStat{i}));
                end
            end
            if nonOpt, plot(t(rep_vect(1),:), -meanAll, 'k:', 'DisplayName', 'Mean of All Solutions'); end
            plot(t(rep_vect(1),:), -meanOpt, 'k-.', 'DisplayName', 'Mean of Optimal Solutions');
            xlabel('Time (s)');
            ylabel(model.Unitname(model.dof.Twist));
            title(strcat('Twisting during simulation - ', name));
            hold off
            legend show
            leg = findobj(gcf, 'Type', 'Legend');
            set(leg, 'Interpreter', 'none');
    end
else
    disp('No optimal solutions found for this model.');
end

end