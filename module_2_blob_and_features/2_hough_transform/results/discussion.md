# Part 2 Hough Transform and Corner Detection

---

* Perform the HT and describe the Hough-Buffer you found. How many peaks has it?


<img src="./00d_Original Image and Edge Image.jpg" width="600">

<img src="./00d_Hough Buffer.jpg" width="300">


        According to the nPeaks = 5 we setted,
        5 Peaks can be found
        but only 1 strongest peak represent the straight line.

* Shift and rotate the line, so that it intersects the top leftcorner of the image and has an angle of approx 45° to the x-axis. Take an image. 
  
<img src="./45d_Original Image and Edge Image.jpg" width="600">

<img src="./45d_Hough Buffer.jpg" width="300">

* Repeat this with approx 30° and 60°, but keep the line in intersecting the upper left corner!
  
<img src="./30d_Original Image and Edge Image.jpg" width="600">

<img src="./30d_Hough Buffer.jpg" width="300">

<img src="./60d_Original Image and Edge Image.jpg" width="600">

<img src="./60d_Hough Buffer.jpg" width="300">
  
* For all three images: Perform the HT, extract the strongest peak. What do you find?
  
        As the angle of line goes bigger from 30 -> 45 -> 60,
        the Strongest peak is moving to right gradually.
        Which means θ of peak shart from -90d, and goes to -60, -45, -30

| Angle |  θ   |  ρ   |
|-------|------|------|
| 30d   | -60  |  0   |
| 45d   | -45  |  0   |
| 60d   | -30  |  0   |


* Now adjust the angle back to 45° and perform a parallel shift along the x-axes. Perform the HT, extract the strongest peaks and analyze. What do you find?

<img src="./Shifted_45d_Original Image and Edge Image.jpg" width="600">

<img src="./Shifted_45d_Hough Buffer.jpg" width="300">

        While θ remian -45d,
        The Strongest peak is moving down,
        The ρ of the peak goes biggher.

| Angle |  θ   |  ρ   |
|-------|------|------|
| 45d   |  -45 |  0   |
|Shifted|  -45 |  20  |

* Draw a square and do HT. What do you find. 

<img src="./Square_Original Image and Edge Image.jpg" width="600">

<img src="./Square_Hough Buffer.jpg" width="300">

        4 lines can be detected by 4 peaks.

| Angle |  θ   |  ρ   |
|-------|------|------|
| Top   | -90  | -200 |
| Bottom| -90  | -600 |
| Left  |   0  |  200 |
| Right |   0  |  600 |
  
* In the lab report: explain HT in your own words.
