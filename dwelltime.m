function tau = dwelltime(data,bin)
% For exponential fitting using f(x)=a*exp(b*x) for on/off dwelltimes. 11-27-17
if nargin <2
    bin=50;
end

[dis,sec] = hist(data,bin);
options = optimset('Tolfun',1e-16,'MaxFunEvals',100000000,'TolX',1e-16,'DISPLAY','final');
xplot = linspace(0,sec(end),100);
yplot = zeros(1,100);
guess = [max(dis),0.1];
result = fminsearch(@eq,guess,options,sec,dis);

    for i = 1:length(xplot)
       yplot(i) = result(1)*exp(-result(2)*xplot(i)); 
    end 
    hist(data,bin);
    hold on
    plot(xplot,yplot,'r','linewidth',1);
    box on   
        
    %k = result(2)/conc; %exponential term is -k[T] for off-time
    %xlabel('Off-time (s)','fontsize',20);
    %textk = strcat('k_{on} = ',num2str(k,'%.1e'),' M^{-1}s^{-1}');

    tau = 1/result(2); %exponential term is -k for on-time
    xlabel('Off-time (s)','fontsize',20);
    textk = strcat('\tau_{off} = ',num2str(tau,'%.1f'),' s');
    
    ylabel('Count','fontsize',20);
    set(gca,'fontsize',20);
    ylim([0 max(dis)*1.15]);
    text(max(sec)*0.5,max(dis),num2str(textk),'fontsize',16);
    hold off    
end

function chiq = eq(guess,t,count)
    model = zeros(size(count,1),size(count,2));
    for i = 1:length(t)
       model(i) = guess(1)*exp(-guess(2)*t(i)); 
       %exponential fit f(x) = a*exp(b*x);
    end
    chiq = mean((model-count).^2);
end
