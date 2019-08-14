function obj = createToolBar(obj, visible, creation)

if creation    
    obj.fig.rotate3D = createUI(obj.fig.hpanelGraph,'Rotate',[0.45 0.95 0.1 0.04],'togglebutton');
    set(obj.fig.rotate3D, 'Visible', visible);
    set(obj.fig.rotate3D, 'Value', 0);
    
    obj.fig.pause = createUI(obj.fig.hpanelGraph,'Pause',[0.56 0.95 0.1 0.04],'togglebutton');
    set(obj.fig.pause, 'Visible', visible);
    set(obj.fig.pause, 'Value', 0);
end
set(obj.fig.rotate3D, 'Visible', visible);
set(obj.fig.pause, 'Visible', visible);
set(obj.fig.rotate3D, 'Callback', @(src, event, type)handleToolBar(src, event, 'rot'));
set(obj.fig.pause, 'Callback', @(src, event, type)handleToolBar(src, event, 'pause'));
    
    
end