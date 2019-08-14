function obj = getOBJ(lock, ignoreLock)
% Code from Benjamin Michaud

obj = get(gcf, 'userdata');
if ignoreLock
    return;
end

while obj.lock == true
    obj = get(gcf, 'userdata');
end
% Locker l'objet
if lock
    obj.lock = true;
    setOBJ(obj);
end
end

