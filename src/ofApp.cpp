#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){
  finder.setup("haarcascade_frontalface_default.xml");
  finder.setScaleHaar(2.0);
  string basedir = "downloaded_images";
  dir = ofDirectory(basedir);
  dir.allowExt("jpg");
  dir.listDir();
  totalImages = dir.size();
  currentImage = 0;
  pause = 0;
  ofSetLineWidth(2);
  ofNoFill();
}

//--------------------------------------------------------------
void ofApp::update(){
  if (pause > 0) {
    pause--;
  }
  else {
    img.load(dir.getPath(currentImage));
    facesFound = finder.findHaarObjects(img);
    if (facesFound > 0) {
      faceImage.load(dir.getPath(currentImage));
      pause = 30;
      saveFace(img,finder.blobs[0].boundingRect,currentImage);
      cur = finder.blobs[0].boundingRect;
      faceImageCrop.load(dir.getPath(currentImage));
      faceImageCrop.crop(cur.x, cur.y, cur.width, cur.height);
    }
    currentImage++;
    if (currentImage >= totalImages) {
      ofExit();
    }
  }
}

//--------------------------------------------------------------
void ofApp::draw(){
  ofSetColor(255,255,255);
  img.draw(0,0);
  if (faceImage.isAllocated()) {
    faceImage.draw(200,0);

    for(unsigned int i = 0; i < finder.blobs.size(); i++) {
      ofRectangle cur = finder.blobs[i].boundingRect;
      ofSetColor(255,255,255);
      faceImage.drawSubsection(100*i,200,cur.width,cur.height,cur.x,cur.y);
      ofSetColor(200,0,0); 
      ofDrawRectangle(cur.x+200, cur.y, cur.width, cur.height);
    }
  }
}

void ofApp::saveFace(ofImage &orig, ofRectangle bounds, int num) {
  ofImage newImage;
  newImage.cropFrom(orig, bounds.x, bounds.y, bounds.width, bounds.height);
  newImage.save("downloaded_faces/" + ofToString(num) + ".png");
}
