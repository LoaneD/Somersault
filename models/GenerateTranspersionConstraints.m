function model = GenerateTranspersionConstraints(model)
% % Generate function giving distances between all segments defined in
% % model.markers.collisionP
% % To be used in NLP constraints definition
% % If distance < sum of arms ray

import casadi.*

% % Get rototranslation matrix in frame of DoF 6
rot = @(x) model.ForKin2(x);
d = SX.sym('d',size(model.markers.collisionP,1),1);
Q = SX.sym('Q', model.nx);
RT = rot(Q(model.idx_q));
dist = @(A,B) sqrt((A(1)-B(1))^2+(A(2)-B(2))^2+(A(3)-B(3))^2);
    
for i=1:size(model.markers.collisionP,1)
    pt1 = model.markers.collisionP(i,1);
    parent1 = model.markers.parent(pt1);
    length1 = model.markers.param(pt1,3);
    coord1 = model.markers.coordinates(:,pt1);
    coordExt11 = RT((parent1-1)*4+1:parent1*4,:)*([coord1;0] + [0 0 length1 1]');
    coordExt12 = RT((parent1-1)*4+1:parent1*4,:)*([coord1;0] - [0 0 length1 -1]');
    
    pt2 = model.markers.collisionP(i,2);
    parent2 = model.markers.parent(pt2);
    length2 = model.markers.param(pt2,3);
    coord2 = model.markers.coordinates(:,pt2);
    coordExt21 = RT((parent2-1)*4+1:parent2*4,:)*([coord2;0] + [0 0 length2 1]');
    coordExt22 = RT((parent2-1)*4+1:parent2*4,:)*([coord2;0] - [0 0 length2 -1]');
    
    A = coordExt11(1:3);B = coordExt12(1:3);
    Y = coordExt22(1:3);X = coordExt21(1:3);
    
    v1 = B - A;
    v2 = Y - X;
    v3 = cross(v1,v2);
    Ax = X(1) - A(1);
    Ay = X(2) - A(2);
    Az = X(3) - A(3);
    
    % % Get the coordinates of closest points on line (AB) and (XY)
    den = v1(1)*v2(2)*v3(3) - v1(1)*v3(2)*v2(3) - v2(1)*v1(2)*v3(3) +...
        v2(1)*v3(2)*v1(3) + v3(1)*v1(2)*v2(3) - v3(1)*v2(2)*v1(3);
    Xs = (Ax*v2(2)*v3(3) - Ax*v3(2)*v2(3) - Ay*v2(1)*v3(3) +...
        Ay*v3(1)*v2(3) + Az*v2(1)*v3(2) - Az*v3(1)*v2(2))/den;
    Z = (Ax*v1(2)*v3(3) - Ax*v3(2)*v1(3) - Ay*v1(1)*v3(3) +...
        Ay*v3(1)*v1(3) + Az*v1(1)*v3(2) - Az*v3(1)*v1(2))/den;
    % % Verify the point is on segment and take the closest if not
    Z = max(Z, 0); Z = min(Z, 1);
    Xs = max(Xs, 0); Xs = min(Xs, 1);
    
    % % Calculates the distance between segments
    d(i,1) = dist(X + Z.*v2, A + Xs.*v1);
end
% % Create function used in NLP constraints definition
model.colD = Function('colD', {Q}, {d}, {'Q'}, {'d'});

end






