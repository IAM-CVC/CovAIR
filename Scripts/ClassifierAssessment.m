%% --------------------------
%% Authors: ACDK CVC Team 
%% Contact: DGil(debora@cvc.uab.es)
%% Version: 28/04/2020
%% --------------------------
%==========================================================================
% FUNCTION NAME : 
% [PrecCovTR,RecCovTR,PrecNCovTR,RecNCovTR]=ClassifierAssessment(W,Data,LabTR,CovLabel)
%--------------------------------------------------------------------------
% DESCRIPTION : Computes Precision and Recall scores for the samples in
% Data and classifier defined by W
%--------------------------------------------------------------------------
% INPUTS : 
% W: prltools linear classifier
% Data: prltools dataset
% LabTR: [NSamples,NClass] binary matrix indicating each sample class
%        For each sample i, the entry of LabTR(i,:) equal 1 indicates its
%        class
% CovLabel: index(label) of the CovidClass
%--------------------------------------------------------------------------
% OUTPUTS : 
% PrecCovTR,RecCovTR: Precision/Recall for CovidClass
% PrecNCovTR,RecNCovTR: Precision/Recall for Non-CovidClass
%---------------------------------------------------------------------------
function [PrecCovTR,RecCovTR,PrecNCovTR,RecNCovTR,Acc,RecCovTREarly]=ClassifierAssessment(W,Data,LabTR,CovLabel,idxEarly)

    
   
    Prob=getdata(Data*W);
    P=Prob==repmat(max(Prob,[],2),1,size(Prob,2));
    PrecTR=sum((P).*LabTR)./sum(P);
    RecTR=sum((P).*LabTR)./sum(LabTR);
    

    % Covid Scores
    PrecCovTR=PrecTR(:,CovLabel);
    RecCovTR=RecTR(:,CovLabel);
    RecTR=sum((P(idxEarly,:)).*LabTR(idxEarly,:),1)./sum(LabTR(idxEarly,:),1);
    RecCovTREarly=RecTR(:,CovLabel);
    
    % NonCovid Scores
    NCovClass=setdiff(1:size(Prob,2),CovLabel);
    P=max(P(:,NCovClass),[],2);
    PrecNCovTR=sum(P.*sum(LabTR(:,NCovClass),2))/sum((P));
    RecNCovTR=sum(P.*sum(LabTR(:,NCovClass),2))/sum(sum(LabTR(:,NCovClass),2));
    
    % Accuracy
     P=Prob==repmat(max(Prob,[],2),1,size(Prob,2));
     Acc=sum(sum((P).*LabTR))/sum(sum(LabTR));
    