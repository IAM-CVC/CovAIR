
# Covχ
[Project](http://iam.cvc.uab.es/portfolio/covair/) | [Arxiv]()

The main objective of this project is to diagnose and follow up patients with COVID-19 early 
from the analysis of X-ray images. In particular, this project has two main objectives: 
(1) Early detection of CoVID-19; and (2) Monitoring of CoVID-19.

## Prerequisites
- Windows, Linux or OSX.
- Matlab 2016a or more.

## Datasets
Download the datasets: 

- `covid-chest-xray`: 152 images of covid19 [covid-chest-xray](https://www.kaggle.com/bachrr/covid-chest-xray). 
- `NIH Chest X-ray Dataset`: 112120 images of 14 Common Thorax Disease Categories [ChestXray-NIHCC](http://academictorrents.com/details/557481faacd824c83fbf57dcf7b6da9383b3235a). 

## Scripts 

The following scripts are included (see the script itself for detailed help about inputs and outputs):

- `ChestNIHCC_Dataset_Extraction.m`: Extraction of ChestXray-NIHCC dataset from excel information (Data_Entry_2017.mat).
- `covidchestxray_Dataset_Extraction.m`: Extraction of covid-chest-xray dataset dataset from excel information (metadata_18_03_2020.xlsx).
- `ClassifierAssessment.m`:  Computes Precision and Recall scores for the samples in Data and classifier defined by W.
- `DefinekFold.m`: Computes NFold partition of Data class-wise. That is, for each class a kfold partition is computed and the final partition is given by ensembling all classes folds.
- `Export2Excel4R.m`: Exports results to excel.
- `SampleInfo2PRLData.m`: Convert data to PLR structure.

*modify all paths to your local ones

## Experiment

These experiments are disigned to explore capability of classical feature spaces for covid discrimination/early detection in XRAY IA methods: SVM classifier over DCV space on HOG trained to discriminate 4 groups (covid19, pneumonia, infiltrate and no finding). 
(see the script itself for detailed help about inputs and outputs).

- `XRayCovidDiagnosis_Comparison2OtherMths.m`
- `XRayCovidDiagnosis_EarlyDetection.m`
- `XRayCovidDiagnosis_ParameterTunning.m`
- `XRayExploring_DimReductionAssessment.m`


## Citation
If you use this code for your research, please cite our paper:

```

```


## Acknowledgments
