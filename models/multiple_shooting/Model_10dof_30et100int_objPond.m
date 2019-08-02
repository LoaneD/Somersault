% Script to optimize a twisting somersault with 2 10 DoF, 1sec time frame
% models with a twist and control ponderated objective function
% One with 30 intervals
% One with 100 intervals
clear, clc, close all
addpath(genpath('casadi-windows-matlabR2016a-v3.4.5'))
run('startup.m')
import casadi.*

path = 'C:\Users\p1238838\Documents\Trampoline\Results\param2\';

% 100 intervals - Direct Multiple Shooting - t = 1s
data10Pond_30.Duration = 1; % Time horizon
data10Pond_30.Nint = 30;% number of control intervals
data10Pond_30.odeMethod = 'rk4';%'sundials'; %'rk4';
% objective function = -twist + 10*Rz_controls + 0.01*Ry_controls
data10Pond_30.obj = 'twistPond';%torque or trajectory or twistPond or twist
data10Pond_30.NLPMethod = 'MultipleShooting';

% 100 intervals - Direct Multiple Shooting - t = 1 sec
data10Pond_100.Duration = 1; % Time horizon
data10Pond_100.Nint = 100;% number of control intervals
data10Pond_100.odeMethod = 'rk4';%'sundials'; %'rk4';
% objective function = -twist + 10*Rz_controls + 0.01*Ry_controls
data10Pond_100.obj = 'twistPond';%torque or trajectory or twistPond or twist
data10Pond_100.NLPMethod = 'MultipleShooting';

[model10Pond_30, data10Pond_30] = GenerateModel('10',data10Pond_30);
model10Pond_30 = GenerateODE(model10Pond_30,data10Pond_30);% Formulate discrete time dynamics
model10Pond_30 = GenerateTranspersionConstraints(model10Pond_30);
[prob10Pond_30, lbw10Pond_30, ubw10Pond_30, lbg10Pond_30, ubg10Pond_30] = GenerateNLP(model10Pond_30, data10Pond_30);

[model10Pond_100, data10Pond_100] = GenerateModel('10',data10Pond_100);
model10Pond_100 = GenerateODE(model10Pond_100,data10Pond_100);% Formulate discrete time dynamics
model10Pond_100 = GenerateTranspersionConstraints(model10Pond_100);
[prob10Pond_100, lbw10Pond_100, ubw10Pond_100, lbg10Pond_100, ubg10Pond_100] = GenerateNLP(model10Pond_100, data10Pond_100);

options = struct;
options.ipopt.max_iter = 3000;
options.ipopt.print_level = 5;

solver10Pond_30 = nlpsol('solver', 'ipopt', prob10Pond_30, options);
solver10Pond_100 = nlpsol('solver', 'ipopt', prob10Pond_100, options);

QVU10Pond_30 = [];
QVU10Pond_100 = [];

for rep = 2:10
    fprintf('***************** ITER %d **********************\n', rep)
    if rep == 1
        [w010Pond_30, QVU10Pond_30, stat10Pond_30, feasible10Pond_30, ~] = optim(model10Pond_30, data10Pond_30,...
            rep, QVU10Pond_30, solver10Pond_30, lbw10Pond_30, ubw10Pond_30, lbg10Pond_30, ubg10Pond_30, 1,...
            [], [], struct, 'x');
        [w010Pond_100, QVU10Pond_100, stat10Pond_100, feasible10Pond_100, ~] = optim(model10Pond_100, data10Pond_100,...
            rep, QVU10Pond_100, solver10Pond_100, lbw10Pond_100, ubw10Pond_100, lbg10Pond_100, ubg10Pond_100, 1,...
            [], [], struct, 'x');
    else
        [w010Pond_30, QVU10Pond_30, stat10Pond_30, feasible10Pond_30, ~] = optim(model10Pond_30, data10Pond_30,...
            rep, QVU10Pond_30, solver10Pond_30, lbw10Pond_30, ubw10Pond_30, lbg10Pond_30, ubg10Pond_30, 1,...
            w010Pond_30, feasible10Pond_30, stat10Pond_30, 'x');
        save(strcat(path,'15-DMS_30int_objPond.mat'),...
            'model10Pond_30', 'data10Pond_30', 'QVU10Pond_30', 'feasible10Pond_30', 'w010Pond_30', 'stat10Pond_30')
        
        [w010Pond_100, QVU10Pond_100, stat10Pond_100, feasible10Pond_100, ~] = optim(model10Pond_100, data10Pond_100,...
            rep, QVU10Pond_100, solver10Pond_100, lbw10Pond_100, ubw10Pond_100, lbg10Pond_100, ubg10Pond_100, 1,...
            w010Pond_100, feasible10Pond_100, stat10Pond_100, 'x');
        save(strcat(path,'16-DMS_100int_objPond.mat'),...
            'model10Pond_100', 'data10Pond_100', 'QVU10Pond_100', 'feasible10Pond_100', 'w010Pond_100', 'stat10Pond_100')
    end
end