function [cv] = CriVal(N,alpha)

yd=-log(-log(alpha)/2);
x=log(N);
a=sqrt(2*log(x));
b=2*log(x)+log(log(x));
cv=(yd+b)/a;




