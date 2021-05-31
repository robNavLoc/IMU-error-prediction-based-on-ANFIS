
clc;
clear;
close all;

% Create Time-Series Data
load('saved.mat')                          % Same as 3.txt
data=importdata('3.txt');                  % Format about 3.txt can be found at ErrorCalculation.m
startTime=0;
nData = size(data,1)-startTime;
Inputs = zeros(nData,7);
Targets = zeros(nData,1);
Truepose = zeros(nData,2);
Inputs(:,:) = [data(startTime+1:nData+startTime,11),data(startTime+1:nData+startTime,12),data(startTime+1:nData+startTime,13),data(startTime+1:nData+startTime,4),data(startTime+1:nData+startTime,5),data(startTime+1:nData+startTime,6),data(startTime+1:nData+startTime,7)];
Targets(:,:) = saved_data(startTime+1:nData+startTime,15);


% Shuffling Data
PERM = randperm(nData); % Permutation to Shuffle Data
pTrain=0.5;
nTrainData=round(pTrain*nData);
TrainInd=1:nTrainData;
TrainInputs=Inputs(TrainInd,:);
TrainTargets=Targets(TrainInd,:);
pTest=1-pTrain;
nTestData=nData-nTrainData;
TestInd=nTrainData+1:nData;
TestInputs=Inputs(TestInd,:);
TestTargets=Targets(TestInd,:);

% Parameter
Prompt={'Influence Radius:'};
Title='Enter genfis2 parameters';
DefaultValues={'0.7'};
PARAMS=inputdlg(Prompt,Title,1,DefaultValues);
pause(0.01);
Radius=str2num(PARAMS{1});
fis=genfis2(TrainInputs,TrainTargets,Radius);

% Training ANFIS Structure
Prompt={'Maximum Number of Epochs:',...
        'Error Goal:',...
        'Initial Step Size:',...
        'Step Size Decrease Rate:',...
        'Step Size Increase Rate:'};
Title='Enter genfis2 parameters';
DefaultValues={'20', '0', '0.01', '0.9', '1.1'};
PARAMS=inputdlg(Prompt,Title,1,DefaultValues);
pause(0.01);
MaxEpoch=str2num(PARAMS{1});
ErrorGoal=str2num(PARAMS{2});
InitialStepSize=str2num(PARAMS{3}); 
StepSizeDecreaseRate=str2num(PARAMS{4});
StepSizeIncreaseRate=str2num(PARAMS{5}); 
TrainOptions=[MaxEpoch ...
              ErrorGoal ...
              InitialStepSize ...
              StepSizeDecreaseRate ...
              StepSizeIncreaseRate];

DisplayInfo=true;
DisplayError=true;
DisplayStepSize=true;
DisplayFinalResult=true;
DisplayOptions=[DisplayInfo ...
                DisplayError ...
                DisplayStepSize ...
                DisplayFinalResult];

OptimizationMethod=1;
% 0: Backpropagation
% 1: Hybrid
            
fis=anfis([TrainInputs TrainTargets],fis,TrainOptions,DisplayOptions,[],OptimizationMethod);


% Apply ANFIS to Data
Outputs=evalfis(Inputs,fis);
TrainOutputs=Outputs(TrainInd,:);
TestOutputs=Outputs(TestInd,:);

% Error Calculation
TrainErrors=TrainTargets-TrainOutputs;
TrainMSE=mean(TrainErrors.^2);
TrainRMSE=sqrt(TrainMSE);
TrainErrorMean=mean(TrainErrors);
TrainErrorSTD=std(TrainErrors);
TestErrors=TestTargets-TestOutputs;
TestMSE=mean(TestErrors.^2);
TestRMSE=sqrt(TestMSE);
TestErrorMean=mean(TestErrors);
TestErrorSTD=std(TestErrors);

% Plot Results
figure;
PlotResults(TrainTargets,TrainOutputs,'Train Data');
figure;
PlotResults(TestTargets,TestOutputs,'Test Data');
figure;
PlotResults(Targets,Outputs,'All Data');

