%CCE:Clustering by connection center evolution, 
%2018, Hairong Tang,Xiurui Geng£¬Yi Li(2022,revised)
%output:---
%cc_set:the set of cluster centers for each iteration
%label_set:cluster the set of label for each iteration
%cost_set:the sets of the number of clusters and of the cost function for each iteration
%input:---
%X:origin data,[sample,dimension]
%sigSq2:the square of variance used in Gaussion kernel,
%normalize:normalize similarity matrix if it is 1
%iternum:the number of iteration of CCE
%factor£ºWeighting factor

function [cc_set,label_set,cost_set]=CCE(X,sigSq2,normalize,iternum,factor)

label=0;
if  nargin<1
    clear;
    close all;
    
    %read data
    [filename, pathname] = uigetfile('*.txt', 'Pick a data file','C:\');
    if isequal(filename,0)
       disp('User selected Cancel');
       return;
    else
       X=load(fullfile(pathname, filename));
    end
    normalize=0;
    iternum=100;
      plot(X(:,1),X(:,2),'r.');
      sig=input('sigma=','s');
        if isempty(sig)
            sig=10;
            sigSq2=sig^2;
        else
            sig=str2double(sig);
            sigSq2=sig^2;
        end
        if sigSq2==0
            return;
        end

end

if  nargin==1
    sigSq2=0.1^2;
    normalize=0;
    iternum=50;
end

%calculate distance square matrix******************************
[ND,P]=size(X);%ND samples,P dimensions
dist2= distance2matrix(X);
dist2= dist2.*factor;
  show1=0;
  cn1num=10;%the largest number when cn==1

    %gauss sigma, adjacent matrix
    dc=sigSq2;

    if ND<=500000000
        W=exp(-dist2/dc);

        if (normalize==1) %Normalize
           D=diag( sum(W,2) );
           D=D^(-0.5);
           W=D*W*D;%Normalize
        end

%         if cutdoor~=0
%         end
    end

    dist2=0;

    W0=W;%%%%%%%
    Wk=1;

    cn_set=[];
    cc_set=[];
    label_set=[];
    cost_set=[];
    RI_set=[];
    ARI_set=[];

    for k=1:iternum %interation begin
        Wk=Wk*W;
        Wk=Wk/max(max(Wk));%++++++++++++++++++++++++++++++++++++++++

        cc=[];%cluster center
        for i=1:ND
            if ( Wk(i,i)==max(Wk(i,:)) && Wk(i,i)~=0)
                cc=[cc,i];
            end
        end
        cn=length(cc)%cluster number
        cn_set=[cn_set;cn];


    if cn>50 %too large to cluster%
        continue;
    end
    if cn==0
        return;
    end 


        costfun=0;
        %cluster all points
        label=zeros(1,ND);
        label(cc)=1:cn;
        tmp=diag(Wk);
        tmp=tmp(cc)';            

        for i=1:ND
            [maxd,ind]=max(Wk(i,cc)./tmp);
              if (maxd==0)
                label(i)=0;
                continue;
              end
            label(i)=label(cc(ind));
        end

       costJ_SC=cal_SC_cost(W0,label,cn);
%        if ~isempty(cost_set)
%            if (costJ_SC >= cost_set(end,2) && costJ_SC < 0.3)%0.1
%                return
%            end
%        end
        cost_set=[cost_set;[cn,costJ_SC]];
        cc_set=[cc_set;{cc}];
        label_set=[label_set;label];
        if costJ_SC == 0
            return
        end
        
          if cn==1
              cn1num=cn1num-1;
              if cn1num==0
                  break;
              end
          end

    end%k,iteration times
    %cost_set(find(isnan(cost_set)==1)) = 0
    %label_set(find(isnan(label_set)==1)) = 1
    disp('ok!');
   
function costJ=cal_SC_cost(W,label,K) %Ncut
    [ND,ND]=size(W);
    costJ=0;
     for i=1:K
        tmpi = (label==i);
        tmpNi= (label~=i);
        costJ=costJ+sum(sum(W(tmpi,tmpNi)))/sum(sum(W(tmpi,:)));
     end
     
function dist=distance2matrix(X)%distance square matrix
    [ND,D]=size(X);%M samples,D dimensions
    tmp=sum(X.*X,2);
    xx1=repmat(tmp,1,ND);
    xx2=repmat(tmp',ND,1);
    dist=(xx1+xx2-2*X*X');%