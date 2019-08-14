function out = checkRange(mainV, range, limitMin, limitMax)

% if range = inf means there is no constraint added
if (mainV + range >= limitMin && mainV + range <= limitMax &&...
        mainV - range >= limitMin && mainV - range <= limitMax) || range == Inf
    out = true;
else
    out = false;
end

end