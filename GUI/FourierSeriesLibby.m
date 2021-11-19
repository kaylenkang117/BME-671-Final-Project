function [ak,bk,f0,Series] = FourierSeriesLibby(input,order,t)
ak = zeros(1,order);
bk = zeros(1,order);
dt = t(2)-t(1);
T0 = t(end)-t(1)+dt;
f0 = 1/T0;
a0 = 1/T0*sum(input)*dt;
Series = a0*ones(1,length(t));

for i = 1:1:order
    ak(i) = 2/T0.*sum(input.*cos(2*pi*i*f0.*t))*dt;
    bk(i) = 2/T0.*sum(input.*sin(2*pi*i*f0.*t))*dt;
    Series = Series + ak(i).*cos(2*pi*i*f0.*t) + bk(i).*sin(2*pi*i*f0.*t);
end
ak = [a0 ak];
end