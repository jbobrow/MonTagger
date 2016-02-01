#pragma once

#include "ofxiOS.h"
#include "ofxOpenCv.h"

enum displayMode {
    DISPLAY_VIDEO_COLOR,
    DISPLAY_VIDEO_CHANNEL_RED,
    DISPLAY_VIDEO_CHANNEL_GREEN,
    DISPLAY_VIDEO_CHANNEL_BLUE,
    DISPLAY_VIDEO_GRAY,
    DISPLAY_VIDEO_THRESHOLD,
    DISPLAY_VIDEO_BACKGROUND,
    DISPLAY_VIDEO_TOTAL
};

class ofApp : public ofxiOSApp {
	
    public:
        void setup();
        void update();
        void draw();
        void exit();
	
        void touchDown(ofTouchEventArgs & touch);
        void touchMoved(ofTouchEventArgs & touch);
        void touchUp(ofTouchEventArgs & touch);
        void touchDoubleTap(ofTouchEventArgs & touch);
        void touchCancelled(ofTouchEventArgs & touch);

        void lostFocus();
        void gotFocus();
        void gotMemoryWarning();
        void deviceOrientationChanged(int newOrientation);
    
        ofVideoGrabber vidGrabber;
    
        ofTexture tex;
        
        ofxCvColorImage	colorImg;
        
        ofxCvGrayscaleImage redChannel, blueChannel, greenChannel, subtractionChannel, colorDiff;
        ofxCvGrayscaleImage grayImage;
        ofxCvGrayscaleImage grayBg;
        ofxCvGrayscaleImage grayDiff;
                
        ofxCvContourFinder contourFinder;
        
        int threshold;
        bool bLearnBackground;

        bool bUseRedChannel;
        bool bRemoveBlueChannel;
        bool bRemoveGreenChannel;
    
        bool bDrawContours;

        int displayMode;
    
        ofPoint     videoSize;
        ofPoint     openCvSize;
        ofPoint     displaySize;
        int numVideoPixels;
    
        int displayPadding;
    
        std::vector<ofPoint> recordedPoints;
        float lineContinuityThreshold;
    
        // Buttons
        ofImage modeButton, contourButton, clearButton;
};


