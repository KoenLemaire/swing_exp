clear all;
close all

S=[-.2; 2.6]; % [m] left struct
A=[1.7; 2.8]; % [m] anchor
C=[1.4; 0.8]; % [m] connection point on chair
Px=1;
m=1;
g=-1;
Fz=[0; m*g]; % this is the largest force we'll ever get ...  

parms.S=S;
parms.A=A;
parms.C=C;
parms.m=m;
parms.g=g;
parms.Px=Px;

x0=[2.2; 1000; 1000; 300];

optimFun = @(x)construct_swing(x,parms);

% test testfun:
y=feval(optimFun,x0);

% find roots:
x=newt_root(optimFun,x0);

% evaluate if root is really a root:
check=feval(optimFun,x)

Py=x(1)
F1=x(2)
F2=x(3)
Fx=x(4)

P=[Px; Py];

figure;
% plot all points of interest
plot(S(1),S(2),'ko'); hold on
plot(A(1),A(2),'ko')
plot(C(1),C(2),'ko')
plot(Px,Py,'ro')

% plot rope lines:
plot([A(1) Px],[A(2) Py],'k')
plot([C(1) Px],[C(2) Py],'k')
plot([S(1) Px],[S(2) Py],'b')

ylim([0 3])
axis equal

%arrow(Start,Stop,Length)

% calculate rope lengths:

% make unit vectors
PC=C-P; e_PC=PC/norm(PC);
PA=A-P; e_PA=PA/norm(PA);
PS=S-P; e_PS=PS/norm(PS);

% plot forces:
start=P+[.07; 0];
stop=start+e_PA*F2/(-m*g*2);
plot([start(1) stop(1)],[start(2) stop(2)],'r')

start=P+[.07; 0];
stop=start+e_PC*F2/(-m*g*2);
plot([start(1) stop(1)],[start(2) stop(2)],'r')

start=P+[.07; 0];
stop=start-e_PS*F1/(-m*g*2);
plot([start(1) stop(1)],[start(2) stop(2)],'r')


l_support=norm(PS)*2*sqrt(2)
l_side=(norm(PA)+norm(PC))*2
