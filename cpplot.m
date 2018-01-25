function cpplot(data)

load(data);
pick=randperm(length(pass(:,1)),40);
%pick=[279,539,409,323];
num1=ceil(length(pick)/4);
frame_time=0.119;
frame_num=1800;
l=0;
t=[0:frame_time:frame_time*frame_num];
t(end)=[];

for f=1:num1

figure

for m=1:4
   if m+l<=length(pick)

ontime=[];
offtime=[];

x=pass(pick(m+l),:);
changePointFound=1;
alpha=0.05;
traj(1).x=x;
traj(1).minIndex=1;
traj(1).active=1;
sec(1).mean=1;
sec(1).state=1;
index=2;
prevMinIndex=1;
cp=[];
llr=[];
dotx=[];
doty=[(min(x)*0.8):0.1:(max(x)*1.15)];

ind=pick(m+l);
text_y=max(x)*1.25;
subplot(2,2,m)
while changePointFound  
    for i=1:length(traj)
        if traj(i).active
            prevMinIndex=traj(i).minIndex;
            [llrOut,kOut]=CPcall(traj(i).x);            
            if length(traj(i).x)>10 && llrOut>CriVal(length(traj(i).x),alpha)                
                changePointFound=1;                                                          
                llr(end+1)=llrOut;
                cp(end+1)=traj(i).minIndex+kOut-1;                               
                dotx=ones(size(doty))*cp(end);
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
        if isempty(dotx)
            continue;
        end
    end
end

cp=sort(cp);
cpnum=length(cp);
sec_mean=[];
ontime(end+1)=0;% ontime always refers to high-intensity state
offtime(end+1)=0;% offtime always refers to low-intensity state
sbr=1.6;

if cpnum>1
for k=1:(cpnum+1)   
    if k==cpnum+1
        break;
    elseif k==1
        sec(k).mean=mean(x(1:cp(k)));
    elseif k==cpnum
        sec(k).mean=mean(x(cp(k-1):cp(k)));
        sec(k+1).mean=mean(x(cp(k):end));
    else
        sec(k).mean=mean(x(cp(k-1):cp(k)));
    end
    sec_mean(end+1)=sec(k).mean;
end
%note that k is the index for section, not change point
sec_mean(end+1)=sec(cpnum+1).mean;

%if min(sec_mean)>150
    bg=min(sec_mean);
%else
%    bg=150;
%end
%modified according to performance on many trajs
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
        end
        
    elseif sec(k-1).state==1 && sec(k).state==1
        if sec(k+1).state~=2
        ontime(end)=ontime(end)+abs(cp(k)-cp(k-1));
        elseif sec(k+1).state==2
            ontime(end)=0;
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

traj=[];
ontime(ontime==0)=[];
offtime(offtime==0)=[];      
cp_true=[];

for c=1:(length(cp)-1)
        dwell=cp-cp(c);            
        find_dwell=ismember(dwell,ontime);
        if isempty(find(find_dwell==1, 1))
            continue
        else            
            cp_true=[cp_true cp(c) cp(find_dwell==1)];
        end        
end    
        if mean(x(1:cp(1)))>1.5*mean(x(cp(1):end))
        cp_true(end+1)=cp(1);
        end       
        cp_true=unique(cp_true);
    
        plot(t,x);        
        xlim([0 t(end)]);
        ylim([0 max(x)*1.4]);
        set(gca,'fontsize',16);
        xlabel('Time (s)','fontsize',16);
        ylabel('Intensity (a.u.)','fontsize',16);
        t_ind=strcat('molecule index:',num2str(ind));
        text(20,text_y,num2str(t_ind),'fontsize',14);
        
        hold on
        for c=1:length(cp_true)
        dotx=ones(size(doty))*cp_true(c);
        plot(dotx*frame_time,doty,'r');
        end
        hold off
       
end      
end
l=f*m;
end
end




