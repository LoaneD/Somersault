function setObjec(src, event)

obj = getOBJ(true, false);

if src == obj.fig.wsomerTOfree
    if obj.fig.wsomerTOfree.Value == 1
        set(obj.fig.obj2, 'Visible', 'on');
        set(obj.fig.obj, 'Visible', 'off');
        set(obj.fig.wsomerTO, 'Enable', 'off');
        set(obj.fig.wsomerTO_u, 'Enable', 'off');
    else
        set(obj.fig.obj2, 'Visible', 'off');
        set(obj.fig.obj, 'Visible', 'on');
        set(obj.fig.wsomerTO, 'Enable', 'on');
        set(obj.fig.wsomerTO_u, 'Enable', 'on');
    end
else
    set(obj.fig.obj2, 'Visible', 'off');
    set(obj.fig.obj, 'Visible', 'on');
    set(obj.fig.wsomerTO, 'Enable', 'on');
    set(obj.fig.wsomerTO_u, 'Enable', 'on');
end

setOBJ(obj);

end