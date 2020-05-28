%% --------------------------
%% Authors: ACDK CVC Team
%% Contact: CSanchez (csanchez@cvc.uab.es)
%% Version: 28/04/2020
%% --------------------------

%% 0. EXP SET-UP
clear all
CodeDir=[Code Directory];
DataDir=[DataSets Directory];

DataSets={'covid-chest-xray','ChestXray-NIHCC'};


addpath(genpath(CodeDir))
DataSet=DataSets{1};
cd([DataDir filesep DataSet])

ExcelFile='metadata_18_03_2020.xlsx';

%% 1. LOAD SAMPLE META DATA
[ndata, text, alldata] = xlsread(ExcelFile);
PatientID=ndata(:,1);
offset=ndata(:,2);
patologies=alldata(2:end,5);
view=alldata(2:end,17);
modality=alldata(2:end,18);
ImageIndex=alldata(2:end,22);
PatientGender=alldata(2:end,3);
PatientAge=ndata(1:end,4);

% Select PA XRay cases
for k=1:length(modality)
    IsX(k)=strcmp(modality{k},'X-ray');
    IsPA(k)=1-strcmp(view{k},'L');
end
idxXPA=IsX.*IsPA;
idxXPA=find(idxXPA);

sampleInfo= [];
idx = 1;
for j=1:length(idxXPA)
    i=idxXPA(j);
    sampleInfo(idx).file = {ImageIndex{i}};
    sampleInfo(idx).PatientID = PatientID(i);
    sampleInfo(idx).FollowUp = offset(i);
    sampleInfo(idx).Gender = PatientGender(i);
    sampleInfo(idx).Age = PatientAge(i);
    sampleInfo(idx).Pathology = patologies{i};
    idx = idx+1;
    
end


pat = unique({sampleInfo(:).Pathology});
numSampPat = [];
idxSampPat = [];

for i=1:size(pat,2)
    numSampPat(i) = 0;
    idxSampPat{i} = '';
    for j=1:size(sampleInfo,2)
        if strcmp(sampleInfo(j).Pathology,pat{i})
            numSampPat(i) = numSampPat(i)+1;
            idxSampPat{i} = [idxSampPat{i} sampleInfo(j).file];
            sampleInfo(j).ClassSample = i;
        end
    end
end
save('sampleInfo.mat','sampleInfo');





