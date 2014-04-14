//
//  AgentView.cpp
//  DoubleAgent
//
//  Created by Robby on 4/11/14.
//
//

#include "AgentView.h"
#include "agentController.h"

void AgentView::setup(){
    width = ofGetWidth();
    height = ofGetHeight();
    centerX = ofGetWidth()/2.;
    centerY = ofGetHeight()/2.;
    
    font.loadFont("Avenir.ttf", ofGetWidth() / 12., true, true);   // 4.2
    fontSmall.loadFont("AvenirNextCondensed.ttf", ofGetWidth() / 16., true, true);
    fontMedium.loadFont("AvenirNextCondensed.ttf", ofGetWidth() / 12., true, true);
    fontLarge.loadFont("AvenirNextCondensed.ttf", ofGetWidth() / 8., true, true);
    font.setLetterSpacing(.9);
    fontSmall.setLetterSpacing(.9);
    fontMedium.setLetterSpacing(.9);
    reticleOutline.loadImage("reticle_outline.png");
    reticleOutline.setAnchorPercent(.5, .5);
    reticleCompass.loadImage("reticle_compass.png");
    reticleCompass.setAnchorPercent(.5, .5);
    fingerPrint.loadImage("fingerprint.png");
    fingerPrint.setAnchorPercent(.5, .5);
    insideCircle.loadImage("inside_circle_w_fade.png");
    insideCircle.setAnchorPercent(.5, .5);
    reticleInside.loadImage("reticle_inside.png");
    reticleInside.setAnchorPercent(0, 0);
    reticleInside.crop(reticleInside.width/2., reticleInside.height/2., reticleInside.width/2., reticleInside.height/2.);
    increment.loadImage("increment.png");
    increment.setAnchorPercent(.5, .5);
    decrement.loadImage("decrement.png");
    decrement.setAnchorPercent(.5, .5);
    
    spymess[0] = rand()%23+65;
    spymess[1] = rand()%23+65;
    spymess[2] = rand()%23+65;
    spymess[3] = rand()%23+65;
    spymess[4] = NULL;
    
    primaries[0] = ofColor(255, 0, 210);    // pink  0
    primaries[1] = ofColor(17, 188, 61);    // green  1
    primaries[2] = ofColor(178, 44, 255);   // purple  2
    primaries[3] = ofColor(255, 96, 0);     // orange   3
    primaries[4] = ofColor(255, 0, 0);      // red       4
    primaries[5] = ofColor(255, 174, 0);    // yellow     5
    primaries[6] = ofColor(44, 138, 255);   // light blue  6
    
    primaryColor = ofRandom(0, 7);
    complementaries[0*3+0] = 1;     complementaries[0*3+1] = 5;     complementaries[0*3+2] = 6;
    complementaries[1*3+0] = 0;     complementaries[1*3+1] = 3;     complementaries[1*3+2] = 5;
    complementaries[2*3+0] = 0;     complementaries[2*3+1] = 3;     complementaries[2*3+2] = 5;
    complementaries[3*3+0] = 6;     complementaries[3*3+1] = 2;     complementaries[3*3+2] = 5;
    complementaries[4*3+0] = 6;     complementaries[4*3+1] = 2;     complementaries[4*3+2] = 5;
    complementaries[5*3+0] = 2;     complementaries[5*3+1] = 0;     complementaries[5*3+2] = 6;
    complementaries[6*3+0] = 0;     complementaries[6*3+1] = 5;     complementaries[6*3+2] = 2;

    // might be getting rid of sphere
    sphere.setRadius( ofGetWidth()  );
    ofSetSphereResolution(24);

}

// draw function outline
// =====================
//
//clear background color
//draw bottom white bar
//if(gameState == GameStateLogin)
//    draw login screen (multiple screens)
//if(gameState == GameStateReadyRoom)
//    draw avatars
//if(gameState == GameStatePlaying)
//    draw hexagon
//if(gameState == GameStateDeciding)
//    draw hexagon
//if(gameState == GameStateGameOver)
//    draw hexagon
//

void AgentView::draw(GameState gameState, LoginStateState loginState, TurnState turnState, BOOL isSpy, int step, unsigned long stepInterval, unsigned long long stepTimer, BOOL isServer, BOOL isClient, int currentTurn) {
    
    ofClear(primaries[primaryColor]);
    
    if(gameState == GameStateLogin){
        //        drawAnimatedSphereBackground();
    }
    else if(gameState == GameStateReadyRoom){
        drawAnimatedSphereBackground();
        
        string backString = "< BACK";
        fontMedium.drawString(backString,fontMedium.stringWidth(backString)*.35,ofGetHeight()*.1 - fontMedium.stringHeight(backString)/2.);
        
        float fade = 255;
        if(step == 1 || step == 9)
            fade = 255. * (float)(ofGetElapsedTimeMillis() - stepTimer) / stepInterval;
        else if(step == 7 || step == 15)
            fade = 255. * (1 - (float)(ofGetElapsedTimeMillis() - stepTimer) / stepInterval );
        ofSetColor(255, 255, 255, fade);
        if(step >= 1 && step < 8)
            fontMedium.drawString("MESSAGE FROM HQ:\n\nWe have a detected\na double agent in your\nmidst. HQ will send\nthree encrypted commands\nfor all agents to\nenact simultaneously.", 20, centerY-200);
        else if(step >= 9 && step < 16)
            fontMedium.drawString("The double agent will\nonly receive scrambled\ncommands and will attempt\nto mimic the movements\nof the other agents.\nWatch your team closely!\n\nEND OF MESSAGE", 20, centerY-200);
        
        if (isServer){
            ofSetColor(255);
            
            string hostString = "JOIN CODE";
            string clientString = controller->getCodeFromIp();
            fontMedium.drawString(hostString,width*.75 - fontMedium.stringWidth(hostString)/2.,ofGetHeight()*.1 - fontMedium.stringHeight(hostString)/2.);
            font.drawString(clientString,width*.5 - font.stringWidth(clientString)/2.,ofGetHeight()*.25 - font.stringHeight(clientString)/2.);
            
            backString = "START";
            fontMedium.drawString(backString,width*.5 - fontMedium.stringWidth(backString)*.5,height*.75 - fontMedium.stringHeight(backString)/2.);
        }
    }
    
    // white bar at bottom
    //ofSetColor(primaries[complementaries[primaryColor*3+0]]);
    ofSetColor(255, 255, 255);
    ofDrawPlane(width*.5, height-125, width, 250);
    
    if (gameState == GameStatePlaying || gameState == GameStateDeciding || gameState == GameStateGameOver) {
        
        if(controller->preGameCountdownSequence && step < 5){
            if(step >1){
                if(isSpy)
                    font.drawString("shhh", centerX-font.stringWidth("shhh")/2., centerY);
                else
                    font.drawString("AGENT", centerX-font.stringWidth("AGENT")/2., centerY);
            }
            if(step > 2){
                if(isSpy)
                    fontSmall.drawString("you are the double agent",centerX - fontSmall.stringWidth("you are the double agent")/2., centerY+font.stringHeight("shhh"));
                else
                    fontSmall.drawString("prepare yourself", centerX - fontSmall.stringWidth("prepare yourself")/2., centerY+font.stringHeight("AGENT"));
            }
        }
        else{
            
            ofSetColor(255, 255, 255, 255);
            ofEnableBlendMode( OF_BLENDMODE_ALPHA );
            
            ofEnableAlphaBlending();
            
            drawInGameBackground();
            
            ofSetLineWidth(3.);
            
            // for drawing a circle path
            float outerRadius;
            int resolution;
            float deltaAngle;
            float angle;
            ////////////////////////////////////////////////////////
            // break out
            if(currentTurn > 1){
                for(int i = 1; i < currentTurn; i++){
                    ofSetColor(primaries[complementaries[primaryColor*3+(i-1)]]);
                    //ofSetColor(6, 140, 210, 100);   // blue motion shape
                    //ofSetColor(74,193,255, 50); // blue motion shape border
                    ofFill();
                    ofBeginShape();
                    outerRadius = centerX*.55;
                    deltaAngle = TWO_PI / (float)SENSOR_DATA_ARRAY_SIZE;
                    angle = 0;
                    float turnProgress = 1.0;
                    for(int i = 0; i < SENSOR_DATA_ARRAY_SIZE; i++){
                        if((float)i/SENSOR_DATA_ARRAY_SIZE < turnProgress){
                            float x = centerX + outerRadius * sin(angle) * controller->recordedSensorData[(i-1)*SENSOR_DATA_ARRAY_SIZE + i];
                            float y = centerY + outerRadius * -cos(angle) * controller->recordedSensorData[(i-1)*SENSOR_DATA_ARRAY_SIZE + i];
                            ofVertex(x,y);
                            angle += deltaAngle;
                        }
                    }
                    ofEndShape();
                }
            }
            ////////////////////////////////////////////////////////
            
            if(turnState == TurnStateAction || turnState == TurnStateActionSuccess || turnState == TurnStateWaiting){
                ofSetColor(primaries[complementaries[primaryColor*3+(currentTurn-1)]]);
                //ofSetColor(6, 140, 210, 100);   // blue motion shape
                //ofSetColor(74,193,255, 50); // blue motion shape border
                ofFill();
                ofBeginShape();
                outerRadius = centerX*.55;
                deltaAngle = TWO_PI / (float)SENSOR_DATA_ARRAY_SIZE;
                angle = 0;
                float turnProgress = (float)(ofGetElapsedTimeMillis() - controller->turnTime) / ACTION_TIME;   // from 0 to 1
                for(int i = 0; i < SENSOR_DATA_ARRAY_SIZE; i++){
                    if((float)i/SENSOR_DATA_ARRAY_SIZE < turnProgress){
                        float x = centerX + outerRadius * sin(angle) * controller->recordedSensorData[(currentTurn-1)*SENSOR_DATA_ARRAY_SIZE + i];
                        float y = centerY + outerRadius * -cos(angle) * controller->recordedSensorData[(currentTurn-1)*SENSOR_DATA_ARRAY_SIZE + i];
                        ofVertex(x,y);
                        angle += deltaAngle;
                    }
                }
                ofEndShape();
                
            }
            ofSetColor(255, 255, 255,255);
            
            insideCircle.draw(centerX, centerY);
            if(gameState == GameStateDeciding){
                ofSetColor(primaries[complementaries[primaryColor*3+((currentTurn+1)%3)]]);  // modulus to vary color
                fingerPrint.draw(centerX, centerY,insideCircle.width*.5, insideCircle.height*.5);
            }
            
            if (( gameState == GameStatePlaying && !controller->preGameCountdownSequence ) || gameState == GameStateDeciding || gameState == GameStateGameOver){
                ofNoFill();
                if(turnState == TurnStateReceivingScrambled || turnState == TurnStateAction || gameState == GameStateDeciding)
                    ofSetColor(primaries[complementaries[primaryColor*3+((currentTurn+1)%3)]]);  // modulus to vary color
                else
                    ofSetColor(primaries[primaryColor]);
                ofBeginShape();
                outerRadius = centerX*.52;
                resolution = 64;
                deltaAngle = TWO_PI / (float)resolution;
                angle = 0;
                float roundProgress = (float)currentTurn / NUM_TURNS;
                for(int i = 0; i <= resolution; i++){
                    if((float)i/resolution <= roundProgress){
                        float x = centerX + outerRadius * sin(angle);
                        float y = centerY + outerRadius * -cos(angle);
                        ofVertex(x,y);
                        angle += deltaAngle;
                    }
                }
                ofEndShape();
            }
            
            ofDisableAlphaBlending();
            
            // BACK TO BUSINESS
            
            if (controller->mainMessage.length()){
                ofSetColor(255,255,255,255);
                
                if (controller->animatedScrambleFont) {
                    //if(rand()%2 == 0){
                    int index = rand()%4;
                    spymess[index] = rand()%23+65;
                    //}
                    font.drawString(ofToString(spymess),ofGetWidth()/2 - font.stringWidth(spymess)/2.,ofGetHeight()/2 + font.stringHeight(ofToString(spymess))/2.);
                }
                else if (controller->useScrambledText){
                    font.drawString(ofToString(spymess),ofGetWidth()/2 - font.stringWidth(spymess)/2.,ofGetHeight()/2 + font.stringHeight(ofToString(spymess))/2.);
                }
                else
                    font.drawString(controller->mainMessage,ofGetWidth()/2 - font.stringWidth(controller->mainMessage)/2.,ofGetHeight()/2 + font.stringHeight(controller->mainMessage)/2.);
            }
        }
    }
    
    if (!isServer && !isClient) {  // if not server or client
        drawLoginScreen(loginState);
    }
    ofSetColor(255, 255);
    if(gameState == GameStateLogin){
        lowerTextLine1 = "ONLY 1 HOST IS REQUIRED";
        lowerTextLine2 = "";
        lowerTextLine3 = "";
    }
    if(loginState == LoginStateChoose){
        fontLarge.drawString("DOUBLE AGENT", centerX-fontLarge.stringWidth("DOUBLE AGENT")*.5, 125);
    }
    
    if(gameState == GameStateReadyRoom){
        if (isServer) {
            lowerTextLine1 = "YOU ARE THE HOST";
            lowerTextLine2 = controller->getCodeFromIp();
            lowerTextLine3 = "Share this code for others to log in";
        }
        else {
            lowerTextLine1 = "YOU ARE CONNECTED";
            lowerTextLine2 = "to host: " + controller->getCodeFromInt(controller->loginCode);
            lowerTextLine3 = "Waiting for host to start the game";
        }
    }
    
    if(gameState == GameStatePlaying){
        if(controller->preGameCountdownSequence){
            if(step > 6){
                lowerTextLine1 = "AGENT ID";
                lowerTextLine2 = "AGENT";
                lowerTextLine3 = "Purpose: to identify the double agent";
            }
            else{
                lowerTextLine1 = lowerTextLine2 = lowerTextLine3 = "";
            }
        }
        else{
            lowerTextLine1 = "AGENT ID";
            lowerTextLine2 = "AGENT";
            lowerTextLine3 = "Purpose: to identify the double agent";
        }
    }
    if(gameState == GameStateDeciding){
        lowerTextLine1 = "TARGET";
        lowerTextLine2 = "DOUBLE AGENT";
        lowerTextLine3 = "Select operative identified as double agent";
    }
    if(gameState == GameStateGameOver){
        lowerTextLine1 = "MISSION";
        if(strcmp(controller->mainMessage.c_str(), "SPY CAPTURED!") == 0){
            lowerTextLine2 = "SUCCESS";
            lowerTextLine3 = "You have sucessfully uncovered the double agent";
        }
        else if(strcmp(controller->mainMessage.c_str(), "NOPE!") == 0){
            lowerTextLine2 = "FAIL";
            lowerTextLine3 = "the double agent got away";
        }
    }
    
    ofSetColor(0, 0, 0, 255);
    fontSmall.drawString(lowerTextLine1, 60, centerY+centerY*.66);
    ofSetColor(0, 0, 0, 255);
    fontSmall.drawString(lowerTextLine2, 60, centerY+centerY*.66+40);
    fontSmall.drawString(lowerTextLine3, 60, centerY+centerY*.66+80);
    
    if (controller->connectedAgents > 1){   // CONNECTED AGENTS
        string count = connectedAgentsStrings[controller->connectedAgents];//ofToString(connectedAgents);
        ofSetColor(0,0,0);
        font.drawString(count, centerX-font.stringWidth(count)/2.,ofGetHeight() - font.stringHeight(count));
    }
}

void AgentView::drawLoginScreen(LoginStateState loginState) {
    
    string hostString = "HOST";
    string clientString = "JOIN";
    string backString = "< BACK";
    string thirdString;
    
    ofSetColor(255,255,255);
    
    ofEnableAlphaBlending();
    
    switch (loginState) {
        case LoginStateChoose:
            font.drawString(hostString,ofGetWidth()/2 - font.stringWidth(hostString)/2.,ofGetHeight()*.4 - font.stringHeight(hostString)/2.);
            font.drawString(clientString,ofGetWidth()/2 - font.stringWidth(clientString)/2.,ofGetHeight()*.6 - font.stringHeight(clientString)/2.);
            break;
            
        case LoginStateServer:
            hostString = "JOIN CODE";
            clientString = controller->getCodeFromIp();
            fontMedium.drawString(backString,fontMedium.stringWidth(backString)*.35,ofGetHeight()*.1 - fontMedium.stringHeight(backString)/2.);
            font.drawString(hostString,ofGetWidth()/2 - font.stringWidth(hostString)/2.,ofGetHeight()*.4 - font.stringHeight(hostString)/2.);
            font.drawString(clientString,ofGetWidth()/2 - font.stringWidth(clientString)/2.,ofGetHeight()*.6 - font.stringHeight(clientString)/2.);
            break;
            
        case LoginStateClient:
            hostString = "CODE";
            clientString = controller->getCodeFromInt(controller->loginCode);
            fontMedium.drawString(backString,fontMedium.stringWidth(backString)*.35,ofGetHeight()*.1 - fontMedium.stringHeight(backString)/2.);
            font.drawString(hostString,ofGetWidth()/2 - font.stringWidth(hostString)/2.,ofGetHeight()*.2 - font.stringHeight(hostString)/2.);
            font.drawString(clientString,ofGetWidth()/2 - font.stringWidth(clientString)/2.,ofGetHeight()*.475 - font.stringHeight(clientString)/2.);
            increment.draw(width*.31, height*.325, width*.1, width*.1);
            increment.draw(width*.5, height*.325, width*.1, width*.1);
            increment.draw(width*.7, height*.325, width*.1, width*.1);
            decrement.draw(width*.31, height*.525, width*.1, width*.1);
            decrement.draw(width*.5, height*.525, width*.1, width*.1);
            decrement.draw(width*.7, height*.525, width*.1, width*.1);
            hostString = "JOIN";
            font.drawString(hostString,ofGetWidth()/2 - font.stringWidth(hostString)/2.,ofGetHeight()*.75 - font.stringHeight(hostString)/2.);
            break;
            
        case LoginStateConnecting:
            hostString = "CONNECTING TO";
            clientString = controller->getCodeFromInt(controller->loginCode);
            font.drawString(hostString,ofGetWidth()/2 - font.stringWidth(hostString)/2.,ofGetHeight()*.4 - font.stringHeight(hostString)/2.);
            font.drawString(clientString,ofGetWidth()/2 - font.stringWidth(clientString)/2.,ofGetHeight()*.6 - font.stringHeight(clientString)/2.);
            break;
            
        case LoginStateFailed:
            hostString = "BACK";
            clientString = "CONNECTION";
            thirdString = "FAILED";
            font.drawString(hostString,ofGetWidth()/2 - font.stringWidth(hostString)/2.,ofGetHeight()*.15 - font.stringHeight(hostString)/2.);
            font.drawString(clientString,ofGetWidth()/2 - font.stringWidth(clientString)/2.,ofGetHeight()*.5 - font.stringHeight(clientString)/2.);
            font.drawString(thirdString,ofGetWidth()/2 - font.stringWidth(thirdString)/2.,ofGetHeight()*.6 - font.stringHeight(thirdString)/2.);
            break;
            
        case LoginStateServerQuit:
            hostString = "BACK";
            clientString = "HOST STOPPED";
            thirdString = "THE GAME";
            font.drawString(hostString,ofGetWidth()/2 - font.stringWidth(hostString)/2.,ofGetHeight()*.15 - font.stringHeight(hostString)/2.);
            font.drawString(clientString,ofGetWidth()/2 - font.stringWidth(clientString)/2.,ofGetHeight()*.5 - font.stringHeight(clientString)/2.);
            font.drawString(thirdString,ofGetWidth()/2 - font.stringWidth(thirdString)/2.,ofGetHeight()*.6 - font.stringHeight(thirdString)/2.);
            break;
            
        case LoginStateNoIP:
            hostString = "NO ADDRESS";
            clientString = "CHECK WIFI ?";
            fontMedium.drawString(backString,fontMedium.stringWidth(backString)*.35,ofGetHeight()*.1 - fontMedium.stringHeight(backString)/2.);
            font.drawString(hostString,ofGetWidth()/2 - font.stringWidth(hostString)/2.,ofGetHeight()*.4 - font.stringHeight(hostString)/2.);
            font.drawString(clientString,ofGetWidth()/2 - font.stringWidth(clientString)/2.,ofGetHeight()*.6 - font.stringHeight(clientString)/2.);
            break;
            
        default:
            break;
    }
    
    ofDisableAlphaBlending();
}

void AgentView::drawInGameBackground(){
    ofSetColor(255, 255, 255, 75);
    reticleOutline.draw(centerX, centerY);
    ofPushMatrix();
    float compassAngle = atan2f(controller->orientation.d, controller->orientation.e);
    ofTranslate(centerX, centerY);
    ofRotate(compassAngle*180/PI);
    reticleCompass.draw(0,0);
    ofPopMatrix();
    ofPushMatrix();
    float reticleInsideAngle = asinf(controller->orientation.f);
    ofTranslate(centerX, centerY);
    ofRotate(reticleInsideAngle*180/PI);
    reticleInside.draw(0, 0);
    ofPopMatrix();
}

void AgentView::drawAnimatedSphereBackground() {
    
    float spinX = sin(ofGetElapsedTimef()*.35f);
    float spinY = cos(ofGetElapsedTimef()*.075f);
    sphere.setPosition(ofGetWidth()*.5, ofGetHeight()*.5, 200.);
    sphere.rotate(spinX, 1.0, 0.0, 0.0);
    sphere.rotate(spinY, 0, 1.0, 0.0);
    
    ofEnableLighting();
    ofNoFill();
    ofSetColor(255);
    ofSetLineWidth(.1);
    sphere.drawWireframe();
    ofFill();
    ofDisableLighting();
}
