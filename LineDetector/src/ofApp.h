#pragma once

#include "ofMain.h"

#include "ofxOpenCv.h"

//#define _USE_LIVE_VIDEO

class ofApp : public ofBaseApp{

	public:
		void setup();
		void update();
		void draw();
    
        void getLineEndPoints(ofxCvBlob blob, ofPoint &start, ofPoint &end);
        void fitLineToWindow(ofPoint &start, ofPoint &end, int width, int height);
        void getIntersectionPoint(ofPoint line1Start, ofPoint line1End, ofPoint line2Start, ofPoint line2End, ofPoint &intersection);
    
		void keyPressed(int key);
		void keyReleased(int key);
		void mouseMoved(int x, int y );
		void mouseDragged(int x, int y, int button);
		void mousePressed(int x, int y, int button);
		void mouseReleased(int x, int y, int button);
		void windowResized(int w, int h);
		void dragEvent(ofDragInfo dragInfo);
		void gotMessage(ofMessage msg);
    
        #ifdef _USE_LIVE_VIDEO
                  ofVideoGrabber 		vidGrabber;
        #else
                  ofVideoPlayer 		vidPlayer;
        #endif
            
        ofxCvColorImage			colorImg;
        
        ofxCvGrayscaleImage     redChannel, blueChannel, greenChannel;
        ofxCvGrayscaleImage 	grayImage;
        ofxCvGrayscaleImage 	grayBg;
        ofxCvGrayscaleImage 	grayDiff;
        
        ofxCvContourFinder 	contourFinder;
        
        int 				threshold;
        bool				bLearnBakground;
    
        ofPoint     videoSize;
        ofPoint     displaySize;
    
        int displayPadding;
};
