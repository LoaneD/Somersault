function setIntervalsNumb(src, event)

obj = getOBJ(true, false);

if src == obj.fig.nlp
    if src.Value == 1 && obj.fig.armR.Value == 1
        obj.fig.int.String = max(85, str2double(obj.fig.int.String));
    end
else
    if src.Value == 1
        obj.fig.nlp.Value = 2;
    end
end

% if src.Value == 1
%     obj.fig.int.String = '75';
% 	obj.fig.duration.String = 'free';
% 	obj.fig.duration.Enable = 'off';
% else
%     obj.fig.int.String = '30';
% 	obj.fig.duration.String = '1';
% 	obj.fig.duration.Enable = 'on';
% end

setOBJ(obj);

end