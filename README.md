


<img width="1398" height="752" alt="GSPT_logo" src="https://github.com/user-attachments/assets/0a97c0d1-59d0-46a0-9612-54358fce7b5c" />





# Gastric Signal Processing Toolbox (GSPT)

**GSPT** is a complete and fully automated pipeline for Electrogastrography (EGG) data analysis. Starting from raw EGG data and requiring only a single main script to run with just a **single button press**, **GSPT** provides both **classical** single-channel **metrics**, such as dominant frequency and power, and **advanced measures**, including signal dispersion entropy, correlation dimension, and spectral entropy.

In addition to these quantities, **GSPT** computes the **instantaneous phase, amplitude, and frequency** of gastric activity, alongside new measures of **total correlation** and multivariate entropy across all recorded channels.

**GSPT** supports recordings with an **arbitrary number of channels** and implements several processing steps, including a novel **artifact localization algorithm** with a tested **precision of 90%**. It also features two distinct methods for **estimating feature reliability** based on Monte Carlo surrogate testing and dominant frequency coherence between channels.

By being completely automated and data-driven, **GSPT** aims to be a cornerstone for a **standardized**, **user-friendly**, and **reproducible** EGG processing pipeline.


## GSPT flowchart

<img width="8113" height="8741" alt="Pipeline_flowchart_last" src="https://github.com/user-attachments/assets/55bd8bad-5791-40b0-824f-31409366d81d" />


## Prerequisites

To run this toolbox, you need:
* **MATLAB** (version R2023a or later)
* The following **MATLAB Toolboxes**:
    * Signal Processing Toolbox
    * Audio Toolbox
    * DSP System Toolbox
    * Optimization Toolbox
    * System Identification Toolbox
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

Once GSPT has finished, it will save three different files in your selected Output folder:

* **Single_channel_parameters**: A collection of features describing each channel individually. This includes classical metrics, such as the dominant frequency, as well as more advanced measures like TFR Renyi Entropy and the Lyapunov exponent.
* **Total_correlation_and_multivariate_entropies**: Metrics describing the overall correlation and complexity across all recorded channels.
* **Instantaneous_curves**: The instantaneous Phase, Frequency, and Amplitude of the fundamental normogastric component.

In addition to the gastric features, the **Single_channel_parameters** file also contains several other important columns:


<img width="601" height="76" alt="nuovo_single_channel_excel" src="https://github.com/user-attachments/assets/6d94164a-1274-48b9-bbcc-7f72193a0ba9" />

* **Fraction_of_contaminated_signal**: the ratio between the duration of time intervals labeled as anomalies (and subsequently removed) and the total length of the signal.
* **is_noise**: the result of a quality check via Monte Carlo surrogates (IAAFWT). If is_noise is "yes," the EGG features for that channel are not statistically distinguishable from IAAFWT noise.
* **CV_selection_low_0.5CPM**: a selection criterion based on Dominant Frequency (DF) coherence across different EGG channels. For this threshold, the maximum DF difference allowed between channels is 0.5 cpm (0.0083 Hz).
* **CV_selection_low_1CPM**: a selection criterion based on Dominant Frequency (DF) coherence across different EGG channels. For this threshold, the maximum DF difference allowed between channels is 1 cmp (0.016 Hz).
* **CV_selection_low_2CPM**: a selection criterion based on Dominant Frequency (DF) coherence across different EGG channels. For this threshold, the maximum DF difference allowed between channels is 2 cmp (0.033 Hz).

All these columns serve as data selection tools. For example, if a channel has a *Fraction_of_contaminated_signal* of 0.9, it means that only 10% of the signal is free from anomalies, suggesting the data from this channel should likely be discarded.
The CV-based selection is provided with three different thresholds; the choice of being more or less conservative is left to the user's discretion.


## An overview on the gastric features

GPPT calculates a total of 32 single channel features, 3 single channel instantaneous curves (amplitude, phase and frequency) and 6 multichannel metrics and 3. The 32 singla channel features can be organized as follows:

* Power Spectrum Density (PSD) features:
  * Dominant frequency and power
  * Spectral Centroid
  * Spectral Spread
  * Sectral entropy
  * PSD Tsallis Entropy
* Time frequency representation (TFR) features:
  * Renyi entropy
  * Hoyer measure
  * Gradient entropy
  * Relative gradient entropy  
* Filtered signal features:
  * Signal dispersion entropy
  * Signal sample entropy
  * Correlation Dimension
  * Maximum Lyapunov exponent
  * Detrend Fluctuation Analysis (DFA) exponent
  * Active Information Storage (AIS)
 
<img width="7200" height="6000" alt="spectral_descriptors" src="https://github.com/user-attachments/assets/1a5b6010-3e52-4a38-889a-24a2a60e47bf" />


## Citation

If you use GSPT in your research, please cite it as follows:

> Iannone A., Panasiti M.S., Aglioti S.M., Della Penna S. (2026). GSPT: a full automated pipeline for channel-wise multi-electrod electrogastrography data analysis [Software]. Available from [https://github.com/AleIan2025/Gastric-Signal-Processing-Toolbox-GSPT-](https://github.com/AleIan2025/Gastric-Signal-Processing-Toolbox-GSPT-)

BibTeX entry:

```bibtex
@software{GSPT2026,
  author = {Iannone Alessandro, Panasiti Maria Serena, Aglioti Salvatore Maria, Della Penna Stefania},
  title = {GSPT: Gastric Signal Processing Toolbox},
  url = {([https://github.com/AleIan2025/Gastric-Signal-Processing-Toolbox-GSPT-](https://github.com/AleIan2025/Gastric-Signal-Processing-Toolbox-GSPT-))},
  version = {1.0.0},
  year = {2026}
}



