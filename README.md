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

GSPT can be run simply by the file `EGG_main_multichannel_v4_with_choice` by modifiyng according to you needs the lines of code inside the red boxed in the following figure:

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
* preliminary check on the existence of movent or spike-like artifacts in the given channel based on Monte Carlo Randopm Shuffling surrogate testing: Conditional (RP control) (see figure below)

* no preliminary check: Forced (always localize)

If the Conditional option is selected, GSPT will run the artifact localization and removal algorithm only if the MC test finds that the signal is affected by movement or spike-like artifacts.
If the Forced option is selected, the artifact localization and removal will be run by default. The latter protect from an exessive number of false positive at the expense of loosing some true positive;
the former is more aggressive leading to a greater number of true positive at the expense of having more false positive. The choice between the two is left to the needs of the user.

<img width="415" height="371" alt="MC_test_spike_anomalies_found" src="https://github.com/user-attachments/assets/9397b1a7-fca8-4a0d-8be8-ba60fb175e5e" /> <img width="415" height="371" alt="MC_spike_test" src="https://github.com/user-attachments/assets/13416fee-0a26-4fef-a86e-618dae117dff" />

Monte Carlo RP control possible outcomes. Following the results of the figure on the left, the artifact removal algorithm will be run on that specific channel. The opposite is true for the image on the right.


## Output files

Once GSPT has finished, it will save three different files in your slected Output folder:
* Single_channel_parameters: a combination of many features describing each single channel separately. You will find classical metrics like the dominant frequency and others like TFR Renyi Entropy or the Lyapunov exponent
* Total_correlation_and_multivariate_entropies: metrics describing the overall correlation and complexity of all the channels in the recording
* Instantaneous_curves: the intantaneous Phase, Frequency and Amplitude of the fundamental gastric normogastric components

Together with gastric features there are also other importat colums in the Single_channel_parameters file:


<img width="601" height="76" alt="nuovo_single_channel_excel" src="https://github.com/user-attachments/assets/6d94164a-1274-48b9-bbcc-7f72193a0ba9" />

* Fraction_of_contaminated_signal: the ratio between the duration of time intervals labeled as anomalies (and therefore removed) and the total length of that specific signal
* is_noise: the results of a quality check via Monte Carlo surrogates (IAAFWT surrogates) if is_noise is yes, the EGG features for that channel are not distinguisheable from IAAFWT noise according to the test
* CV_selection_low_0.5CPM: a recording selection based on dominant frequency (DF) coherence between different EGG channels. Tha maximum DF difference between the channel for this threhsold is set to 0.5 cmp or 0.0083 Hz
* CV_selection_low_1CPM: a recording selection based on dominant frequency (DF) coherence between different EGG channels. The maximum DF difference between the channel for this threhsold is set to 1 cmp or 0.016 Hz
* CV_selection_low_2CPM: a recording selection based on dominant frequency (DF) coherence between different EGG channels. The maximum DF difference between the channel for this threhsold is set to 2 cmp or 0.033 Hz

All these columns can serve as data selection tools. For example, if a channel has a Fraction_of_contaminated_signal of 0.9, it means that only 10% of the signal is free from anomalies and you may want to discard the data from this channel.
The selection based on CV is proposed with three different thresholds, the choise to be more or less selective is left to the user.




