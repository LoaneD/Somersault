function handleToolBar(src, ~, type)

obj = getOBJ(true, false);
togglestate = src.Value;

if strcmpi(type, 'rot')
    switch togglestate
        case 1
            % Toggle on, turn on zoom
            rotate3d(obj.fig.axes, 'on')
        case 0
            % Toggle off, turn off zoom
            rotate3d(obj.fig.axes, 'off')
    end
elseif strcmpi(type, 'pause')
    % add a function enabling to pause the running simulation
    switch togglestate
        case 1
            uiwait();
        case 0
            uiresume();
    end
end
setOBJ(obj);

end