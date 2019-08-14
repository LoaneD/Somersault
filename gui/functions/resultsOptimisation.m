function obj = resultsOptimisation(obj)

% get only the simulation where an optimal solution was found
obj = filterOptimalSol(obj);

% display results and options panel
repDone = sprintf('Optimal solution found: %d/%d', size(obj.opt.listOpt,2), obj.repDone);
set(obj.fig.labelRepDone, 'Visible', 'on');
set(obj.fig.labelRepDone, 'String', repDone);
if obj.term == 2
    labelStop = sprintf('Stopped by user command, %d/%d done', obj.repDone, obj.opt.rep);
    set(obj.fig.labelStopReason, 'Visible', 'on');
    set(obj.fig.labelStopReason, 'String', labelStop);
elseif obj.term == 1
    labelStop = sprintf('Reached maximum time, %d/%d done', obj.repDone, obj.opt.rep);
    set(obj.fig.labelStopReason, 'Visible', 'on');
    set(obj.fig.labelStopReason, 'String', labelStop);
end
obj = createButtonDOF(obj);

% get ordered list of simulation from best to worst
% one with all and one with the ones over 95%

% obj = onAndOffResults(obj, 'on');
obj = orderResults(obj);
if size(obj.opt.listOpt,2) ~= obj.repDone, set(obj.fig.showNO, 'Enable', 'on'); end
% set values of best repetition
% display it directly only if there are optimal solution
if size(obj.opt.listOpt,2) ~= 0
    index = find(obj.results.listValues(:,1) == str2double(obj.results.best));
    obj.results.bestSim = str2double(obj.results.best);
    obj.results.bestSimStr = obj.results.best;
    obj.results.bestScore = num2str(obj.results.listValues(index,2));
    obj.results.bestPercent = num2str(obj.results.listValues(index,3));
    obj = onAndOffResults(obj, 'on', 'best'); 
else
    index = find(obj.results.listValues(:,1) == str2double(obj.results.bestNO{2}));
    obj.results.bestSim = str2double(obj.results.bestNO{2});
    obj.results.bestSimStr = obj.results.bestNO{1};
    obj.results.bestScore = num2str(obj.results.listValues(index,2));
    obj.results.bestPercent = num2str(obj.results.listValues(index,3));
end
    
end