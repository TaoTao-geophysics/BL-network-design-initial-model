clear;clc;
warning off all;
load train_x.mat;load train_y.mat;load test_y.mat;
train_x = train_x';train_x=log(train_x(:,:));
train_y = train_y';train_y=log(train_y(:,:));
train_x1=train_x(:,:);train_y1=train_y(:,:);
load test_x.mat;
test_x = test_x';test_x = log(test_x(1,:));
test_y = test_y';test_y =log(test_y);
% test_y =train_y(1,:);

assert(isfloat(train_x1), 'train_x must be a float');
assert(isfloat(test_x), 'test_x must be a float');
[m,n]=size(train_y1);fprintf(1, 'row of the train_y.= %d, columns of the train_y. =%d\n', m,n);
[m,n]=size(train_x1);fprintf(1, 'row of the train_x.= %d, columns of the train_x. =%d\n', m,n);
[m,n]=size(test_y);fprintf(1, 'row of the test_y.= %d, columns of the test_y. =%d\n', m,n);
[m,n]=size(test_x);fprintf(1, 'row of the test_x.= %d, columns of the test_x. =%d\n', m,n);

C = 2^-25;      %----C: the regularization parameter for sparse regualarization
s = .8;              %----s: the shrinkage parameter for enhancement nodes
best = 1;
result = [];result1=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% We apply the grid search on the test data set for instance and simplicity
% in this code, however, the reader can easily modify it to perform a grid
% search on validation set by replacing the test set with a validation set.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for Num_i =10:20:10             %searching range for feature nodes  per window in feature layer
       NumFea= Num_i;
    for Num_j=10:20:10            %searching range for number of windows in feature layer
       NumWin=Num_j;
        for Num_k=100:50:100   %searching range for enhancement nodes
            NumEnhan=Num_k;
            rand('state',1);          
            for i=1:NumWin
                WeightFea=2*rand(size(train_x1,2)+1,NumFea)-1;
                %   b1=rand(size(train_x,2)+1,N1);  % sometimes use this may lead to better results, but not for sure!
                WF{i}=WeightFea;
            end    %generating weight and bias matrix for each window in feature layer
            WeightEnhan=2*rand(NumWin*NumFea+1,NumEnhan)-1;
            fprintf(1, 'Fea. No.= %d, Win. No. =%d, Enhan. No. = %d\n', NumFea, NumWin, NumEnhan);
            [NetoutTest, Training_time,Testing_time, train_MAPE,test_MAPE] = bls_train(train_x1,train_y1,test_x,test_y,WF,WeightEnhan,s,C,NumFea,NumWin);
            time =Training_time + Testing_time;
              result1=[real(NumFea), real(NumWin), real(NumEnhan),real(train_MAPE), real(test_MAPE), real(NetoutTest)];
              result=[result;result1;];
            end
            clearvars -except best NumFea NumWin NumEnhan train_x train_y test_x test_y   C s result NetoutTest
        end
    end
    toc
% end
temp_index = find(result(:,5)==min(result(:,5)));
NumFea_hat = result(temp_index,1);
NumWin_hat = result(temp_index,2);
NumEnhan_hat = result(temp_index,3);
train_error_Y1=result(temp_index,4);
test_error_Y1=result(temp_index,5);
Y_hat = result(temp_index,6:end);


save('Y_hat.mat','Y_hat');
fp=fopen('Y_hat.txt','w');
for i=1:length(Y_hat(1,:))
    fprintf(fp,'%15.7f\n',1/Y_hat(i));
end
fclose(fp);

moxing1(1./Y_hat,0);




