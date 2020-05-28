%% --------------------------
%% Authors: ACDK CVC Team 
%% Contact: DGil(debora@cvc.uab.es)
%% Version: 28/04/2020
%% --------------------------
%==========================================================================
% FUNCTION NAME : [TR,TS]=DefinekFold(Data,Lab,NFold,cv)
%--------------------------------------------------------------------------
% DESCRIPTION : Computes NFold partition of Data class-wise. That is, for
% each class a kfold partition is computed and the final partition is given
% by ensembling all classes folds.
%--------------------------------------------------------------------------
% INPUTS : 
% Data: [NSamples,NFeatures] matrix
% Lab: index of each class in Data
% NFold: Number of folds
% cv (optional): cell array of fold partitions, one for each class. If
% ommited partition is computed here
%--------------------------------------------------------------------------
% OUTPUTS : 
% TR,TS: Matrix of ([NTrainSamp,NFeatures]) training and 
%        ([NTestSamp,NFeatures]) test sets
%---------------------------------------------------------------------------
function [TR,TS]=DefinekFold(Data,Lab,NFold,varargin)

NClass=length(Lab);

if isempty(varargin)
    for k=1:NClass
        cv(k) = cvpartition(length(Lab{k}),'KFold',NFold);
    end
else
    cv=varargin{1};
end

TR={};
TS={};
for kF=1:NFold
    DataTr=[];
    DataTs=[];
    LabTr=[];
    LabTs=[];
    for k=1:NClass
        
        idx=find(cv(k).training(kF));
        idxTr=Lab{k}(idx);
        DataTr=[DataTr;Data(idxTr,:)];
        LabTr=[LabTr;ones(size(idxTr))*k];
        
        idx=find(cv(k).test(kF));
        idxTs=Lab{k}(idx);
        DataTs=[DataTs;Data(idxTs,:)];
        LabTs=[LabTs;ones(size(idxTs))*k];
    end
    
    TR{kF}=prdataset(DataTr,uint8(LabTr));
    TS{kF}=prdataset(DataTs,uint8(LabTs));
end