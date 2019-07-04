function  X = xlt( r)

% xlt  spatial coordinate transform (translation of origin).
% xlt(r)  calculates the coordinate transform matrix from A to B
% coordinates for spatial motion vectors, in which frame B is translated by
% an amount r (3D vector) relative to frame A.  r can be a row or column
% vector.
import casadi.*

% X=SX.sym(sprintf('X_%d',i), 6,6);
X=SX.zeros(6,6);


for i=1:6
    X(i,i)=1;
end

X(4:6,1:3) = [0     r(3) -r(2)
             -r(3)  0     r(1)
              r(2) -r(1)  0 ];


% 
% X = [  1     0     0    0  0  0 ;
%        0     1     0    0  0  0 ;
%        0     0     1    0  0  0 ;
%        0     r(3) -r(2) 1  0  0 ;
%       -r(3)  0     r(1) 0  1  0 ;
%        r(2) -r(1)  0    0  0  1
%     ];
