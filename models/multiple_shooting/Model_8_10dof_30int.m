% Script to optimize a twisting somersault a 8 and a 10 DoF, 1sec time frame
% 30 intervals models with a twist and control ponderated objective function
% 10 DoF model using 8DoF optimal solutions as initial guesses
% One 10 DoF model without non transpersion constraints
clear, clc, close all
addpath(genpath('casadi-windows-matlabR2016a-v3.4.5'))
run('startup.m')
import casadi.*

path = 'C:\Users\p1238838\Documents\Trampoline\Results\param2\';

% 30 intervals - Direct Multiple Shooting - t = 1s
data8_30.Duration = 1; % Time horizon
data8_30.Nint = 30;% number of control intervals
data8_30.odeMethod = 'rk4';%'sundials'; %'rk4';
data8_30.obj = 'twistPond';%torque or trajectory or twistPond or twist
data8_30.NLPMethod = 'MultipleShooting';

% 30 intervals - Direct Multiple Shooting - t = 1 sec
data10_8_30.Duration = 1; % Time horizon
data10_8_30.Nint = 30;% number of control intervals
data10_8_30.odeMethod = 'rk4';%'sundials'; %'rk4';
data10_8_30.obj = 'twist';%torque or trajectory or twistPond or twist
data10_8_30.NLPMethod = 'MultipleShooting';

[model8_30, data8_30] = GenerateModel('8',data8_30);
model8_30 = GenerateODE(model8_30,data8_30);% Formulate discrete time dynamics
[prob8_30, lbw8_30, ubw8_30, lbg8_30, ubg8_30] = GenerateNLP(model8_30, data8_30);

[model10_8_30, data10_8_30] = GenerateModel('10',data10_8_30);
model10_8_30 = GenerateODE(model10_8_30,data10_8_30);% Formulate discrete time dynamics
model10_8_30 = GenerateTranspersionConstraints(model10_8_30);
[prob10_8_30, lbw10_8_30, ubw10_8_30, lbg10_8_30, ubg10_8_30] = GenerateNLP(model10_8_30, data10_8_30);

% model without non transpersion constraints
[model10_8_30sCT, data10_8_30] = GenerateModel('10',data10_8_30);
model10_8_30sCT = GenerateODE(model10_8_30sCT,data10_8_30);% Formulate discrete time dynamics
[prob10_8_30sCT, lbw10_8_30sCT, ubw10_8_30sCT, lbg10_8_30sCT, ubg10_8_30sCT] = GenerateNLP(model10_8_30sCT, data10_8_30);

options = struct;
options.ipopt.max_iter = 3000;
options.ipopt.print_level = 5;

solver8_30 = nlpsol('solver', 'ipopt', prob8_30, options);
solver10_8_30 = nlpsol('solver', 'ipopt', prob10_8_30, options);
solver10_8_30sCT = nlpsol('solver', 'ipopt', prob10_8_30sCT, options);

QVU8_30 = [];
QVU10_8_30 = [];
QVU10_8_30sCT = [];

for rep = 2:10
    fprintf('***************** ITER %d **********************\n', rep)
    if rep == 1
        [w08_30, QVU8_30, stat8_30, feasible8_30, ~] = optim(model8_30, data8_30,...
            rep, QVU8_30, solver8_30, lbw8_30, ubw8_30, lbgw8_30, ubg8_30, 1,...
            [], [], struct, 'x');
        [w010_8_30, QVU10_8_30, stat10_8_30, feasible10_8_30, ~] = optim(model10_8_30, data10_8_30,...
            rep, QVU10_8_30, solver10_8_30, lbw10_8_30, ubw10_8_30, lbgw10_8_30, ubg10_8_30, 1,...
            [], [], struct, 'x');
        [w010_8_30sCT, QVU10_8_30sCT, stat10_8_30sCT, feasible10_8_30sCT, ~] = optim(model10_8_30sCT, data10_8_30,...
            rep, QVU10_8_30sCT, solver10_8_30sCT, lbw10_8_30sCT, ubw10_8_30sCT, lbgw10_8_30sCT, ubg10_8_30sCT, 1,...
            [], [], struct, 'x');
    else
        [w08_30, QVU8_30, stat8_30, feasible8_30, ~] = optim(model8_30, data8_30,...
            rep, QVU8_30, solver8_30, lbw8_30, ubw8_30, lbgw8_30, ubg8_30, 1,...
            w08_30, feasible8_30, stat8_30, 'x');
        save(strcat(path,'17-DMS_8DL_30int.mat'),...
            'model8_30', 'data8_30', 'QVU8_30', 'feasible8_30', 'w08_30', 'stat8_30')
        
        [w010_8_30, QVU10_8_30, stat10_8_30, feasible10_8_30, ~] = optim(model10_8_30, data10_8_30,...
            rep, QVU10_8_30, solver10_8_30, lbw10_8_30, ubw10_8_30, lbgw10_8_30, ubg10_8_30, 1,...
            w010_8_30, feasible10_8_30, stat10_8_30, 'x');
        save(strcat(path,'18-DMS_10DL_30int_IGopt8DL'),...
            'model10_8_30', 'data10_8_30', 'QVU10_8_30', 'feasible10Pond_100', 'w010_8_30', 'stat10Pond_100')
        
        [w010_8_30sCT, QVU10_8_30sCT, stat10_8_30sCT, feasible10_8_30sCT, ~] = optim(model10_8_30sCT, data10_8_30,...
            rep, QVU10_8_30sCT, solver10_8_30sCT, lbw10_8_30sCT, ubw10_8_30sCT, lbgw10_8_30sCT, ubg10_8_30sCT, 1,...
            w010_8_30sCT, feasible10_8_30sCT, stat10_8_30sCT, 'x');
        save(strcat(path,'19-DMS_10DL_30int_IGopt8DL_sCT.mat'),...
            'model10_8_30sCT', 'data10_8_30', 'QVU10_8_30sCT', 'feasible10_8_30sCT', 'w010_8_30sCT', 'stat10_8_30sCT')
    end
end