## 1.4d

### Binomial Filter

* Binomial filter is a linear weighted average filter.

* Each pixel is replaced by a weighted average of its neighbors.

* Low values (black points) reduce the output slightly, but weights are spread out.

* Result: overall brightness is slightly lower than median filter, and black points become gray instead of fully disappearing.

### Median Filter

* medfilt2 takes the median of each window as the output pixel.

* For white paper images:

* Background should be gray (gray value approx. 128)

* Noise is isolated white black points (too high or low gray value)

* In a 3×3 window, the median gray value is usually near 128.

Result: noise are replaced by median value, so the overall image appears brighter than with average or Binomial filters.

---
### Noise Amplitude Result 
        Original noise amplitude: 2.2701

        Noise after 3x3 binomial filter: 0.81315

        Noise after 5x5 binomial filter: 0.58741

        Noise after 7x7 binomial filter: 0.48136

        Noise after 3x3 median filter: 1.0106

---
### Image Features
* Binomial 3×3:	Small window, weak smoothing.

* Binomial 5×5:	Medium window, stronger smoothing.

* Binomial 7×7:	Large window, strongest smoothing.

* Median 3x3: Black and white points are replaced by gray, image appears brighter.


![Filter Result](./filter_result.jpg)

---
### Noise Histogram Distribution

* After subtracting two white paper images, most pixel values are around 0, because the background gray level is similar (~128).

* The peak at 0 indicates that most pixels have little change.

* Small tails on both sides represent isolated noise points or slight gray fluctuations.

* The distribution is approximately symmetric, with occasional isolated high-amplitude noise (positive or negative).

![Hist Result](./histogram_result.jpg)

### Filter Effects on Noise Histogram
* Median 3×3: high-amplitude noise reduced, almost no isolated black points, Most effective for removing isolated noise, histogram more concentrated
* Binomial 3×3: high-amplitude noise slightly reduced, noise  slightly concentrate near central.
* Binomial 5×5: high-amplitude noise further reduced, noise more concentrate near central.
* Binomial 7×7: high-amplitude noise smallest, central peak sharpest, Strongest smoothing, most black points averaged to gray.

---
### Summary Comparison

#### Image Effects

* Median 3×3, Removes isolated black points, High Brightness (black points replaced by white)

* Binomial 3×3/5×5/7×7, Smooths noise, keeps some original values Slightly lower, black points become gray.

#### Histogram Effects

Sharper histogram peak → lower noise.

* Median 3×3 is best for removing isolated noise points;

* Binomial filters reduce overall noise as window size increases, but isolated black points are not completely removed, but averaged to gray.

---

