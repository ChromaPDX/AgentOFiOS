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
    // AvenirNextCondensed.ttf
    font.loadFont("Brandon_blk.ttf", ofGetWidth() / 12., true, true);   // 4.2
    fontTiny.loadFont("Brandon_blk.ttf", ofGetWidth() / 24., true, true);
    fontSmall.loadFont("Brandon_blk.ttf", ofGetWidth() / 16., true, true);
    fontMedium.loadFont("Brandon_blk.ttf", ofGetWidth() / 12., true, true);
    fontLarge.loadFont("Brandon_blk.ttf", ofGetWidth() / 6., true, true);
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
    wifiImage.loadImage("wifi.png");
    wifiImage.setAnchorPercent(.5, .5);
    circleWhite.loadImage("circleWhite.png");
    circleWhite.setAnchorPercent(.5, .5);
    circleBlack.loadImage("circleBlack.png");
    circleBlack.setAnchorPercent(.5, .5);
    circleShadow.loadImage("circleShadow.png");
    circleShadow.setAnchorPercent(.5, .5);
    
    avatarCoords[0*2+0] = centerX;      avatarCoords[0*2+1] = height*.75;
    avatarCoords[1*2+0] = centerX;      avatarCoords[1*2+1] = height*.5;
    avatarCoords[2*2+0] = width*.25;    avatarCoords[2*2+1] = height*.66;
    avatarCoords[3*2+0] = width*.75;    avatarCoords[3*2+1] = height*.66;
    avatarCoords[4*2+0] = width*.25;    avatarCoords[4*2+1] = height*.33;
    avatarCoords[5*2+0] = width*.75;    avatarCoords[5*2+1] = height*.33;
    avatarCoords[6*2+0] = centerX;      avatarCoords[6*2+1] = height*.25;
    avatarCoords[7*2+0] = width*.75;    avatarCoords[7*2+1] = height*.2;
    avatarCoords[8*2+0] = width*.25;    avatarCoords[8*2+1] = height*.2;
    
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

    avatars[1].loadImage("ape.png");
    avatars[2].loadImage("bear.png");
    avatars[3].loadImage("eagle.png");
    avatars[4].loadImage("horse.png");
    avatars[5].loadImage("lion.png");
    avatars[6].loadImage("moth.png");
    avatars[7].loadImage("owl.png");
    avatars[8].loadImage("snake.png");
    avatars[1].setAnchorPercent(.5f, .5f);
    avatars[2].setAnchorPercent(.5f, .5f);
    avatars[3].setAnchorPercent(.5f, .5f);
    avatars[4].setAnchorPercent(.5f, .5f);
    avatars[5].setAnchorPercent(.5f, .5f);
    avatars[6].setAnchorPercent(.5f, .5f);
    avatars[7].setAnchorPercent(.5f, .5f);
    avatars[8].setAnchorPercent(.5f, .5f);
}
void AgentView::setWIFIExist(bool w){
    WIFIExist = w;
}
void AgentView::setIsServer(bool s){
    isServer = s;
}
void AgentView::setIsSpy(bool s){
    isSpy = s;
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

//void AgentView::draw(GameState gameState, LoginStateState loginState, TurnState turnState, BOOL isSpy, int step, unsigned long stepInterval, unsigned long long stepTimer, BOOL isServer, BOOL isClient, int currentTurn)
void AgentView::draw(ProgramState state, NetworkState networkState, long elapsedMillis, long stateBeginTime, bool transitionActive, long transitionDuration, long transitionEndTime){
    
    ofClear(primaries[primaryColor]);
    
    // from 1 to 0
    if(transitionActive)
        transition = (transitionEndTime-elapsedMillis)/(float)transitionDuration;
    else
        transition = 1.0;
    
    // network states
//        NetworkNone,
//        NetworkHostAttempt,
//        NetworkHostSuccess,
//        NetworkJoinAttempt,
//        NetworkJoinSuccess,
//        NetworkLostConnection,      // try to make these 2 into 1
//        NetworkServerDisconnected   //
    
    if(state == StateWelcomeScreen){
        ofSetColor(255, 255);
        fontLarge.drawString("DOUBLE", centerX - fontLarge.stringWidth("DOUBLE")/2., height*.2);
        fontLarge.drawString("AGENT",  centerX - fontLarge.stringWidth("AGENT")/2., height*.2 + fontLarge.stringHeight("AGENT"));
        fontTiny.drawString("A GAME OF RIDICULOUS GESTURES", centerX - fontTiny.stringWidth("A GAME OF RIDICULOUS GESTURES")/2., height*.2 + fontLarge.stringHeight("AGENT")*2.0);
        fontLarge.drawString("BEGIN", centerX - fontLarge.stringWidth("BEGIN")/2., height*.75 - fontLarge.stringHeight("BEGIN")*.5);

        ofDrawPlane(width*.5, height-50, width, 100);
        ofSetColor(0, 255);
        wifiImage.draw(50, height - 50, 50, 50);
        string wifistr;
        if(WIFIExist) wifistr = "WIFI connected :)";
        else wifistr = "I need WIFI :(";
        fontSmall.drawString(wifistr, 110, height - 50 + fontSmall.stringHeight(wifistr)*.5);
    }
    else if(state == StateConnectionScreen){
        int alpha = 255;
        if(transitionActive){
            alpha = 255*transition;
        }
        ofSetColor(255, alpha);
        fontLarge.drawString("DOUBLE", centerX - fontLarge.stringWidth("DOUBLE")/2., height*.2);
        fontLarge.drawString("AGENT",  centerX - fontLarge.stringWidth("AGENT")/2., height*.2 + fontLarge.stringHeight("AGENT"));
        fontTiny.drawString("A GAME OF RIDICULOUS GESTURES", centerX - fontTiny.stringWidth("A GAME OF RIDICULOUS GESTURES")/2., height*.2 + fontLarge.stringHeight("AGENT")*2.0);
        string hostString = "HOST";
        string clientString = "JOIN";
        string backString = "< BACK";
        string thirdString;
        

        avatars[controller->avatarSelf].draw(centerX, height*.75, 100, 100);

        float yPos = height-50;
        if(transitionActive){
            float speed = 7; // speed to progress through animation curve
            float time = (transition) * speed;
            float curve = cosf(time-PI)/(9*powf(2, time-PI)) + 1;
            yPos += (1-curve)*150;
        }
        
//        if(networkState == NetworkNone){
            font.drawString("HOST", width*.25 - font.stringWidth("HOST")/2., height*.6 - font.stringHeight("HOST")/2.);
            font.drawString("JOIN", width*.75 - font.stringWidth("JOIN")/2., height*.6 - font.stringHeight("JOIN")/2.);
            ofSetColor(255, 255);
            ofDrawPlane(width*.5, yPos, width, 100);
            ofSetColor(0,255);
            fontTiny.drawString("ONLY ONE HOST IS NEEDED", width*.5 - fontTiny.stringWidth("ONLY ONE HOST IS NEEDED")/2., yPos + fontTiny.stringHeight("ONLY ONE HOST IS NEEDED")*.5);
//        }
        
        
//    case LoginStateServer:
//        hostString = "JOIN CODE";
//        clientString = controller->getCodeFromIp();
//        fontMedium.drawString(backString,fontMedium.stringWidth(backString)*.35,ofGetHeight()*.1 - fontMedium.stringHeight(backString)/2.);
//        font.drawString(hostString,ofGetWidth()/2 - font.stringWidth(hostString)/2.,ofGetHeight()*.4 - font.stringHeight(hostString)/2.);
//        font.drawString(clientString,ofGetWidth()/2 - font.stringWidth(clientString)/2.,ofGetHeight()*.6 - font.stringHeight(clientString)/2.);
//        break;
        
    }
    else if(state == StateJoinScreen){
        
//        avatars[controller->avatarSelf].draw(centerX, height*.9, 100, 100);
        
//        if(networkState == NetworkJoinAttempt){

        string clientString = controller->getCodeFromInt(controller->loginCode);
        
        ofSetColor(255, 255);
        fontLarge.drawString("JOIN",  centerX - fontLarge.stringWidth("JOIN")*.5, height*.66 + fontLarge.stringHeight("JOIN")*.5);
        fontTiny.drawString("JOIN CODE", width*.5 - fontTiny.stringWidth("JOIN CODE")*.5, fontTiny.stringHeight("JOIN CODE")*2.5);
        fontMedium.drawString("QUIT", fontMedium.stringWidth("QUIT")*.1, height - fontMedium.stringHeight("QUIT")*.5);
        fontLarge.drawString(clientString,width/2. - fontLarge.stringWidth(clientString)/2.,height*.425 - fontLarge.stringHeight(clientString)/2.);
        increment.draw(width*.25, height*.2, width*.2, width*.2);
        increment.draw(width*.5, height*.2, width*.2, width*.2);
        increment.draw(width*.75, height*.2, width*.2, width*.2);
        decrement.draw(width*.25, height*.45, width*.2, width*.2);
        decrement.draw(width*.5, height*.45, width*.2, width*.2);
        decrement.draw(width*.75, height*.45, width*.2, width*.2);
        
        // X VALUES:
        // middle left: width * .375
        // middle right: width * .625
        
        // Y VALUES:
        // middle of text: height * .325
        // top row upper bounds:  height * .1
        // top row lower bounds:  height * .3
        // bottom row upper bounds: height * .35
        // bottom row lower bounds: height * .55
        
//        }
        
//    case LoginStateConnecting:
//        hostString = "CONNECTING TO";
//        clientString = controller->getCodeFromInt(controller->loginCode);
//        font.drawString(hostString,ofGetWidth()/2 - font.stringWidth(hostString)/2.,ofGetHeight()*.4 - font.stringHeight(hostString)/2.);
//        font.drawString(clientString,ofGetWidth()/2 - font.stringWidth(clientString)/2.,ofGetHeight()*.6 - font.stringHeight(clientString)/2.);
//        break;
//        
//    case LoginStateFailed:
//        hostString = "BACK";
//        clientString = "CONNECTION";
//        thirdString = "FAILED";
//        font.drawString(hostString,ofGetWidth()/2 - font.stringWidth(hostString)/2.,ofGetHeight()*.15 - font.stringHeight(hostString)/2.);
//        font.drawString(clientString,ofGetWidth()/2 - font.stringWidth(clientString)/2.,ofGetHeight()*.5 - font.stringHeight(clientString)/2.);
//        font.drawString(thirdString,ofGetWidth()/2 - font.stringWidth(thirdString)/2.,ofGetHeight()*.6 - font.stringHeight(thirdString)/2.);
//        break;
//        
//    case LoginStateServerQuit:
//        hostString = "BACK";
//        clientString = "HOST STOPPED";
//        thirdString = "THE GAME";
//        font.drawString(hostString,ofGetWidth()/2 - font.stringWidth(hostString)/2.,ofGetHeight()*.15 - font.stringHeight(hostString)/2.);
//        font.drawString(clientString,ofGetWidth()/2 - font.stringWidth(clientString)/2.,ofGetHeight()*.5 - font.stringHeight(clientString)/2.);
//        font.drawString(thirdString,ofGetWidth()/2 - font.stringWidth(thirdString)/2.,ofGetHeight()*.6 - font.stringHeight(thirdString)/2.);
//        break;
//        
//    case LoginStateNoIP:
//        hostString = "NO ADDRESS";
//        clientString = "CHECK WIFI ?";
//        fontMedium.drawString(backString,fontMedium.stringWidth(backString)*.35,ofGetHeight()*.1 - fontMedium.stringHeight(backString)/2.);
//        font.drawString(hostString,ofGetWidth()/2 - font.stringWidth(hostString)/2.,ofGetHeight()*.4 - font.stringHeight(hostString)/2.);
//        font.drawString(clientString,ofGetWidth()/2 - font.stringWidth(clientString)/2.,ofGetHeight()*.6 - font.stringHeight(clientString)/2.);
//        break;
    }
    else if(state == StateReadyRoom){
//        drawAnimatedSphereBackground();
        
        
        ofSetColor(255, 70);
        
        wifiImage.draw(centerX, centerY, height, height);
        
        ofSetColor(255, 255);

        
//        string backString = "< BACK";
//        fontMedium.drawString(backString,fontMedium.stringWidth(backString)*.35,ofGetHeight()*.1 - fontMedium.stringHeight(backString)/2.);

        int count = 0;
        
        if(isServer){
            ofSetColor(255, 255);
            circleShadow.draw(centerX, height*.75, 240, 240);
            ofSetColor(primaries[primaryColor]);
            circleWhite.draw(centerX, height*.75, 200, 200);
            ofSetColor(255, 255);
            avatars[controller->avatarSelf].draw(centerX, height*.75, 150, 150);
            count++;
        }
        for(int i = 0; i < 256; i++){
            if(controller->avatarIcons[i] != 0 &&  count < NUM_AVATAR_COORDS){  // todo make case for count > NUM_AVATAR_COORDS
                ofSetColor(255, 255);
                circleShadow.draw(avatarCoords[count*2+0], avatarCoords[count*2+1], 240, 240);
                ofSetColor(primaries[controller->avatarColors[i]-1]);
                circleWhite.draw(avatarCoords[count*2+0], avatarCoords[count*2+1], 200, 200);
                ofSetColor(255, 255);
                avatars[controller->avatarIcons[i]].draw(avatarCoords[count*2+0], avatarCoords[count*2+1], 150, 150);
                count++;
            }
        }

//        float fade = 255;
//        if(step == 1 || step == 9)
//            fade = 255. * (float)(ofGetElapsedTimeMillis() - stepTimer) / stepInterval;
//        else if(step == 7 || step == 15)
//            fade = 255. * (1 - (float)(ofGetElapsedTimeMillis() - stepTimer) / stepInterval );
//        ofSetColor(255, 255, 255, fade);
//        if(step >= 1 && step < 8)
//            fontMedium.drawString("MESSAGE FROM HQ:\n\nWe have a detected\na double agent in your\nmidst. HQ will send\nthree encrypted commands\nfor all agents to\nenact simultaneously.", 20, centerY-200);
//        else if(step >= 9 && step < 16)
//            fontMedium.drawString("The double agent will\nonly receive scrambled\ncommands and will attempt\nto mimic the movements\nof the other agents.\nWatch your team closely!\n\nEND OF MESSAGE", 20, centerY-200);
        
        if (isServer){
            ofSetColor(255);
            
            string clientString = controller->getCodeFromIp();
            fontTiny.drawString("JOIN CODE", width*.5 - fontTiny.stringWidth("JOIN CODE")*.5, fontTiny.stringHeight("JOIN CODE")*1.5);
            fontLarge.drawString(clientString, width*.5 - fontLarge.stringWidth(clientString)*.5, fontLarge.stringHeight(clientString)*2);
            
            fontMedium.drawString("START", width - fontMedium.stringWidth("START")*1.1, height - fontMedium.stringHeight("START")*.5);
        }
        
        fontMedium.drawString("LEAVE", fontMedium.stringWidth("LEAVE")*.1, height - fontMedium.stringHeight("LEAVE")*.5);

        if(transitionActive){
            int alpha = 255*(1.0-transition);
            ofSetColor(0, alpha);
            ofRect(0, 0, width, height);
        }
    }
    else if(state == StateStartGame){
        ofClear(0, 255);
        ofSetColor(255, 255);
        if(elapsedMillis > stateBeginTime + 1000){
            if(isSpy)   font.drawString("shhh", centerX-font.stringWidth("shhh")/2., centerY);
            else        font.drawString("AGENT", centerX-font.stringWidth("AGENT")/2., centerY);
        }
        if(elapsedMillis > stateBeginTime + 2000){
            if(isSpy)   fontSmall.drawString("you are the double agent",centerX - fontSmall.stringWidth("you are the double agent")/2., centerY+font.stringHeight("shhh"));
            else        fontSmall.drawString("prepare yourself", centerX - fontSmall.stringWidth("prepare yourself")/2., centerY+font.stringHeight("AGENT"));
        }
    }
    else if(state == StateCountdown){

        if(elapsedMillis < stateBeginTime + 2000){
            float fade = (elapsedMillis-stateBeginTime-1000)/1000.0;
            if(fade < 0) fade = 0;
            ofSetColor(0, 255-fade*255);
            ofRect(0, 0, width, height);
        }
        
        float diameter = width*.75;
        if(elapsedMillis < stateBeginTime + 500){
            float speed = 7; // speed to progress through animation curve
            float time = (elapsedMillis-stateBeginTime)/500.0 * speed;
            float curve = cosf(time-PI)/(9*powf(2, time-PI)) + 1;
            diameter *= curve;
        }

        ofSetColor(255, 255);
        circleShadow.draw(centerX, centerY, diameter, diameter);
        ofSetColor(primaries[primaryColor]);
        circleWhite.draw(centerX, centerY, diameter*.83, diameter*.83);
        ofSetColor(255, 255);
        avatars[controller->avatarSelf].draw(centerX, centerY, diameter*.625, diameter*.625);

        ofSetColor(255, 255);
        string countdownString;
        if(elapsedMillis > stateBeginTime + 5000){
            countdownString = "";
        }
        else if(elapsedMillis > stateBeginTime + 4000){
            countdownString = "1";
        }
        else if(elapsedMillis > stateBeginTime + 3000){
            countdownString = "2";
        }
        else if(elapsedMillis > stateBeginTime + 2000){
            countdownString = "3";
        }
        else if(elapsedMillis > stateBeginTime + 1000){
            countdownString = "";
        }
        else if(elapsedMillis > stateBeginTime){
            countdownString = "";
        }
        fontLarge.drawString(countdownString, centerX-fontLarge.stringWidth(countdownString)*.5, fontLarge.stringHeight(countdownString)*2.5);
    }
    else if(state == StateTurnScramble){
        static int count = 0;
        count++;
        if(count >= 7) count = 0;
        font.drawString(scrambleStrings[count], centerX-font.stringWidth(scrambleStrings[count])*.5, height*.83-font.stringHeight(scrambleStrings[count])*.5);
    }
    else if(state == StateTurnGesture){
        if(!controller->isSpy)
            font.drawString(controller->mainMessage, centerX-font.stringWidth(controller->mainMessage)*.5, height*.83+font.stringHeight(controller->mainMessage)*.75);
    }
    else if(state == StateTurnComplete){
//        font.drawString("COMPLETE", centerX-font.stringWidth("COMPLETE")*.5, height*.83-font.stringHeight("COMPLETE")*.5);
    }
    else if(state == StateDecide){
        
        // not an elegant solution
        spin = 0.0;
        spinSpeed = 0.0;
        // not an elegant solution
        
        float yPos = height-50;
        if(elapsedMillis < stateBeginTime + 500){
            float speed = 7; // speed to progress through animation curve
            float time = (elapsedMillis-stateBeginTime)/500.0 * speed;
            float curve = cosf(time-PI)/(9*powf(2, time-PI)) + 1;
            yPos += (1-curve)*150;
        }
        ofSetColor(255, 255);
        font.drawString("WHO IS IT?", centerX-font.stringWidth("WHO IS IT?")*.5, height*.2-font.stringHeight("WHO IS IT?")*.5);
        ofDrawPlane(width*.5, yPos, width, 100);
        ofSetColor(0, 255);
        fontSmall.drawString("turn screen towards crowd", centerX - fontSmall.stringWidth("turn screen towards crowd")*.5, yPos + fontSmall.stringHeight("turn screen towards crowd")*.5);
    }
    else if(state == StateGameOver){
        if (controller->mainMessage.compare("WIN") == 0) {
            font.drawString("GOT 'EM", centerX-font.stringWidth("GOT 'EM")*.5, height*.83-font.stringHeight("GOT 'EM")*.5);
            float diameter = width*.75;
            ofSetColor(255, 255);
            circleShadow.draw(centerX, centerY, diameter, diameter);
            ofSetColor(primaries[primaryColor]);
            circleWhite.draw(centerX, centerY, diameter*.83, diameter*.83);
            ofSetColor(255, 255);
            avatars[controller->avatarSelf].draw(centerX, centerY, diameter*.625, diameter*.625);

        }
        else if (controller->mainMessage.compare("CAPTURED") == 0) {  // same as WIN, but this means you were the double agent
            font.drawString("CAPTURED", centerX-font.stringWidth("CAPTURED")*.5, height*.83-font.stringHeight("CAPTURED")*.5);
            
            float diameter = width*.75;
            ofSetColor(255, 255);
            circleShadow.draw(centerX, centerY, diameter, diameter);
            ofSetColor(primaries[primaryColor]);
            circleWhite.draw(centerX, centerY, diameter*.83, diameter*.83);
            ofSetColor(255, 255);
            avatars[controller->avatarSelf].draw(centerX, centerY, diameter*.625, diameter*.625);

        }
        else if (controller->mainMessage.compare("LOSE") == 0) {
            font.drawString("THEY GOT AWAY", centerX-font.stringWidth("THEY GOT AWAY")*.5, height*.83-font.stringHeight("THEY GOT AWAY")*.5);
            
            float iconScale = 1.0;
            if(elapsedMillis-stateBeginTime < 750){
                if(elapsedMillis - stateBeginTime > 500 && elapsedMillis - stateBeginTime < 750){
                    iconScale = 1 - (elapsedMillis-stateBeginTime-500)/250.0;
                }
                if(spinSpeed < 30)
                    spinSpeed +=.33;
                spin += spinSpeed;
                ofPushMatrix();
                ofTranslate(centerX, centerY);
                ofRotate(spin, 0, 0, 1);
                ofScale(iconScale, iconScale);
                float diameter = width*.75;
                ofSetColor(255, 255);
                circleShadow.draw(0, 0, diameter, diameter);
                ofSetColor(primaries[primaryColor]);
                circleWhite.draw(0, 0, diameter*.83, diameter*.83);
                ofSetColor(255, 255);
                avatars[controller->avatarSelf].draw(0, 0, diameter*.625, diameter*.625);
                ofPopMatrix();
            }
            else{
                spin = 1.0;
            }
        }
    }
    
    if(state == StateTurnComplete || state == StateTurnGesture || state == StateTurnScramble || state == StateDecide){
        int i1 = controller->turnNumber - 1;
        if(i1 < 0) i1 = 0;
        if(i1 >= NUM_TURNS) i1 = NUM_TURNS-1;
        
        // bezier curves are complicated, and this code is messy, sorry!
        for(int t = 0; t <= i1; t++){
            ofSetColor(primaries[complementaries[primaryColor*3+(t)]]);
            ofFill();
            ofBeginShape();
            float innerRadius = width*.3;//1125;
            float outerRadius = width*.18;
            float deltaAngle = TWO_PI / (float)SENSOR_DATA_ARRAY_SIZE;
            float angle = 0;
            
            float max = 3;
            for(int i = 0; i < SENSOR_DATA_ARRAY_SIZE; i++){
                if(controller->recordedSensorData[t][i] > max)
                    max = controller->recordedSensorData[t][i];
            }
            float x = centerX + innerRadius * sin(angle-deltaAngle);
            float y = centerY + innerRadius * -cos(angle-deltaAngle);
            float presentMagnitude, previousMagnitude = 0;  // to make a bezier vertex, you need to bulid the previous point's control point's magnitude
            bool notTheLastOne = 1;
            ofVertex(x, y);
            for(int i = 0; i < SENSOR_DATA_ARRAY_SIZE; i++){
                if(i == SENSOR_DATA_ARRAY_SIZE - 1) notTheLastOne = 0;  // forces the last entry back to the circle to prevent an overhanging edge
                presentMagnitude = controller->recordedSensorData[t][i] / max * notTheLastOne;
                x = centerX + innerRadius * sin(angle)  + outerRadius * sin(angle) * presentMagnitude;
                y = centerY + innerRadius * -cos(angle) + outerRadius * -cos(angle) * presentMagnitude;
//                ofVertex(x,y);
                ofBezierVertex(centerX + innerRadius * sin(angle-.6666*deltaAngle) + outerRadius * sin(angle-.6666*deltaAngle) * previousMagnitude,
                               centerY + innerRadius * -cos(angle-.6666*deltaAngle) + outerRadius * -cos(angle-.6666*deltaAngle) * previousMagnitude,
                               centerX + innerRadius * sin(angle-.3333*deltaAngle) + outerRadius * sin(angle-.3333*deltaAngle) * presentMagnitude,
                               centerY + innerRadius * -cos(angle-.3333*deltaAngle) + outerRadius * -cos(angle-.3333*deltaAngle) * presentMagnitude,
                               x,
                               y);
                previousMagnitude = presentMagnitude;
                angle += deltaAngle;
            }
            
            ofEndShape();
        }
    }

    // CLOCK DIAL
    if(state == StateTurnScramble){
        float length = width*.425;
        if(elapsedMillis < stateBeginTime + 250){
            float time = (elapsedMillis-stateBeginTime)/250.0 * 7;
            float curve = cosf(time-PI)/(9*powf(2, time-PI)) + 1;
            length *= curve;
        }
        ofSetLineWidth(20);
        ofSetColor(255, 255);
        ofLine(centerX, centerY, centerX, centerY-length);
    }
    else if(state == StateTurnGesture){
        float turnTime = PI*2*(elapsedMillis-stateBeginTime)/(float)ACTION_TIME;
        ofSetLineWidth(20);
        ofSetColor(255, 255);
        ofLine(centerX, centerY, centerX+sinf(turnTime)*width*.425, centerY-cosf(turnTime)*width*.425);
    }
    else if(state == StateTurnComplete) {
        float length = width*.425;
        if(elapsedMillis < stateBeginTime + 250){
            float time = 7 - ((elapsedMillis-stateBeginTime)/250.0 * 7);
            float curve = cosf(time-PI)/(9*powf(2, time-PI)) + 1;
            length *= curve;

            ofSetLineWidth(20);
            ofSetColor(255, 255);
            ofLine(centerX, centerY, centerX, centerY-length);
        }
    }
    // END CLOCK DIAL

    if(state == StateTurnScramble || state == StateTurnGesture || state == StateTurnComplete || state == StateDecide){
        
        float diameter = width*.75;
        ofSetColor(255, 255);
        circleShadow.draw(centerX, centerY, diameter, diameter);
        ofSetColor(primaries[primaryColor]);
        circleWhite.draw(centerX, centerY, diameter*.83, diameter*.83);  // .6225
        ofSetColor(255, 255);
        avatars[controller->avatarSelf].draw(centerX, centerY, diameter*.625, diameter*.625);
    }
    
    
    // white bar at bottom
    //ofSetColor(primaries[complementaries[primaryColor*3+0]]);
//    ofSetColor(255, 255, 255);
//    ofDrawPlane(width*.5, height-125, width, 250);
    
//    if (sta == GameStatePlaying || gameState == GameStateDeciding || gameState == GameStateGameOver) {
//            
//            ofSetColor(255, 255, 255, 255);
//            ofEnableBlendMode( OF_BLENDMODE_ALPHA );
//            
//            ofEnableAlphaBlending();
//            
//            drawInGameBackground();
//            
//            ofSetLineWidth(3.);
//            
//            // for drawing a circle path
//            float outerRadius;
//            int resolution;
//            float deltaAngle;
//            float angle;
//            ////////////////////////////////////////////////////////
//            // break out
//            if(currentTurn > 1){
//                for(int i = 1; i < currentTurn; i++){
//                    ofSetColor(primaries[complementaries[primaryColor*3+(i-1)]]);
//                    //ofSetColor(6, 140, 210, 100);   // blue motion shape
//                    //ofSetColor(74,193,255, 50); // blue motion shape border
//                    ofFill();
//                    ofBeginShape();
//                    outerRadius = centerX*.55;
//                    deltaAngle = TWO_PI / (float)SENSOR_DATA_ARRAY_SIZE;
//                    angle = 0;
//                    float turnProgress = 1.0;
//                    for(int i = 0; i < SENSOR_DATA_ARRAY_SIZE; i++){
//                        if((float)i/SENSOR_DATA_ARRAY_SIZE < turnProgress){
//                            float x = centerX + outerRadius * sin(angle) * controller->recordedSensorData[(i-1)*SENSOR_DATA_ARRAY_SIZE + i];
//                            float y = centerY + outerRadius * -cos(angle) * controller->recordedSensorData[(i-1)*SENSOR_DATA_ARRAY_SIZE + i];
//                            ofVertex(x,y);
//                            angle += deltaAngle;
//                        }
//                    }
//                    ofEndShape();
//                }
//            }
//            ////////////////////////////////////////////////////////
//            
//            if(turnState == TurnStateAction || turnState == TurnStateActionSuccess || turnState == TurnStateWaiting){
//                ofSetColor(primaries[complementaries[primaryColor*3+(currentTurn-1)]]);
//                //ofSetColor(6, 140, 210, 100);   // blue motion shape
//                //ofSetColor(74,193,255, 50); // blue motion shape border
//                ofFill();
//                ofBeginShape();
//                outerRadius = centerX*.55;
//                deltaAngle = TWO_PI / (float)SENSOR_DATA_ARRAY_SIZE;
//                angle = 0;
//                float turnProgress = (float)(ofGetElapsedTimeMillis() - controller->turnTime) / ACTION_TIME;   // from 0 to 1
//                for(int i = 0; i < SENSOR_DATA_ARRAY_SIZE; i++){
//                    if((float)i/SENSOR_DATA_ARRAY_SIZE < turnProgress){
//                        float x = centerX + outerRadius * sin(angle) * controller->recordedSensorData[(currentTurn-1)*SENSOR_DATA_ARRAY_SIZE + i];
//                        float y = centerY + outerRadius * -cos(angle) * controller->recordedSensorData[(currentTurn-1)*SENSOR_DATA_ARRAY_SIZE + i];
//                        ofVertex(x,y);
//                        angle += deltaAngle;
//                    }
//                }
//                ofEndShape();
//
//            }
//            ofSetColor(255, 255, 255,255);
//            
//            insideCircle.draw(centerX, centerY);
//            if(gameState == GameStateDeciding){
//                ofSetColor(primaries[complementaries[primaryColor*3+((currentTurn+1)%3)]]);  // modulus to vary color
//                fingerPrint.draw(centerX, centerY,insideCircle.width*.5, insideCircle.height*.5);
//            }
//            
//            if (( gameState == GameStatePlaying && !controller->preGameCountdownSequence ) || gameState == GameStateDeciding || gameState == GameStateGameOver){
//                ofNoFill();
//                if(turnState == TurnStateReceivingScrambled || turnState == TurnStateAction || gameState == GameStateDeciding)
//                    ofSetColor(primaries[complementaries[primaryColor*3+((currentTurn+1)%3)]]);  // modulus to vary color
//                else
//                    ofSetColor(primaries[primaryColor]);
//                ofBeginShape();
//                outerRadius = centerX*.52;
//                resolution = 64;
//                deltaAngle = TWO_PI / (float)resolution;
//                angle = 0;
//                float roundProgress = (float)currentTurn / NUM_TURNS;
//                for(int i = 0; i <= resolution; i++){
//                    if((float)i/resolution <= roundProgress){
//                        float x = centerX + outerRadius * sin(angle);
//                        float y = centerY + outerRadius * -cos(angle);
//                        ofVertex(x,y);
//                        angle += deltaAngle;
//                    }
//                }
//                ofEndShape();
//            }
//            
//            ofDisableAlphaBlending();
//            
//            // BACK TO BUSINESS
//            
//            if (controller->mainMessage.length()){
//                ofSetColor(255,255,255,255);
//                
//                if (controller->animatedScrambleFont) {
//                    //if(rand()%2 == 0){
//                    int index = rand()%4;
//                    spymess[index] = rand()%23+65;
//                    //}
//                    font.drawString(ofToString(spymess),ofGetWidth()/2 - font.stringWidth(spymess)/2.,ofGetHeight()/2 + font.stringHeight(ofToString(spymess))/2.);
//                }
//                else if (controller->useScrambledText){
//                    font.drawString(ofToString(spymess),ofGetWidth()/2 - font.stringWidth(spymess)/2.,ofGetHeight()/2 + font.stringHeight(ofToString(spymess))/2.);
//                }
//                else
//                    font.drawString(controller->mainMessage,ofGetWidth()/2 - font.stringWidth(controller->mainMessage)/2.,ofGetHeight()/2 + font.stringHeight(controller->mainMessage)/2.);
//            }
//
//    }
//    
//    if (!isServer && !isClient) {  // if not server or client
//        drawLoginScreen(loginState);
//    }
//    ofSetColor(255, 255);
//    if(gameState == GameStateLogin){
//        lowerTextLine1 = "ONLY 1 HOST IS REQUIRED";
//        lowerTextLine2 = "";
//        lowerTextLine3 = "";
//    }
//    if(loginState == LoginStateChoose){
//        fontLarge.drawString("DOUBLE AGENT", centerX-fontLarge.stringWidth("DOUBLE AGENT")*.5, 125);
//    }
//    
//    if(gameState == GameStateReadyRoom){
//        if (isServer) {
//            lowerTextLine1 = "YOU ARE THE HOST";
//            lowerTextLine2 = controller->getCodeFromIp();
//            lowerTextLine3 = "Share this code for others to log in";
//        }
//        else {
//            lowerTextLine1 = "YOU ARE CONNECTED";
//            lowerTextLine2 = "to host: " + controller->getCodeFromInt(controller->loginCode);
//            lowerTextLine3 = "Waiting for host to start the game";
//        }
//    }
//    
//    if(gameState == GameStatePlaying){
//        if(controller->preGameCountdownSequence){
//            if(step > 6){
//                lowerTextLine1 = "AGENT ID";
//                lowerTextLine2 = "AGENT";
//                lowerTextLine3 = "Purpose: to identify the double agent";
//            }
//            else{
//                lowerTextLine1 = lowerTextLine2 = lowerTextLine3 = "";
//            }
//        }
//        else{
//            lowerTextLine1 = "AGENT ID";
//            lowerTextLine2 = "AGENT";
//            lowerTextLine3 = "Purpose: to identify the double agent";
//        }
//    }
//    if(gameState == GameStateDeciding){
//        lowerTextLine1 = "TARGET";
//        lowerTextLine2 = "DOUBLE AGENT";
//        lowerTextLine3 = "Select operative identified as double agent";
//    }
//    if(gameState == GameStateGameOver){
//        lowerTextLine1 = "MISSION";
//        if(strcmp(controller->mainMessage.c_str(), "SPY CAPTURED!") == 0){
//            lowerTextLine2 = "SUCCESS";
//            lowerTextLine3 = "You have sucessfully uncovered the double agent";
//        }
//        else if(strcmp(controller->mainMessage.c_str(), "NOPE!") == 0){
//            lowerTextLine2 = "FAIL";
//            lowerTextLine3 = "the double agent got away";
//        }
//    }
//    
//    ofSetColor(0, 0, 0, 255);
//    fontSmall.drawString(lowerTextLine1, 60, centerY+centerY*.66);
//    ofSetColor(0, 0, 0, 255);
//    fontSmall.drawString(lowerTextLine2, 60, centerY+centerY*.66+40);
//    fontSmall.drawString(lowerTextLine3, 60, centerY+centerY*.66+80);
//    
//    if (controller->connectedAgents > 1){   // CONNECTED AGENTS
//        string count = connectedAgentsStrings[controller->connectedAgents];//ofToString(connectedAgents);
//        ofSetColor(0,0,0);
//        font.drawString(count, centerX-font.stringWidth(count)/2.,ofGetHeight() - font.stringHeight(count));
//    }
}

//void AgentView::drawLoginScreen(LoginStateState loginState) {
//    
//    string hostString = "HOST";
//    string clientString = "JOIN";
//    string backString = "< BACK";
//    string thirdString;
//    
//    ofSetColor(255,255,255);
//    
//    ofEnableAlphaBlending();
//    
//    switch (loginState) {
//        case LoginStateChoose:
//            font.drawString(hostString,ofGetWidth()/2 - font.stringWidth(hostString)/2.,ofGetHeight()*.4 - font.stringHeight(hostString)/2.);
//            font.drawString(clientString,ofGetWidth()/2 - font.stringWidth(clientString)/2.,ofGetHeight()*.6 - font.stringHeight(clientString)/2.);
//            break;
//            
//        case LoginStateServer:
//            hostString = "JOIN CODE";
//            clientString = controller->getCodeFromIp();
//            fontMedium.drawString(backString,fontMedium.stringWidth(backString)*.35,ofGetHeight()*.1 - fontMedium.stringHeight(backString)/2.);
//            font.drawString(hostString,ofGetWidth()/2 - font.stringWidth(hostString)/2.,ofGetHeight()*.4 - font.stringHeight(hostString)/2.);
//            font.drawString(clientString,ofGetWidth()/2 - font.stringWidth(clientString)/2.,ofGetHeight()*.6 - font.stringHeight(clientString)/2.);
//            break;
//            
//        case LoginStateClient:
//            hostString = "CODE";
//            clientString = controller->getCodeFromInt(controller->loginCode);
//            fontMedium.drawString(backString,fontMedium.stringWidth(backString)*.35,ofGetHeight()*.1 - fontMedium.stringHeight(backString)/2.);
//            font.drawString(hostString,ofGetWidth()/2 - font.stringWidth(hostString)/2.,ofGetHeight()*.2 - font.stringHeight(hostString)/2.);
//            font.drawString(clientString,ofGetWidth()/2 - font.stringWidth(clientString)/2.,ofGetHeight()*.475 - font.stringHeight(clientString)/2.);
//            increment.draw(width*.31, height*.325, width*.1, width*.1);
//            increment.draw(width*.5, height*.325, width*.1, width*.1);
//            increment.draw(width*.7, height*.325, width*.1, width*.1);
//            decrement.draw(width*.31, height*.525, width*.1, width*.1);
//            decrement.draw(width*.5, height*.525, width*.1, width*.1);
//            decrement.draw(width*.7, height*.525, width*.1, width*.1);
//            hostString = "JOIN";
//            font.drawString(hostString,ofGetWidth()/2 - font.stringWidth(hostString)/2.,ofGetHeight()*.75 - font.stringHeight(hostString)/2.);
//            break;
//            
//        case LoginStateConnecting:
//            hostString = "CONNECTING TO";
//            clientString = controller->getCodeFromInt(controller->loginCode);
//            font.drawString(hostString,ofGetWidth()/2 - font.stringWidth(hostString)/2.,ofGetHeight()*.4 - font.stringHeight(hostString)/2.);
//            font.drawString(clientString,ofGetWidth()/2 - font.stringWidth(clientString)/2.,ofGetHeight()*.6 - font.stringHeight(clientString)/2.);
//            break;
//            
//        case LoginStateFailed:
//            hostString = "BACK";
//            clientString = "CONNECTION";
//            thirdString = "FAILED";
//            font.drawString(hostString,ofGetWidth()/2 - font.stringWidth(hostString)/2.,ofGetHeight()*.15 - font.stringHeight(hostString)/2.);
//            font.drawString(clientString,ofGetWidth()/2 - font.stringWidth(clientString)/2.,ofGetHeight()*.5 - font.stringHeight(clientString)/2.);
//            font.drawString(thirdString,ofGetWidth()/2 - font.stringWidth(thirdString)/2.,ofGetHeight()*.6 - font.stringHeight(thirdString)/2.);
//            break;
//            
//        case LoginStateServerQuit:
//            hostString = "BACK";
//            clientString = "HOST STOPPED";
//            thirdString = "THE GAME";
//            font.drawString(hostString,ofGetWidth()/2 - font.stringWidth(hostString)/2.,ofGetHeight()*.15 - font.stringHeight(hostString)/2.);
//            font.drawString(clientString,ofGetWidth()/2 - font.stringWidth(clientString)/2.,ofGetHeight()*.5 - font.stringHeight(clientString)/2.);
//            font.drawString(thirdString,ofGetWidth()/2 - font.stringWidth(thirdString)/2.,ofGetHeight()*.6 - font.stringHeight(thirdString)/2.);
//            break;
//            
//        case LoginStateNoIP:
//            hostString = "NO ADDRESS";
//            clientString = "CHECK WIFI ?";
//            fontMedium.drawString(backString,fontMedium.stringWidth(backString)*.35,ofGetHeight()*.1 - fontMedium.stringHeight(backString)/2.);
//            font.drawString(hostString,ofGetWidth()/2 - font.stringWidth(hostString)/2.,ofGetHeight()*.4 - font.stringHeight(hostString)/2.);
//            font.drawString(clientString,ofGetWidth()/2 - font.stringWidth(clientString)/2.,ofGetHeight()*.6 - font.stringHeight(clientString)/2.);
//            break;
//            
//        default:
//            break;
//    }
//    
//    ofDisableAlphaBlending();
//}

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
