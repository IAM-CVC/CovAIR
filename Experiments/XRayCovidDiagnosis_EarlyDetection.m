%% --------------------------
%% Authors: ACDK CVC Team
%% Contact: KtDiaz (kdiaz@cvc.uab.es)/DGil(debora@cvc.uab.es)
%% Version: 28/04/2020
%% --------------------------

%% DESCRIPTION:
% THESE EXPERIMENTS ARE DESIGNED TO EXPLORE
% CAPABILITY OF CLASSICAL FEATURE SPACES FOR COVID EARLY DETECTION IN XRAY
% IA METHODS: SVM CLASSIFIER OVER DCV SPACE ON HOG WITH CELLSIZE=16
% TRAINED TO DISCRIMINATE 4 GROUPS:
% 1) No-covid pneumonia from ChestXray-NIHCC database ('Pneumonia')
% 2) covid pneumonia from 'covid-chest-xray' database ('COVID-19')
% 3) Healthy cases from ChestXray-NIHCC database ('No Finding')
% 4) Infiltrate cases from ChestXray-NIHCC database ('Infiltrate')
%
% VALIDATION: K-FOLD WITH RECALL ASSESSMENT FOR COVID AT EARLY STAGE
% (OFFSET). 
% ANOVA of CORRECT DETECTIONS GROUPED IN 3 CATEGORIES: 
% early covid (offset <=3), mid covid (offset between 3 and 10) and late covid (offset>10)
% DATA LINKS:
% ChestXray-NIHCC: http://academictorrents.com/details/557481faacd824c83fbf57dcf7b6da9383b3235a
% covid-chest-xray: https://www.kaggle.com/bachrr/covid-chest-xray
%
% CONCLUSIONS:
% 

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

% 1.3 Covid data base complemented with pneumonia, infiltrates and healthy cases from
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
CellSze=[16,16];
HD3=hogData(D3,CellSze);


%% 2. CROSS VALIDATION WITH MIXED DATA SET (D3)
% 2.1 KFOLD PARTITION
F=F3;
HD=HD3;
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

HD=HD3;
Data=getdata(HD);
% A call to this function without last argument cv will compute a
% different k-fold partition for each feature space
[TR,TS]=DefinekFold(Data,Lab,NFold,cv);

for k=1:NFold
    % Train Classifier
    [~, WHD{k}] = dcv_frac(TR{k}, 0.08);
    W=WHD{k};
    TRp = TR{k} * W;
    [Wsvm{k}] = mclassc(TRp,svc,'multi');
end



% Assessment
CovLabel=2;
CovTP=0*Lab{CovLabel};
for k=1:NFold
    
    W=WHD{k};
    TSp = HD3 * W;
  
          
    idxTS=(find(cv(CovLabel).test(k)));
    LabTS=(getlabels(HD3)==CovLabel);
    LabTS= LabTS(idxTS);
    Prob=getdata(TSp*Wsvm{k});
    Prob=Prob(idxTS,:);
    P=Prob==repmat(max(Prob,[],2),1,size(Prob,2));
    CovTP(idxTS)=P(:,CovLabel).*LabTS;
     
end



% 2.3 STATISTICAL ANALYSIS: ANOVA of CORRECT DETECTIONS
% GROUPED IN 3 CATEGORIES: early covid (offset <=3), mid covid (offset
% between 3 and 10) and late covid (offset>10)
offset=[sampleInfo1Cov.FollowUp];
idxNan=find(1-isnan(offset));
CovTPNan=CovTP(idxNan);
offset=offset(idxNan);
offset(find((offset>3).*(offset<=10)))=1;
offset(offset<=3)=0;
offset(offset>10)=2;

[P,ANOVATAB,STATS] = anova1(CovTPNan,offset);


