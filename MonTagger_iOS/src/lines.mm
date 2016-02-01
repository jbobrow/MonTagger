//
//  lines.cpp
//  MonTagger
//
//  Created by Jonathan Bobrow on 1/31/16.
//
//

#include "lines.h"


//--------
void getLineEndPoints(ofxCvBlob blob, ofPoint &start, ofPoint &end) {

    start = blob.pts[0];
    end = blob.pts[1];
    float maxDist = start.distance(end);

    for(int i=0; i < blob.nPts; i++){

        if(blob.pts[i].distance(start) > maxDist) {
            end = blob.pts[i];
            maxDist = start.distance(end);
        }
    }

    // get points closest to the corners of the rectangle
//    ofPoint nearTL, nearTR, nearBL, nearBR;
//    nearTL.z = MAXFLOAT;
//    nearTR.z = MAXFLOAT;
//    nearBL.z = MAXFLOAT;
//    nearBR.z = MAXFLOAT;
//    float distTL, distTR, distBL, distBR;
//    
//    ofPoint closest, nextClosest;
//    closest.z = MAXFLOAT;
//    nextClosest.z = MAXFLOAT;
//    
//    for(int i=0; i < blob.nPts; i++){
//        
//        distTL = blob.pts[i].distance(blob.boundingRect.getTopLeft());
//        distTR = blob.pts[i].distance(blob.boundingRect.getTopRight());
//        distBL = blob.pts[i].distance(blob.boundingRect.getBottomLeft());
//        distBR = blob.pts[i].distance(blob.boundingRect.getBottomRight());
//        
//        if(distTL < nearTL.z) {
//            nearTL.x = blob.pts[i].x;
//            nearTL.y = blob.pts[i].y;
//            nearTL.z = distTL;
//        }
//        if(distTR < nearTR.z) {
//            nearTR.x = blob.pts[i].x;
//            nearTR.y = blob.pts[i].y;
//            nearTR.z = distTR;
//        }
//        if(distBL < nearBL.z) {
//            nearBL.x = blob.pts[i].x;
//            nearBL.y = blob.pts[i].y;
//            nearBL.z = distBL;
//        }
//        if(distBR < nearBR.z) {
//            nearBR.x = blob.pts[i].x;
//            nearBR.y = blob.pts[i].y;
//            nearBR.z = distBR;
//        }
//        
//        if(distTL < closest.z || distTR < closest.z || distBL < closest.z || distBR < closest.z) {
//            // this is the closest point yet
//            closest.x = blob.pts[i].x;
//            closest.y = blob.pts[i].y;
//            closest.z = blob.pts[i].z;
//        }
//        else if(distTL < nextClosest.z || distTR < nextClosest.z || distBL < nextClosest.z || distBR < nextClosest.z) {
//            // this is the closest point yet
//            nextClosest.x = blob.pts[i].x;
//            nextClosest.y = blob.pts[i].y;
//            nextClosest.z = blob.pts[i].z;
//        }
//
//    }
//    
//    start = closest;
//    end = nextClosest;
}


//--------
void getIntersectionPoint(ofPoint line1Start, ofPoint line1End, ofPoint line2Start, ofPoint line2End, ofPoint &intersection) {
    
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
    if (d == 0) return;
    
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

