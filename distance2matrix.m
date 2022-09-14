function dist=distance2matrix(X)%distance square matrix
    [ND,D]=size(X);%M samples,D dimensions
    tmp=sum(X.*X,2);
    xx1=repmat(tmp,1,ND);
    xx2=repmat(tmp',ND,1);
    dist=(xx1+xx2-2*X*X');%