% Script to optimize a twisting somersault with 2 10 DoF, 1sec time frame
% models with legendre collocation
% One with 30 intervals
% One with 100 intervals
clear, clc, close all
addpath(genpath('casadi-windows-matlabR2016a-v3.4.5'))
run('startup.m')
import casadi.*

path = 'C:\Users\p1238838\Documents\Trampoline\Results\param2\';

% 30 intervals - Direct Multiple Shooting - t = 1s
data10DCL3_30.Duration = 1; % Time horizon
data10DCL3_30.Nint = 30;% number of control intervals
data10DCL3_30.odeMethod = 'rk4';%'sundials'; %'rk4';
data10DCL3_30.obj = 'twist';%torque or trajectory
data10DCL3_30.NLPMethod = 'Collocation';
data10DCL3_30.collocMethod = 'legendre';
data10DCL3_30.degree = 3; %choose degree of approximating polynomial

% 100 intervals - Direct Multiple Shooting - t = 1s
data10DCL3_100.Duration = 1; % Time horizon
data10DCL3_100.Nint = 100;% number of control intervals
data10DCL3_100.odeMethod = 'rk4';%'sundials'; %'rk4';
data10DCL3_100.obj = 'twist';%torque or trajectory
data10DCL3_100.NLPMethod = 'Collocation';
data10DCL3_100.collocMethod = 'legendre';
data10DCL3_100.degree = 3; %choose degree of approximating polynomial

[model10DCL3_30, data10DCL3_30] = GenerateModel('10',data10DCL3_30);
model10DCL3_30 = GenerateODE(model10DCL3_30,data10DCL3_30);% Formulate discrete time dynamics
model10DCL3_30 = GenerateTranspersionConstraints(model10DCL3_30);
[prob10DCL3_30, lbw10DCL3_30, ubw10DCL3_30, lbg10DCL3_30, ubg10DCL3_30] = GenerateNLP(model10DCL3_30, data10DCL3_30);

[model10DCL3_100, data10DCL3_100] = GenerateModel('10',data10DCL3_100);
model10DCL3_100 = GenerateODE(model10DCL3_100,data10DCL3_100);% Formulate discrete time dynamics
model10DCL3_100 = GenerateTranspersionConstraints(model10DCL3_100);
[prob10DCL3_100, lbw10DCL3_100, ubw10DCL3_100, lbg10DCL3_100, ubg10DCL3_100] = GenerateNLP(model10DCL3_100, data10DCL3_100);

options = struct;
options.ipopt.max_iter = 3000;
options.ipopt.print_level = 5;

solver10DCL3_30 = nlpsol('solver', 'ipopt', prob10DCL3_30, options);
solver10DCL3_100 = nlpsol('solver', 'ipopt', prob10DCL3_100, options);

QVU10DCL3_30 = [];
QVU10DCL3_100 = [];

for rep = 1:100
    fprintf('***************** ITER %d **********************\n', rep)
    if rep == 1
        [w010DCL3_30, QVU10DCL3_30, stat10DCL3_30, feasible10DCL3_30, ~] = optim(model10DCL3_30, data10DCL3_30,...
            rep, QVU10DCL3_30, solver10DCL3_30, lbw10DCL3_30, ubw10DCL3_30, lbg10DCL3_30, ubg10DCL3_30, 1,...
            [], [], struct, 'x');
        [w010DCL3_100, QVU10DCL3_100, stat10DCL3_100, feasible10DCL3_100, ~] = optim(model10DCL3_100, data10DCL3_100,...
            rep, QVU10DCL3_100, solver10DCL3_100, lbw10DCL3_100, ubw10DCL3_100, lbg10DCL3_100, ubg10DCL3_100, 1,...
            [], [], struct, 'x');
    else
        [w010DCL3_30, QVU10DCL3_30, stat10DCL3_30, feasible10DCL3_30, ~] = optim(model10DCL3_30, data10DCL3_30,...
            rep, QVU10DCL3_30, solver10DCL3_30, lbw10DCL3_30, ubw10DCL3_30, lbg10DCL3_30, ubg10DCL3_30, 1,...
            w010DCL3_30, feasible10DCL3_30, stat10DCL3_30, 'x');
        save(strcat(path,'9-DC_Legendre3_30int.mat'),...
            'model10DCL3_30', 'data10DCL3_30', 'QVU10DCL3_30', 'feasible10DCL3_30', 'w010DCL3_30', 'stat10DCL3_30')
        
        [w010DCL3_100, QVU10DCL3_100, stat10DCL3_100, feasible10DCL3_100, ~] = optim(model10DCL3_100, data10DCL3_100,...
            rep, QVU10DCL3_100, solver10DCL3_100, lbw10DCL3_100, ubw10DCL3_100, lbg10DCL3_100, ubg10DCL3_100, 1,...
            w010DCL3_100, feasible10DCL3_100, stat10DCL3_100, 'x');
        save(strcat(path,'12-DC_Legendre3_100int.mat'),...
            'model10DCL3_100', 'data10DCL3_100', 'QVU10DCL3_100', 'feasible10DCL3_100', 'w010DCL3_100', 'stat10DCL3_100')
        
    end
end