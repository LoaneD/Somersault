% Script to optimize a twisting somersault with 2 10 DoF, 1sec time frame models
% One with 30 intervals
% One with 100 intervals
% Starting somersault speed let free (variable to optimize)
clear, clc, close all
addpath(genpath('casadi-windows-matlabR2016a-v3.4.5'))
run('startup.m')
import casadi.*

path = 'C:\Users\p1238838\Documents\Trampoline\Results\param2\';

% 30 intervals - Direct Multiple Shooting - t = 1s
data10_30_fS.Duration = 1; % Time horizon
data10_30_fS.Nint = 30;% number of control intervals
data10_30_fS.odeMethod = 'rk4';%'sundials'; %'rk4';
data10_30_fS.obj = 'twistPond';%torque or trajectory
data10_30_fS.NLPMethod = 'MultipleShooting';
%if this field exists enable somersault initial speed to be optimized
data10_30_fS.freeSomerSpeed = 0.01; % if field equals pond then value used in objective

% 100 intervals - Direct Multiple Shooting - t = 1s
data10_100_fS_pond.Duration = 1; % Time horizon
data10_100_fS_pond.Nint = 100;% number of control intervals
data10_100_fS_pond.odeMethod = 'rk4';%'sundials'; %'rk4';
data10_100_fS_pond.obj = 'twistPond';%torque or trajectory
data10_100_fS_pond.NLPMethod = 'MultipleShooting';
%if this field exists enable somersault initial speed to be optimized
data10_100_fS_pond.freeSomerSpeed = 0.01;

[model10_30_fS, data10_30_fS] = GenerateModel('10',data10_30_fS);
model10_30_fS = GenerateODE(model10_30_fS,data10_30_fS);% Formulate discrete time dynamics
model10_30_fS = GenerateTranspersionConstraints(model10_30_fS);
[prob10_30_fS, lbw10_30_fS, ubw10_30_fS, lbg10_30_fS, ubg10_30_fS] = GenerateNLP(model10_30_fS, data10_30_fS);

[model10_100_fS_pond, data10_100_fS_pond] = GenerateModel('10',data10_100_fS_pond);
model10_100_fS_pond = GenerateODE(model10_100_fS_pond,data10_100_fS_pond);% Formulate discrete time dynamics
model10_100_fS_pond = GenerateTranspersionConstraints(model10_100_fS_pond);
[prob10_100_fS_pond, lbw10_100_fS_pond, ubw10_100_fS_pond, lbg10_100_fS_pond, ubg10_100_fS_pond] = GenerateNLP(model10_100_fS_pond, data10_100_fS_pond);

options = struct;
options.ipopt.max_iter = 3000;
options.ipopt.print_level = 5;

solver10_30_fS = nlpsol('solver', 'ipopt', prob10_30_fS, options);
solver10_100_fS_pond = nlpsol('solver', 'ipopt', prob10_100_fS_pond, options);

QVU10_30_fS = [];
QVU10_100_fS_sCT = [];

for rep = 1:100
    fprintf('***************** ITER %d **********************\n', rep)
    if rep == 1
        [w010_30_fS, QVU10_30_fS, stat10_30_fS, feasible10_30_fS, ~] = optim(model10_30_fS, data10_30_fS,...
            rep, QVU10_30_fS, solver10_30_fS, lbw10_30_fS, ubw10_30_fS, lbg10_30_fS, ubg10_30_fS, 1,...
            [], [], struct, 'x');
        [w010_100_fS_sCT, QVU10_100_fS_sCT, stat10_100_fS_sCT, feasible10_100_fS_sCT, ~] = optim(model10_100_fS_pond, data10_100_fS_pond,...
            rep, QVU10_100_fS_sCT, solver10_100_fS_pond, lbw10_100_fS_pond, ubw10_100_fS_pond, lbg10_100_fS_pond, ubg10_100_fS_pond, 1,...
            [], [], struct, 'x');
    else
        [w010_30_fS, QVU10_30_fS, stat10_30_fS, feasible10_30_fS, ~] = optim(model10_30_fS, data10_30_fS,...
            rep, QVU10_30_fS, solver10_30_fS, lbw10_30_fS, ubw10_30_fS, lbg10_30_fS, ubg10_30_fS, 1,...
            w010_30_fS, feasible10_30_fS, stat10_30_fS, 'x');
        save(strcat(path,'7-DMS_30int_freeSomerSpeed.mat'),...
            'model10_30_fS', 'data10_30_fS', 'QVU10_30_fS', 'feasible10_30_fS', 'w010_30_fS', 'stat10_30_fS')
        
        [w010_100_fS_sCT, QVU10_100_fS_sCT, stat10_100_fS_sCT, feasible10_100_fS_sCT, ~] = optim(model10_100_fS_pond, data10_100_fS_pond,...
            rep, QVU10_100_fS_sCT, solver10_100_fS_pond, lbw10_100_fS_pond, ubw10_100_fS_pond, lbg10_100_fS_pond, ubg10_100_fS_pond, 1,...
            w010_100_fS_sCT, feasible10_100_fS_sCT, stat10_100_fS_sCT, 'x');
        save(strcat(path,'DMS10_100int_pond_fS_sCT.mat'),...
            'model10_100_fS_sCT', 'data10_100_fS_sCT', 'QVU10_100_fS_sCT', 'feasible10_100_fS_sCT', 'w010_100_fS_sCT', 'stat10_100_fS_sCT')
        
    end
end