function terminateOptimisation(src, ~)

obj = getOBJ(true, false);
src.String = 'Stopping...';
src.Enable = 'inactive';
if strcmpi(obj.fig.labelWait.String, 'Creating model...')
    obj.fig.labelWait.String = 'Stopping...';
else
    obj.fig.labelWait.String = 'Stopping after this repetition...';
end
obj.stop = 1;
setOBJ(obj);
end