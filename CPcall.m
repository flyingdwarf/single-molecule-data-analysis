function [llrt_max,k_max]=CPcall(x)

N=length(x);
wvar=sum(x.^2)/N;
llrt=arrayfun(@(k) lr(k,N,x,wvar),1:N,'uniformoutput',false);
llrt=cell2mat(llrt');
llrt(isinf(llrt))=0;
%llrt(isnan(llrt))=0;
[llrt_max,k_max]=max(llrt);

end

function lrt=lr(k,N,x,wvar)
    
    lvar=sum(x(1:k).^2)/k;     
    rvar=sum(x((k+1):N).^2)/(N-k);    
    lrt=abs(sqrt(N*log(wvar)-k*log(lvar)-(N-k)*log(rvar)));
    
end




