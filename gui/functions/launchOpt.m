function launchOpt()
obj = getOBJ(true, false);

% stopped by exceeding time
if obj.term == 1
    obj.launchOpt = questdlg('Maximum time allowed exceeded...', '', ...
        'OK');
% stopped by user
elseif obj.term == 2
    obj.launchOpt = questdlg('');
else
    obj.launchOpt = questdlg('Model created, launch optimisation?', '', ...
        'YES', 'NO', 'YES');
end

if obj.term == 2 || obj.term == 1
    waitbar(0, obj.opt.h, 'Stopping model creation and optimisation');
    pause(0.5)
    delete(obj.opt.h)
else
    obj =  optimisation(obj);
end
msgOutput(obj);
if obj.repDone ~= 0
    obj = resultsOptimisation(obj);
end
obj = initialise(obj, 'optDone');

setOBJ(obj);

end