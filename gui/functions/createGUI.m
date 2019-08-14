function obj = createGUI(obj, results)
    

    obj.firstLaunch = true;
    obj.font = 'Times New Roman';

% % Presentation and launching buttons
    obj.fig.GO = createUI(obj.fig.hfig, 'LAUNCH', [0.1 0.09 0.1 0.05],...
        'pushbutton');
    set(obj.fig.GO, 'Callback', @(src,event)prepareOptimisation(src,event));
    set(obj.fig.GO, 'ForegroundColor',[0.4660 0.6740 0.1880], 'FontWeight',...
        'bold', 'FontSize', get(obj.fig.GO, 'FontSize')*1.1, 'FontName', obj.font);  
    obj.fig.STOP = createUI(obj.fig.hfig, 'STOP', [0.3 0.09 0.1 0.05],...
        'togglebutton');
    set(obj.fig.STOP, 'Callback', @(src,event)terminateOptimisation(src,event));
    set(obj.fig.STOP, 'ForegroundColor', [0.8500 0.3250 0.0980], 'FontWeight',...
        'bold', 'FontSize', get(obj.fig.GO, 'FontSize')*1.1, 'FontName', obj.font);
    
    obj.fig.title = createUI(obj.fig.hfig, 'Somersault Optimisation', [0.05 0.93 0.34 0.05], 'text');
    set(obj.fig.title, 'FontSize', obj.fig.title.FontSize*2.5, 'ForegroundColor', [0.6350 0.0780 0.1840],...
        'FontWeight', 'bold', 'FontName', obj.font, 'horizontalalignment', 'center');
    
    obj.fig.reini = createUI(obj.fig.hfig, 'Reinitialise', [0.26 0.87 0.18 0.048], 'pushbutton');
    set(obj.fig.reini, 'Callback', @(src, event) reinit(src, event));
    
% % Create panels to contain variables
    obj.fig.hpanelTakeOff = uipanel(obj.fig.hfig, 'Units', 'normalize', 'Title', 'Take-off',...
        'Position', [0.01 0.45 0.24 0.48], 'FontUnits', 'normalize', 'FontSize', 0.05, 'FontName', obj.font);   
    obj.fig.hpanelLanding = uipanel(obj.fig.hfig, 'Units', 'normalize', 'Title', 'Landing',...
        'Position', [0.26 0.61 0.18 0.25], 'FontUnits', 'normalize', 'FontSize', 0.1, 'FontName', obj.font);  
    obj.fig.hpanelTime = uipanel(obj.fig.hfig, 'Units', 'normalize', 'Title', 'Options',...
        'Position', [0.26 0.45 0.18 0.15], 'FontUnits', 'normalize', 'FontSize', 0.16, 'FontName', obj.font);  
    obj.fig.hpanelOpt = uipanel(obj.fig.hfig, 'Units', 'normalize', 'Title', 'Optimisation',...
        'Position', [0.01 0.15 0.27 0.29], 'FontUnits', 'normalize', 'FontSize', 0.08, 'FontName', obj.font); 
    obj.fig.hpanelModel = uipanel(obj.fig.hfig, 'Units', 'normalize', 'Title', 'Model',...
        'Position', [0.29 0.15 0.15 0.29], 'FontUnits', 'normalize', 'FontSize', 0.08, 'FontName', obj.font);  
    obj.fig.hpanelResults = uipanel(obj.fig.hfig, 'Units', 'normalize', 'Title', 'Results',...
        'Position', [0.45 0.86 0.54 0.13], 'FontUnits', 'normalize', 'FontSize', 0.17, 'FontName', obj.font);  
    obj.fig.hpanelGraph = uipanel(obj.fig.hfig, 'Units', 'normalize',...
        'Position', [0.45 0.17 0.54 0.68], 'FontUnits', 'normalize', 'FontSize', 0.05, 'FontName', obj.font);  
    obj.fig.hpanelOptions = uipanel(obj.fig.hfig, 'Units', 'normalize', 'Title', 'Display options',...
        'Position', [0.45 0.01 0.54 0.15], 'FontUnits', 'normalize', 'FontSize', 0.15, 'FontName', obj.font); 
    obj.fig.hpanelBar = uipanel(obj.fig.hfig, 'Units', 'normalize', 'BorderType', 'none',...
        'Position', [0.01 0.01 0.42 0.07]); 
    obj.fig.hpanelBarOut = uipanel(obj.fig.hpanelBar, 'Units', 'normalize', 'Position', [0.001 0.15 1 0.4]);%,...
%         'BorderType', 'line', 'HighlightColor', [0.25 0.25 0.25]);
    obj.fig.hpanelBarIn = uipanel(obj.fig.hpanelBarOut, 'Units', 'normalize', 'BorderType', 'none',...
        'Position', [0 0 0.5 1], 'BackgroundColor', [0.4660 0.6740 0.1880]);
    
    obj.fig.labelWait = createUI(obj.fig.hpanelBar,'Optimising... ', [0.01 0.55 0.99 0.4], 'text');
    set(obj.fig.labelWait, 'ForegroundColor', [0.4660 0.6740 0.1880], 'FontName', obj.font);
    set(obj.fig.labelWait, 'horizontalalignment', 'center');
    set(obj.fig.labelWait, 'FontSize', get(obj.fig.labelWait, 'FontSize'), 'FontWeight', 'bold');
    
    % % Fill each panel
    % Take-off
    obj.fig.height = uicontrol(obj.fig.hpanelTakeOff, 'Units', 'normalize',...
        'Style', 'text', 'String', 'Height: ', 'horizontalalignment', 'left', 'FontName', obj.font, 'FontSize', 10);
    size = get(obj.fig.height, 'position');
    set(obj.fig.height, 'position', [0.01 0.74 0.4 size(4)]);
    obj.fig.heightTO = createUI(obj.fig.hpanelTakeOff, '0', [0.44 0.74 0.09 size(4)], 'edit');
    createUI(obj.fig.hpanelTakeOff, 'm', [0.55 0.74 0.12 size(4)], 'text');
    
    createUI(obj.fig.hpanelTakeOff, 'Duration: ', [0.01 0.85 0.4 size(4)], 'text');
    obj.fig.duration = createUI(obj.fig.hpanelTakeOff, '1', [0.44 0.85 0.09 size(4)], 'edit');
    createUI(obj.fig.hpanelTakeOff, 's', [0.55 0.85 0.12 size(4)], 'text');
    obj.fig.durfree = createUI(obj.fig.hpanelTakeOff, 'FREE', [0.68 0.85 0.3 size(4)], 'text');
    set(obj.fig.durfree, 'ForegroundColor', [0 0.4470 0.7410]);
    
    createUI(obj.fig.hpanelTakeOff, 'Somersault: ', [0.01 0.63 0.4 size(4)], 'text');
    obj.fig.somerTO = createUI(obj.fig.hpanelTakeOff, '0', [0.44 0.63 0.09 size(4)], 'edit');
    obj.fig.somerTO_u = createUI(obj.fig.hpanelTakeOff, {'rev', '°', 'rad'}, [0.55 0.64 0.18 size(4)*0.9], 'popupmenu');
    
    createUI(obj.fig.hpanelTakeOff, 'Twist: ', [0.01 0.52 0.4 size(4)], 'text');
    obj.fig.twistTO = createUI(obj.fig.hpanelTakeOff, '0', [0.44 0.52 0.09 size(4)], 'edit');
    obj.fig.twistTO_u = createUI(obj.fig.hpanelTakeOff, {'rev', '°', 'rad'}, [0.55 0.53 0.18 size(4)*0.9], 'popupmenu');
    
    createUI(obj.fig.hpanelTakeOff, 'Horizontal Speed: ', [0.01 0.41 0.4 size(4)], 'text');
    obj.fig.vhTO = createUI(obj.fig.hpanelTakeOff, '0', [0.44 0.41 0.09 size(4)], 'edit');
    createUI(obj.fig.hpanelTakeOff, 'm/s', [0.55 0.41 0.12 size(4)], 'text');

    createUI(obj.fig.hpanelTakeOff, 'Vertical Speed: ', [0.01 0.3 0.4 size(4)], 'text');
    obj.fig.vvTO = createUI(obj.fig.hpanelTakeOff, '4.9', [0.44 0.3 0.09 size(4)], 'edit');
    createUI(obj.fig.hpanelTakeOff, 'm/s', [0.55 0.3 0.12 size(4)], 'text');
    obj.fig.vvTOfree = createUI(obj.fig.hpanelTakeOff, 'FREE', [0.68 0.3 0.3 size(4)], 'text');
    set(obj.fig.vvTOfree, 'ForegroundColor', [0 0.4470 0.7410]);

    createUI(obj.fig.hpanelTakeOff, 'Somersault Rotation: ', [0.01 0.19 0.4 size(4)], 'text');
    obj.fig.wsomerTO = createUI(obj.fig.hpanelTakeOff, '6.3', [0.44 0.19 0.09 size(4)], 'edit');
    obj.fig.wsomerTO_u = createUI(obj.fig.hpanelTakeOff, {'rad/s', '°/s', 'rev/s'}, [0.55 0.2 0.18 size(4)*0.9], 'popupmenu');
    obj.fig.wsomerTOfree = createUI(obj.fig.hpanelTakeOff,'Free',...
        [0.75 0.19 0.25 size(4)],'checkbox',0);
    set(obj.fig.wsomerTOfree, 'Callback', @(src,event)setObjec(src,event));
    
    createUI(obj.fig.hpanelTakeOff, 'Twist Rotation: ', [0.01 0.08 0.4 size(4)], 'text');
    obj.fig.wtwistTO = createUI(obj.fig.hpanelTakeOff, '0', [0.44 0.08 0.09 size(4)], 'edit');
    obj.fig.wtwistTO_u = createUI(obj.fig.hpanelTakeOff, {'rad/s', '°/s', 'rev/s'}, [0.55 0.09 0.18 size(4)*0.9], 'popupmenu');
    
    
    % Landing
    % see how to put heigth upon landing
    obj.fig.height = uicontrol(obj.fig.hpanelLanding, 'Units', 'normalize',...
        'Style', 'text', 'String', 'Height: ', 'horizontalalignment', 'left', 'FontName', obj.font, 'FontSize', 10);
    size = get(obj.fig.height, 'position');
    set(obj.fig.height, 'position', [0.01 0.78 0.40 size(4)]);
    obj.fig.heightL = createUI(obj.fig.hpanelLanding, '0', [0.45 0.78 0.15 size(4)], 'edit');
    createUI(obj.fig.hpanelLanding, '±', [0.61 0.78 0.05 size(4)], 'text');
    obj.fig.heightRL = createUI(obj.fig.hpanelLanding,...
        {'inf', '0.05 m', '0.1 m', '0.2 m', '0.5 m'}, [0.67 0.78 0.27 size(4)], 'popupmenu');
    obj.menu.height = [Inf, 0.05, 0.1, 0.2, 0.5];
    
    obj.menu.rad = [Inf, 0.0873, 0.1745, 0.2618];
    createUI(obj.fig.hpanelLanding, 'Somersault: ', [0.01 0.54 0.4 size(4)], 'text');
    obj.fig.somerL = createUI(obj.fig.hpanelLanding, '1', [0.45 0.54 0.15 size(4)], 'edit');
    createUI(obj.fig.hpanelLanding, '±', [0.61 0.54 0.05 size(4)], 'text');
    obj.fig.somerRL = createUI(obj.fig.hpanelLanding,...
        {'inf', '5°', '10°', '15°'}, [0.67 0.54 0.27 size(4)], 'popupmenu');
    
    obj.menu.rev = [Inf, 0.05, 0.1, 0.2, 0.5];
    createUI(obj.fig.hpanelLanding, 'Twist: ', [0.01 0.29 0.4 size(4)], 'text');
    obj.fig.twistL = createUI(obj.fig.hpanelLanding, '0', [0.45 0.29 0.15 size(4)], 'edit');
    createUI(obj.fig.hpanelLanding, '±', [0.61 0.29 0.05 size(4)], 'text');
    obj.fig.twistRL = createUI(obj.fig.hpanelLanding,...
        {'inf', '0.05 rev', '0.1 rev', '0.2 rev', '0.5 rev'}, [0.67 0.29 0.27 size(4)],'popupmenu');

    obj.menu.deg = [Inf, 0, 10, 15, 20];
    createUI(obj.fig.hpanelLanding, 'Tilt: ', [0.01 0.04 0.4 size(4)], 'text');
    obj.fig.tiltL = createUI(obj.fig.hpanelLanding, '0', [0.45 0.04 0.15 size(4)], 'edit');
    createUI(obj.fig.hpanelLanding, '±', [0.61 0.04 0.05 size(4)], 'text');
    obj.fig.tiltRL = createUI(obj.fig.hpanelLanding,...
        {'inf', '0°', '10°','15°', '20°'}, [0.67 0.04 0.27 size(4)], 'popupmenu');
    
    % Options
    obj.fig.height = uicontrol(obj.fig.hpanelTime, 'Units', 'normalize', 'FontSize', 10,...
        'Style', 'text', 'String', 'Number of intervals: ', 'horizontalalignment', 'left', 'FontName', obj.font);
    size = get(obj.fig.height, 'position');
    set(obj.fig.height, 'position', [0.01 0.7 0.7 size(4)]);
    obj.fig.int = createUI(obj.fig.hpanelTime, '30', [0.8 0.7 0.15 size(4)], 'edit');
    
    createUI(obj.fig.hpanelTime, 'Number of repetitions: ', [0.01 0.45 0.7 size(4)], 'text');
    obj.fig.rep = createUI(obj.fig.hpanelTime, '10', [0.8 0.45 0.15 size(4)], 'edit');
    
    createUI(obj.fig.hpanelTime, 'Approximate Time Max (min): ', [0.01 0.15 0.7 size(4)], 'text');
    obj.fig.time = createUI(obj.fig.hpanelTime, 'Inf', [0.8 0.15 0.15 size(4)], 'edit');   

    % Optimisation
    obj.fig.height = uicontrol(obj.fig.hpanelOpt, 'Units', 'normalize', 'FontSize', 10,...
        'Style', 'text', 'String', 'Objective: ', 'horizontalalignment', 'left', 'FontName', obj.font);
    size = get(obj.fig.height, 'position');
    set(obj.fig.height, 'position', [0.01 0.8 0.45 size(4)]);
    obj.fig.obj = createUI(obj.fig.hpanelOpt,...
        {'max Twist', 'min Arm Trajectory', 'min Torque', 'max Twist min Controls'}, [0.48 0.8 0.5 size(4)], 'popupmenu');
    obj.fig.obj2 = createUI(obj.fig.hpanelOpt,...
        {'max Twist', 'min Arm Trajectory', 'min Torque', 'max Twist min Controls', 'max Twist min Control-Somersault'}, [0.48 0.8 0.5 size(4)], 'popupmenu');
    set(obj.fig.obj2, 'Visible', 'off'); 
    
    createUI(obj.fig.hpanelOpt, 'NLP Method: ', [0.01 0.6 0.45 size(4)], 'text');
    obj.fig.nlp = createUI(obj.fig.hpanelOpt,...
        {'Direct Multiple Shooting', 'Direct Collocation'}, [0.48 0.6 0.5 size(4)], 'popupmenu');
    set(obj.fig.nlp, 'Callback', @(src,event)setNLP(src,event));
    
    obj.fig.collocC = createUI(obj.fig.hpanelOpt, 'Collocation Method: ', [0.01 0.4 0.45 size(4)], 'text');
    obj.fig.colloc = createUI(obj.fig.hpanelOpt,...
        {'Trapezoidal', 'Hermite', 'Legendre'}, [0.48 0.4 0.5 size(4)], 'popupmenu');
    set(obj.fig.colloc, 'Callback', @(src,event)setNLP(src,event));
    set(obj.fig.colloc, 'Visible', 'off');
    set(obj.fig.collocC, 'Visible', 'off');
     
    obj.fig.collocDegreeC = createUI(obj.fig.hpanelOpt, 'Collocation Degree: ', [0.01 0.2 0.45 size(4)], 'text');
    obj.fig.collocDegree = createUI(obj.fig.hpanelOpt,...
        {'3', '5'}, [0.48 0.2 0.5 size(4)], 'popupmenu');
    set(obj.fig.collocDegree, 'Visible', 'off');
    set(obj.fig.collocDegreeC, 'Visible', 'off');
     
    % Model
    obj.fig.armE = uicontrol(obj.fig.hpanelModel, 'Style', 'checkbox', 'String', 'Arm Elevation',...
         'Units', 'normalize', 'Value', 1, 'FontName', obj.font, 'FontSize', 10);
    size = get(obj.fig.armE, 'position');
    set(obj.fig.armE, 'position', [0.1 0.78 0.8 size(4)]);
    obj.fig.armR = createUI(obj.fig.hpanelModel,'Arm Rotation',...
        [0.1 0.61 0.8 size(4)],'checkbox',0);
    obj.fig.hips3D = createUI(obj.fig.hpanelModel,'3D Hips',...
        [0.1 0.44 0.8 size(4)],'checkbox',0);
    set(obj.fig.hips3D, 'Enable', 'off');
    obj.fig.elbow = createUI(obj.fig.hpanelModel,'Elbow',...
        [0.1 0.27 0.8 size(4)],'checkbox',0);
    set(obj.fig.elbow, 'Enable', 'off');
    obj.fig.head3D = createUI(obj.fig.hpanelModel,'3D Head',...
        [0.1 0.1 0.8 size(4)],'checkbox',0);
    set(obj.fig.head3D, 'Enable', 'off');
    
    % Results
    obj.fig.results = createUI(obj.fig.hpanelResults,...
        {'BEST', '< 105%', 'ALL'}, [0.04 0.1 0.15 0.8],'popupmenu');
    set(obj.fig.results, 'Callback', @(src, event)enableSimChoice(src, event));
    
    obj.fig.sim = createUI(obj.fig.hpanelResults,...
        {'Simulation'}, [0.21 0.1 0.15 0.8],'popupmenu');
    set(obj.fig.sim, 'Callback', @(src, event)simulationChosen(src, event));
    
    obj.fig.score = createUI(obj.fig.hpanelResults, 'Score',...
        [0.4 0.68 0.09 0.2], 'text'); 
    obj.fig.percent = createUI(obj.fig.hpanelResults, '%',...
        [0.5 0.68 0.05 0.2], 'text'); 
    obj.fig.freeTime = createUI(obj.fig.hpanelResults, 'time',...
        [0.58 0.68 0.13 0.2], 'text');
    set(obj.fig.freeTime, 'Visible', 'off');
    obj.fig.labelRepDone = createUI(obj.fig.hpanelResults, 'Initialise',...
        [0.4 0.4 0.31 0.2], 'text'); 
    set(obj.fig.labelRepDone, 'Visible', 'off');
    obj.fig.labelStopReason = createUI(obj.fig.hpanelResults, 'Initialise',...
        [0.4 0.1 0.31 0.2], 'text'); 
    set(obj.fig.labelStopReason, 'Visible', 'off');
    set(obj.fig.labelStopReason, 'ForegroundColor', [0.8500 0.3250 0.0980]);
    obj.fig.showNO = createUI(obj.fig.hpanelResults, 'Show non optimal solutions',...
        [0.73 0.68 0.26 0.2], 'checkbox', 0); 
    set(obj.fig.showNO, 'CallBack', @(src, event)enableSimChoice(src, event));
    obj.fig.labelShowNO = createUI(obj.fig.hpanelResults, 'Initialise',...
        [0.73 0.4 0.26 0.2], 'text'); 
    set(obj.fig.labelShowNO, 'ForegroundColor', 'red');
    
    % Axes
    obj.fig.axes = axes('Parent',obj.fig.hpanelGraph,'Position',[.1 .05 .8 .85],...
        'Units', 'normalize', 'FontName', obj.font);
    obj = createToolBar(obj, 'off', true);
    
    % Display options
    obj.fig.anim = createUI(obj.fig.hpanelOptions,...
        {'ANIMATION', 'Kinetics', 'Kinematics'}, [0.4 0.1 0.25 0.8],'popupmenu');
    set(obj.fig.anim, 'Callback', @(src,event)displayResults(src,event));
    obj.fig.animPart = createUI(obj.fig.hpanelOptions,...
        {'ALL', 'Arms Only'}, [0.7 0.1 0.25 0.8],'popupmenu');
    obj.fig.display = createUI(obj.fig.hpanelOptions, 'DISPLAY', [0.1 0.25 0.25 0.5],...
        'pushbutton');
    set(obj.fig.display, 'Callback', @(src,event)displayResults(src,event));
        
    obj = initialise(obj, 'start');
    obj = onAndOffResults(obj, results);

end