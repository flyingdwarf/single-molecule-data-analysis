function [sec,on,off,pass]=cppass_sec(data)

int=data;
spot_num=size(int,1);
traj=cell(1,spot_num);
for m=1:spot_num
x=int(m,:);
traj{m}(1).x=x;
traj{m}(1).minIndex=1;
traj{m}(1).active=1;
end

[cp,secmean,ontime,offtime,rawtraj]=arrayfun(@(t) findcp(traj{t}),1:spot_num,'UniformOutput',false);
sec=cell2mat(secmean);
sec(sec==0)=[];
on=cell2mat(ontime);
on(on==0)=[];
off=cell2mat(offtime);
off(off==0)=[];
pass=arrayfun(@(t) traj_check(cp{t},rawtraj{t}),1:spot_num,'UniformOutput',false);
pass=cell2mat(pass');
fake=(pass(:,1)==0);
pass(fake,:)=[];

end

function [cp,secmean,ontime,offtime,peak]=findcp(traj)

peak=traj(1).x;
secmean=[];
ontime=[];
offtime=[];
changePointFound=1;
alpha=0.05;
index=2;
prevMinIndex=1;
llr=[];
cp=[];

while changePointFound 
    for i=1:length(traj)
        if traj(i).active
            prevMinIndex=traj(i).minIndex;
            [llrOut,kOut]=CPcall(traj(i).x);            
            if length(traj(i).x)>10 && llrOut>CriVal(length(traj(i).x),alpha)                 
                changePointFound=1;                                                        
                llr(end+1)=llrOut;
                cp(end+1)=traj(i).minIndex+kOut-1;                                              
                traj(i).active=0;
                traj(index).x=traj(i).x(1:kOut);             
                traj(index).active=1;
                traj(index).minIndex=prevMinIndex;               
                index=index+1;
                traj(index).x=traj(i).x(kOut+1:end);               
                traj(index).active=1;
                traj(index).minIndex=kOut+prevMinIndex-1;                                  
                index=index+1;               
            elseif i==length(traj)               
                changePointFound=0;
                break;              
            elseif traj(i+1).active
                prevMinIndex=traj(i+1).minIndex;
                [llrOut,kOut]=CPcall(traj(i+1).x);
                if length(traj(i+1).x)>10 && llrOut>CriVal(length(traj(i+1).x),alpha)
                llr(end+1)=llrOut;
                cp(end+1)=traj(i+1).minIndex+kOut;              
                traj(i+1).active=0;                                             
                traj(index).x=traj(i+1).x(1:kOut); 
                traj(index).active=1;
                traj(index).minIndex=prevMinIndex;  
                index=index+1;
                traj(index).x=traj(i+1).x(kOut+1:end);               
                traj(index).active=1;
                traj(index).minIndex=kOut+prevMinIndex-1;                                  
                index=index+1;                                                
                end
            end
        end       
    end
end

cp=unique(cp);
%cp=sort(cp);
cpnum=length(cp);
sec_mean=[];
secmean(end+1)=0;
ontime(end+1)=0;
offtime(end+1)=0;
sbr=1.6;

if cpnum>3
for k=1:(cpnum+1)   
    if k==cpnum+1
        break;
    elseif k==1
        sec(k).mean=mean(traj(1).x(1:cp(k)));
    elseif k==cpnum
        sec(k).mean=mean(traj(1).x(cp(k-1):cp(k)));
        sec(k+1).mean=mean(traj(1).x(cp(k):end));
    else
        sec(k).mean=mean(traj(1).x(cp(k-1):cp(k)));
    end
    sec_mean(end+1)=sec(k).mean;
end

sec_mean(end+1)=sec(cpnum+1).mean;

%if min(sec_mean)>150
    bg=min(sec_mean);
%else
%    bg=150;
%end

for k=1:(cpnum+1)
    if k==1 && sec(k).mean>bg*sbr
        sec(k).state=2;
    elseif k==(cpnum+1) && sec(k).mean>bg*sbr
        sec(k).state=2;
    elseif sec(k).mean>bg*sbr
        sec(k).state=1;
    else sec(k).state=0;
    end
end    
    
for k=2:cpnum            
    if sec(k-1).state==2 && sec(k).state==1
        sec(k).state=2;
             
    elseif sec(k-1).state==0 && sec(k).state==1 
        if sec(k+1).state~=2
        ontime(end+1)=abs(cp(k)-cp(k-1));
        secmean(end+1)=sec(k).mean;
        end
        
    elseif sec(k-1).state==1 && sec(k).state==1
        if sec(k+1).state~=2
        secmean(end)=(secmean(end)*ontime(end)+sec(k).mean*abs(cp(k)-cp(k-1)))/(ontime(end)+abs(cp(k)-cp(k-1)));
        ontime(end)=ontime(end)+abs(cp(k)-cp(k-1));
        elseif sec(k+1).state==2
            ontime(end)=0;
            secmean(end)=0;
        end
        
    elseif sec(k-1).state~=0 && sec(k).state==0
       if k~=cpnum
        offtime(end+1)=abs(cp(k)-cp(k-1));
        elseif k==cpnum && sec(k+1).state==2
        offtime(end+1)=abs(cp(k)-cp(k-1));  
       end
    
    elseif sec(k-1).state==0 && sec(k).state==0
        if offtime(end)~=0
            if k==cpnum && sec(k+1).state==0
            offtime(end)=0;            
            else
            offtime(end)=offtime(end)+abs(cp(k)-cp(k-1));
            end
        end
    end
end    
end
end

function pass=traj_check(cp,peak)
if length(cp)<4
    pass=zeros(1,length(peak));
else
    pass=peak;
end
end








 
        
        
