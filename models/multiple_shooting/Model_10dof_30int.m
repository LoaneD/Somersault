% Script to optimize a twisting somersault with 2 10 DoF, 30 intervals models
% One with fixed time frame (1 sec)
% One with free time frame (becomes a variable to optimize)
clear, clc, close all
addpath(genpath('casadi-windows-matlabR2016a-v3.4.5'))
run('startup.m')
import casadi.*

% Where to store the results
path = 'C:\Users\p1238838\Documents\Trampoline\Results\param2\';

% 30 intervals - Direct Multiple Shooting - t = 1s
data10_30.Duration = 1; % Time horizon
data10_30.Nint = 30;% number of control intervals
data10_30.odeMethod = 'rk4';%sundials or rk4 or rk4_dt
data10_30.obj = 'twist';%torque or trajectory or twistPond
data10_30.NLPMethod = 'MultipleShooting';

% 30 intervals - Direct Multiple Shooting - t free
data10_30t.Nint = 30;% number of control intervals
data10_30t.odeMethod = 'rk4';%sundials or rk4 or rk4_dt
data10_30t.obj = 'twist';%torque or trajectory or twist or twistPond
data10_30t.NLPMethod = 'MultipleShooting';

[model10_30, data10_30] = GenerateModel('10',data10_30);
model10_30 = GenerateODE(model10_30,data10_30);% Formulate discrete time dynamics
model10_30 = GenerateTranspersionConstraints(model10_30);
[prob10_30, lbw10_30, ubw10_30, lbg10_30, ubg10_30] = GenerateNLP(model10_30, data10_30);

[model10_30t, data10_30t] = GenerateModel('10',data10_30t);
model10_30t = GenerateODE(model10_30t,data10_30t);% Formulate discrete time dynamics
model10_30t = GenerateTranspersionConstraints(model10_30t);
[prob10_30t, lbw10_30t, ubw10_30t, lbg10_30t, ubg10_30t] = GenerateNLP(model10_30t, data10_30t);

options = struct;
options.ipopt.max_iter = 3000;
options.ipopt.print_level = 5;

solver10_30 = nlpsol('solver', 'ipopt', prob10_30, options);
solver10_30t = nlpsol('solver', 'ipopt', prob10_30t, options);

QVU10_30 = [];
QVU10_30t = [];

for rep = 1:100
    fprintf('***************** ITER %d **********************\n', rep)
    if rep == 1
        [w010_30, QVU10_30, stat10_30, feasible10_30, ~] = optim(model10_30, data10_30,...
            rep, QVU10_30, solver10_30, lbw10_30, ubw10_30, lbg10_30, ubg10_30, 1,...
            [], [], struct, 'x');
        [w010_30t, QVU10_30t, stat10_30t, feasible10_30t, t_opt30] = optim(model10_30t, data10_30t,...
            rep, QVU10_30t, solver10_30t, lbw10_30t, ubw10_30t, lbg10_30t, ubg10_30t, 1,...
            [], [], struct, 'x');
    else
        [w010_30, QVU10_30, stat10_30, feasible10_30, ~] = optim(model10_30, data10_30,...
            rep, QVU10_30, solver10_30, lbw10_30, ubw10_30, lbg10_30, ubg10_30, 1,...
            w010_30, feasible10_30, stat10_30, 'x');
        save(strcat(path,'5-DMS_30int.mat'),...
            'model10_30', 'data10_30', 'QVU10_30', 'feasible10_30', 'w010_30', 'stat10_30')
        
        [w010_30t, QVU10_30t, stat10_30t, feasible10_30t, t_opt30] = optim(model10_30t, data10_30t,...
            rep, QVU10_30t, solver10_30t, lbw10_30t, ubw10_30t, lbg10_30t, ubg10_30t, t_opt30,...
            w010_30t, feasible10_30t, stat10_30t, 'x');
        save(strcat(path,'6-DMS_30int_tlibre.mat'),...
            'model10_30t', 'data10_30t', 't_opt30', 'QVU10_30t', 'feasible10_30t', 'w010_30t', 'stat10_30t')
    end
end