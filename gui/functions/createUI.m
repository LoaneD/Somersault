function ui = createUI(parent, string, position, style, value)

    if strcmpi(style, 'checkbox')
        ui = uicontrol(parent, 'Style', style, 'String', string,...
         'Units', 'normalize', 'Position', position, 'Value', value, 'FontName', 'Times New Roman', 'FontSize', 10);
    else
        ui = uicontrol(parent, 'Style', style, 'String', string,...
            'Units', 'normalize', 'Position', position, 'horizontalalignment', 'left', 'FontName', 'Times New Roman', 'FontSize', 10);
    end
    
end