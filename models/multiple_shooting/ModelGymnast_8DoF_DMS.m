% Create model of a 8 DoF gymnast 
% With a Direct Multiple Shooting as NLP Method
% Possible to change the objective function and the ode method

clear, clc, close all
addpath(genpath('casadi-windows-matlabR2016a-v3.4.5'))
run('startup.m')
import casadi.*

% % Enter the path in which to store results (workspaces)
path = 'C:\\Users\p1238838\Documents\MATLAB\spatial_v2\workspaces\results\';

% % Time horizon - don't create Duration field to let time free
data8.Duration = 1; 
% % Number of control intervals
data8.Nint = 30; 
% % Objective function : select torque or trajectory or twist
data8.obj = 'twist';
% % NLP Algorithm : choose MultipleShooting or Collocation
data8.NLPMethod = 'MultipleShooting';
% % If Collocation : choose legendre or trapezoidal or hermite
% data10.collodMethod = 'hermite';
% % If Legendre : choose polynomial degree
% data10.degree = 5;
% % If Direct Multiple Shooting : choose rk4 or rk4dt or sundials
data8.odeMethod = 'rk4';
% % If rk4_dt field to add to precise how to create time intervals
% % Choose log (decreasing logarithm) or a (affine)
% data10.dt = 'log';

% % Generate the model
[model8, data8] = GenerateModel('8',data8);
% % Formulate discrete time dynamics
model8 = GenerateODE(model8,data8);
% % Only for DoF > 8 - needed to add transpersion constraints to the problem
% model8 = GenerateTranspersionConstraints(model8);
% % Generate the NLP solver
[prob8, lbw8, ubw8, lbg8, ubg8] = GenerateNLP(model8, data8);

% % Add options to the solver
options = struct;
options.ipopt.max_iter = 6000;
options.ipopt.print_level = 5;
% options.ipopt.max_cpu_time = 5000;

% options.monitor = char('nlp_g');

% % Create the solver
solver8 = nlpsol('solver', 'ipopt', prob8, options);

% % Initialize the variable holding the results
QVU8 = []; 

% % Launch the optimisation with a multi start
for rep=1:100
    fprintf('***************** ITER %d **********************\n', rep) 
    % % Randomised initial guesses
    % % To use previous results add (QVU, model, data) to optim function
    % % To use previous initial guesses add (w0) to optim function
    if rep == 1 
        [w08, QVU8, stat8, feasible8, ~] = optim(model8, data8,...
             rep, QVU8, solver8, lbw8, ubw8, lbg8, ubg8, 1,...
             [], [], struct);
    else
        % % To put nitial guesses for arms Ry speed to 0 change none to vRy0
        [w08, QVU8, stat8, feasible8, ~] = optim(model8, data8,...
            rep, QVU8, solver8, lbw8, ubw8, lbg8, ubg8, 1,...
            w08, feasible8, stat8, 'none');
    end
    save(strcat(path, '8DMS_Twist_1sec_30int.mat'),...
        'model8', 'data8', 'QVU8', 'feasible8', 'w08', 'stat8')
end  