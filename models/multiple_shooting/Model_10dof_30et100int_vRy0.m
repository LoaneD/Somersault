% Script to optimize a twisting somersault with 2 10 DoF, 1sec time frame models
% One with 30 intervals
% One with 100 intervals
% Initial guesses for arms speed set to 0
clear, clc, close all
addpath(genpath('casadi-windows-matlabR2016a-v3.4.5'))
run('startup.m')
import casadi.*

path = 'C:\Users\p1238838\Documents\Trampoline\Results\param2\';

% 30 intervals - Direct Multiple Shooting - t = 1s
data10_30v0.Duration = 1; % Time horizon
data10_30v0.Nint = 30;% number of control intervals
data10_30v0.odeMethod = 'rk4';%sundials or rk4 or rk4_dt
data10_30v0.obj = 'twist';%torque or trajectory
data10_30v0.NLPMethod = 'MultipleShooting';

% 100 intervals - Direct Multiple Shooting - t = 1s
data10_100v0.Duration = 1; % Time horizon
data10_100v0.Nint = 100;% number of control intervals
data10_100v0.odeMethod = 'rk4';%sundials or rk4 or rk4_dt
data10_100v0.obj = 'twist';%torque or trajectory
data10_100v0.NLPMethod = 'MultipleShooting';

[model10_30v0, data10_30v0] = GenerateModel('10',data10_30v0);
model10_30v0 = GenerateODE(model10_30v0,data10_30v0);% Formulate discrete time dynamics
model10_30v0 = GenerateTranspersionConstraints(model10_30v0);
[prob10_30v0, lbw10_30v0, ubw10_30v0, lbg10_30v0, ubg10_30v0] = GenerateNLP(model10_30v0, data10_30v0);

[model10_100v0, data10_100v0] = GenerateModel('10',data10_100v0);
model10_100v0 = GenerateODE(model10_100v0,data10_100v0);% Formulate discrete time dynamics
model10_100v0 = GenerateTranspersionConstraints(model10_100v0);
[prob10_100v0, lbw10_100v0, ubw10_100v0, lbg10_100v0, ubg10_100v0] = GenerateNLP(model10_100v0, data10_100v0);

options = struct;
options.ipopt.max_iter = 3000;
options.ipopt.print_level = 5;

solver10_30v0 = nlpsol('solver', 'ipopt', prob10_30v0, options);
solver10_100v0 = nlpsol('solver', 'ipopt', prob10_100v0, options);

QVU10_30v0 = [];
QVU10_100v0 = [];

for rep = 1:100
    fprintf('***************** ITER %d **********************\n', rep)
    % Using the initial guess from another calculated model
    % To be able to compare the consequencies of putting 0 for arms speed
    % To remove the use of former initial guess close brackets after 'vRy0'
    if rep == 1
        [w010_30v0, QVU10_30v0, stat10_30v0, feasible10_30v0, ~] = optim(model10_30v0, data10_30v0,...
            rep, QVU10_30v0, solver10_30v0, lbw10_30v0, ubw10_30v0, lbg10_30v0, ubg10_30v0, 1,...
            [], [], struct, 'vRy0', w010_30(:,rep));
        [w010_100v0, QVU10_100v0, stat10_100v0, feasible10_100v0, ~] = optim(model10_100v0, data10_100v0,...
            rep, QVU10_100v0, solver10_100v0, lbw10_100v0, ubw10_100v0, lbg10_100v0, ubg10_100v0, 1,...
            [], [], struct, 'vRy0', w010_100(:,rep));
    else
        [w010_30v0, QVU10_30v0, stat10_30v0, feasible10_30v0, ~] = optim(model10_30v0, data10_30v0,...
            rep, QVU10_30v0, solver10_30v0, lbw10_30v0, ubw10_30v0, lbg10_30v0, ubg10_30v0, 1,...
            w010_30v0, feasible10_30v0, stat10_30v0, 'vRy0', w010_30(:,rep));
        save(strcat(path,'1-DMS_30int_vRy0.mat'),...
            'model10_30v0', 'data10_30v0', 'QVU10_30v0', 'feasible10_30v0', 'w010_30v0', 'stat10_30v0')
        
        [w010_100v0, QVU10_100v0, stat10_100v0, feasible10_100v0, ~] = optim(model10_100v0, data10_100v0,...
            rep, QVU10_100v0, solver10_100v0, lbw10_100v0, ubw10_100v0, lbg10_100v0, ubg10_100v0, 1,...
            w010_100v0, feasible10_100v0, stat10_100v0, 'vRy0', w010_100(:,rep));
        save(strcat(path,'2-DMS_100int_vRy0.mat'),...
            'model10_100v0', 'data10_100v0', 'QVU10_100v0', 'feasible10_100v0', 'w010_100v0', 'stat10_100v0')
        
    end
end