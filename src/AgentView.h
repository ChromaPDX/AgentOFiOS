//
//  AgentView.h
//  DoubleAgent
//
//  Created by Robby on 4/11/14.
//
//

#ifndef __DoubleAgent__AgentView__
#define __DoubleAgent__AgentView__

#include <iostream>
#include "ofMain.h"

#include "AgentCommon.h"


class AgentView{
    
public:
    
    void setup(); // must be called
    void draw(GameState gameState, LoginStateState loginState, TurnState turnState, BOOL isServer, BOOL isSpy, int step, unsigned long stepInterval, unsigned long long stepTimer);
    
    
private:

    void drawLoginScreen();
    void drawInGameBackground();
    void drawAnimatedSphereBackground();

    int width, height;
    int centerX, centerY;  // screen Coords
    
    int primaryColor;       // what is your color this round?
    ofColor primaries[7];   // 7 colors
    int complementaries[21]; // indexes of primaries[] of complements to the primaries
    ofTrueTypeFont font;
    ofTrueTypeFont fontSmall;
    ofTrueTypeFont fontMedium;
    ofTrueTypeFont fontLarge;
    ofSpherePrimitive sphere;
    ofImage reticleCompass;
    ofImage reticleOutline;
    ofImage reticleInside;
    ofImage fingerPrint;
    ofImage insideCircle;
    
    ofImage increment;
    ofImage decrement;
    string lowerTextLine1, lowerTextLine2, lowerTextLine3;
};

#endif /* defined(__DoubleAgent__AgentView__) */
