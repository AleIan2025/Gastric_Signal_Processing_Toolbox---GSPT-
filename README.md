


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

**Fraction_of_contaminated_signal** is the ratio between the duration of time intervals labeled as anomalies (and subsequently removed) and the total length of the signal. The other columns represent the results of two proposed channel selection GSPT offers.

Analogaousely the **Instantaeous_curves** output file has these columns at the start of the dataset

<img width="2667" height="378" alt="inst_quantities" src="https://github.com/user-attachments/assets/bd73aa78-81fc-45fa-a78c-f1290482fd96" />

Finally, these informations are also present on the **Total_correlation_and_multivariate_entropies** where these quantities are computed one time for all the EGG channels and the also for the number of channels that surpass the various channel selction criteria

<img width="1240" height="183" alt="tot_cor" src="https://github.com/user-attachments/assets/1cef75ad-81bb-4988-ae58-25097f11793a" />



## Channel selection 

GSPT features two automated algorithms to assess EGG recording quality. 

### Monte Carlo (MC) surrogate slection

The first is a Monte Carlo test using surrogate data (IAAFWT). The underlying logic follows three steps:
* **Surrogate Generation**: Starting from the original EGG time series, the algorithm generates artificial "surrogate" time series. These act as a custom        noise model (the null hypothesis, $H_0$) specifically tailored to your actual data.
* **Feature Extraction**: We calculate two spectral metrics—spectral skewness and spectral sparsity (Hoyer measure)—for both the original signal and all the    generated surrogates.
* **Statistical Testing**: The metrics extracted from the surrogates create an empirical noise distribution. By comparing the original signal's metrics          against this distribution, we compute a p-value to determine if the recording contains true physiological activity or is simply background noise.

Generating surrogate data disrupts the original Power Spectral Density (PSD), scattering its energy across a wider range of frequencies. As a result, spectral sparsity, which measures how tightly the signal's energy is concentrated within a narrow frequency band, will be significantly lower in the surrogates compared to an original signal with a clear, strong peak (a hallmark of a high-quality physiological recording). Likewise, spectral skewness, which quantifies the asymmetry of the PSD amplitude distribution across frequencies, exhibits the same behavior. As illustrated in the figure below, the few exceptionally high values characterizing the physiological peak create a heavy right tail in the distribution. Therefore, both metrics can effectively distinguish background noise from a structured signal featuring a strong dominant peak.

  <img width="4200" height="2400" alt="spec_skew" src="https://github.com/user-attachments/assets/9a8825b2-8416-4ca4-a69f-669a4168d434" />


The other one is based on the Dominant Frequency (DF) coherence between the different channels of a recording.

* **is_noise**: the result of a quality check via Monte Carlo surrogates (IAAFWT). If is_noise is "yes," the EGG features for that channel are not statistically distinguishable from IAAFWT noise.

### Dominant frequency (DF) standard deviation (SD) selection

$$s=\Delta_{max} \frac{c_4(n)}{d_2(n)}$$



* **CV_selection_low_0.5CPM**: a selection criterion based on Dominant Frequency (DF) coherence across different EGG channels. For this threshold, the maximum DF difference allowed between channels is 0.5 cpm (0.0083 Hz).
* **CV_selection_low_1CPM**: a selection criterion based on Dominant Frequency (DF) coherence across different EGG channels. For this threshold, the maximum DF difference allowed between channels is 1 cmp (0.016 Hz).
* **CV_selection_low_2CPM**: a selection criterion based on Dominant Frequency (DF) coherence across different EGG channels. For this threshold, the maximum DF difference allowed between channels is 2 cmp (0.033 Hz).

All these columns serve as data selection tools. For example, if a channel has a *Fraction_of_contaminated_signal* of 0.9, it means that only 10% of the signal is free from anomalies, suggesting the data from this channel should likely be discarded.
The CV-based selection is provided with three different thresholds; the choice of being more or less conservative is left to the user's discretion.

<img width="8400" height="6000" alt="GSPT_Categorization_Flow" src="https://github.com/user-attachments/assets/dcb2827d-ce5e-4f77-9490-01b8dc5fdce4" />



## An overview on the gastric features

**GSPT** calculates a total of 32 single channel features, 3 single channel instantaneous curves (amplitude, phase and frequency) and 6 multichannel metrics. 

### Single channel features
The 32 single channel features can be organized as follows:

* **Power Spectrum Density (PSD)** features:
  * **Spectral descriptors**. They quantify some key features of the PSD
     * **Dominant frequency (DF) & power (DP)**. Classical quantities. They provide a good summary of the PSD when the signal exhibits a single strong peak.             However, distinct PSDs can share the same DF and DP despite having very different shapes (Figure F1)
     * **Spectral Centroid (SC) & Spread (SS)**. The "the center of mass of the PSD (Centroid) and its dispersion around it (Spread).  
     * **Spectral (SE) & Tsallis (PSD TE) entropy**. They measure how much the PSD is dispersed.
  * **Spectral powers**. They quantify the power in specific spectral bands: the traditional ones are **bradigastria (0.016-0.033 Hz)**, **normogastria          (0.033-0.067 Hz)** and **tachigastria (0.067 - 0.16 Hz)**. We also introduces **adaptive bands** centered around the DF value: the **Domianant band          (DF $\pm 0.015$ Hz)**, the **Subdominant band (0.016, DF-0.015 Hz)** and the **Superdomianant band (DF+0.015, 0.016 Hz)**
     * **Total normogastric, bradigastric and tachigastric powers**. Computed as the absolute sum of the power across their specific frequency bands.
     * **Mean relative normogastric, bradigastric and tachigastric powers**. the ratio of the mean power density in a specific band (e.g., the normogastric         band) to the sum of the mean power densities across the bradygastria, normogastria, and tachygastria bands. It takes values between 0 and 1. The             power in each band is divided by its frequency width (hence the term "mean" power density) to account for different noise powers across bands.
     * **Mean relative Dominant, Subdominant and Superdominant powers**. These are essentially signal-to-noise ratios (SNRs) comparing the mean power in            different frequency bands
* Features related to the **TFR ridge points**:
  * **Fraction of normogastria**. Here, it is defined as the ratio of the portion of the instantaneous frequency (IF) curve that falls within the                normogastric frequency band (0.033–0.067 Hz) to the total length of the curve (Figure F2).
  * **Mean ridge frequency**
  * **Ridge frequency standard deviation** 
* **Signal's Instantaneous energy (IE)** features. The IE is a curve that evolves over time. Its variability can be characterized by its standard deviation    or entropy.
  * **Mean energy**
  * **Energy standard deviation**
  * **Energy dispersion (IEDisp) & sample (IESamp) entropies**. The higher the entropies, the higher IE vairibility.
* **Time-frequency representation (TFR)** features. They consider the whole TFR, thus combining the time and frequency dimensions. They can quantify the       sparsity, concentration, or regularity of the TFR.
  * **Renyi entropy (RE)**. A high RE indicates that the signal energy is scattered across multiple time and frequency intervals (Figure F3).
  * **Hoyer measure (HM)**. A high HM means the TFR is sparser (Figure F3).
  * **Gradient entropy (GE)**. Considers the TFR as an image and compute the granularity of its texture.
  * **Relative gradient entropy (rGE)**. Same as GE, but compares the irregularity in the dominant band with that in the rest of the TFR.  
* **Filtered gastric signal (0.016-0.16 Hz)** features:
  * **Entropies**. The higher the entropy, the more irregular is the gastric signal
    * **Signal dispersion (SigDisp) & sample (SigSamp) entropy**
  * **Dynamical systems** quantities: 
    * **Correlation Dimension**. Regular periodic signals (e.g., stable heartbeats) exhibit low Correlation dimension, while chaotic systems (e.g.,                turbulent fluid flow) display higher values.
    * **Maximum Lyapunov exponent**. A positive exponent indicates chaotic dynamics: if we identify two distinct moments in the recording where the gastric        activity is nearly identical, their subsequent temporal evolutions will still rapidly and unpredictably diverge.
    * **Detrend Fluctuation Analysis (DFA) exponent**. Quantifies long-range correlations in time series and reflects the likelihood of a value                    increase/decrease being followed by another similar trend.
    * **Active Information Storage (AIS)**. Quantifies the amount of information from a system’s past that is actively used to influence its present state.        High AIS implies strong dependency on historical data. 
 
<img width="7200" height="6000" alt="spectral_descriptors_wow" src="https://github.com/user-attachments/assets/3d15a3e8-2662-4842-b642-624e05954437" />
Figure F1. An example of two different PSDs with the same DF and DP. SC, SS, SE (and PSD TE, not shown here) capture this difference.

 <img width="2240" height="1219" alt="ridge_superlet_curve_sub_07" src="https://github.com/user-attachments/assets/8516e554-81b4-4a92-a7ef-5afc930fbd7f" />
 Figure F2. Ridge points are the points where the TFR reaches its maximum values. The IF curve is obtained from these points using curvature constraints (we expect the instantaneous frequency to be a smooth curve with no sudden jumps). In this example, the entire IF curve (black line) lies within the normogastric band; thus, the fraction of normogastria is 1.

<img width="1901" height="580" alt="Low Renyi entropy" src="https://github.com/user-attachments/assets/451ada8f-5a03-475a-b7b4-58db82faf2db" />
Figure F3. Time-frequency representation (TFR) of an EGG signal obtained via the Superlet Transform. On the left, the TFR of a simple, clean signal. On the right, the TFR of a complex and variable signal.


### Instantaneous quantities

Instantaneous quantities are becoming increasingly important in neuroscience after the discovery of a gastric network coupling stomach activity with brain dynamics. Here, we extract these instantaneous curves of the fundamental gastric component via ridge points, outperforming current Hilbert transform-based approaches. An example of the extracted curves from an EGG signal is shown in Figure F4.

<img width="1609" height="877" alt="Inst_curvevs" src="https://github.com/user-attachments/assets/ef3be2f3-45da-4007-8e44-b691fb2146d4" />
Figure F4. Reconstructed fundamental gastric component from a real EGG recorded signal together with its 3 instantaneous quantities: instantaneous amplitude, phase and frequency.

Analysis of the estimation errors for instantaneous phase, frequency, and amplitude in test signals across various signal-to-noise ratios (SNRs) demonstrates that the ridge method significantly outperforms the conventional approach involving the analytic signal (Figure F5).

<img width="1638" height="1364" alt="Phase_Log" src="https://github.com/user-attachments/assets/0a5563e1-172f-482a-95e3-0cdc90fbd64f" />
Figure F5. Instantaneous phase estimation errors across various SNRs. Each data point is computed from 1,000 independent noise realizations. Markers denote the mean values, and error bars represent the standard deviations.



### Total correlations & Multivariate Entropies

The total correlation is the amount of information shared among the variables in the set, or their redundancy. This concept applied to time series is depicted in Figure F6.

<img width="8400" height="5100" alt="total_correlation_concept_global_legend_labeled" src="https://github.com/user-attachments/assets/0b38f64e-d8d5-4a6e-977b-d6b43ce97e42" />
Figure F6. The concept of total correlation with Venn Diagrams. The more the system contains shared information between the channels, the more is their Total Correlation.



GSPT computes total correlations for different quantities, such as the instantaneous amplitude and phase of the different channels, among others.

GSPT alsto computes multivariate entropies. They represent the total amount of unique information contained within the entire set of variables, effectively quantifying the overall complexity of the network.

In terms of the Venn diagrams in Figure F5, multivariate entropy corresponds to the total area covered by all the circles combined:

* Left Panel (Low Total Correlation): Because the channels are independent, the circles have minimal overlap and spread out, covering a massive total area. This indicates that the network exhibits maximum global complexity and unpredictability (High ME).
* Right Panel (High Total Correlation): Because the channels are synchronized, the circles heavily overlap and collapse onto each other. The total area covered is drastically reduced, meaning the network is highly redundant and predictable, leading to a drop in global complexity (Low ME).







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



