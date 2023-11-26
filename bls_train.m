function [NetoutTest, Training_time,Testing_time, train_MAPE,test_MAPE] = bls_train(train_x,train_y,test_x,test_y,WF,WeightEnhan,s,C,NumFea,NumWin)
tic
H1 = [train_x,  0.1 * ones(size(train_x,1),1)];
y=zeros(size(train_x,1),NumWin*NumFea);
for i=1:NumWin
    WeightFea=WF{i};
    A1 = H1 * WeightFea;A1 = mapminmax(A1);%Map matrix row minimum and maximum values to [-1 1].
    clear WeightFea;
    WeightFeaSparse  = sparse_bls(A1,H1,1e-3,50)';
    WFSparse{i}=WeightFeaSparse;
    
    T1 = H1 * WeightFeaSparse;
    [T1,ps1]  =  mapminmax(T1',0,1);
    T1 = T1';
    
    ps(i)=ps1;
    y(:,NumFea*(i-1)+1:NumFea*i)=T1;
end

clear H1;
clear T1;
H2 = [y,  0.1 * ones(size(y,1),1)];

T2 = H2 * WeightEnhan;

% l2 = max(max(T2));
% l2 = s/l2;
%T2 = tansig(T2 * l2);%tansig(x)=2/(1+exp(-2*x))-1

T2 = tansig(T2);
T3=[y T2];
clear H2;
clear T2;

WeightTop = (T3'  *  T3+eye(size(T3',1)) * (C)) \ ( T3'  *  train_y);
%% 

NetoutTrain = T3 * WeightTop;
clear T3;

MAPE = sum(sum( abs((exp(NetoutTrain)-exp(train_y))./exp(train_y)) )/size(train_y,1))/size(train_y,2);
train_MAPE = MAPE;
fprintf(1, 'Training MAPE is: %e\n',MAPE);
Training_time = toc;
% disp('Training has been finished!');
disp(['The Total Training Time is : ', num2str(Training_time), ' seconds' ]);
% tic;

HH1 = [test_x .1 * ones(size(test_x,1),1)];
yy1=zeros(size(test_x,1),NumWin*NumFea);
for i=1:NumWin
    WeightFeaSparse=WFSparse{i};ps1=ps(i);
    TT1 = HH1 * WeightFeaSparse;
    TT1  =  mapminmax('apply',TT1',ps1)';
    
    clear WeightFeaSparse; clear ps1;
    %yy1=[yy1 TT1];
    yy1(:,NumFea*(i-1)+1:NumFea*i)=TT1;
end
clear TT1;clear HH1;
HH2 = [yy1 .1 * ones(size(yy1,1),1)];
% TT2 = tansig(HH2 * b2 * l2);
TT2 = tansig(HH2 * WeightEnhan);
TT3=[yy1 TT2];
clear HH2;clear b2;clear TT2;

NetoutTest = TT3 * WeightTop;

NetoutTest=exp(NetoutTest);%TT2021.11.7
  MAPE=  sum(sum( abs((NetoutTest-exp(test_y))./exp(test_y)))/size(test_y,1))/size(test_y,2);
 fprintf(1, 'Testing MAPE is: %e\n', MAPE);
clear TT3;
test_MAPE = MAPE;
%% Calculate the testing accuracy
Testing_time = toc;
% disp('Testing has been finished!');
disp(['The Testing Time is : ', num2str(Testing_time-Training_time), ' seconds' ]);
disp(['The Total Time is : ', num2str(Testing_time), ' seconds' ]);
disp('.............................................................');
