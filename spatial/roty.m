function  X = roty( theta)

% roty  spatial coordinate transform (Y-axis rotation).
% roty(theta)  calculates the coordinate transform matrix from A to B
% coordinates for spatial motion vectors, where coordinate frame B is
% rotated by an angle theta (radians) relative to frame A about their
% common Y axis.
import casadi.*

c = cos(theta);
s = sin(theta);


% X=SX.sym(sprintf('X_%d',i), 6,6);
X=SX.zeros(6,6);


X(1,1)=c;
X(2,2)=1;
X(3,3)=c;
X(4,4)=c;
X(5,5)=1;
X(6,6)=c;

X(1,3)=-s;
X(3,1)= s;

X(4,6)= -s;
X(6,4)=  s;


% X = [ c  0 -s  0  0  0 ;
%       0  1  0  0  0  0 ;
%       s  0  c  0  0  0 ;
%       0  0  0  c  0 -s ;
%       0  0  0  0  1  0 ;
%       0  0  0  s  0  c
%     ];
