function stated=simple_pend(t,state,parms)

phi=state(1);
phid=state(2);
L=parms.L;
%m=parms.m;
g=-9.81;

% impulse momentum about suspension point:
phidd=cos(phi)*g/L;

stated=[phid; phidd];


