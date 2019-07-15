function tgrid = getTimeScale(model,data, t)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
if strcmpi(data.odeMethod,'rk4_dt')
    t = 0;
    tgrid = [0];
    if strcmpi(data.dt,'log')
        for k=0:data.Nint-1
            DT = -log((k+1)/(data.Nint+1))/data.Nint*data.Duration;
            tgrid = [tgrid t+DT];
            t = t + DT;
        end
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
            tgrid = [tgrid spaces(i)+collocation_points(data.degree, 'legendre') spaces(i+1)];
        end
    elseif strcmpi(data.NLPMethod, 'Collocation') && strcmpi(data.collocMethod, 'hermite')
        tgrid = linspace(0, data.Duration, data.Nint*2+1);
    else
        if nargin > 2
            tgrid = linspace(0, t, data.Nint+1);
        else
            tgrid = linspace(0, data.Duration, data.Nint+1);
        end
    end    
    
    
end
end

