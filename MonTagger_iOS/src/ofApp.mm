#include "ofApp.h"
#include "lines.h"

//--------------------------------------------------------------
void ofApp::setup(){	
    ofSetOrientation(OF_ORIENTATION_90_LEFT);//Set iOS to Orientation Landscape Right
    
    videoSize.x = 640;  //1280;
    videoSize.y = 480;  //720;
    
    displaySize.x = ofGetHeight()*640/480;    //1334;
    displaySize.y = ofGetHeight();
    
    vidGrabber.setup(videoSize.x, videoSize.y);
    videoSize.x = vidGrabber.getWidth();
    videoSize.y = vidGrabber.getHeight();
    numVideoPixels = videoSize.x * videoSize.y;
    
    printf("capture size:(%i,%i)\n",int(videoSize.x), int(videoSize.y));
    printf("display size:(%i,%i)\n",int(displaySize.x), int(displaySize.y));
    printf("device size:(%i,%i)",ofGetWidth(), ofGetHeight());
    
    colorImg.allocate(videoSize.x,videoSize.y);
    redChannel.allocate(videoSize.x,videoSize.y);
    greenChannel.allocate(videoSize.x,videoSize.y);
    blueChannel.allocate(videoSize.x,videoSize.y);
    subtractionChannel.allocate(videoSize.x,videoSize.y);
    colorDiff.allocate(videoSize.x,videoSize.y);
    
    grayImage.allocate(videoSize.x,videoSize.y);
    grayBg.allocate(videoSize.x,videoSize.y);
    grayDiff.allocate(videoSize.x,videoSize.y);
    
    bLearnBackground = true;
    threshold = 80;
    lineContinuityThreshold = 0.05;
    
    bUseRedChannel = true;
    bRemoveBlueChannel = false;
    bRemoveGreenChannel = true;
    
    bDrawContours = false;
    
    displayMode = 0;
    
    ofSetFrameRate(30);
}

//--------------------------------------------------------------
void ofApp::update(){
    ofBackground(0,0,0);
    
    bool bNewFrame = false;
    
    vidGrabber.update();
    bNewFrame = vidGrabber.isFrameNew();
    
    if (bNewFrame){
        
        if( vidGrabber.getPixels().getData() != NULL ){
        
            colorImg.setFromPixels(vidGrabber.getPixels().getData(), videoSize.x, videoSize.y);
        
            // get color channels
            colorImg.convertToGrayscalePlanarImages(redChannel, greenChannel, blueChannel);
            // remove green and blue
            
            subtractionChannel.clear();
            subtractionChannel.allocate(videoSize.x,videoSize.y);

            if(bRemoveBlueChannel) {
                subtractionChannel += blueChannel;
            }
            if(bRemoveGreenChannel) {
                subtractionChannel += greenChannel;
            }
            
            colorDiff = redChannel;
            colorDiff -= subtractionChannel;
            
            if(bUseRedChannel) {
                grayImage = colorDiff;
            }
            else {
                grayImage = colorImg;
            }
            
            if (bLearnBackground == true){
                grayBg = grayImage;		// the = sign copys the pixels from grayImage into grayBg (operator overloading)
                bLearnBackground = false;
            }
            
            // take the abs value of the difference between background and incoming and then threshold:
            grayDiff.absDiff(grayBg, grayImage);
            grayDiff.threshold(threshold);
            
            // find contours which are between the size of 20 pixels and 1/3 the w*h pixels.
            // also, find holes is set to true so we will get interior contours as well....
            contourFinder.findContours(grayDiff, 20, numVideoPixels/3, 10, true);	// find holes
            
        }
    }

}

//--------------------------------------------------------------
void ofApp::draw(){
    
    ofSetHexColor(0xffffff);
    switch(displayMode) {
        case DISPLAY_VIDEO_COLOR:
            colorImg.draw(0,0, displaySize.x, displaySize.y);
            break;
            
        case DISPLAY_VIDEO_CHANNEL_RED:
            redChannel.draw(0,0, displaySize.x, displaySize.y);
            break;
            
        case DISPLAY_VIDEO_CHANNEL_GREEN:
            greenChannel.draw(0,0, displaySize.x, displaySize.y);
            break;
        
        case DISPLAY_VIDEO_CHANNEL_BLUE:
            blueChannel.draw(0,0, displaySize.x, displaySize.y);
            break;
        
        case DISPLAY_VIDEO_GRAY:
            grayImage.draw(0,0, displaySize.x, displaySize.y);
            break;

        case DISPLAY_VIDEO_THRESHOLD:
            grayDiff.draw(0,0, displaySize.x, displaySize.y);
            break;
            
        case DISPLAY_VIDEO_BACKGROUND:
            grayBg.draw(0,0, displaySize.x, displaySize.y);
            break;
        
        default: break;
    }
    
    // place a dark layer over video
    ofFill();
    ofSetColor(0, 0, 0, 153);
    ofDrawRectangle(0, 0, displaySize.x, displaySize.y);
    
    // draw recorded path on screen (if path exists)
    if(recordedPoints.size() > 2) {
        
        ofBeginShape();
        float distSinceLastPoint = 0;
        for(int i=0; i < recordedPoints.size(); i++){
            if(i>0) {
                distSinceLastPoint = recordedPoints[i].distance(recordedPoints[i-1]);

                // if points aren't continuous, don't connect them
                if(distSinceLastPoint > lineContinuityThreshold) {
                    ofEndShape();
                    ofBeginShape();
                }
            }
            ofNoFill();
            ofSetLineWidth(4);
            ofSetHexColor(0xffff00);
            ofCurveVertex(recordedPoints[i].x * displaySize.x, recordedPoints[i].y * displaySize.y);
        }
        ofEndShape();
    }
    
    // draw blobs and contours
//    if(bDrawContours) {
//        // lets draw the contours.
//        // this is how to get access to them:
//        ofPushMatrix();
//        float scaleRatioX = displaySize.x / videoSize.x;
//        float scaleRatioY = displaySize.y / videoSize.y;
//        ofScale(scaleRatioX, scaleRatioY);
//        for (int i = 0; i < contourFinder.nBlobs; i++){
//            contourFinder.blobs[i].draw(0,0);
//        }
//        ofPopMatrix();
//    }
    
    
    // get the widest and tallest blob ids
    int widestId = 0;
    int tallestId = 0;
    float maxWidth = 0.0;
    float maxHeight = 0.0;
    float blobWidth, blobHeight;
    for (int i = 0; i < contourFinder.nBlobs; i++){
        blobWidth = contourFinder.blobs[i].boundingRect.getWidth();
        blobHeight = contourFinder.blobs[i].boundingRect.getHeight();
        
        if(blobWidth > maxWidth) {
            widestId = i;
            maxWidth = blobWidth;
        }
        
        if(blobHeight > maxHeight) {
            tallestId = i;
            maxHeight = blobHeight;
        }
    }

    // draw intersection info
    int totalPts = 0;
    
    // scale ratio
    float ratio = displaySize.x/videoSize.x;
    ofPoint startA, startB, endA, endB;
    // draw each blob individually from the blobs vector,
    for (int i = 0; i < contourFinder.nBlobs; i++){
        
        if(bDrawContours) {
            // draw the points of the contour
            for(int j=0; j < contourFinder.blobs[i].nPts; j++){
                totalPts++;
                ofNoFill();
                ofSetLineWidth(2);
                ofSetHexColor(0xff00ff);
                ofDrawCircle( ratio*contourFinder.blobs[i].pts[j].x, ratio*contourFinder.blobs[i].pts[j].y, 3);
            }
            
            // connect them by a line
            ofBeginShape();
            for(int j=0; j < contourFinder.blobs[i].nPts; j++){
                ofNoFill();
                ofSetLineWidth(2);
                ofSetHexColor(0xffff00);
                ofVertex( ratio*contourFinder.blobs[i].pts[j].x, ratio*contourFinder.blobs[i].pts[j].y);
            }
            ofEndShape();
        }
        
        // set start and end points
        if(i == widestId){ // widest (horizontal line...)
            getLineEndPoints(contourFinder.blobs[i], startA, endA);
            
            // draw the end points
            ofFill();
            ofSetHexColor(0xffffff);
            ofDrawCircle( ratio*startA.x, ratio*startA.y, 3);
            ofDrawCircle( ratio*endA.x, ratio*endA.y, 3);
            // connect with line
            ofNoFill();
            ofSetLineWidth(2);
            ofSetHexColor(0xff9900);
            ofDrawLine(ratio*startA.x, ratio*startA.y, ratio*endA.x, ratio*endA.y);
        }
        else if(i == tallestId){    // talest (vertical line...)
            getLineEndPoints(contourFinder.blobs[i], startB, endB);
            
            // draw the end points
            ofFill();
            ofSetHexColor(0xffffff);
            ofDrawCircle( ratio*startB.x, ratio*startB.y, 3);
            ofDrawCircle( ratio*endB.x, ratio*endB.y, 3);
            // connect with line
            ofNoFill();
            ofSetLineWidth(2);
            ofSetHexColor(0xff9900);
            ofDrawLine(ratio*startB.x, ratio*startB.y, ratio*endB.x, ratio*endB.y);
        }
    }
    
    ofPoint lineAStart, lineBStart, lineAEnd, lineBEnd;
    
    
    // draw a point at the intersection of the two lines
    ofPoint intersection;
    //    ofLineSegmentIntersection(startA, endA, startB, endB, intersection);
    getIntersectionPoint(startA, endA, startB, endB, intersection);
    ofFill();
    ofSetHexColor(0xFF0099);
    ofDrawCircle(ratio*intersection.x, ratio*intersection.y, 5);
    
    // record drawing point if not 0,0
    if(intersection.x > 1.0 || intersection.y > 1.0) {
        ofPoint normalizedIntersection;
        normalizedIntersection.x = intersection.x / videoSize.x;
        normalizedIntersection.y = intersection.y / videoSize.y;
        recordedPoints.push_back(normalizedIntersection);
    }
    
    // draw buttons on screen
    ofNoFill();
    ofSetHexColor(0xff00ff);
    ofDrawRectRounded(displaySize.x + 20, 20, 135, 135, 10);
    ofSetHexColor(0xffff00);
    ofDrawRectRounded(displaySize.x + 20, 175, 135, 135, 10);
    ofSetHexColor(0x00ffff);
    ofDrawRectRounded(displaySize.x + 20, 330, 135, 135, 10);
    ofSetHexColor(0x335566);
    ofDrawRectRounded(displaySize.x + 20, 485, 135, 135, 10);

    // finally, a report:
    ofSetHexColor(0xffffff);
    stringstream reportStr;
    reportStr << "<MonTagger>\nGraffiti Field Recorder\n";
    reportStr << "threshold[0,255]: "<< threshold << "\nfps: " << ofGetFrameRate();
    ofDrawBitmapString(reportStr.str(), 20, 640-60);

}

//--------------------------------------------------------------
void ofApp::exit(){

}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
    // Todo: check if touch is in button
//    bLearnBakground = true;
//    printf("touch position: (%f,%f)", touch.x, touch.y);
    
    if(touch.x > displaySize.x && touch.y < 175) {
        displayMode = (displayMode + 1) % int(DISPLAY_VIDEO_TOTAL);
    }
    if(touch.x > displaySize.x && touch.y > 175 && touch.y < 330) {
        bDrawContours = !bDrawContours;
    }
    if(touch.x > displaySize.x && touch.y > 330 && touch.y < 485) {
        recordedPoints.clear();
    }
    if(touch.x > displaySize.x && touch.y > 485 && touch.y < 640) {
        bLearnBackground = true;
    }
    // update threshold
    if(touch.x < displaySize.x) {
        threshold = 255-255 * touch.y / displaySize.y;
    }
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){
    
    // update threshold
    if(touch.x < displaySize.x) {
        threshold = 255-255 * touch.y / displaySize.y;
    }
}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){
    
    // update threshold
    if(touch.x < displaySize.x) {
        threshold = 255-255 * touch.y / displaySize.y;
    }
}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::lostFocus(){

}

//--------------------------------------------------------------
void ofApp::gotFocus(){

}

//--------------------------------------------------------------
void ofApp::gotMemoryWarning(){

}

//--------------------------------------------------------------
void ofApp::deviceOrientationChanged(int newOrientation){

}
