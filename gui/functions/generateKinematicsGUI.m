function generateKinematicsGUI(model, data, qvu, rep, f, display)

ODEMethod = data.odeMethod;

if isfield(data, 'Duration')
    t = data.Duration;
else
    t = data.t_opt;
end

%generate integrated solution
q_opt = qvu(1:model.nq,:,rep);
v_opt = qvu(model.nq+1:model.nx,:,rep);
u_opt = qvu(model.nx+1:model.nx+model.nu,:,rep);
if data.Nint <= 100
    for i=1:size(q_opt,2)-1
        x = [q_opt(:,i); v_opt(:,i)];
        u = u_opt(:,i);
        if strcmpi(ODEMethod,'rk4_dt')
            if strcmpi(data.dt,'log'), DT = -log((i+1)/(data.Nint+1))/data.Nint*t;
            elseif strcmpi(data.dt,'a'), DT = (0.005+1/data.Nint*(1-fix(i*10/data.Nint)/data.Nint))*t;
            end
            [~,~,xi]= model.odeF(x,u,DT);
        else
            [~,~,xi]= model.odeF(x,u);
        end
        xi = full(xi);
        q_int(:,(i-1)*4+1:i*4) = xi(1:model.nq,1:4);
    end
else
    q_int = q_opt;
end

clear X
for i=size(q_int, 2):-1:1
    [xp] = model.ForKin(q_int(:,i));
    X(:,:,i) = full(xp);
end
X = reshape(X,3,[])';
minX = min(X); maxX=max(X);

for j=1:size(q_int, 2)
    cla
    if strcmpi(display, 'all')
        [xp] = model.ForKin(q_int(:,j));
        X = full(xp);
    else
        [xp] = model.ForKin2(q_int(:,j));
        RT = full(xp);
    end
    plot3(f, [minX(1)-0.15 maxX(1)+0.15], [minX(2) maxX(2)],[minX(3) maxX(3)],'k.')
    %pelvis - thorax - shoulder - head - uarm - larm - hand - thigh - shank
    %- foot
    xlabel('x');
    ylabel('y');
    zlabel('z');
    hold on
    param = model.markers.param;
    
    for i=1:size(param)
        parent = model.markers.parent(i);
        coef = model.Unitcoef(parent);
        if strcmpi(display, 'arms')
            X4 = RT((parent-1)*4+1:parent*4,:)*[model.markers.coordinates(:,i);1];
            X(1:3,i) = X4(1:3);
        end
        [x, y, z] = ellipsoid(X(1,i),X(2,i),X(3,i),...
            param(i,1),param(i,2),param(i,3));
        if parent == model.dof.LeftArmY
            S = surf(f, x, y, z, 'FaceColor', 'g', 'EdgeColor', 'none');
            rotate(S, [0 1 0], q_int(parent,j)*coef,[X(1,i),X(2,i),X(3,i)]);
            if strcmpi(model.name,'10')
                rotate(S, [0 0 1], q_int(parent-1,j)*coef,[X(1,i),X(2,i),X(3,i)]);
            end
        elseif parent == model.dof.RighArmY
            S = surf(f, x, y, z, 'FaceColor', 'r', 'EdgeColor', 'none');
            rotate(S, [0 1 0], q_int(parent,j)*coef,[X(1,i),X(2,i),X(3,i)]);
            if strcmpi(model.name,'10')
                rotate(S, [0 0 1], q_int(parent-1,j)*coef,[X(1,i),X(2,i),X(3,i)]);
            end
        else
            S = surf(f, x, y, z, 'FaceColor', 'k');
        end
        if strcmpi(display, 'all')
            rotate(S, [0 0 1], q_int(model.dof.Twist,j)*model.Unitcoef(model.dof.Tilt),[X(1,i),X(2,i),X(3,i)]);
            rotate(S, [0 1 0], q_int(model.dof.Tilt,j)*model.Unitcoef(model.dof.Tilt),[X(1,i),X(2,i),X(3,i)]);
            rotate(S, [1 0 0], q_int(model.dof.Somer,j)*model.Unitcoef(model.dof.Tilt),[X(1,i),X(2,i),X(3,i)]);
        end
    end
    axis image
    drawnow
end
end
