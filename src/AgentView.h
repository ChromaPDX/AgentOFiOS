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

class agentController;

class AgentView{
    
public:
    
    agentController *controller;  // delegate

    void    setup(); // must be called
    void    draw(ProgramState state, NetworkState networkState, long elapsedMillis, long stateBeginTime, bool transitionActive, long transitionDuration, long transitionEndTime);
    
    void    setWIFIExist(bool w);
    void    setIsServer(bool s);
    void    setIsSpy(bool s);
    int     primaryColor;       // what is your color this round?

private:
    
    int     width, height;
    int     centerX, centerY;  // screen Coords

    bool    WIFIExist;
    bool    isServer;
    bool    isSpy;
    
    ofImage avatars[9];
    ofColor primaries[7];   // 7 colors
    int     complementaries[21]; // indexes of primaries[] of complements to the primaries
    
    float   transition;  // 0 - 1, from beginning of transition to end, use for animations

    void    drawInGameBackground();  // reticle

    
    char    spymess[5];  // scrambled text

    ofTrueTypeFont  font;
    ofTrueTypeFont  fontTiny;
    ofTrueTypeFont  fontSmall;
    ofTrueTypeFont  fontMedium;
    ofTrueTypeFont  fontLarge;
    ofImage         reticleCompass;
    ofImage         reticleOutline;
    ofImage         reticleInside;
    ofImage         fingerPrint;
    ofImage         insideCircle;
    ofImage         increment;
    ofImage         decrement;
    
    ofImage         wifiImage;
    ofImage         circleWhite;
    ofImage         circleBlack;
    ofImage         circleShadow;
    
};

#endif /* defined(__DoubleAgent__AgentView__) */
