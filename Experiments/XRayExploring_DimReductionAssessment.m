%% EXPERIMENTS TO EXPLORE
%% MOST SUITABLE REDUCTION OF DIMENSIONALITY 
%% IN CAPABILITY HOG FEATURE SPACES FOR COVID DISCRIMINATION IN XRAY
%--------------------------
%Author: DGil
%Version: 12/05/2020
%--------------------------

%% 0. EXP SET-UP
clear all
CodeDir='D:\Experiments\Covid19\XRayCovidScreening\Code\MatLab';
DataDir='D:\Experiments\Covid19\XRayCovidScreening\Data';
DataSets={'covid-chest-xray','ChestXray-NIHCC'};

addpath(genpath(CodeDir))
cd(DataDir)

%% 1. LOAD DATA
% 1.1 Train with covid
load([DataSets{1} filesep 'XrayKate.mat'])
D1=D;
F1 = {'ARDS', 'COVID-19', 'Pneumocystis', 'SARS', 'Streptococcus'};
% Reduced classes for covid cross-validation
% FTRRed={'ARDS-SARS','COVID-19','Other'};
% DLabels=(getlabels(DTR));
% DLabelsRed=DLabels;
% DLabelsRed(find(DLabels==4))=1;
% DLabelsRed(find(DLabels==5))=3;
% D1Red=setlabels(D1,DLabelsRed);

F1Red={'Other','COVID-19'};
DLabels=(getlabels(D1));
DLabelsRed=DLabels;
DLabelsRed(find(DLabels==4))=1;
DLabelsRed(find(DLabels==5))=1;
DLabelsRed(find(DLabels==3))=1;
D1Red=setlabels(D1,DLabelsRed);

% 1.2 Test without covid
load( [DataSets{2} filesep 'XRayTest.mat'])
D2=D;
load([DataDir filesep DataSets{2} filesep 'sampleTestInfo.mat'])
F2=unique({sampleInfo.Pathology});

% FTS={'Atelectasis','Effusion','Infiltrate','Mass','Pneumonia','Pneumothorax',...
%     'No Finding','Consolidation','Edema','Emphysema','Fibrosis'};

% 1.3 Covid data base complemented with pneumonia cases and healthy from
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
CellSze=[4,4];
HD3=hogData(D3,CellSze);


%% 2. EXP3: CROSS VALIDATION WITH MIXED DATA SET (D3)
% Define Train/Test sets
F=F3;
HD=HD3;
Lab={};
for k=1:length(F)
    Lab{k}=find(getlabels(HD)==k);
end

OutIdx=[1:length(F)];
F={F{OutIdx}};
NTr=60;
Data=getdata(HD);
DataTr=[];
DataTs=[];
LabTr=[];
LabTs=[];
for k0=1:length(OutIdx)
    k=OutIdx(k0);
    idx=randperm(length(Lab{k}));
    idxTr=Lab{k}(idx(1:NTr));
    idxTs=Lab{k}(idx(NTr+1:end));
    DataTr=[DataTr;Data(idxTr,:)];
    DataTs=[DataTs;Data(idxTs,:)];
    LabTr=[LabTr;ones(size(idxTr))*k0];
    LabTs=[LabTs;ones(size(idxTs))*k0];
end

TR=prdataset(DataTr,uint8(LabTr));
TS=prdataset(DataTs,uint8(LabTs));


%- PCA using prtools
Wpca = klm(TR); 
%- KPCA 
parameter_train.type = 'r';
parameter_train.S = 0.5; %100; 
[V, kmap, sumK, D_proj] = kpca_map(TR, parameter_train); 
%- QR/LDA
Wlda = qrLda(TR);    
%- DCV 
[~, WHD] = dcv_frac(TR, 0.08);

% VISUALIZATION/TESTING
%- KPCA
TRp = kpca_proj(TR, V, kmap, sumK);
TSp = kpca_proj(TS, V, kmap, sumK);
%- DCV 
W=Wpca;
TRp = TR * W;
TSp = TS * W;

NVis=min(3,length(F)-1);
FTS={};
for k=1:length(F)
    FTS{k}=[F{k},'_TS'];
end
TSp=setlabels(TSp,getlabels(TSp)+length(F));


figure, scatterd([TRp;TSp],NVis), grid on
legend({F{:},FTS{:}})
title('QR/LDA Reduced Space')


figure, scatterd([TRp],NVis), grid on
legend(F{:})
title('PCA Reduced Space for Training')

figure, scatterd([TSp],NVis), grid on
legend(FTS{:})
title('PCA Reduced Space for Testing')



