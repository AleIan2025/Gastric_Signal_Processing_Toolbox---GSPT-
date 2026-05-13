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

First, ensure that the folder containing the GSPT code is visible to MATLAB. If it is not, simply run the command `addpath('YOUR\PATH')` in the Command Window, specifying the folder where the GSPT files are located on your computer.

You can run GSPT using the script `EGG_main_multichannel_v4_with_choice`. Before running it, ensure you update the lines of code highlighted in the red boxes in the figure below to suit your needs.

<img width="530" height="460" alt="initial_lines" src="https://github.com/user-attachments/assets/a2e45fda-96ff-49a4-8a95-588e52bc7fdf" />

These are, respectively:

* Output folder: The directory where gastric features will be saved across three different Excel files. You can choose any path on your PC.
* FieldTrip path: The location of the FieldTrip toolbox on your computer.
* Dataset path: The path to the dataset you wish to analyze.

Additionally, you may need to modify the `cfg.channel` structure to match the channel names of your specific recording. You can select channels in several ways, such as selecting all of them or filtering them by a common identifier.

Once these lines have been correctly modified, a window will appear as shown in the figure below:


<img width="445" height="258" alt="initial_choice_pipeline" src="https://github.com/user-attachments/assets/3db85188-d672-4dc7-9119-3838ca3668e2" />


You can now choose to run GSPT in two different modes:

* **Conditional (RP control)**: Performs a preliminary check for movement or spike-like artifacts in the selected channel using Monte Carlo Random Shuffling surrogate testing.
* **Forced (always localize)**: No preliminary check is performed; the algorithm proceeds directly to localization.

If the **Conditional** option is selected, GSPT will run the artifact localization and removal algorithm only if the Monte Carlo (MC) test detects that the signal is affected by movement or spike-like artifacts. An example of the two possible outcomes can be seen in the figures below

<img width="415" height="371" alt="MC_test_spike_anomalies_found" src="https://github.com/user-attachments/assets/9397b1a7-fca8-4a0d-8be8-ba60fb175e5e" /> <img width="415" height="371" alt="MC_spike_test" src="https://github.com/user-attachments/assets/13416fee-0a26-4fef-a86e-618dae117dff" />

If the **Forced** option is selected, artifact localization and removal are performed by default. This latter mode protects against an excessive number of false positives at the expense of losing some true positives. Conversely, the Conditional option is more aggressive, leading to a higher number of true positives at the cost of more false positives. The choice between the two is left to the user's specific needs.


## Output files

Once GSPT has finished, it will save three different files in your slected Output folder:
* **Single_channel_parameters**: a combination of many features describing each single channel separately. You will find classical metrics like the dominant frequency and others like TFR Renyi Entropy or the Lyapunov exponent
* **Total_correlation_and_multivariate_entropies**: metrics describing the overall correlation and complexity of all the channels in the recording
* **Instantaneous_curves**: the intantaneous Phase, Frequency and Amplitude of the fundamental gastric normogastric components

Together with gastric features there are also other importat colums in the **Single_channel_parameters** file:


<img width="601" height="76" alt="nuovo_single_channel_excel" src="https://github.com/user-attachments/assets/6d94164a-1274-48b9-bbcc-7f72193a0ba9" />

* **Fraction_of_contaminated_signal**: the ratio between the duration of time intervals labeled as anomalies (and therefore removed) and the total length of that specific signal
* **is_noise**: the results of a quality check via Monte Carlo surrogates (IAAFWT surrogates) if is_noise is yes, the EGG features for that channel are not distinguisheable from IAAFWT noise according to the test
* **CV_selection_low_0.5CPM**: a recording selection based on dominant frequency (DF) coherence between different EGG channels. Tha maximum DF difference between the channel for this threhsold is set to 0.5 cmp or 0.0083 Hz
* **CV_selection_low_1CPM**: a recording selection based on dominant frequency (DF) coherence between different EGG channels. The maximum DF difference between the channel for this threhsold is set to 1 cmp or 0.016 Hz
* **CV_selection_low_2CPM**: a recording selection based on dominant frequency (DF) coherence between different EGG channels. The maximum DF difference between the channel for this threhsold is set to 2 cmp or 0.033 Hz

All these columns can serve as data selection tools. For example, if a channel has a **Fraction_of_contaminated_signal** of 0.9, it means that only 10% of the signal is free from anomalies and you may want to discard the data from this channel.
The selection based on CV is proposed with three different thresholds, the choise to be more or less selective is left to the user.




