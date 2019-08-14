function loadGUI()

% % Création de la figure
    obj.fig.hfig = figure('Name', 'Somersault on trampoline optimisation',...
        'Unit', 'normalize', 'Position', [0.05 0.05 .9 .9], 'MenuBar', 'none',...
        'CloseRequestFcn', @(src,event)terminate(), 'NumberTitle', 'off', 'ToolBar', 'none');

    obj = createGUI(obj, 'off');
    
% % Store data created
    setOBJ(obj);

end