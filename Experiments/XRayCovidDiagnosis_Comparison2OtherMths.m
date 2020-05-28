%% --------------------------
%% Authors: ACDK CVC Team
%% Contact: KtDiaz (kdiaz@cvc.uab.es)/DGil(debora@cvc.uab.es)
%% Version: 28/04/2020
%% --------------------------

%% DESCRIPTION:
% THESE EXPERIMENTS ARE DESIGNED TO EXPLORE
% CAPABILITY OF CLASSICAL FEATURE SPACES FOR COVID DISCRIMINATION IN XRAY
% IA METHODS: SVM CLASSIFIER OVER DCV SPACE ON HOG TRAINED TO DISCRIMINATE
% 4 GROUPS:
% 1) No-covid pneumonia from ChestXray-NIHCC database ('Pneumonia')
% 2) covid pneumonia from 'covid-chest-xray' database ('COVID-19')
% 3) Healthy cases from ChestXray-NIHCC database ('No Finding')
% 4) Infiltrate cases from ChestXray-NIHCC database ('Infiltrate')
%
% VALIDATION: K-FOLD WITH PRECISION AND RECALL ASSESSMENT FOR COVID VS NON-COVID CASES
%             EXPLORATORY ANALYSIS OF THE OPTIMAL SCALE OF THE FILTER
% DATA LINKS:
% ChestXray-NIHCC: http://academictorrents.com/details/557481faacd824c83fbf57dcf7b6da9383b3235a
% covid-chest-xray: https://www.kaggle.com/bachrr/covid-chest-xray
%
% CONCLUSIONS:
% Small scales seem to perform better in terms of detection (recall or sensitivity)
% of NonCovid cases. Equal performance in terms of precision.
% Regarding Covid, small scales also seem better in terms of Covid precision.
% Confidence Intervals in test are:
%     RecallNonCov=[0.8400    0.9749], for scale 4
%     RecallCov=[ 0.7553    0.9224], for scale 4
%     PrecisionNonCov=[ 0.9040    0.9673], for scale 4
%     PrecisionCov=[ 0.7046    0.9277], for scale 4
%     RecallNonCov=[0.8912    0.9555], for scale 8
%     RecallCov=[ 0.7772    0.9184], for scale 8
%     PrecisionNonCov=[0.9119    0.9676], for scale 8
%     PrecisionCov=[ 0.7529    0.8903], for scale 8

%% 0. EXP SET-UP
clear all
CodeDir=[Code Directory];
DataDir=[DataSets Directory];
DataSets={'covid-chest-xray','ChestXray-NIHCC'};

addpath(genpath(CodeDir))
cd(DataDir)

%% 1. LOAD DATA
% 1.1 covid-chest-xray
load([ DataSets{1} filesep 'sampleInfo.mat'])
idx=find([sampleInfo.ClassSample]~=3);
sampleInfo1=sampleInfo(idx);
idx=find([sampleInfo.ClassSample]==2);
sampleInfo1Cov=sampleInfo(idx);

load([DataSets{1} filesep 'Xray.mat'])
D1=D;
DLabels=(getlabels(D1));
DLabelsRed=DLabels(find(DLabels==2));
idx=find(DLabels==2);
Data=getdata(D1);
Data=Data(idx,:);
D1Red=prdataset(Data,uint8(DLabelsRed),'featsize',[400,400]);

% 1.2 ChestXray-NIHCC
load( [DataDir filesep DataSets{2} filesep 'XRayTest.mat'])
D2=D;
load([DataDir filesep DataSets{2} filesep 'sampleTestInfo.mat'])
sampleInfo2=sampleInfo;
F2=unique({sampleInfo.Pathology});

% 1.3 Covid data base complemented with healthy cases from
% CHEST data base
idx={};
for k=1:length(F2)
    idx{k}=find(getlabels(D2)==k);
end
idx3=[idx{10}];
Data1=getdata(D1Red);
Lab1=getlabels(D1Red);
Data2=getdata(D2);
Data2=Data2(idx3,:);
Lab2=getlabels(D2);
Lab2(idx{10})=1;
Lab2=Lab2(idx3);

F3={'No Finding','COVID-19'};

Data=[Data1;Data2];
Lab=[Lab1;Lab2];

DCovHealthy=prdataset(Data,uint8(Lab),'featsize',[400,400]);

% 1.4 Covid data base complemented with pneumonia and healthy cases from
% CHEST data base
idx={};
for k=1:length(F2)
    idx{k}=find(getlabels(D2)==k);
end
idx3=[idx{10};idx{13}];
Data1=getdata(D1Red);
Lab1=getlabels(D1Red);
Data2=getdata(D2);
Data2=Data2(idx3,:);
Lab2=getlabels(D2);
Lab2(idx{10})=3;
Lab2(idx{13})=1;
Lab2=Lab2(idx3);

F3={'Pneumonia','COVID-19', 'No Finding'};

Data=[Data1;Data2];
Lab=[Lab1;Lab2];

DCovNeumoHealthy=prdataset(Data,uint8(Lab),'featsize',[400,400]);

% 1.5 Covid data base complemented with pneumonia cases from
% CHEST data base
idx={};
for k=1:length(F2)
    idx{k}=find(getlabels(D2)==k);
end
idx3=[idx{13}];
Data1=getdata(D1Red);
Lab1=getlabels(D1Red);
Data2=getdata(D2);
Data2=Data2(idx3,:);
Lab2=getlabels(D2);
Lab2(idx{13})=1;
Lab2=Lab2(idx3);

F3={'Pneumonia','COVID-19'};

Data=[Data1;Data2];
Lab=[Lab1;Lab2];

DCovNeumo=prdataset(Data,uint8(Lab),'featsize',[400,400]);


% 1.5 Covid data base complemented with pneumonia cases from
% CHEST data base
idx={};
for k=1:length(F2)
    idx{k}=find(getlabels(D2)==k);
end
idx3=[idx{13}];
Data1=getdata(D1Red);
Lab1=getlabels(D1Red);
Data2=getdata(D2);
Data2=Data2(idx3,:);
Lab2=getlabels(D2);
Lab2(idx{13})=1;
Lab2=Lab2(idx3);

F3={'Pneumonia','COVID-19'};

Data=[Data1;Data2];
Lab=[Lab1;Lab2];

DCovNeumo=prdataset(Data,uint8(Lab),'featsize',[400,400]);

%% 1. FEATURE EXTRACTION
% OBS: Parameters tunned for optimal performance in train set
% Histogram of Oriented Gradients (HoG). The parameter CellSze codifies the
% scale of the descriptor, as well as, the dimensionality of the HoG feature space
% Larger cell sizes capture large scale spatial information at the cost of loosing small
% scale detail and also reduce the dimensionality of the HoG feature space
CellSze=[16,16];
H3={};
HD3{1}=hogData(DCovHealthy,CellSze);
HD3{2}=hogData(DCovNeumoHealthy,CellSze);
HD3{3}=hogData(DCovNeumo,CellSze);

%% 2. CROSS VALIDATION WITH MIXED DATA SET (D3)
% 2.1 KFOLD PARTITION
F=F3;

HD=HD3{1};
Lab={};
NClass=length(F);
for k=1:NClass
    Lab{k}=find(getlabels(HD)==k);
end
% Run these code to have a partition common to all feature spaces
NFold=15;
for k=1:NClass
    cv(k) = cvpartition(length(Lab{k}),'KFold',NFold);
end

% 2.2 K-FOLD TRAIN/TEST
for kH=1:length(HD3)
    HD=HD3{kH};
    
    Data=getdata(HD);
    % A call to this function without last argument cv will compute a
    % different k-fold partition foer each feature space
    [TR,TS]=DefinekFold(Data,Lab,NFold,cv);
    
    for k=1:NFold
        % Train Classifier
        [~, WHD{kH,k}] = dcv_frac(TR{k}, 0.08);
        W=WHD{kH,k};
        TRp = TR{k} * W;
        [Wsvm{kH,k}] = mclassc(TRp,svc,'multi');
    end
    
end

for kH=1:length(HD3)
    HD=HD3{kH};
    Data=getdata(HD);
    % A call to this function without last argument cv will compute a
    % different k-fold partition for each feature space
    [TR,TS]=DefinekFold(Data,Lab,NFold,cv);
    % Assessment
    CovLabel=2;
    NCovLabel=1;
    for k=1:NFold
        LabTR=[];
        LabTS=[];
        for kLab=1:length(Lab)
            LabTR(find(getlabels(TR{k})==kLab),kLab)=1;
            LabTS(find(getlabels(TS{k})==kLab),kLab)=1;
        end
        
        W=WHD{kH,k};
        TRp = TR{k} * W;
        [PrecCovTR(kH,k),RecCovTR(kH,k),PrecNCovTR(kH,k),RecNCovTR(kH,k),AccTR(kH,k),~]=ClassifierAssessment(Wsvm{kH,k},TRp,LabTR,CovLabel,NCovLabel);
        TSp = TS{k} * W;
        [PrecCovTS(kH,k),RecCovTS(kH,k),PrecNCovTS(kH,k),RecNCovTS(kH,k),AccTS(kH,k),~]=ClassifierAssessment(Wsvm{kH,k},TSp,LabTS,CovLabel,NCovLabel);
        
    end
end


% 2.3 STATISTICAL ANALYSIS
% Confidence intervals of quality scores
for kH=1:length(HD3)
    % Test
    [~,~,PrecCICovTS(kH,:),~] = ttest(PrecCovTS(kH,:));
    [~,~,PrecCINCovTS(kH,:),~] = ttest(PrecNCovTS(kH,:));
    [~,~,RecCICovTS(kH,:),~] = ttest(RecCovTS(kH,:));
    [~,~,RecCINCovTS(kH,:),~] = ttest(RecNCovTS(kH,:));
    [~,~,AccCITS(kH,:),~] = ttest(AccTS(kH,:));
end




