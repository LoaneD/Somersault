function [model, data] = GenerateModel(nDoF,data)

import casadi.*

model.name = nDoF;


switch nDoF
    case '8'
        model.dof.Tz=3;
        model.dof.Somer=4;
 
        MGbras = SX.zeros(1,3); MGbras(3) = -0.233088;
        model.dof.Tilt = 5;
        model.dof.Twist=6; 
        model.dof.RighArmY=7;
        model.dof.LeftArmY=8;
        
        model.NB = 3;
        model.jtype = {'R','Ry', 'Ry'};
        model.parent = [0, 1, 1];
        %dep pelvis-thorax + thorax-shoulder + shoulder-arm
%         model.Xtree = {SX.eye(6), ...
%             xlt(([0., 0.010, 0.110 ]+[ 0.035, 0.0205, 0.2645]+[ 0.1525, 0., 0.])),... right arm
%             xlt(([0., 0.010, 0.110 ]+[-0.035, 0.0205, 0.2645]+[-0.1525, 0., 0.]))    };%left arm
        model.Xtree = {SX.eye(6), ...
            xlt(([0.1875, 0.0205, 0.4719])),... right arm
            xlt(([-0.1875, 0.0205, 0.4719]))    };%left arm
        
%         model.I = {mcI(52.5892, [4.61176e-18  0.00965155  -0.0479683],[7.85829  1.37295e-18 -2.40392e-17;
%             1.37295e-18      8.12771    0.0239748;
%             -2.40392e-17    0.0239748     0.518018]), ...
%             mcI(3.106, MGbras, diag([0.0910283,0.0909983,0.00292])), ...
%             mcI(3.106, MGbras, diag([0.0910283,0.0909983,0.00292]))    } ;
        model.I = {mcI(58.801, [0  0  0.09410],diag([7.85829,8.12771,0.51802])), ...
                   mcI(3.106, MGbras, diag([0.0910283,0.0909983,0.00292])), ...
                   mcI(3.106, MGbras, diag([0.0910283,0.0909983,0.00292]))    } ;        

%         model.markers.name = {'handL', 'handR', 'shoulderL', 'shoulderR', 'hipR', 'hipL', 'kneeR', 'kneeL', 'footR', 'footL', ...
%             'frontR','frontL', 'backR', 'backL',  'pelvis'};
%         model.markers.parent = [8 7 8 7 6 6 6 6 6 6,  6 6 6 6, 6];
%         model.markers.coordinates = [0 0 -0.4885; 
%                                      0 0 -0.4885; 
%                                      0 0 0; 
%                                      0 0 0; 
%                                      0.096 0.01 -0.105; 
%                                     -0.096 0.01 -0.105; ...
%                                      0.096 0.01 -0.485; 
%                                     -0.096 0.01 -0.485; 
%                                      0.096 0.01 -0.839; 
%                                     -0.096 0.01 -0.839; ...
%                                      0.1875    0.1305    0.3745
%                                     -0.1875    0.1305    0.3745 
%                                      0.1875   -0.0695    0.3745
%                                     -0.1875   -0.0695    0.3745 
%                                      0 0 0]';
%          model.markers.lines = [1 3; 2 4; 3 4; 5 6; 5 7; 6 8; 8 10; 7 9; 15 5; 15 6];
%          model.markers.ind = [1 2 5;2 3 5;3 4 5;4 1 5];
                        
        model.markers.name = {'pelvis', 'thorax', 'shoulder', 'head', 'thighR', 'thighL',...
            'shankR', 'shankL', 'footR', 'footL', 'uarmR','uramL', 'larmR', 'larmL',  'handR', 'handL'};
        model.markers.collisionP = [11 4;12 4;
                                    11 2;12 2;
                                    11 1;12 1;
                                    13 2;14 2;
                                    13 1;14 1;
                                    13 4;14 4;
                                    14 6;13 5;
                                    15 1;16 1;
                                    15 5;16 6];
% %         sum of the max length semi axis for segments of constraints pairs
        model.markers.dmin = [0.085;0.085;0.11;0.11;0.11;0.11;0.1;...
            0.1;0.1;0.1;0.075;0.075;0.08;0.08;0.1;0.1;0.08;0.08];
        model.markers.dmax = [Inf;Inf;Inf;Inf;Inf;Inf;Inf;...
            Inf;Inf;Inf;Inf;Inf;Inf;Inf;Inf;Inf;Inf;Inf];
        model.markers.parent = [6 6 6 6 6 6 6 6 6 6 7 8 7 8 7 8];
        model.markers.coordinates = [0 0 0; 
                                     0 0.01 0.2530; 
                                     0 0.0205 0.4719; 
                                     0 0.018 0.6498; 
                                     0.0941 0.01 -0.19; 
                                    -0.0941 0.01 -0.19; 
                                     0.0941 0.01 -0.55; 
                                    -0.0941 0.01 -0.55; 
                                     0.0941 0.0769 -0.72; 
                                    -0.0941 0.0769 -0.72; 
                                     0 0 -0.13;
                                     0 0 -0.13;
                                     0 0 -0.37;
                                     0 0 -0.37; 
                                     0 0 -0.5426
                                     0 0 -0.5426]';
        model.markers.param = [0.096 0.05 0.0941;
                               0.12 0.05 0.15891;
                               0.1875 0.0305 0.06;...
                               0.05 0.06 0.11788;
                               0.05 0.05 0.19;
                               0.05 0.05 0.19;
                               0.03 0.04 0.17;
                               0.03 0.04 0.17;
                               0.02 0.06639 0.01;
                               0.02 0.06639 0.01;
                               0.035 0.03 0.13;
                               0.035 0.03 0.13;
                               0.025 0.01 0.11;
                               0.025 0.01 0.11;
                               0.03 0.006 0.06257;
                               0.03 0.006 0.06257];
        
        model = floatbase(model); 
        model.nq = model.NB;

        q0    = zeros(model.nq,1);
        v0    = zeros(model.nq,1);
        tau0  = zeros(model.nq,1);

        v0(model.dof.Tz,1) = 4.9;%5;%6;
        v0(model.dof.Somer,1)=6.3;
        q0(model.dof.RighArmY,1) = -3.0;
        q0(model.dof.LeftArmY,1) = 3.0;

        data.x0 = [q0; v0];
        model.nx = model.nq+model.nq;
        model.nu = model.nq-6;
        data.u0 = tau0(7:end);

        model.idx_q = 1:model.nq;
        model.idx_v = model.nq+1:2*model.nq;
        
%         xmin    = [-inf,-inf,-inf, -inf, -1, -inf, -3.1, 0.1];
%         xmax    = [ inf, inf, inf,  inf,  1,  inf, -0.1,  3.1];
        
        xmin    = [-inf,-inf,-inf, -inf, -pi/4, -inf, -3.1, 0.1];
        xmax    = [ inf, inf, inf,  inf,  pi/4,  inf, -0.1,  3.1];
        model.xmin   =  [xmin, -inf,-inf,-inf,-inf,-inf,-inf, -100, -100]';
        model.xmax   =  [xmax,  inf, inf, inf, inf, inf, inf,  100,  100]';
        
%         model.xmin   =  [xmin, -inf,-inf,-inf,-inf,-inf,-inf, -40, -40]';
%         model.xmax   =  [xmax,  inf, inf, inf, inf, inf, inf,  40,  40]';

        model.umin = [-50; -50];
        model.umax = [ 50;  50];
        
        model.DOFname = {'Tx';'Ty';'Tz';'Somersault';'Tilt';'Twist'; 'Right Arm Flexion'; 'Left Arm Flexion'};
        model.Unitname = {'m';'m';'m';'Rev';'deg';'Rev'; 'deg'; 'deg'};
        model.Unitcoef = [1 1 1, 1/(2*pi), 180/pi, 1/(2*pi),   180/pi, 180/pi];

        model.Scaling.q = [.1 .1 2, 10 1 10, 3, 3]';
        model.Scaling.v = [1 1 6, 3 3 10,  50, 50]';
        model.Scaling.u = [50 50]';
        model.Scaling.x = [model.Scaling.q; model.Scaling.v];
        
    case '10'
        
        model.dof.Tz=3;
        model.dof.Somer=4;
        model.dof.Tilt=5;
        model.dof.Twist=6;
        model.dof.RighArmY=8;
        model.dof.LeftArmY=10;
        model.NB = 5;
        model.jtype = {'R',  'Rz','Ry',   'Rz', 'Ry'};
                      %1   2  3  4  5
        model.parent = [0, 1, 2, 1, 4];
%         model.Xtree = {SX.eye(6), ...
%             xlt(([0., 0.010, 0.110 ]+[ 0.035, 0.0205, 0.2645]+[ 0.1525, 0., 0.])),  SX.eye(6),... right arm
%             xlt(([0., 0.010, 0.110 ]+[-0.035, 0.0205, 0.2645]+[-0.1525, 0., 0.])),  SX.eye(6)    };%left arm

        model.Xtree = {SX.eye(6), ...
            xlt(([0.1875, 0.0205, 0.4719])),  SX.eye(6),... right arm
            xlt(([-0.1875, 0.0205, 0.4719])),  SX.eye(6)    };%left arm
        MGbras = SX.zeros(1,3); MGbras(3) = -0.233088;
        model.I = {mcI(58.801, [0  0  0.09410],diag([7.85829,8.12771,0.51802])), ...
                   SX(6,6), mcI(3.106, MGbras, diag([0.0910283,0.0909983,0.00292])), ...
                   SX(6,6), mcI(3.106, MGbras, diag([0.0910283,0.0909983,0.00292])), ...
                   SX.zeros(6,6), mcI(3.106, MGbras, diag([0.0910283,0.0909983,0.00292])), ...
                   SX.zeros(6,6), mcI(3.106, MGbras, diag([0.0910283,0.0909983,0.00292]))    } ;        
        
%         model.I = {mcI(52.5892, [4.61176e-18  0.00965155  -0.0479683],[7.85829  1.37295e-18 -2.40392e-17;  
%                                                                        1.37295e-18      8.12771    0.0239748; 
%                                                                        -2.40392e-17    0.0239748     0.518018]), ...
%             SX(6,6),    mcI(3.106, MGbras, diag([0.0910283,0.0909983,0.00292])), ...
%             SX(6,6),    mcI(3.106, MGbras, diag([0.0910283,0.0909983,0.00292])) } ;
%             SX.zeros(6,6),    mcI(3.106, MGbras, diag([0.0910283,0.0909983,0.00292])), ...
%             SX.zeros(6,6),    mcI(3.106, MGbras, diag([0.0910283,0.0909983,0.00292])) } ;
%         model.markers.name = {'handL', 'handR', 'shoulderL', 'shoulderR', 'hipR', 'hipL', 'kneeR', 'kneeL', 'footR', 'footL', ...
%             'frontR','frontL', 'backR', 'backL',  'pelvis'};
%         model.markers.parent = [10 8 10 8 6 6 6 6 6 6,  6 6 6 6, 6];
%         model.markers.coordinates = [0 0 -0.4885; 
%                                      0 0 -0.4885; 
%                                      0 0 0; 
%                                      0 0 0; 
%                                      0.096 0.01 -0.105; 
%                                     -0.096 0.01 -0.105; ...
%                                      0.096 0.01 -0.485; 
%                                     -0.096 0.01 -0.485; 
%                                      0.096 0.01 -0.839; 
%                                     -0.096 0.01 -0.839; ...
%                                      0.1875    0.1305    0.3745
%                                     -0.1875    0.1305    0.3745 
%                                      0.1875   -0.0695    0.3745
%                                     -0.1875   -0.0695    0.3745 
%                                      0 0 0]';
%          model.markers.lines = [1 3; 2 4; 3 4; 5 6; 5 7; 6 8; 8 10; 7 9; 15 5; 15 6];
%          model.markers.ind = [1 2 5;2 3 5;3 4 5;4 1 5];

        model.markers.name = {'pelvis', 'thorax', 'shoulder', 'head', 'thighR', 'thighL',...
            'shankR', 'shankL', 'footR', 'footL', 'uarmR','uramL', 'larmR', 'larmL',  'handR', 'handL'};
        model.markers.collisionP = [11 4;12 4;
                                    11 2;12 2;
                                    11 1;12 1;
                                    13 2;14 2;
                                    13 1;14 1;
                                    13 4;14 4;
                                    14 6;13 5;
                                    15 1;16 1;
                                    15 5;16 6];
% %         sum of the max length semi axis for segments of constraints pairs
        model.markers.dmin = [0.085;0.085;0.11;0.11;0.11;0.11;0.1;...
            0.1;0.1;0.1;0.075;0.075;0.08;0.08;0.1;0.1;0.08;0.08];
%         model.markers.dmax = [Inf;Inf;Inf;Inf;Inf;Inf;Inf;...
%             Inf;Inf;Inf;Inf;Inf;Inf;Inf;Inf;Inf;Inf;Inf];
        model.markers.parent = [6 6 6 6 6 6 6 6 6 6 8 10 8 10 8 10];
        model.markers.coordinates = [0 0 0; 
                                     0 0.01 0.2530; 
                                     0 0.0205 0.4719; 
                                     0 0.018 0.6498; 
                                     0.0941 0.01 -0.19; 
                                    -0.0941 0.01 -0.19; 
                                     0.0941 0.01 -0.55; 
                                    -0.0941 0.01 -0.55; 
                                     0.0941 0.0769 -0.72; 
                                    -0.0941 0.0769 -0.72; 
                                     0 0 -0.13;
                                     0 0 -0.13;
                                     0 0 -0.37;
                                     0 0 -0.37; 
                                     0 0 -0.5426
                                     0 0 -0.5426]';
        model.markers.param = [0.096 0.05 0.0941;
                               0.12 0.05 0.15891;
                               0.1875 0.0305 0.06;...
                               0.05 0.06 0.11788;
                               0.05 0.05 0.19;
                               0.05 0.05 0.19;
                               0.03 0.04 0.17;
                               0.03 0.04 0.17;
                               0.02 0.06639 0.01;
                               0.02 0.06639 0.01;
                               0.035 0.03 0.13;
                               0.035 0.03 0.13;
                               0.025 0.01 0.11;
                               0.025 0.01 0.11;
                               0.03 0.006 0.06257;
                               0.03 0.006 0.06257];

        model = floatbase(model);         
        
        model.nq = model.NB;

        q0    = zeros(model.nq,1);
        v0    = zeros(model.nq,1);
        tau0  = zeros(model.nq,1);

        v0(model.dof.Tz,1) = 4.9;%5;%6;
        v0(model.dof.Somer,1)=6.3;
        q0(model.dof.RighArmY,1) = -3.0;
        q0(model.dof.LeftArmY,1) = 3.0;

        data.x0 = [q0; v0];
        model.nx = model.nq+model.nq;
        model.nu = model.nq-6;
        data.u0 = tau0(7:end);

        model.idx_q = 1:model.nq;
        model.idx_v = model.nq+1:2*model.nq;

%         xmin    = [-inf,-inf,-inf,    -inf, -1, -inf,     -0.2, -3.14,     -1.4, 0  ];
%         xmax    = [ inf, inf, inf,     inf,  1,  inf,      1.4,  0,         0.2, 3.14];
        xmin    = [-inf,-inf,-inf,    -inf, -pi/4, -inf,     -0.8, -3.1,     -2.25, 0.1  ];
        xmax    = [ inf, inf, inf,     inf,  pi/4,  inf,     2.25, -0.1,      0.8, 3.1];
%         xmin    = [-10000,-10000,-10000,    -10000, -pi/4, -10000,     -0.8, -3.1,     -2.25, 0.1  ];
%         xmax    = [ 10000, 10000, 10000,     10000,  pi/4,  10000,     2.25, -0.1,      0.8, 3.1];

        model.xmin   =  [xmin, -inf,-inf,-inf,   -inf,-inf,-inf,    -10, -100, -10, -100]';
        model.xmax   =  [xmax,  inf, inf, inf,    inf, inf, inf,     10,  100,  10,  100]';
%         model.xmin   =  [xmin, -10000,-10000,-10000,   -10000,-10000,-1000,    -100, -100, -100, -100]';
%         model.xmax   =  [xmax,  10000, 10000, 10000,    10000, 10000, 10000,     100,  100,  100,  100]';

%         model.xmin   =  [xmin, -inf,-inf,-inf,   -inf,-inf,-inf,    -10, -40, -10, -40]';
%         model.xmax   =  [xmax,  inf, inf, inf,    inf, inf, inf,     10,  40,  10,  40]';
       
%         x_0      = zeros(nx,1);
        model.umin = [-5; -50; -5; -50];
        model.umax = [ 5;  50;  5;  50];
%         model.umin = [-50; -50; -50; -50];
%         model.umax = [ 50;  50;  50;  50];
        
        model.DOFname = {'Tx';'Ty';'Tz';'Somersault';'Tilt';'Twist';...
        'Right Arm PoE'; 'Righ Arm Elevation'; 'Left Arm PoE'; 'Left Arm Elevation'};
        model.Unitname = {'m';'m';'m';'Rev';'deg';'Rev'; 'deg'; 'deg'; 'deg'; 'deg'};
        model.Unitcoef = [1 1 1, 1/(2*pi), 180/pi, 1/(2*pi),   180/pi, 180/pi,   180/pi, 180/pi];
        model.Scaling.q = [.1 .1 2, 10 1 10, 10 3, 10 3]';
        model.Scaling.v = [1 1 6, 3 3 10, 100 50, 100 50]';
        model.Scaling.u = [5 50 5 50]';
        model.Scaling.x = [model.Scaling.q; model.Scaling.v];
    case '10b'
        
        Tz=3;
        Somer=4;
        model.Twist=6;
        
        model.NB = 5;
        model.jtype = {'R',  'Rz','Rx',   'Ry', 'Rz'};
                      %1   2  3  4  5
        model.parent = [0, 1, 2, 1, 4];

        model.Xtree = {SX.eye(6), ...
            xlt([0., 0.010, 0.110 ]+[ 0.035, 0.0205, 0.2645]+[ 0.1525, 0., 0.]),  SX.eye(6), ...%right arm
            xlt([0., 0.010, 0.110 ]+[-0.035, 0.0205, 0.2645]+[-0.1525, 0., 0.]),  SX.eye(6)};   %left arm

        MGbras = SX.zeros(1,3); MGbras(3) = -0.233088;
        
        model.I = {mcI(52.5892, [4.61176e-18  0.00965155  -0.0479683],[7.85829  1.37295e-18 -2.40392e-17;  
                                                                       1.37295e-18      8.12771    0.0239748; 
                                                                       -2.40392e-17    0.0239748     0.518018]), ...
            SX.zeros(6,6),    mcI(3.106, MGbras, diag([0.0910283,0.0909983,0.00292])), ...
            SX.zeros(6,6),    mcI(3.106, MGbras, diag([0.0910283,0.0909983,0.00292])) } ;
        model = floatbase(model);         
        
        model.nq = model.NB;

        q0    = zeros(model.nq,1);
        v0    = zeros(model.nq,1);
        tau0  = zeros(model.nq,1);

        v0(Tz,1) = 6;
        v0(Somer,1)=6.3;
        q0(7,1) = -3.0;
        q0(9,1) =  3.0;


        data.x0 = [q0; v0];
        model.nx = model.nq+model.nq;
        model.nu = model.nq-6;
        data.u0 = tau0(7:end);

        model.idx_q = 1:model.nq;
        model.idx_v = model.nq+1:2*model.nq;

%         xmin    = [-inf,-inf,-inf,    -inf, -1, -inf,     -0.2, -3.14,     -1.4, 0  ];
%         xmax    = [ inf, inf, inf,     inf,  1,  inf,      1.4,  0,         0.2, 3.14];
        xmin    = [-inf,-inf,-inf,    -inf, -1, -inf,     -3.14, -1.5,     0, -1.5  ];
        xmax    = [ inf, inf, inf,     inf,  1,  inf,      0,     1.5,     3.15, 1.5];

%         model.xmin   =  [xmin, -inf,-inf,-inf,   -inf,-inf,-inf,    -100, -100, -100, -100]';
%         model.xmax   =  [xmax,  inf, inf, inf,    inf, inf, inf,     100,  100,  100,  100]';

        model.xmin   =  [xmin, -inf,-inf,-inf,   -inf,-inf,-inf,    -10, -100, -10, -100]';
        model.xmax   =  [xmax,  inf, inf, inf,    inf, inf, inf,     10,  100,  10,  100]';

        
%         x_0      = zeros(nx,1);
        model.umin = [-5; -50; -5; -50];
        model.umax = [ 5;  50;  5;  50];
        
        model.DOFname = {'Tx';'Ty';'Tz';'Somersault';'Tilt';'Twist';...
        'Right Arm Abd'; 'Righ Arm Flex'; 'Left Arm Abd'; 'Left Arm Flex'};
        model.Unitname = {'m';'m';'m';'Rev';'deg';'Rev'; 'deg'; 'deg'; 'deg'; 'deg'};
        model.Unitcoef = [1 1 1, 1/(2*pi), 180/pi, 1/(2*pi),   180/pi, 180/pi,   180/pi, 180/pi];
        model.Scaling.q = [.1 .1 2, 10 1 10, 10 3, 10 3]';
        model.Scaling.v = [1 1 6, 3 3 10, 100 50, 100 50]';
        model.Scaling.u = [5 50 5 50]';
        model.Scaling.x = [model.Scaling.q; model.Scaling.v];

end

