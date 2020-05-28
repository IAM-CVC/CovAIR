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
DLabelsRed=DLabels;
DLabelsRed(find(DLabels==4))=1;
DLabelsRed(find(DLabels==6))=1;
DLabelsRed(find(DLabels==5))=1;

DLabelsRed=DLabelsRed(find(DLabels~=3));
%DLabelsRed(find(DLabels==3))=1;

%D1Red=setlabels(D1,DLabelsRed);
idx=find(DLabels~=3);
Data=getdata(D1);
Data=Data(idx,:);
D1Red=prdataset(Data,uint8(DLabelsRed),'featsize',[400,400]);

% 1.2 ChestXray-NIHCC
load( [DataDir filesep DataSets{2} filesep 'XRayTest.mat'])
D2=D;
load([DataDir filesep DataSets{2} filesep 'sampleTestInfo.mat'])
sampleInfo2=sampleInfo;
F2=unique({sampleInfo.Pathology});

% 1.3 Covid data based complemented with neumonia, infiltration and healthy cases from
% CHEST data base
idx={};
for k=1:length(F2)
    idx{k}=find(getlabels(D2)==k);
end
idx3=[idx{8};idx{10};idx{13}];
Data1=getdata(D1Red);
Lab1=getlabels(D1Red);
Data2=getdata(D2);
Data2=Data2(idx3,:);
Lab2=getlabels(D2);
Lab2(idx{10})=3;
Lab2(idx{13})=1;
Lab2(idx{8})=4;
Lab2=Lab2(idx3);

F3={'Pneumonia','COVID-19', 'No Finding','Infiltrate'};

Data=[Data1;Data2];
Lab=[Lab1;Lab2];

D3=prdataset(Data,uint8(Lab),'featsize',[400,400]);


%% 1. FEATURE EXTRACTION
% OBS: Parameters tunned for optimal performance in train set
% Histogram of Oriented Gradients (HoG). The parameter CellSze codifies the
% scale of the descriptor, as well as, the dimensionality of the HoG feature space 
% Larger cell sizes capture large scale spatial information at the cost of loosing small
% scale detail and also reduce the dimensionality of the HoG feature space
CellSze=[[4,4];[8,8];[16,16];[32,32]];
for kH=1:size(CellSze,1)
    HD3{kH}=hogData(D3,CellSze(kH,:));
end

%% 2. CROSS VALIDATION WITH MIXED DATA SET (D3)
% 2.1 KFOLD PARTITION
F=F3;
HD=HD3{1};
Lab={};
NClass=length(F);
for k=1:NClass
    Lab{k}=find(getlabels(HD)==k);
end
% Run this code to have a partition common to all feature spaces
NFold=15;
for k=1:NClass
    cv(k) = cvpartition(length(Lab{k}),'KFold',NFold);
end

% 2.2 K-FOLD TRAIN/TEST
for kH=1:length(HD3)
    HD=HD3{kH};
    
    Data=getdata(HD);
    % A call to this function without last argument cv will compute a
    % different k-fold partition for each feature space
    [TR,TS]=DefinekFold(Data,Lab,NFold,cv);
    
    CovLabel=2;
    for k=1:NFold
        % Train Classifier
        [~, WHD{kH,k}] = dcv_frac(TR{k}, 0.08);
        W=WHD{kH,k};
        TRp = TR{k} * W;
        [Wsvm{kH,k}] = mclassc(TRp,svc,'multi');
        
        % Assessment
        LabTR=[];
        LabTS=[];
        for kLab=1:length(Lab)
            LabTR(find(getlabels(TR{k})==kLab),kLab)=1;
            LabTS(find(getlabels(TS{k})==kLab),kLab)=1;
        end
        
        idxTS=(find(cv(CovLabel).training(k)));
        idxEarly=find([sampleInfo1Cov(idxTS).FollowUp]==0)+sum(cv(1).training(k));
        [PrecCovTR(kH,k),RecCovTR(kH,k),PrecNCovTR(kH,k),RecNCovTR(kH,k),RecCovETR(kH,k)]=ClassifierAssessment(Wsvm{kH,k},TRp,LabTR,CovLabel,idxEarly);
        TSp = TS{k} * W;
        idxTS=(find(cv(CovLabel).test(k)));
        idxEarly=find([sampleInfo1Cov(idxTS).FollowUp]==0)+sum(cv(1).test(k));
        [PrecCovTS(kH,k),RecCovTS(kH,k),PrecNCovTS(kH,k),RecNCovTS(kH,k),RecCovETS(kH,k)]=ClassifierAssessment(Wsvm{kH,k},TSp,LabTS,CovLabel,idxEarly);
        
    end
    
end

% 2.3 STATISTICAL ANALYSIS
% Confidence intervals of quality scores
for kH=1:length(HD3)
    % Train
    [~,~,PrecCICovTR(kH,:),~] = ttest(PrecCovTR(kH,:));
    [~,~,PrecCINCovTR(kH,:),~] = ttest(PrecNCovTR(kH,:));
    [~,~,RecCICovTR(kH,:),~] = ttest(RecCovTR(kH,:));
    [~,~,RecCINCovTR(kH,:),~] = ttest(RecNCovTR(kH,:));
    % Test
    [~,~,PrecCICovTS(kH,:),~] = ttest(PrecCovTS(kH,:));
    [~,~,PrecCINCovTS(kH,:),~] = ttest(PrecNCovTS(kH,:));
    [~,~,RecCICovTS(kH,:),~] = ttest(RecCovTS(kH,:));
    [~,~,RecCINCovTS(kH,:),~] = ttest(RecNCovTS(kH,:));
end
% Pair-wise Comparison
IdxPairs=combnk(1:length(HD3),2);
for k=1:size(IdxPairs,1)
    [~,PPrecCovTSPair(k),PrecCICovTSPair(k,:),~] = ttest(PrecCovTS(IdxPairs(k,1),:)-PrecCovTS(IdxPairs(k,2),:));
    [~,PPrecNCovTSPair(k),PrecCINCovTSPair(k,:),~] = ttest(PrecNCovTS(IdxPairs(k,1),:)-PrecNCovTS(IdxPairs(k,2),:));
    [~,PRecCovTSPair(k),RecCICovTSPair(k,:),~] = ttest(RecCovTS(IdxPairs(k,1),:),RecCovTS(IdxPairs(k,2),:));
    [~,PRecNCovTSPair(k),RecCINCovTSPair(k,:),~] = ttest(RecNCovTS(IdxPairs(k,1),:),RecCovTS(IdxPairs(k,2),:));
end

% 2.4 VISUALIZATION
F=F3;
kH=2;
HD=HD3{kH};
Data=getdata(HD);
[TR,TS]=DefinekFold(Data,Lab,NFold,cv);
for kF=1:NFold
    W=WHD{kH,kF};
    TSp = TS{kF} * W;
    TRp = TR{kF} * W;
    NVis=min(3,length(Lab)-1);
    FTS={};
    for k=1:length(F)
        FTS{k}=[F{k},'_TS'];
    end
    TSp=setlabels(TSp,getlabels(TSp)+length(F));
    figure, scatterd([TRp;TSp],NVis), grid on
    legend({F{:},FTS{:}})
    
    axis equal
end




