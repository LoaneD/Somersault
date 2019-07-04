function  X = rotz( theta)

% rotz  spatial coordinate transform (Z-axis rotation).
% rotz(theta)  calculates the coordinate transform matrix from A to B
% coordinates for spatial motion vectors, where coordinate frame B is
% rotated by an angle theta (radians) relative to frame A about their
% common Z axis.
import casadi.*

c = cos(theta);
s = sin(theta);

% X=SX.sym(sprintf('X_%d',i), 6,6);
X=SX.zeros(6,6);


X(1,1)=c;
X(2,2)=c;
X(3,3)=1;
X(4,4)=c;
X(5,5)=c;
X(6,6)=1;

X(1,2)= s;
X(2,1)=-s;

X(4,5)=  s;
X(5,4)= -s;

% X = [  c  s  0  0  0  0 ;
%       -s  c  0  0  0  0 ;
%        0  0  1  0  0  0 ;
%        0  0  0  c  s  0 ;
%        0  0  0 -s  c  0 ;
%        0  0  0  0  0  1
%     ];
