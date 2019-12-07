
parms.m=60;
parms.L=2;
tspan=[0 10];
state0=[1.25*pi 0];

odeopt=odeset('abstol',1e-9,'reltol',1e-9);

[t,state]=ode113(@simple_pend,tspan,state0,odeopt,parms);

stated=zeros(size(state'));
for i=1:length(t)
    stated(:,i)=simple_pend(t(i),state(i,:),parms);
end
stated=stated';

phi=state(:,1);
phid=state(:,2);
phidd=stated(:,2);

r=parms.L*[cos(phi) sin(phi)];
rd=parms.L*repmat(phid,1,2).*[-sin(phi) cos(phi)];
rdd=parms.L*(repmat(phidd,1,2).*[-sin(phi) cos(phi)] + (repmat(phid,1,2).^2).*[-cos(phi) -sin(phi)]);

Ekin=.5*sum(rd.^2,2);
Epot=parms.L*sin(phi)*9.81;

figure;plot(t,[Epot+Ekin])

figure;subplot(311);plot(t,rdd)
delta_phi=1.75*pi;
a_exp=rdd-9.81*[-cos(phi+delta_phi) -sin(phi+delta_phi)];

[COEFF, pcaData, LATENT] = pca(a_exp,'Centered','on');
subplot(313);plot(t,pcaData)
subplot(312);plot(t,a_exp)

figure;plot(t,r)

Fsum=parms.m*rdd;
Frope=[Fsum(:,1) Fsum(:,2)-9.81*parms.m];