function tgrid = getTimeScale(model,data, t)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
import casadi.*

if isfield(data,'dt')
    t = 0;
    tgrid = [0];
    if strcmpi(data.dt,'log')
        for k=0:data.Nint-1
            DT = -log((k+1)/(data.Nint+1))/data.Nint*data.Duration;
            if strcmpi(data.NLPMethod, 'Collocation') && strcmpi(data.collocMethod, 'legendre')
                tgrid = [tgrid DT+collocation_points(data.degree, 'legendre')*(-log((k+2)/(data.Nint+1))/data.Nint*data.Duration-DT)];
            end
            tgrid = [tgrid t+DT];
            t = t + DT;
        end
        tgrid(data.Nint+1) = data.Duration;
    elseif strcmpi(data.dt,'a')
        for k=0:data.Nint-1
            DT = (0.005+1/data.Nint*(1-fix(k*10/data.Nint)/data.Nint))*data.Duration;
            tgrid = [tgrid t+DT];
            t = t + DT;
        end
    end
else
    tgrid = [0];
    if strcmpi(data.NLPMethod, 'Collocation') && strcmpi(data.collocMethod, 'legendre')
        if nargin > 2, spaces = linspace(0, t, data.Nint+1);
        else, spaces = linspace(0, data.Duration, data.Nint+1); end
        for i=1:data.Nint
            tgrid = [tgrid spaces(i)+collocation_points(data.degree, 'legendre')*(spaces(i+1)-spaces(i))...
                spaces(i+1)];
        end
    else
        if nargin > 2
            tgrid = linspace(0, t, data.Nint+1);
        else
            tgrid = linspace(0, data.Duration, data.Nint+1);
        end
    end    
end
end

