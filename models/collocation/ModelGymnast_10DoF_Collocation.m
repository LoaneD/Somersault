% Create model of a 10 DoF gymnast 
% With a Direct Collocation as NLP Method
% Possible to change the objective function and the collocation method

clear, clc, close all
addpath(genpath('casadi-windows-matlabR2016a-v3.4.5'))
run('startup.m')
import casadi.*

% % Enter the path in which to store results (workspaces)
path = 'C:\\Users\p1238838\Documents\MATLAB\spatial_v2\workspaces\results\';

% % Time horizon - don't create Duration field to let time free
data10.Duration = 1; 
% % Number of control intervals
data10.Nint = 30; 
% % Objective function : select torque or trajectory or twist
data10.obj = 'twist';
% % NLP Algorithm : choose MultipleShooting or Collocation
data10.NLPMethod = 'Collocation';
% % If Collocation : choose legendre or trapezoidal or hermite
data10.collodMethod = 'hermite';
% % If Legendre : choose polynomial degree
% data10.degree = 5;
% % If Direct Multiple Shooting : choose rk4 or rk4dt or sundials
% data10.odeMethod = 'rk4';
% % If rk4_dt field to add to precise how to create time intervals
% % Choose log (decreasing logarithm) or a (affine)
% data10.dt = 'log';

% % Generate the model
[model10, data10] = GenerateModel('10',data10);
% % Formulate discrete time dynamics
model10 = GenerateODE(model10,data10);
% % Only for DoF > 8 - needed to add transpersion constraints to the problem
model10 = GenerateTranspersionConstraints(model10);
% % Generate the NLP solver
[prob10, lbw10, ubw10, lbg10, ubg10] = GenerateNLP(model10, data10);

% % Add options to the solver
options = struct;
options.ipopt.max_iter = 6000;
options.ipopt.print_level = 5;
% options.ipopt.max_cpu_time = 5000;

% options.monitor = char('nlp_g');

% % Create the solver
solver10 = nlpsol('solver', 'ipopt', prob10, options);

% % Initialize the variable holding the results
QVU10 = []; 

% % Launch the optimisation with a multi start
for rep=1:100
    fprintf('***************** ITER %d **********************\n', rep) 
    % % Randomised initial guesses
    % % To use previous results add (QVU, model, data) to optim function
    % % To use previous initial guesses add (w0) to optim function
    if rep == 1 
        [w010, QVU10, stat10, feasible10, ~] = optim(model10, data10,...
             rep, QVU10, solver10, lbw10, ubw10, lbg10, ubg10, 1,...
             [], [], struct);
    else
        % % To put nitial guesses for arms Ry speed to 0 change none to vRy0
        [w010, QVU10, stat10, feasible10, ~] = optim(model10, data10,...
            rep, QVU10, solver10, lbw10, ubw10, lbg10, ubg10, 1,...
            w010, feasible10, stat10, 'none');
    end
    save(strcat(path, '10CollocationHermite_Twist_1sec_30int.mat'),...
        'model10', 'data10', 'QVU10', 'feasible10', 'w010', 'stat10')
end  