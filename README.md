


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

After this selection process, GSPT provides an additional option, as illustrated in the figure below.

<img width="982" height="663" alt="SD_selection_choice" src="https://github.com/user-attachments/assets/ff0d5fca-ab87-44a0-8203-381928b3492c" />

These parameters only affect the level of strictness of one of the quality evaluation methods implemented in GSPT (see the **Dominant frequency (DF) standard deviation (SD) selection** section below for more details); they do not alter the values of the extracted gastric features.

If the Set Custom Thresholds option is selected, the three DF range thresholds can be freely adjusted, as shown in the following figure.

<img width="621" height="486" alt="custom_SD" src="https://github.com/user-attachments/assets/cea1cc71-a94f-43dd-a9f4-1da3d04df866" />


The **default thresholds** were tested on 15-minute resting-state EGG data from 60 healthy participants. Given that healthy subjects are expected to exhibit a clear dominant frequency in the normogastric band under these conditions, an effective channel selection method should increase the proportion of normogastric recordings while reducing tachygastric and bradygastric dominant frequencies. As illustrated in the figure below, the default thresholds successfully achieve this. The resulting frequency proportions, along with the fraction of retained signals, show a good performance of these **default thresholds** on this dataset.

<img width="3300" height="2250" alt="SD_thresholds_Final_Elegance" src="https://github.com/user-attachments/assets/ccda4c34-8c28-424e-bc4c-604d9d56adca" />




## Output files

Once GSPT has finished, it will save three different files in your selected Output folder:

* **Single_channel_parameters**: A collection of features describing each channel individually. This includes classical metrics, such as the dominant frequency, as well as more advanced measures like TFR Renyi Entropy and the Lyapunov exponent.
* **Total_correlation_and_multivariate_entropies**: Metrics describing the overall correlation and complexity across all recorded channels.
* **Instantaneous_curves**: The instantaneous Phase, Frequency, and Amplitude of the fundamental normogastric component.

In addition to the gastric features, the **Single_channel_parameters** file also contains several other important columns:

<img width="1246" height="153" alt="single_ch_clean" src="https://github.com/user-attachments/assets/e51c14dc-20fa-4762-9f91-1c771b94463c" />

**Fraction_of_contaminated_signal** is the ratio between the duration of time intervals labeled as anomalies (and subsequently removed) and the total length of the signal. The other columns represent the results of two proposed channel selection GSPT offers.

Analogously, the **Instantaneous_curves** output file summarizes the channel reliability status based on these selection criteria at the beginning of the dataset

<img width="2169" height="496" alt="inst_curv_clean" src="https://github.com/user-attachments/assets/1d52c3b2-1fe6-4af8-8378-7b7acaf5ea2e" />


Finally, this information is also present in the **Total_correlation_and_multivariate_entropies** file. In this dataset, the metrics are calculated both for the entire set of EGG channels and specifically for the number of channels that successfully meet the various channel selection criteria.


<img width="1243" height="186" alt="tot_cor_clean" src="https://github.com/user-attachments/assets/57e36143-ed4e-4317-967e-be50702e1610" />


All these columns serve as data selection tools. For example, if a channel has a *Fraction_of_contaminated_signal* of 0.9, it means that only 10% of the signal is free from anomalies, suggesting the data from this channel should likely be discarded.
The CV-based selection is provided with three different thresholds; the choice of being more or less conservative is left to the user's discretion.



## Channel selection 

GSPT features two automated algorithms to assess EGG recording quality. 

### Monte Carlo (MC) surrogate slection

The first is a Monte Carlo test using surrogate data (IAAFWT). The underlying logic follows three steps:
* **Surrogate Generation**: Starting from the original EGG time series, the algorithm generates artificial "surrogate" time series. These act as a custom        noise model (the null hypothesis, $H_0$) specifically tailored to your actual data.
* **Feature Extraction**: We calculate two spectral metrics—spectral skewness and spectral sparsity (Hoyer measure)—for both the original signal and all the    generated surrogates.
* **Statistical Testing**: The metrics extracted from the surrogates create an empirical noise distribution. By comparing the original signal's metrics          against this distribution, we compute a p-value to determine if the recording contains true physiological activity or is simply background noise.

Generating surrogate data disrupts the original Power Spectral Density (PSD), scattering its energy across a wider range of frequencies. As a result, spectral sparsity, which measures how tightly the signal's energy is concentrated within a narrow frequency band, will be significantly lower in the surrogates compared to an original signal with a clear, strong peak (a hallmark of a high-quality physiological recording). Likewise, spectral skewness, which quantifies the asymmetry of the PSD amplitude distribution across frequencies, exhibits the same behavior. As illustrated in the figure below, the few exceptionally high values characterizing the physiological peak create a heavy right tail in the distribution. Therefore, both metrics can effectively distinguish background noise from a structured signal featuring a strong dominant peak.

  <img width="4200" height="2400" alt="spec_skew" src="https://github.com/user-attachments/assets/9a8825b2-8416-4ca4-a69f-669a4168d434" />




* **is_noise**: the result of a quality check via Monte Carlo surrogates (IAAFWT). If is_noise is "yes," the EGG features for that channel are not statistically distinguishable from IAAFWT noise.

### Dominant frequency (DF) standard deviation (SD) selection

At rest, a healthy stomach exhibits coherent slow-wave propagation; consequently, the measured Dominant Frequency (DF) should remain independent of the recording electrode. We can leverage this characteristic to perform quality control on EGG recordings by evaluating DF variability, typically indexed by its Standard Deviation (SD). However, the SD of the DF is not an intuitive metric and lacks a direct physiological interpretation. Conversely, the maximum difference in DF across EGG channels—referred to as the DF range—provides a much more intuitive measure. Therefore, a recording can be classified as high-quality if its DF range falls below a predefined threshold. To this end, the GSPT implements three distinct thresholds: strict (0.5 cpm / 0.0083 Hz), medium (1.0 cpm / 0.016 Hz), and loose (2.0 cpm / 0.033 Hz). Hypothesizing that the underlying true DF of a recording is unique, and that cross-channel variations can be modeled as additive Gaussian noise, we can relate the DF range $\Delta_{max}$ to the observed sample SD $s$ via the following formula:

$$s=\Delta_{max} \frac{c_4(n)}{d_2(n)},$$

where n is the number of channels in the recroding and $c_4$ and $d_2$ are costants (Shewhart and Tippett). 

Occasionally, one or more channels in a recording may suffer from specific issues (e.g., defective cables, poor skin contact) that artificially inflate the SD of the recording. To address this, the GSPT implements a recursive algorithm that systematically eliminates the channels contributing the most to the SD of the DF. This process continues until the SD falls below one of the three predefined thresholds, or until only 50% of the initial channels remain (ensuring a minimum of three channels are kept). Consequently, this channel selection algorithm can salvage viable recordings even when specific channels or groups of channels are compromised. The procedure is illustrated in the figure below.


<img width="8400" height="6000" alt="GSPT_Categorization_Flow" src="https://github.com/user-attachments/assets/dcb2827d-ce5e-4f77-9490-01b8dc5fdce4" />

* **CV_selection_low_0.5CPM**: a selection criterion based on Dominant Frequency (DF) coherence across different EGG channels. For this threshold, the maximum DF difference allowed between channels is 0.5 cpm (0.0083 Hz).
* **CV_selection_low_1CPM**: a selection criterion based on Dominant Frequency (DF) coherence across different EGG channels. For this threshold, the maximum DF difference allowed between channels is 1 cmp (0.016 Hz).
* **CV_selection_low_2CPM**: a selection criterion based on Dominant Frequency (DF) coherence across different EGG channels. For this threshold, the maximum DF difference allowed between channels is 2 cmp (0.033 Hz).


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



