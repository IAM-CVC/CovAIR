
%--------------------------
%Author: KtDiaz
%Version: 15/04/2020
%Modification: DGil
%Version: 21/04/2020
%--------------------------

%% 0. EXP SET-UP
CodeDir=[Code Directory];
DataDir=[DataSets Directory];
DataSets={'covid-chest-xray','ChestXray-NIHCC'};
IAMDataDir{2}='ChestXray-NIHCC\Database';
IAMDataDir{1}='covid-chest-xray\images';
kSampSet=[1,4];

addpath(genpath(CodeDir))

kSet=1;
%% 1. LOAD DATA

load([DataDir filesep DataSets{kSet} filesep 'sampleInfo.mat'])
FTS=unique({sampleInfo.Pathology});
DTSLabels=unique([sampleInfo.ClassSample]);

% FTS={'Atelectasis','Effusion','Infiltrate','Mass','Pneumonia','Pneumothorax',...
%     'No Finding','Consolidation','Edema','Emphysema','Fibrosis'};

%% 2. CONVERT 2 PRL STRUCTURE
cd(IAMDataDir{kSet})
kSamp=1;
Data=[];
Newsze=[400,400];
for k=1:kSampSet(kSet):length(sampleInfo)
    
    im=imread([sampleInfo(k).file{1}]);
    if exist(sampleInfo(k).file{1})
        if size(im, 3)==3
            
            im = rgb2gray(im);
            
        end
        aux = mat2gray(imresize(im, Newsze));
        Data(kSamp,:)=aux(:);
        DLab(kSamp)=sampleInfo(k).ClassSample;
        kSamp=kSamp+1;
    end
end

% D = prdataset(+Data(Samples x Features) , nlab (Samples x 1), 'featsize', [image size], 'name', 'XXX')
D=prdataset(Data,uint8(DLab'),'featsize',[400,400]);
save([DataDir filesep DataSets{kSet} filesep 'XRay'],'D');