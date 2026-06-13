# Industrial Vision Inspection and 3D Geometric Reconstruction: From Sensor to 3D Stereo Reconstruction

This project implements an end-to-end industrial computer vision pipeline, bridging the gap between raw hardware sensor physics and 3D geometric vision algorithms. Developed and validated inside the laboratory, this repository contains practical implementations tracking the complete data flow: from photon capture on a CMOS sensor to dense 3D point cloud synthesis.

---

## Hardware & Experimental Setup

To validate our theoretical vision models against real-world physical constraints, we utilized standard industrial-grade laboratory equipment:

* **Stereo Sensor:** **Stereolabs ZEDm Stereo Camera**. This sensor features dual 4-megapixel sensors ($2208 \times 1242$) with a $63\text{ mm}$ baseline (replicating the average human interpupillary distance), widely used in robotics and AR vision.
* **Calibration Target:** A high-precision checkerboard target printed on a durable **$6\text{ mm}$ Alu Dibond** panel, providing rigid planarity to avoid geometric warping during intrinsic/extrinsic parameter extraction.
* **Physical Verification:** A standard metric **plastic ruler** was used as a ground-truth reference to directly benchmark and verify our final 3D spatial reconstruction measurements.

---

## Project Objectives

The main goal here is to understand and quantify how low-level hardware choices (like camera gain or lighting angles) propagate through a vision pipeline and impact final 3D spatial measurements. 

Specifically, we focus on three core areas:
1. **Noise vs. Signal:** Analyzing how hardware amplification (Gain) introduces stochastic noise under aggressive exposure constraints.
2. **Feature Robustness:** Solving edge and blob detection failures caused by non-uniform, high-reflection industrial illumination.
3. **3D Reconstruction:** Implementing sub-pixel accurate calibration and stereo rectification to extract millimeter-level physical metrics from dual 2D images.

---

## Project Modules & Core Implementation

### Module 1: Sensor Noise Analysis and Spatial Filtering
* **Path:** `module_1_noise_and_filters`
* **What it does:** We evaluated CMOS sensor noise profiles using Poisson statistics. By subtracting consecutive frames captured at static luminance, we isolated dark current and thermal noise. We then tested various spatial convolution filters to find the sweet spot between cutting high-frequency noise and keeping important structural edges sharp.

### Module 2: Morphological Feature Extraction and Parameter Space
* **Path:** `module_2_blob_and_features`
* **What it does:** This module handles segmentation stability on challenging surfaces. We experimented with the physics of lighting (Reflected vs. Transmitted Light) to optimize image binarization on metallic parts. Additionally, we used the mathematical duality of the Hough Accumulator Space to isolate linear boundaries without relying on fragile heuristic tracking.

### Module 3: Geometric Calibration and 3D Stereo Reconstruction
* **Path:** `module_3_stereo_reconstruction`
* **What it does:** Built on the Projective Pinhole Camera Model and Epipolar Geometry. We calculated the camera's intrinsic matrix to wipe out radial and tangential lens distortions. After executing coplanar stereo rectification, the 2D correspondence search drops from a heavy 2D grid search down to a fast 1D horizontal line scan, enabling dense depth mapping via Semi-Global Matching (SGM).

---

## Quantitative Performance and Experimental Results

### 1. Sensor Noise and Filter Trade-Offs (Module 1)
Our lab tests clearly showed the heavy trade-off between pumping up hardware gain and maintaining a clean Signal-to-Noise Ratio (SNR).
* **Low-Gain Configuration (0 dB, 101 ms exposure):** Delivered a clean baseline with a mean noise amplitude of $\bar{n} = 1.2163$.
* **High-Gain Configuration (18 dB, 12 ms exposure):** Triggered a massive $7.5\times$ spike in noise amplitude, hitting $\bar{n} = 9.1764$. This proves why maximizing exposure time to capture actual photons is always better than using electronic gain to artificially brighten a dark frame.
* **Filtering Trade-offs:** A large 7x7 Binomial filter successfully dragged noise down to 0.2646, but it completely blurred out fine details. A 3x3 Median filter proved to be the best practical choice for preserving edge boundaries.
* **Edge Operators:** We found that second-order derivative operators like the Laplacian are incredibly brittle when noise is present; without an aggressive Gaussian pre-blur, they generate a lot of false edges. First-order Sobel and Prewitt filters showed much better directional stability.

| Filter Typology | Residual Noise Amplitude | Structural Edge Preservation |
| :--- | :---: | :---: |
| Unfiltered Raw Frame | 1.2163 | Baseline |
| Binomial 3x3 | 0.6052 | Minor Blur |
| Binomial 7x7 | 0.2646 | Heavy Defocusing |
| Median 3x3 | 0.8655 | Excellent Boundaries |

<p align="center">
  <img src="module_1_noise_and_filters/2_noise_filter/results/filter_result.jpg" width="48%" alt="Denoising Matrix Benchmarks"/>
  <img src="module_1_noise_and_filters/2_noise_filter/results/histogram_result.jpg" width="48%" alt="Noise Histogram Shift"/>
</p>
<p align="center">
  <em>Figure 1: Visual comparison of spatial filters (left) and the resulting noise amplitude reduction shown via histogram (right).</em>
</p>

### 2. Illumination Invariant Target Tracking (Module 2)
* **The Problem with Reflected Light:** Direct top-down illumination on metallic objects created massive specular reflections (blooming) and harsh shadows. This ruined the binarization thresholds, causing calculated target areas to bleed into each other and scramble the classification logic.
* **The Solution (Backlighting):** Switching to backlighting (transmitted light) bypassed surface reflections completely, turning the objects into clean, high-contrast silhouettes. The target area statistics immediately split into distinct Bimodal Gaussian Peaks, yielding 100% classification reliability.
* **Hough Line Extraction:** By mapping lines into the Hough Accumulator Space across rotational vectors, our pipeline extracted checkerboard calibration corners directly from the sharp intersections of orthogonal Hough peaks, removing the need for standard tracking tweaks.

<p align="center">
  <img src="module_2_blob_and_features/1_blob_analysis/results/Objects%20with%20Centroids.jpg" width="48%" alt="Reflected Light Saturation Detection Errors"/>
  <img src="module_2_blob_and_features/1_blob_analysis/results/Trasmit%20Light_Objects%20with%20Centroids.jpg" width="48%" alt="Transmitted Light Silhouette Classification"/>
</p>
<p align="center">
  <em>Figure 2: Specular reflection errors under direct Reflected Light (left) versus highly stable silhouette segmentation using Transmitted Backlighting (right).</em>
</p>

### 3. Sub-Pixel Calibration and Dense 3D Synthesis (Module 3)
* **Calibration Precision:** Using a 3-parameter Radial and Tangential distortion model on the Alu Dibond checkerboard data, our camera calibration hit a Mean Reprojection Error of **0.1312 Pixels**, safely beating the industrial standard limit of 0.5 pixels.
* **Testing Homography Limits:** We projectively mapped 2D pixels back to the real-world target plane via extrinsic matrices. When the camera was significantly tilted, a physical ground-truth length of $132.00\text{ mm}$ (measured via our plastic ruler) was calculated by the software as $135.76\text{ mm}$. This puts our absolute measurement error at $3.76\text{ mm}$ ($97.2\%$ accuracy), illustrating how homography approximations degrade when viewing targets from sharp angles.
* **Stereo Depth Generation:** The computed Fundamental Matrix effectively aligned the ZEDm’s left and right views onto perfectly horizontal, coplanar scanlines. The Semi-Global Matching (SGM) algorithm successfully captured complex depth steps inside the lab room, outputting a high-density disparity map.

| Target Calibration Metric | Empirical Estimation Result | Nominal Hardware Specification |
| :--- | :---: | :---: |
| Mean Reprojection Error | 0.1312 Pixels | < 0.5000 Pixels (Pass) |
| Stereo Baseline Distance | 62.89 mm | 63.00 mm (Physical ZEDm Specification) |
| System Measurement Precision | Approx. 97.2% Accuracy | Millimeter-level local tolerance |

<p align="center">
  <img src="module_3_stereo_reconstruction/results/5_3_Epipolar%20Lines.png" width="48%" alt="Aligned Epipolar Geometry Lines"/>
  <img src="module_3_stereo_reconstruction/results/5_4_Stereo%20Rectification.png" width="48%" alt="Stereo Rectified Anaglyph Image"/>
</p>
<p align="center">
  <em>Figure 3: Aligned horizontal 1D Epipolar search lines (left) and the resulting stereo rectified red-cyan anaglyph image (right).</em>
</p>

<p align="center">
  <img src="module_3_stereo_reconstruction/results/5_6_Disparity%20map.png" width="48%" alt="High-density Disparity Field"/>
  <img src="module_3_stereo_reconstruction/results/5_6_Dense%20stereo%20matching%20and%203D-reconstruction.png" width="48%" alt="Reconstructed 3D Point Cloud"/>
</p>
<p align="center">
  <em>Figure 4: Pixel disparity map generated via Semi-Global Matching (left) and the final reprojected 3D Point Cloud (right).</em>
</p>

---

## How to Run the Code

### Prerequisites
The code was built and tested using **MATLAB R2022b** (or later). Make sure you have the required toolboxes installed by running these checks in your MATLAB Command Window:
```matlab
license('test', 'Computer_Vision_Toolbox')
license('test', 'Image_Processing_Toolbox')
```

### Execution Steps

1. **Sensor Noise Analysis:** Run the script at `module_1_noise_and_filters/2_noise_filter/src_code/noise_filter_script.m` to generate the statistical noise and filtering profiles.
2. **Target Tracking & Lighting Test:** Run `module_2_blob_and_features/1_blob_analysis/src_code/blob_coin_counting_pipeline.m` to see the comparison between illumination profiles.
3. **3D Stereo Reconstruction:** Run `module_3_stereo_reconstruction/src_code/stereo_measurements.m` to load the ZEDm calibration parameters, process epipolar geometry, and output the 3D point cloud.

---

## Supervision

This project was developed under the academic guidance and supervision of **Prof. Dr. Stephan Neser** at the University of Applied Sciences Darmstadt (h-da).

* **Supervisor:** Prof. Dr. Stephan Neser
* **Institution:** Hochschule Darmstadt (h-da), Department of FBMN
* **Contact:** [stephan.neser@h-da.de](mailto:stephan.neser@h-da.de) (or visit during designated office times via email appointment)
* **Lab Website:** [www.fbmn.h-da.de/~neser](http://www.fbmn.h-da.de/~neser)
