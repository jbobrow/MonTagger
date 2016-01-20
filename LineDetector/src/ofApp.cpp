#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){
    
    #ifdef _USE_LIVE_VIDEO
        vidGrabber.listDevices();   // show the connected cameras
        vidGrabber.setDeviceID(1);  // select the alternate camera (0 for built in, 1 for usb camera)
        vidGrabber.setVerbose(true);
        vidGrabber.initGrabber(320,240);
        videoSize.x = vidGrabber.width;
        videoSize.y = vidGrabber.height;
    #else
        vidPlayer.loadMovie("GML_Test_01.MOV");
        vidPlayer.play();
        videoSize.x = vidPlayer.width;
        videoSize.y = vidPlayer.height;
    #endif
    
    displaySize.x = 320;
    displaySize.y = 320 * videoSize.y / videoSize.x;
    
    colorImg.allocate(videoSize.x,videoSize.y);
    grayImage.allocate(videoSize.x,videoSize.y);
    grayBg.allocate(videoSize.x,videoSize.y);
    grayDiff.allocate(videoSize.x,videoSize.y);
    
    //color channels
    redChannel.allocate(videoSize.x, videoSize.y);
    blueChannel.allocate(videoSize.x, videoSize.y);
    greenChannel.allocate(videoSize.x, videoSize.y);
    
    bLearnBakground = true;
    threshold = 40;

    displayPadding = 20;
}

//--------------------------------------------------------------
void ofApp::update(){
    ofBackground(100,100,100);
    
    bool bNewFrame = false;
    
    #ifdef _USE_LIVE_VIDEO
        vidGrabber.update();
           bNewFrame = vidGrabber.isFrameNew();
    #else
        vidPlayer.update();
        bNewFrame = vidPlayer.isFrameNew();
    #endif
    
    if (bNewFrame){
        
        #ifdef _USE_LIVE_VIDEO
            colorImg.setFromPixels(vidGrabber.getPixels(), videoSize.x, videoSize.y);
        #else
            colorImg.setFromPixels(vidPlayer.getPixels(), videoSize.x, videoSize.y);
        #endif
        
        // get color channels
        colorImg.convertToGrayscalePlanarImages(redChannel, greenChannel, blueChannel);
        // remove green and blue
        greenChannel += blueChannel;
        redChannel -= greenChannel;
        
        grayImage = redChannel;
        if (bLearnBakground == true){
            grayBg = grayImage;		// the = sign copys the pixels from grayImage into grayBg (operator overloading)
            bLearnBakground = false;
        }
        
        // take the abs value of the difference between background and incoming and then threshold:
        grayDiff.absDiff(grayBg, grayImage);
        grayDiff.threshold(threshold);
        
        // find contours which are between the size of 20 pixels and 1/3 the w*h pixels.
        // also, find holes is set to true so we will get interior contours as well....
        contourFinder.findContours(grayDiff, 20, (videoSize.x*videoSize.y)/3, 10, true);	// find holes
    }


}

//--------------------------------------------------------------
void ofApp::draw(){
    
    // draw the incoming, the grayscale, the bg and the thresholded difference
    ofSetHexColor(0xffffff);
    colorImg.draw(displayPadding,displayPadding, displaySize.x, displaySize.y);
    grayImage.draw(displayPadding*2 + displaySize.x, displayPadding, displaySize.x, displaySize.y);
    grayBg.draw(displayPadding, displayPadding*2 + displaySize.y, displaySize.x, displaySize.y);
    grayDiff.draw(displayPadding*2 + displaySize.x,displayPadding*2 + displaySize.y, displaySize.x, displaySize.y);
    
    // then draw the contours:
    ofFill();
    ofSetHexColor(0x333333);
    ofRect(displayPadding*2 + displaySize.x, displayPadding*3 + 2*displaySize.y, displaySize.x, displaySize.y);
    ofSetHexColor(0xffffff);
    
    int totalPts = 0;
    
    // scale ratio
    float ratio = displaySize.x/videoSize.x;
    ofPoint startA, startB, endA, endB;
    ofPushMatrix();
    ofTranslate(displayPadding*2 + displaySize.x, displayPadding*3 + 2*displaySize.y);
    // draw each blob individually from the blobs vector,
    for (int i = 0; i < contourFinder.nBlobs; i++){
        
        // draw the points of the contour
        for(int j=0; j < contourFinder.blobs[i].nPts; j++){
            totalPts++;
            ofNoFill();
            ofSetHexColor(0xff00ff);
            ofCircle( ratio*contourFinder.blobs[i].pts[j].x, ratio*contourFinder.blobs[i].pts[j].y, 3);
        }
        
        // connect them by a line
        ofBeginShape();
        for(int j=0; j < contourFinder.blobs[i].nPts; j++){
            ofNoFill();
            ofSetHexColor(0xffff00);
            ofVertex( ratio*contourFinder.blobs[i].pts[j].x, ratio*contourFinder.blobs[i].pts[j].y);
        }
        ofEndShape();
        
        // set start and end points
        if(i == 0){
            getLineEndPoints(contourFinder.blobs[i], startA, endA);

            // draw the end points
            ofFill();
            ofSetHexColor(0xffffff);
            ofCircle( ratio*startA.x, ratio*startA.y, 3);
            ofCircle( ratio*endA.x, ratio*endA.y, 3);
        }
        else if(i == 1){
            getLineEndPoints(contourFinder.blobs[i], startB, endB);

            // draw the end points
            ofFill();
            ofSetHexColor(0xffffff);
            ofCircle( ratio*startB.x, ratio*startB.y, 3);
            ofCircle( ratio*endB.x, ratio*endB.y, 3);
        }
    }
    
    ofPoint lineAStart, lineBStart, lineAEnd, lineBEnd;
    
    
    // draw a point at the intersection of the two lines
    ofPoint intersection;
//    ofLineSegmentIntersection(startA, endA, startB, endB, intersection);
    getIntersectionPoint(startA, endA, startB, endB, intersection);
    ofFill();
    ofSetHexColor(0xffaa00);
    ofCircle(ratio*intersection.x, ratio*intersection.y, 5);
    
    ofPopMatrix();

    // not finding an intersection because I am not yet elongating the line to the edges of the screen
    // TODO: use the direction of the unit vector from each line, find the y intercept, and draw a line
    // from the top to bottom and left to right
    
    // finally, a report:
    ofSetHexColor(0xffffff);
    stringstream reportStr;
    reportStr << "bg subtraction and blob detection" << endl
    << "press ' ' to capture bg" << endl
    << "threshold " << threshold << " (press: +/-)" << endl
    << "num points found " << totalPts << endl
    << "point A (" << startA.x << "," << startA.y << ") -> (" << endA.x << "," << endA.y << ")" << endl
    << "point B (" << startB.x << "," << startB.y << ") -> (" << endB.x << "," << endB.y << ")" << endl
    << "intersection @ (" << intersection.x << "," << intersection.y << ")" << endl
    << "num blobs found " << contourFinder.nBlobs << ", fps: " << ofGetFrameRate();
    ofDrawBitmapString(reportStr.str(), displayPadding, displayPadding*4 + 2*displaySize.y);

}


//--------
void ofApp::getLineEndPoints(ofxCvBlob blob, ofPoint &start, ofPoint &end) {

    start = blob.pts[0];
    end = blob.pts[1];
    float maxDist = start.distance(end);
    
    for(int i=0; i < blob.nPts; i++){
        
        if(blob.pts[i].distance(start) > maxDist) {
            end = blob.pts[i];
            maxDist = start.distance(end);
        }
    }
}


//--------
void ofApp::getIntersectionPoint(ofPoint line1Start, ofPoint line1End, ofPoint line2Start, ofPoint line2End, ofPoint &intersection) {
    
    // Adapted from the nice function seen here :)
    // http://flassari.is/2008/11/line-line-intersection-in-cplusplus/
    
    // Store the values for fast access and easy
    // equations-to-code conversion
    float x1 = line1Start.x;
    float x2 = line1End.x;
    float x3 = line2Start.x;
    float x4 = line2End.x;
    
    float y1 = line1Start.y;
    float y2 = line1End.y;
    float y3 = line2Start.y;
    float y4 = line2End.y;
    
    float d = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
    // If d is zero, there is no intersection
    if (d == 0) return NULL;
    
    // Get the x and y
    float pre = (x1*y2 - y1*x2);
    float post = (x3*y4 - y3*x4);
    float x = ( pre * (x3 - x4) - (x1 - x2) * post ) / d;
    float y = ( pre * (y3 - y4) - (y1 - y2) * post ) / d;
    
    // Check if the x and y coordinates are within both lines
    // Nah, just want to find the extended intersection point
    
    // Return the point of intersection
    intersection.x = x;
    intersection.y = y;
}


//--------
void ofApp::fitLineToWindow(ofPoint &start, ofPoint &end, int width, int height) {
    
    ofPoint startOrig, endOrig;
    startOrig = start;
    endOrig = end;
    
    float slope = (start.y - end.y)/(start.x - end.x);
    
}

//--------
//void ofApp::recordPoint(ofPoint point, float rotation, DateForm time) {
//    
//}

//--------
//void ofApp::saveGML() {
//    string gml = "<gml spec='1.0 (minimum)'><tag><drawing>";
//    for (int i=0; i<numStrokes; i++) {
//        gml += "<stroke>";
//        gml += "<pt>";
//        gml += "<x>";
//        gml += x;
//        gml += "</x>";
//        gml += "<y>";
//        gml += y;
//        gml += "</y>";
//        gml += "<t>";
//        gml += t;
//        gml += "</t>";
//        gml += "</pt>";
//        // rotation
//        gml += "<rot>";
//        gml += r;
//        gml += "</rot>";
//    }
//    gml += "</drawing></tag></gml>";
//}


//--------------------------------------------------------------
void ofApp::keyPressed(int key){
    
    switch (key){
        case ' ':
            bLearnBakground = true;
            break;
        case '+':
            threshold ++;
            if (threshold > 255) threshold = 255;
            break;
        case '-':
            threshold --;
            if (threshold < 0) threshold = 0;
            break;
    }

}

//--------------------------------------------------------------
void ofApp::keyReleased(int key){

}

//--------------------------------------------------------------
void ofApp::mouseMoved(int x, int y ){

}

//--------------------------------------------------------------
void ofApp::mouseDragged(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::mouseReleased(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::windowResized(int w, int h){

}

//--------------------------------------------------------------
void ofApp::gotMessage(ofMessage msg){

}

//--------------------------------------------------------------
void ofApp::dragEvent(ofDragInfo dragInfo){ 

}
