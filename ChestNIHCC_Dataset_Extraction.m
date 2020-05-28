%% --------------------------
%% Authors: ACDK CVC Team
%% Contact: CSanchez (csanchez@cvc.uab.es)
%% Version: 28/04/2020
%% --------------------------

%% 0. EXP SET-UP
CodeDir=[Code Directory];
DataDir=[DataSets Directory];

%Name of the subdirectories of the 2 datasets
DataSets={'covid-chest-xray','ChestXray-NIHCC'}; 


addpath(genpath(CodeDir))
DataSet=DataSets{2};
cd([DataDir filesep DataSet])

%% 1. LOAD SAMPLE DATA
%% OBS: Patients having more than one pathology are considered for each pathology 
%% as different cases
load('Data_Entry_2017.mat');
sampleInfo= [];
idx = 1;
for i=1:size(Followup,1)
    patologies = strsplit(FindingLabels{i},'|');
    for j=1:size(patologies,2)
        sampleInfo(idx).file = ImageIndex(i);
        sampleInfo(idx).PatientID = PatientID(i);
        sampleInfo(idx).FollowUp = Followup(i);
        sampleInfo(idx).Gender = PatientGender(i);
        sampleInfo(idx).Age = PatientAge(i);
        sampleInfo(idx).Pathology = patologies{j};
        idx = idx+1;
    end    
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
            sampleInfo(j).ClassSample = i-1;
        end
    end
end
save('sampleInfo.mat','sampleInfo');

%% 2. TRAIN/TEST SETS
numsamplesTrain = 1000;
numsamplesTest = 300;
trainsample = [];
testsample = [];
idxtotalTrain= 1;
idxtotalTest= 1;
for i=1:size(pat,2)
    idxTrain = 1;
    idxTest = 1;
    for j=1:size(sampleInfo,2)
        if numSampPat(i)>=numsamplesTrain
            if strcmp(sampleInfo(j).Pathology,pat{i})
                if(idxTrain<=numsamplesTrain)
                    trainsample(idxtotalTrain).file = sampleInfo(j).file;
                    trainsample(idxtotalTrain).PatientID = sampleInfo(j).PatientID;
                    trainsample(idxtotalTrain).FollowUp = sampleInfo(j).FollowUp;
                    trainsample(idxtotalTrain).Gender = sampleInfo(j).Gender;
                    trainsample(idxtotalTrain).Age = sampleInfo(j).Age;
                    trainsample(idxtotalTrain).Pathology = sampleInfo(j).Pathology;
                    trainsample(idxtotalTrain).ClassSample = i-1;
                    idxTrain = idxTrain+1;
                    idxtotalTrain = idxtotalTrain+1;
                else
                    if (idxTest<=numsamplesTest)
                        testsample(idxtotalTest).file = sampleInfo(j).file;
                        testsample(idxtotalTest).PatientID = sampleInfo(j).PatientID;
                        testsample(idxtotalTest).FollowUp = sampleInfo(j).FollowUp;
                        testsample(idxtotalTest).Gender = sampleInfo(j).Gender;
                        testsample(idxtotalTest).Age = sampleInfo(j).Age;
                        testsample(idxtotalTest).Pathology = sampleInfo(j).Pathology;
                        testsample(idxtotalTest).ClassSample = i-1;
                        idxTest = idxTest+1;
                        idxtotalTest = idxtotalTest+1;  
                    end
                end
            end
        end
    end
end

sampleInfo= trainsample;
save('sampleTrainInfo.mat','sampleInfo');
sampleInfo = testsample;
save('sampleTestInfo.mat','sampleInfo');



