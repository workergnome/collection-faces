#pragma once

#include "ofMain.h"
#include "ofxCvHaarFinder.h"


class ofApp : public ofBaseApp{

	public:
		void setup();
		void update();
		void draw();

		void saveFace(ofImage &orig, ofRectangle bounds, int num);

		int pause;
		int totalImages;
		int currentImage;
		ofDirectory dir;
		ofImage img;
		ofImage faceImage;
		int facesFound;
		ofxCvHaarFinder finder;
		ofRectangle cur;
		ofImage faceImageCrop;
};
