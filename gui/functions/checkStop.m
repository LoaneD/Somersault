function tf = checkStop(obj)

% obj = getOBJ(true, false);

if obj.fig.STOP.Value == 1
%     disp(false);
    tf = false;
else
    disp(true);
    tf = true;
end

% setOBJ(obj);

end