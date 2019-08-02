% Script to optimize a twisting somersault with 2 10 DoF, 1sec time frame
% models with hermite simpson collocation
% One with 30 intervals
% One with 100 intervals
clear, clc, close all
addpath(genpath('casadi-windows-matlabR2016a-v3.4.5'))
run('startup.m')
import casadi.*

path = 'C:\Users\p1238838\Documents\Trampoline\Results\param2\';

% 30 intervals - Direct Multiple Shooting - t = 1s
data10DCH_30.Duration = 1; % Time horizon
data10DCH_30.Nint = 30;% number of control intervals
data10DCH_30.odeMethod = 'rk4';%'sundials'; %'rk4';
data10DCH_30.obj = 'twist';%torque or trajectory
data10DCH_30.NLPMethod = 'Collocation';
data10DCH_30.collocMethod = 'hermite';

% 100 intervals - Direct Multiple Shooting - t = 1s
data10DCH_100.Duration = 1; % Time horizon
data10DCH_100.Nint = 100;% number of control intervals
data10DCH_100.odeMethod = 'rk4';%'sundials'; %'rk4';
data10DCH_100.obj = 'twist';%torque or trajectory
data10DCH_100.NLPMethod = 'Collocation';
data10DCH_100.collocMethod = 'hermite';

[model10DCH_30, data10DCH_30] = GenerateModel('10',data10DCH_30);
model10DCH_30 = GenerateODE(model10DCH_30,data10DCH_30);% Formulate discrete time dynamics
model10DCH_30 = GenerateTranspersionConstraints(model10DCH_30);
[prob10DCH_30, lbw10DCH_30, ubw10DCH_30, lbg10DCH_30, ubg10DCH_30] = GenerateNLP(model10DCH_30, data10DCH_30);

[model10DCH_100, data10DCH_100] = GenerateModel('10',data10DCH_100);
model10DCH_100 = GenerateODE(model10DCH_100,data10DCH_100);% Formulate discrete time dynamics
model10DCH_100 = GenerateTranspersionConstraints(model10DCH_100);
[prob10DCH_100, lbw10DCH_100, ubw10DCH_100, lbg10DCH_100, ubg10DCH_100] = GenerateNLP(model10DCH_100, data10DCH_100);

options = struct;
options.ipopt.max_iter = 3000;
options.ipopt.print_level = 5;

solver10DCH_30 = nlpsol('solver', 'ipopt', prob10DCH_30, options);
solver10DCH_100 = nlpsol('solver', 'ipopt', prob10DCH_100, options);

QVU10DCH_30 = [];
QVU10DCH_100 = [];

for rep = 1:10
    fprintf('***************** ITER %d **********************\n', rep)
    if rep == 1
        [w010DCH_30, QVU10DCH_30, stat10DCH_30, feasible10DCH_30, ~] = optim(model10DCH_30, data10DCH_30,...
            rep, QVU10DCH_30, solver10DCH_30, lbw10DCH_30, ubw10DCH_30, lbg10DCH_30, ubg10DCH_30, 1,...
            [], [], struct, 'x');
        [w010DCH_100, QVU10DCH_100, stat10DCH_100, feasible10DCH_100, ~] = optim(model10DCH_100, data10DCH_100,...
            rep, QVU10DCH_100, solver10DCH_100, lbw10DCH_100, ubw10DCH_100, lbg10DCH_100, ubg10DCH_100, 1,...
            [], [], struct, 'x');
    else
        [w010DCH_30, QVU10DCH_30, stat10DCH_30, feasible10DCH_30, ~] = optim(model10DCH_30, data10DCH_30,...
            rep, QVU10DCH_30, solver10DCH_30, lbw10DCH_30, ubw10DCH_30, lbg10DCH_30, ubg10DCH_30, 1,...
            w010DCH_30, feasible10DCH_30, stat10DCH_30, 'x');
        save(strcat(path,'11-DC_Hermite_30int.mat'),...
            'model10DCH_30', 'data10DCH_30', 'QVU10DCH_30', 'feasible10DCH_30', 'w010DCH_30', 'stat10DCH_30')
        
        [w010DCH_100, QVU10DCH_100, stat10DCH_100, feasible10DCH_100, ~] = optim(model10DCH_100, data10DCH_100,...
            rep, QVU10DCH_100, solver10DCH_100, lbw10DCH_100, ubw10DCH_100, lbg10DCH_100, ubg10DCH_100, 1,...
            w010DCH_100, feasible10DCH_100, stat10DCH_100, 'x');
        save(strcat(path,'14-DC_Hermite_100int.mat'),...
            'model10DCH_100', 'data10DCH_100', 'QVU10DCH_100', 'feasible10DCH_100', 'w010DCH_100', 'stat10DCH_100')
        
    end
end