clc,clear;

data=importdata('3.txt');
startTime=0;
nData = size(data,1)-startTime;
Inputs = zeros(nData,4);
Targets = zeros(nData,1);
Truepose = zeros(nData,2);

Inputs(1:nData,:) = [data(1:nData,7).^2,data(1:nData,11),data(1:nData,12),data(1:nData,13)];

Targets(:,:) = data(1:nData,15);

for i=1:size(Inputs,2)
    Inputs(:,i)=Inputs(:,i)/max(Inputs(:,i));
end
maxTar=max(Targets(:,1));
Targets(:,1)=Targets(:,1)/maxTar;

XTrain=Inputs(1:nData/2+9,:);
YTrain=Targets(1:nData/2+9,:);

in=XTrain;
out=YTrain;
i=1;


while ~isempty(in)
    pick=10;
    if pick<=size(in,1)
        X{i}=(in(1:pick,:))';
        Y(i)=out(pick);
        in(1,:)=[];
        out(1,:)=[];
        i=i+1;
    else
        break;
    end
end

inputSize = 4;
numHiddenUnits = 10;
layers = [ ...
    sequenceInputLayer(inputSize)
    bilstmLayer(numHiddenUnits,'OutputMode','last')
    dropoutLayer(0.05)
    fullyConnectedLayer(1)
    regressionLayer];
maxEpochs = 65;
options = trainingOptions('adam', ...
    'MaxEpochs',maxEpochs, ...
    'InitialLearnRate',0.01, ...
    'MiniBatchSize',12931, ...
    'GradientThreshold',1, ...
    'Shuffle','never', ...
    'Plots','training-progress',...
    'Verbose',0);
net = trainNetwork(X,Y',layers,options);
save('net.mat','net')

trainY=double(predict(net,X));
figure, plot(trainY,'-o')
hold on
plot(Y,'-^')
title('Train Results')
xlabel('Time')
ylabel('Error');
legend('LSTM output','Ground Truth')


clear X Y
XTest=Inputs(nData/2+1:end,:);
YTest=Targets(nData/2+1:end,:);
in=XTest;
out=YTest;
i=1;
while ~isempty(in)
    pick=10;
    if pick<=size(in,1)
        X{i}=(in(1:pick,:))';
        Y(i)=out(pick);
        in(1,:)=[];
        out(1,:)=[];
        i=i+1;
    else
        break
    end
end
testY=double(predict(net,X));
figure, plot(testY,'-o')
hold on
plot(Y,'-^')
title('Test Results')
xlabel('Time')
ylabel('Error)');
legend('LSTM output','Ground Truth')
rmse=sqrt((testY-Y')'*(testY-Y')/(nData/2-9))*maxTar;
result=[numHiddenUnits, maxEpochs, rmse];
