//
//  lines.h
//  MonTagger
//
//  Created by Jonathan Bobrow on 1/31/16.
//
//

#ifndef lines_h
#define lines_h

#include "ofApp.h"
#include "ofxOpenCv.h"


void getLineEndPoints(ofxCvBlob blob, ofPoint &start, ofPoint &end);
void getIntersectionPoint(ofPoint line1Start, ofPoint line1End, ofPoint line2Start, ofPoint line2End, ofPoint &intersection);


#endif /* lines_h */
