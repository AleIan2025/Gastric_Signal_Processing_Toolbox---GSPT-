# Gastric-Signal-Processing-Toolbox-GSPT
A complete automated pipeline for electrogastrography (EGG) data analysis

## Prerequisites

To run this toolbox, you need:
* **MATLAB** (version R2023a or later)
* The following **MATLAB Toolboxes**:
    * Signal Processing Toolbox
    * Optimization Toolbox
    * Statistics and Machine Learning Toolbox
    * Econometrics Toolbox
    * Predictive Maintenance Toolbox
    * Wavelet Toolbox
    * Fieldtrip 

## How to Run

<img width="445" height="258" alt="initial_choice_pipeline" src="https://github.com/user-attachments/assets/3db85188-d672-4dc7-9119-3838ca3668e2" />


When control is on there will be an image generated:
<img width="415" height="371" alt="MC_test_spike_anomalies_found" src="https://github.com/user-attachments/assets/9397b1a7-fca8-4a0d-8be8-ba60fb175e5e" />
When the red line (the value of original signals IE Tsallis entropy) is significant lower than the distribution of the surrogates, then an artifact is found and GSPT proceeds to run the artifact removal algorithm

