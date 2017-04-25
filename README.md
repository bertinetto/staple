<b>NEWS!</b> Check out our [CVPR'17 paper+code](http://www.robots.ox.ac.uk/~luca/cfnet.html): training a Correlation Filter end-to-end allows super lightweight networks of 2 layers (600 kB) to achieve state-of-the-art performance at high-speed.

# Staple tracker
Code for the method described in the paper **Staple: Complementary Learners for Real-Time Tracking**, by Luca Bertinetto, Jack Valmadre, Stuart Golodetz, Ondrej Miksik and Philip Torr (University of Oxford) - appeared at CVPR 2016.

### Contacts
For questions about the code or the paper, feel free contact us.
You can find more info at the project page: http://robots.ox.ac.uk/~luca/staple.html

Please cite
```

@InProceedings{Bertinetto_2016_CVPR,
author = {Bertinetto, Luca and Valmadre, Jack and Golodetz, Stuart and Miksik, Ondrej and Torr, Philip H. S.},
title = {Staple: Complementary Learners for Real-Time Tracking},
booktitle = {The IEEE Conference on Computer Vision and Pattern Recognition (CVPR)},
month = {June},
year = {2016}
}
```

### Prerequisites
 - The code is mostly in MATLAB, except the workhorse of `fhog.m`, which is written in C and comes from Piotr Dollar toolbox http://vision.ucsd.edu/~pdollar/toolbox
 - To use the webcam mode (`runTracker_webcam`), install MATLAB's webcam support from http://mathworks.com/hardware-support/matlab-webcam.html

### Modes
* `runTracker(sequence, start_frame)` runs the tracker on `sequence` from `start_frame` onwards.
* `runTracker_webcam` starts an interactive webcam demo.
* `runTracker_VOT` and `run_Staple` run the tracker within the benchmarks VOT and OTB respectively.

### Format
For `runTracker(sequence, start_frame)`, make sure the directory tree looks like the following:

    - staple/
        - runTracker.m
        - thisTracker.m
        - ... 

    - Sequences/
        - ball/
        - bicycle/
        - (any other sequence with the specified format)

Each sequence folder should have the following structure
- `<sequence_name>`/
    - imgs/
        - 00000000.jpg (must be 8digit, any img format allowed)
        - 00000001.jpg
        - ...
    - groundtruth.txt
    - `<sequence_name>`_frames.txt

* `<sequence_name>`_frames.txt contains the interval of frames to track
* groundtruth.txt contains the per frame annotation. The ground truth bounding box can be expressed as a polygon, i.e. `<x1>,<y1>,<x2>,<y2>,<x3>,<y3>,<x4>,<y4>`, or as an axis-aligned bounding box, i.e.`<top-x>,<top-y>,<width>,<height>`

### F.A.Q.

> How can I compile `mexResize` ?
`gradientMex` and `mexResize` have been compiled and tested for Ubuntu, Windows 8 (64 bit) and macOS(Sierra). You can easily recompile the sources in case of need. I have compiled mexResize following the instructions in Martin's old code for DSST. You can find it here http://www.cvl.isy.liu.se/research/objrec/visualtracking/scalvistrack/index.html - just open the archive and run compilemex.m or compilemex_win.m


> How can I reproduce the exact same results of the paper?

Checkout the code at the commit tagged `cvpr16_results`, other commits and future versions might perform differently.
As it is stated in the paper, the performance have been obtained using the last commit of the [VOT toolkit](https://github.com/votchallenge/vot-toolkit) available at the time of the paper submission ([`d3b2b1d`](https://github.com/votchallenge/vot-toolkit/tree/d3b2b1d)).

