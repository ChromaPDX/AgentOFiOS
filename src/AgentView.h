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
    
    void setup(); // must be called
    void draw(ProgramState state, NetworkState networkState, long elapsedMillis, long stateBeginTime, BOOL isServer, BOOL isSpy);
    
//    void draw(GameState gameState, LoginStateState loginState, TurnState turnState, BOOL isSpy, int step, unsigned long stepInterval, unsigned long long stepTimer, BOOL isServer, BOOL isClient, int currentTurn);

    agentController *controller;
    
    void setWIFIExist(bool w);
private:
    
    bool WIFIExist;

//    void drawLoginScreen(LoginStateState loginState);
    void drawInGameBackground();
    void drawAnimatedSphereBackground();

    int width, height;
    int centerX, centerY;  // screen Coords
    
    int primaryColor;       // what is your color this round?
    ofColor primaries[7];   // 7 colors
    int complementaries[21]; // indexes of primaries[] of complements to the primaries
    char spymess[5];  // scrambled text
    ofTrueTypeFont font;
    ofTrueTypeFont fontTiny;
    ofTrueTypeFont fontSmall;
    ofTrueTypeFont fontMedium;
    ofTrueTypeFont fontLarge;
    ofSpherePrimitive sphere;
    ofImage reticleCompass;
    ofImage reticleOutline;
    ofImage reticleInside;
    ofImage fingerPrint;
    ofImage insideCircle;
    string mainMessage;
    
    ofImage increment;
    ofImage decrement;
    string lowerTextLine1, lowerTextLine2, lowerTextLine3;
    string connectedAgentsStrings[NUM_PLACES+1] = {"", ".", ". .", ". . .", ". . . .", ". . . . .", ". . . . . .", ". . . . . . .", ". . . . . . . ."};
};

#endif /* defined(__DoubleAgent__AgentView__) */
