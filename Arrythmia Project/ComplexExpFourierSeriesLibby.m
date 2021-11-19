function [Xk, f0, Series, f] = ComplexExpFourierSeriesLibby(input,order,t)
Xk = zeros(1,order);
dt = t(2)-t(1);
T0 = t(end)-t(1)+dt;
f0 = 1/T0;
[ak,bk,f0,Series] = FourierSeriesLibby(input,order,t);
X0 = ak(1);
Series = X0*ones(1,length(input));
Xk_neg = zeros(1,order);

for k = 1:order
    Xk(k) = (ak(k+1)-1i*bk(k))/2;
    Xk_neg(k) = (ak(k+1)+1i*bk(k))/2;
    Series = Series + Xk_neg(k).*exp(2*pi*1i*-k*f0*t) + Xk(k).*exp(2*pi*1i*k*f0*t);
end
Xk = [flip(Xk_neg) X0 Xk];
f = -order*f0:f0:order*f0;
end
