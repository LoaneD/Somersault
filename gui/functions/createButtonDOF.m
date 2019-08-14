function obj = createButtonDOF(obj)

l = 0.99/obj.model.NB;
for i=1:obj.model.NB
    left = 0.01+(i-1)*l;
    width = 0.99*l;
    obj.fig.buttonDOF(i) = createUI(obj.fig.hpanelGraph,...
        int2str(i), [left 0.95 width 0.04],'pushbutton');
    set(obj.fig.buttonDOF(i), 'Visible', 'off');
    set(obj.fig.buttonDOF(i), 'Callback', @(src, event, dof)plotKinetics(src, event, i));
end

end