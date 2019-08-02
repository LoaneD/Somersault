% Script to optimize a twisting somersault with 2 10 DoF, 1sec time frame
% models with trapezoidal collocation
% One with 30 intervals
% One with 100 intervals
clear, clc, close all
addpath(genpath('casadi-windows-matlabR2016a-v3.4.5'))
run('startup.m')
import casadi.*

path = 'C:\Users\p1238838\Documents\Trampoline\Results\param2\';

% 30 intervals - Direct Multiple Shooting - t = 1s
data10DCT_30.Duration = 1; % Time horizon
data10DCT_30.Nint = 30;% number of control intervals
data10DCT_30.odeMethod = 'rk4';%'sundials'; %'rk4';
data10DCT_30.obj = 'twist';%torque or trajectory
data10DCT_30.NLPMethod = 'Collocation';
data10DCT_30.collocMethod = 'trapezoidal';

% 100 intervals - Direct Multiple Shooting - t = 1s
data10DCT_100.Duration = 1; % Time horizon
data10DCT_100.Nint = 100;% number of control intervals
data10DCT_100.odeMethod = 'rk4';%'sundials'; %'rk4';
data10DCT_100.obj = 'twist';%torque or trajectory
data10DCT_100.NLPMethod = 'Collocation';
data10DCT_100.collocMethod = 'trapezoidal';

[model10DCT_30, data10DCT_30] = GenerateModel('10',data10DCT_30);
model10DCT_30 = GenerateODE(model10DCT_30,data10DCT_30);% Formulate discrete time dynamics
model10DCT_30 = GenerateTranspersionConstraints(model10DCT_30);
[prob10DCT_30, lbw10DCT_30, ubw10DCT_30, lbg10DCT_30, ubg10DCT_30] = GenerateNLP(model10DCT_30, data10DCT_30);

[model10DCT_100, data10DCT_100] = GenerateModel('10',data10DCT_100);
model10DCT_100 = GenerateODE(model10DCT_100,data10DCT_100);% Formulate discrete time dynamics
model10DCT_100 = GenerateTranspersionConstraints(model10DCT_100);
[prob10DCT_100, lbw10DCT_100, ubw10DCT_100, lbg10DCT_100, ubg10DCT_100] = GenerateNLP(model10DCT_100, data10DCT_100);

options = struct;
options.ipopt.max_iter = 3000;
options.ipopt.print_level = 5;

solver10DCT_30 = nlpsol('solver', 'ipopt', prob10DCT_30, options);
solver10DCT_100 = nlpsol('solver', 'ipopt', prob10DCT_100, options);

QVU10DCT_30 = [];
QVU10DCT_100 = [];

for rep = 1:11
    fprintf('***************** ITER %d **********************\n', rep)
    if rep == 1
        [w010DCT_30, QVU10DCT_30, stat10DCT_30, feasible10DCT_30, ~] = optim(model10DCT_30, data10DCT_30,...
            rep, QVU10DCT_30, solver10DCT_30, lbw10DCT_30, ubw10DCT_30, lbg10DCT_30, ubg10DCT_30, 1,...
            [], [], struct, 'x');
        [w010DCT_100, QVU10DCT_100, stat10DCT_100, feasible10DCT_100, ~] = optim(model10DCT_100, data10DCT_100,...
            rep, QVU10DCT_100, solver10DCT_100, lbw10DCT_100, ubw10DCT_100, lbg10DCT_100, ubg10DCT_100, 1,...
            [], [], struct, 'x');
    else
        [w010DCT_30, QVU10DCT_30, stat10DCT_30, feasible10DCT_30, ~] = optim(model10DCT_30, data10DCT_30,...
            rep, QVU10DCT_30, solver10DCT_30, lbw10DCT_30, ubw10DCT_30, lbg10DCT_30, ubg10DCT_30, 1,...
            w010DCT_30, feasible10DCT_30, stat10DCT_30, 'x');
        save(strcat(path,'10-DC_Trapezoidale_30int.mat'),...
            'model10DCT_30', 'data10DCT_30', 'QVU10DCT_30', 'feasible10DCT_30', 'w010DCT_30', 'stat10DCT_30')
        
        [w010DCT_100, QVU10DCT_100, stat10DCT_100, feasible10DCT_100, ~] = optim(model10DCT_100, data10DCT_100,...
            rep, QVU10DCT_100, solver10DCT_100, lbw10DCT_100, ubw10DCT_100, lbg10DCT_100, ubg10DCT_100, 1,...
            w010DCT_100, feasible10DCT_100, stat10DCT_100, 'x');
        save(strcat(path,'13-DC_Trapezoidale_100int.mat'),...
            'model10DCT_100', 'data10DCT_100', 'QVU10DCT_100', 'feasible10DCT_100', 'w010DCT_100', 'stat10DCT_100')
        
    end
end