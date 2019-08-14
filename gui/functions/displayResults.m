function displayResults(src,~)
% called when the display button is pushed

import casadi.*

obj = getOBJ(true, false);

% obj.results.sim = 1;
% if obj.fig.results.Value ~= 1 
%     obj.results.sim = str2num(obj.fig.sim.String{obj.fig.sim.Value});
% end
if src == obj.fig.anim
    if obj.fig.anim.Value ~= 0
        obj.fig.display.Enable = 'on';
    else 
        obj.fig.display.Enable = 'off';
    end
else
    obj = initialise(obj, 'clearFig');
    
    % change sim value when equal 0 to get the best solution
    if obj.fig.anim.Value == 3
        % add a variable in generate kinematics to know choose to display only arms
        obj = createToolBar(obj, 'on', false);
        if obj.fig.animPart.Value == 1
            generateKinematicsGUI(obj.model, obj.data, obj.results.QVU, obj.results.sim, obj.fig.axes, 'all');
        else
            generateKinematicsGUI(obj.model, obj.data, obj.results.QVU, obj.results.sim, obj.fig.axes, 'arms');
        end
    elseif obj.fig.anim.Value == 2
        % generate buttons to choose which DoF to study
        if obj.fig.animPart.Value == 1, start = 1;
        else, start = obj.model.dof.Twist + 1;
        end
        for i=start:obj.model.NB
            set(obj.fig.buttonDOF(i), 'Visible', 'on');
        end
    end
end
setOBJ(obj);

end