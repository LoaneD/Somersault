function  X = rotx( theta)

% rotx  spatial coordinate transform (X-axis rotation).
% rotx(theta)  calculates the coordinate transform matrix from A to B
% coordinates for spatial motion vectors, where coordinate frame B is
% rotated by an angle theta (radians) relative to frame A about their
% common X axis.
import casadi.*

c = cos(theta);
s = sin(theta);

% X=SX.sym(sprintf('X_%d',i), 6,6);
X=SX.zeros(6,6);


X(1,1)=1;
X(2,2)=c;
X(3,3)=c;
X(4,4)=1;
X(5,5)=c;
X(6,6)=c;

X(2,3)=s;
X(3,2)=-s;

X(5,6)=s;
X(6,5)=-s;

% X = [ 1  0  0  0  0  0 ;
%       0  c  s  0  0  0 ;
%       0 -s  c  0  0  0 ;
%       0  0  0  1  0  0 ;
%       0  0  0  0  c  s ;
%       0  0  0  0 -s  c
%     ];
