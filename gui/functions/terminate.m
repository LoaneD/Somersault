function terminate(~,~)

    obj = getOBJ(true, true);
    
    % Delete the figures
    try
        delete(obj.fig.hfig)
    catch
        delete(gcf)
    end

end