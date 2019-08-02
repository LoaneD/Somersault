% Script to optimize a twisting somersault with 2 10 DoF, 100 intervals models
% One with fixed time frame (1 sec)
% One with free time frame (becomes a variable to optimize)
clear, clc, close all
addpath(genpath('casadi-windows-matlabR2016a-v3.4.5'))
run('startup.m')
import casadi.*

path = 'C:\Users\p1238838\Documents\Trampoline\Results\param2\ObjectivePonderatedTwist\';

% 100 intervals - Direct Multiple Shooting - t = 1s
data10_100.Duration = 1; % Time horizon
data10_100.Nint = 100;% number of control intervals
data10_100.odeMethod = 'rk4';%'sundials'; %'rk4';
data10_100.obj = 'twist';%torque or trajectory
data10_100.NLPMethod = 'MultipleShooting';

% 100 intervals - Direct Multiple Shooting - t free
data10_100t.Nint = 100;% number of control intervals
data10_100t.odeMethod = 'rk4';%'sundials'; %'rk4';
data10_100t.obj = 'twist';%torque or trajectory
data10_100t.NLPMethod = 'MultipleShooting';

[model10_100, data10_100] = GenerateModel('10',data10_100);
model10_100 = GenerateODE(model10_100,data10_100);% Formulate discrete time dynamics
model10_100 = GenerateTranspersionConstraints(model10_100);
[prob10_100, lbw10_100, ubw10_100, lbg10_100, ubg10_100] = GenerateNLP(model10_100, data10_100);

[model10_100t, data10_100t] = GenerateModel('10',data10_100t);
model10_100t = GenerateODE(model10_100t,data10_100t);% Formulate discrete time dynamics
model10_100t = GenerateTranspersionConstraints(model10_100t);
[prob10_100t, lbw10_100t, ubw10_100t, lbg10_100t, ubg10_100t] = GenerateNLP(model10_100t, data10_100t);

options = struct;
options.ipopt.max_iter = 3000;
options.ipopt.print_level = 5;

solver10_100 = nlpsol('solver', 'ipopt', prob10_100, options);
solver10_100t = nlpsol('solver', 'ipopt', prob10_100t, options);

QVU10_100 = [];
QVU10_100t = [];

for rep = 2:10
    fprintf('***************** ITER %d **********************\n', rep)
    if rep == 1
        [w010_100, QVU10_100, stat10_100, feasible10_100, ~] = optim(model10_100, data10_100,...
            rep, QVU10_100, solver10_100, lbw10_100, ubw10_100, lbg10_100, ubg10_100, 1,...
            [], [], struct, 'x');
        [w010_100t, QVU10_100t, stat10_100t, feasible10_100t, t_opt100] = optim(model10_100t, data10_100t,...
            rep, QVU10_100t, solver10_100t, lbw10_100t, ubw10_100t, lbg10_100t, ubg10_100t, 1,...
            [], [], struct, 'x');
    else
        [w010_100, QVU10_100, stat10_100, feasible10_100, ~] = optim(model10_100, data10_100,...
            rep, QVU10_100, solver10_100, lbw10_100, ubw10_100, lbg10_100, ubg10_100, 1,...
            w010_100, feasible10_100, stat10_100, 'x');
        save(strcat(path,'3-DMS_100int.mat'),...
            'model10_100', 'data10_100', 'QVU10_100', 'feasible10_100', 'w010_100', 'stat10_100')
        
        [w010_100t, QVU10_100t, stat10_100t, feasible10_100t, t_opt100] = optim(model10_100t, data10_100t,...
            rep, QVU10_100t, solver10_100t, lbw10_100t, ubw10_100t, lbg10_100t, ubg10_100t, t_opt100,...
            w010_100t, feasible10_100t, stat10_100t, 'x');
        save(strcat(path,'4-DMS_100int_tlibre.mat'),...
            'model10_100t', 'data10_100t', 't_opt100', 'QVU10_100t', 'feasible10_100t', 'w010_100t', 'stat10_100t')
        
    end
end