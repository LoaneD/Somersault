function setOBJ(obj)
% Code from Benjamin Michaud

% On est pas autorises a  enregistrer un obj qui n'est pas lock
if obj.lock
    obj.lock = false;
    set(obj.fig.hfig, 'userdata', obj)
end

end