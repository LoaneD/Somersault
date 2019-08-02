% Script containing all functions used to display results
% Using model and data informations, results variables QVU and stat

% Need to create a structure containing all models to study
str = struct;
str.model = struct;
str.stat = struct;
str.QVU = [];
str.data = struct;
str.time = [];

% To get results within model (for each simulation) put only one element in
% structure
% To get results comparaison through models (comparing mean values) put all
% the models to study
models = createStruct(model10_8_30sCT);%list all models variables
datas = createStruct(data10_8_30);%list all datas variables
stats = createStruct(stat10_8_30);%list all stats variables
str = repmat(str, 1, size(models, 2));
str(1).QVU = QVU10_8_30sCT;%str(2).QVU = QVU10Pond_100;%list all QVU variables
str(1).time = ones(1,size(QVU10_8_30sCT,3));%str(2).time = ones(1,size(QVU10Pond_100,3));%to precise the time frame, if free time in model put topt obtained after optimization


for i=1:size(str, 2)
    str(i).model = models(i);
    str(i).data = datas(i);
    str(i).stat = stats(i);
    if isfield(datas(i), 'collocMethod') 
        if isfield(datas(i), 'degree')
            str(i).name = sprintf('%s DoF, %d NInt, t = %d s, Obj : %s, NLP : %s, Colloc : %s %d', ...
                models(i).name, datas(i).Nint, datas(i).Duration, datas(i).obj, datas(i).NLPMethod, datas(i).collocMethod, datas(i).degree);
        elseif datas(i).collocMethod ~= 0
            str(i).name = sprintf('%s DoF, %d NInt, t = %d s, Obj : %s, NLP : %s, Colloc : %s', ...
                models(i).name, datas(i).Nint, datas(i).Duration, datas(i).obj, datas(i).NLPMethod, datas(i).collocMethod);
        else
            str(i).name = sprintf('%s DoF, %d NInt, t = %d s, Obj : %s, NLP : %s', ...
                models(i).name, datas(i).Nint, datas(i).Duration, datas(i).obj, datas(i).NLPMethod);            
        end
    else
        if datas(i).Duration == 0, str(i).name = sprintf('%s DoF, %d Int, obj : %s, NLP : %s, ODE : %s' , ...
            models(i).name, datas(i).Nint, datas(i).obj, datas(i).NLPMethod, datas(i).odeMethod);
        else, str(i).name = sprintf('%s DoF, %d Int, t = %d s, obj : %s, NLP : %s, ODE : %s' , ...
            models(i).name, datas(i).Nint, datas(i).Duration, datas(i).obj, datas(i).NLPMethod, datas(i).odeMethod);
        end
    end
end

% Only for models using collocation 
outIntegrate = struct;
outIntegrate.errors = [];outIntegrate.xint = [];outIntegrate.xint_prop = [];outIntegrate.xt1 = [];
outIntegrate = repmat(outIntegrate, 1, size(str,2));
for i=1:size(str,2)%number of models
    if strcmpi(str(i).data.NLPMethod, 'Collocation'), outIntegrate(i) = getIntegratedSolution(str(i)); end
end
% Only one model :
% - Check the correspondance between solution (collocation approximation through polynomials)
% and integrated solution (integral at each state with solution points or
% propagated intergal calculating integration of state obtained with integration)
fig(1) = figure;fig(2) = figure;fig(3) = figure;
for i=1:size(str,2)%number of models
    % 3 figures needed
    if strcmpi(str(i).data.NLPMethod, 'Collocation'), checkCollocationErrors(str(i), outIntegrate(i), fig); end
    if i~=size(models, 2), pause; end
end

% Several models to compare :
% - Plot means of errors for each model
fig = figure;
% ErrorsInt : get mean error of every simulation for each time step
% ErrorsRep : get mean error of all time steps for each simulation
compareCollocationErrors(str, outIntegrate, 'ErrorsInt', fig,0);% 0 = only optimal solutions
compareCollocationErrors(str, outIntegrate, 'ErrorsInt', fig,1);% 1 = all solutions

% For all models 
% Only one model at a time:
% - Display all results one simulation at a time
fig = figure;
for i=1:size(str,2)
    disp(strcat('### Model: ', str(i).name, ' ###'));
    for rep=1:size(str(i).QVU,3)
        displayAllResults(str(i), rep, fig);
        pause;
    end
end

% - Display either arm movements or twist for all simulations
% Will plot all simulations, can become quickly unreadable if the number of
% simulations is too big. In that case add an input containing vector of
% simulations to print
% Either only when optimal found (mean calculated only for those)
fig = figure;
for i=1:size(str,2)
    disp(strcat('### Model: ', str(i).name, ' ###'));
    %ArmMovement Twisting
    results(str(i), 'ArmMovement', fig, 0);
    if i~= size(str,2), pause; end
end
% Or for all solutions (mean calculated for all)
fig = figure;
for i=1:size(str,2)
    disp(strcat('### Model: ', str(i).name, ' ###'));
    %ArmMovement Twisting
    results(str(i), 'Twisting', fig,0);
    if i~= size(str,2), pause; end
end

% - Display somersault/twisting number or solver return status
fig = figure;
for i=1:size(str,2)
    disp(strcat('### Model: ', str(i).name, ' ###'));
    %SomerNumber TwistNumber SolStat 
    results(str(i), 'TwistNumber', fig, 0);% 0 for only optimal solutions 1 for all
    if i~= size(str,2), pause; end
end


% Several models :
% - Compare arm movement/twist (mean and standard deviation at each state)
% or solver return status
% Either only for optimal solutions
fig = figure;
comparaisonModels(str, 'SolStat', fig, 0);%SolStat ComparaisonTwist ComparaisonArm
comparaisonModels(str, 'ComparaisonTwist', fig, 0);
% Or for all solutions
fig = figure;
comparaisonModels(str, 'ComparaisonArm', fig, 0);%SolStat ComparaisonTwist ComparaisonArm

% Display kinematics of optimal solution
fig = figure;
for i=1:size(str,2)
     disp(strcat('### Model: ', str(i).name, ' ###'));
    for rep=1:size(str(i).QVU,3)
        generateKinematics2(str(1), 5, fig(1));
    end
    if i~= size(str,2), pause; end
end

clear optStat
% Get statistics for each model and store it in a variable
for i=1:size(str,2)
    disp(strcat('### Model: ', str(i).name, ' ###'));
    optStat(i) = getOptimizationStat(str(i));
end