# Staple: Complementary Learners for Real-Time Tracking"
### Luca Bertinetto, Jack Valmadre, Stuart Golodetz, Ondra Miksik and Philip Torr, University of Oxford
### To appear at CVPR 2016.

####Contacts
For questions about the code or the paper, please contact `<luca.bertinetto@eng.ox.ac.uk>` or `<jack.valmadre@eng.ox.ac.uk>`.

You can find more info at the project page: http://robots.ox.ac.uk/~luca/staple.html

####Prerequisites
 - The code is mostly in MATLAB, except the workhorse of fhog.m, which is written in C and comes from Piotr Dollar toolbox http://vision.ucsd.edu/~pdollar/toolbox
 - gradientMex has already been compiled and tested on ubuntu and windows 8 (64 bit). You can easily recompile the sources in case of need.
 - For the webcam demo, you need the MATLAB Computer Vision toolbox.

 ####Setup
 Be sure the directory tree is the following:

 	- Staple/ (tracker)
 		- runTracker.m
 		- thisTracker.m
 		- ... 

	- Sequences/
		- ball/
		- bicycle/
		- (any other sequence with the specified format)

#####Sequences format
Each sequence folder should have the following structure
- <sequence_name>/
	- imgs/
		- 00000000.jpg (must be 8digit, any img format allowed)
		- 00000001.jpg
		- ...
	- groundtruth.txt
	- <sequence_name>_frames.txt

* <sequence_name>_frames.txt* contains the interval of frames to track
* groundtruth.txt contains the per frame annotation.
The ground truth bounding box can be expressed as a polygon, i.e.
<x1>,<y1>,<x2>,<y2>,<x3>,<y3>,<x4>,<y4>
or as an axis-aligned bounding box, i.e.
<top-x><top-y><width><height>

#####Modes
* `<runTracker(sequence, start_frame)>` runs the tracker on `<sequence>` from `<start_frame`> onwards.
* `<runTracker_webcam>` starts an interactive webcam demo. The visualization requires MATLAB Computer Vision Toolbox, please email me if you want to try the demo without the toolbox.
* `<runTracker_VOT>` and `<run_Staple>` run the tracker within the benchmarks.VOT* and OTB respectively.

####F.A.Q.
> How can I reproduce the exact same results of the paper?

Simply checkout the code at the tag `<cvpr16_results>`, other commits and future versions might perform differently.
