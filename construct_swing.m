function err=construct_swing(x,parms)

S=parms.S; % [m] left struct
A=parms.A; % [m] anchor
C=parms.C; % [m] connection point on chair
m=parms.m; % [kg]
g=parms.g; % [m/s^2]
Fz=[0; m*g]; % this is the largest force we'll ever get ...  

P(1,1)=parms.Px;
P(2,1)=x(1);
F1=x(2);
F2=x(3);
Fx=x(4);

% make unit vectors
PC=C-P; e_PC=PC/norm(PC);
PA=A-P; e_PA=PA/norm(PA);
PS=S-P; e_PS=PS/norm(PS);

% force equilibrium at point P:
err1=F1*e_PS + F2*(e_PA+e_PC); % must equal zero

% force equilibrium at point C:
err2=-F2*e_PC + Fz + [Fx; 0];

err=[err1; err2]; % total error vector to be minimized
