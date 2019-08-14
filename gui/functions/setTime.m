function setTime(src, ~)

obj = getOBJ(true, false);

if src.Value == 0
    obj.fig.freedTime1.Visible = 'off';
    obj.fig.freedTime2.Visible = 'off';
    obj.fig.freedTime3.Visible = 'off';
    obj.fig.freedTime4.Visible = 'off';
    obj.fig.fixedTime.Enable = 'on';
else
    obj.fig.freedTime1.Visible = 'on';
    obj.fig.freedTime2.Visible = 'on';
    obj.fig.freedTime3.Visible = 'on';
    obj.fig.freedTime4.Visible = 'on';
    obj.fig.fixedTime.Enable = 'off';
end

setOBJ(obj);

end