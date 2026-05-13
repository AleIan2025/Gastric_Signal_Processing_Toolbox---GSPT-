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

First of all, make sure the folder with GSPT codes are visible to MATLAB. If they are not, you can just run the command addpat("YOUR\PATH") in the command line specifing the folder where all the GSPT are on your PC.

GSPT can be run simply by the file __EGG_main_multichannel_v4_with_choice__ by modifiyng according to you needs the lines of code inside the red boxed in the following figure:

<img width="530" height="460" alt="initial_lines" src="https://github.com/user-attachments/assets/a2e45fda-96ff-49a4-8a95-588e52bc7fdf" />

These are respectively:

* An Output folder where gastric features will be saved in three different excel files. You can choose any path on you PC
* The path where filedtrip is located on your PC
* The path to the dataset you want to analysze

Eventually, you will also need to change the cfg.channel structure to adapt it to the names of the channels of your recording. 
You can also select channels in different ways, like selecting them all or select them characterized by a common identifier.

Once you correctly modify these lines, a window will appear as you can see in the figure below:


<img width="445" height="258" alt="initial_choice_pipeline" src="https://github.com/user-attachments/assets/3db85188-d672-4dc7-9119-3838ca3668e2" />


You can now choose to run GSPT with a 
* preliminary check on the existence of movent or spike-like artifacts in the given channel based on Monte Carlo Randopm Shuffling surrogate testing: Conditional (RP control)
* no preliminary check: Forced (always localize)
If the Conditional option is selected, GSPT will run the artifact localization and removal algorithm only if the MC test finds that the signal is affected by movement or spike-like artifacts.
If the Forced option is selected, the artifact localization and removal will be run by default. The latter protect from an exessive number of false positive at the expense of loosing some true positive;
the former is more aggressive leading to a greater number of true positive at the expense of having more false positive. The choice between the two is left to the needs of the user.

<img width="415" height="371" alt="MC_test_spike_anomalies_found" src="https://github.com/user-attachments/assets/9397b1a7-fca8-4a0d-8be8-ba60fb175e5e" /> <img width="415" height="371" alt="MC_spike_test" src="https://github.com/user-attachments/assets/13416fee-0a26-4fef-a86e-618dae117dff" />



When control is on there will be an image generated:

When the red line (the value of original signals IE Tsallis entropy) is significant lower than the distribution of the surrogates, then an artifact is found and GSPT proceeds to run the artifact removal algorithm

