//
//  agentController.cpp
//  DoubleAgent
//
//  Created by Chroma Developer on 12/30/13.
//
//

#include "agentController.h"

#import "testApp.h"
#import "ofxTimer.h"

string paddedString(int num){
    if (num >= 100)     return ofToString(num);
    else if (num >= 10) return "0" + ofToString(num);
    else                return "00" + ofToString(num);
}

void agentController::setup() {
    
    // GAME / PROGRAM
    gameState = GameStateLogin;
    loginState = LoginStateChoose;
    turnState = TurnStateNotActive;                                                                                         // turnState  :  not active
    currentTurn = 0;

    // GRAPHICS
    spymess[0] = rand()%23+65;
    spymess[1] = rand()%23+65;
    spymess[2] = rand()%23+65;
    spymess[3] = rand()%23+65;
    spymess[4] = NULL;

    width = ofGetWidth();
    height = ofGetHeight();
    centerX = ofGetWidth()/2.;
    centerY = ofGetHeight()/2.;
}

#pragma mark NETWORK

// SERVER:
// CLIENT: turn control (start turn, scramble, execute, pick, captured/not captured), receive isSpy
void agentController::updateTCP() {
    
	if (isServer){
        connectedAgents = 1;
	    for(int i = 0; i < server.getLastID(); i++) { // getLastID is UID of all clients
            if( server.isClientConnected(i) ) { // check and see if it's still around
                connectedAgents++;
                // maybe the client is sending something
                Rx = server.receive(i);
                //server.send(i, "You sent: "+str);
                if (Rx.length()){
                	strcpy( receivedText, Rx.c_str() );
                    ofLogNotice("TCP") << "Agent:" + ofToString(i) + " : " + Rx;
                    
                    if (strcmp(receivedText, "pickedAgent") == 0) {
                        pickedAgent(i+1);
                    }
//                    else  if (strcmp(receivedText, "login") == 0) {
//                        activeAgents++;  // TODO needs a point where activeAgents--
//                    }
                    else {// must be a number
                        recordedTimes[i+1] = ofToInt(Rx);
                    }
                }
            }
	    }
	}
    else if (isClient){
        
    	if (!client.isConnected()){
    		client.close();
    		isClient = false;
    		connectedAgents = 0;
    		gameState = GameStateLogin;
    		loginState = LoginStateServerQuit;
    		return;
    	}
        
        Rx = client.receive();
        if (Rx.length()){
	    	ofLogNotice("TCP") << "Received From Server: " + Rx;
            strcpy( receivedText, Rx.c_str() );
            if (strcmp(receivedText, "startGame") == 0) {
                startGame();
//                sendMessage("login");
            }
            else if (strcmp(receivedText, "execute") == 0) {
                execute(mainMessage);
            }
            else if (strcmp(receivedText, "PICK") == 0) {
                ((testApp*) ofGetAppPtr())->vibrate(true);
                //execute(mainMessage);
                mainMessage = "OPERATIVE I.D.";  // "PICK"
                gameState = GameStateDeciding;                                                                                  // gameState  :  deciding
                turnState = TurnStateNotActive;                                                                                  // turnState  :  not active
            }
            else if (strcmp(receivedText, "spy") == 0) {
                isSpy = true;
            }
            else if (strcmp(receivedText, "notspy") == 0) {
                isSpy = false;
            }
            else if (strcmp(receivedText, "SPY CAPTURED!") == 0) {
                mainMessage = "SPY CAPTURED!";
                gameState = GameStateGameOver;
                stepTimer = ofGetElapsedTimeMillis();
                stepInterval = 5000;
            }
            else if (strcmp(receivedText, "NOPE!") == 0) {
                mainMessage = "NOPE!";
                gameState = GameStateGameOver;
                stepTimer = ofGetElapsedTimeMillis();
                stepInterval = 5000;
            }
            else {
                bool wasTurnRelated = false;
                for (int g = 0; g < NUM_GESTURES; g++) {
                    if (strcmp(receivedText, actionString[g].c_str()) == 0) {
                        ((testApp*) ofGetAppPtr())->vibrate(true);
                        useScrambledText = true;  // everybody's appears scrambled to begin
                        animatedScrambleFont = true;
                        mainMessage = Rx;
                        wasTurnRelated = true;
                        turnState = TurnStateReceivingScrambled;                                                                // turnState  :  scrambled    (client)
                        currentTurn++;
                    }
                }
                for (int g = 0; g < NUM_PLACES; g++) {
                    if (strcmp(receivedText, placeString[g].c_str()) == 0) {
                        useScrambledText = false;
                        mainMessage = Rx;
                        wasTurnRelated = true;
                        turnState = TurnStateWaiting;                                                                           // turnState  :  waiting      (client)
                    }
                }
                if(!wasTurnRelated){  // nothing. can we count on this being a number? maybe.
                    connectedAgents = ofToInt(Rx);
                }
            }
        }
    }
}

void agentController::stopServer(){
	if (isServer){
        for(int i = 0; i < server.getLastID(); i++){ // getLastID is UID of all clients
            if( server.isClientConnected(i) ) {
                server.disconnectClient(i);
            }
        }
        server.close();
        isServer = false;
	}
}

void agentController::updateSlowTCP(){
    if(oneSecond != ofGetSeconds()){   // only runs once/second
        oneSecond = ofGetSeconds();
        if(isServer){  //  send number of clients
            sendMessage(ofToString(connectedAgents));
        }
        else if (isClient) { }
    }
}

void agentController::sendMessage(string message){
    
	if (isServer){
	    for(int i = 0; i < server.getLastID(); i++){ // getLastID is UID of all clients
            if( server.isClientConnected(i) ) { // check and see if it's still around
                server.send(i,message);
            }
	    }
	}
	else if (isClient){
		client.send(message);
	}
}

#pragma mark - GAME LOGIC


void agentController::startGame(){
    
    if (isServer){
        
        gameState = GameStatePlaying;                                                                                       // gameState
        spyAccordingToServer = rand() % (server.getLastID() + 1);
        
        if (spyAccordingToServer != 0){
            while (!server.isClientConnected(spyAccordingToServer-1)){
                spyAccordingToServer = rand() % (server.getLastID() + 1);
            }
        }
       
        for(int i = 0; i < server.getLastID() + 1; i++) { // getLastID is UID of all clients
            
            if (i == spyAccordingToServer) {
                if (i == 0) {
                    isSpy = true;
                }
                else {
                    server.send(i-1, "spy");
                }
            }
            else {
                if (i == 0) {
                    isSpy = false;
                }
                else {
                    server.send(i-1, "notspy");
                }
            }
        }
    }
    countDown(0);
}

void agentController::countDown(int curstep) {
    
    gameState = GameStatePlaying;                                                                                                // gameState  :  playing
    
    if (!curstep) {  // possible for server and clients
        step = 0;
        stepInterval = 1000;
        numSteps = 10;
        stepTimer = ofGetElapsedTimeMillis();
        preGameCountdownSequence = true;
        stepFunction = &agentController::countDown;
        currentTurn = 0;
        return;
    }
    
    switch (curstep) {
        case 6:
            mainMessage = "5";
            break;
        case 7:
            mainMessage = "4";
            break;
        case 8:
            mainMessage = "3";
            break;
        case 9:
            mainMessage = "2";
            break;
        case 10:
            mainMessage = "1";
            break;
        case 11:
            //mainMessage = "";
            stepInterval = 0;
            preGameCountdownSequence = false;
            if (isServer) {
                serveRound(0);
            }
            break;
        default:
            break;
    }
}

// server only function
void agentController::serveRound(int curstep){
    
    // initiate round
    if (!curstep) {
        for(int i = 0; i < NUM_TURNS; i++)
            previousActions[i] = "";
        step = 0;
        stepInterval = 5000;
        numSteps = NUM_TURNS*3;
        stepTimer = ofGetElapsedTimeMillis();
        stepFunction = &agentController::serveRound;
    }
    if (curstep == numSteps) {
       
        mainMessage = "OPERATIVE I.D.";  // everyone
        
        for(int i = 0; i < server.getLastID(); i++) {  // getLastID is UID of all clients
            if( server.isClientConnected(i) ) { // check and see if it's still around
                server.send(i,"PICK");
            }
	    }
        stepInterval = 0;
        gameState = GameStateDeciding;                                                                                      // gameState  :  deciding
        turnState = TurnStateNotActive;
    }
    
    else if (curstep %3 == 0) { // MESSAGE
        
        for (int i = 0 ; i < 16; i++) {
            recordedTimes[i] = 5000 + i;
        }
        // find a gesture which has not yet occurred
        do {
            mainMessage = actionString[rand()%(NUM_GESTURES-1) + 1];
        } while (actionHasOccurred(mainMessage));
        // store it in the first vacant spot in the previousActions array
        bool placed = false;
        for(int i = 0; i < NUM_TURNS; i++){
            if(!placed && strcmp(previousActions[i].c_str(), "") == 0){
                previousActions[i] = mainMessage;
                placed = true;
            }
        }
        
        useScrambledText = true;   // everyone begins with scrambled text
        animatedScrambleFont = true;
        sendMessage(mainMessage);
        ((testApp*) ofGetAppPtr())->vibrate(true);
        turnState = TurnStateReceivingScrambled;                                                                            // turnState  :  scrambled       (server)
        stepInterval = 1000 + rand() % 3000;
        currentTurn++;
    }
    else if (curstep%3 == 1) { // EXCECUTE
        sendMessage("execute");
        stepInterval = ACTION_TIME;
        execute(mainMessage);
    }
    else if (curstep%3 == 2) { // RESULTS
//        countScores();
        useScrambledText = false;
        turnState = TurnStateWaiting;                                                                                       // turnState  :  waiting        (server)
        stepInterval = 6000;
    }
}

bool agentController::actionHasOccurred(string message){
    for(int i = 0; i < NUM_TURNS; i++){
        if(strcmp(previousActions[i].c_str(), message.c_str()) == 0)
            return true;
    }
    return false;
}

void agentController::execute(string gesture){
    
    turnState = TurnStateAction;                                                                                            // turnState  :  action
    animatedScrambleFont = false;
    if(!isSpy){
        useScrambledText = false;
    }
    
    // clear recorded sensor array before every turn  // TODO separate between events which need recording and those which don't
    for(int i = 0; i < SENSOR_DATA_ARRAY_SIZE*3; i++)
        recordedSensorData[i] = 1.;
    
    ofLogNotice("RECORD MODE") << "RECORDING: " + gesture;
    
    char mess[128];
    strcpy(mess, gesture.c_str());
    
    if (strcmp(mess, "TOUCH SCREEN") == 0) {
        recordMode = RecordModeTouch;
    }
    else if (strcmp(mess, "SHAKE PHONE") == 0 ||
             strcmp(mess, "JUMP") == 0 ||
             strcmp(mess, "FREEZE") == 0 ||
             strcmp(mess, "RUN IN PLACE") == 0 ||
             strcmp(mess, "CROUCH") == 0) {
        recordMode = RecordModeAccel;
    }
    else if (strcmp(mess, "SPIN") == 0 ||
             strcmp(mess, "TOUCH PHONE\nWITH NOSE") ||
             strcmp(mess, "RAISE\nA HAND") == 0) {
        recordMode = RecordModeOrientation;
    }
    else if (strcmp(mess, "HIGH FIVE\nNEIGHBOR") == 0 ||
             strcmp(mess, "POINT AT\nAN AGENT") == 0 ||
             strcmp(mess, "STAND ON\nONE LEG") == 0) {
        recordMode = RecordModeNothing;
    }
    else {
        recordMode = RecordModeNothing;
    }
    turnTime = ofGetElapsedTimeMillis();
}

void agentController::update() {
    
    if (isClient || isServer) {
        
      	updateTCP();
        updateSlowTCP();
        
        if(turnState == TurnStateAction){
            float turnProgress = (float)(ofGetElapsedTimeMillis() - turnTime) / ACTION_TIME;   // from 0 to 1
            int index = SENSOR_DATA_ARRAY_SIZE*turnProgress;
            if(index < 0) index = 0;
            if(index >= SENSOR_DATA_ARRAY_SIZE) index = SENSOR_DATA_ARRAY_SIZE-1;
            float maxScale = 4*getMaxSensorScale() + 1.;
            recordedSensorData[(currentTurn-1)*SENSOR_DATA_ARRAY_SIZE + index] = maxScale;
        }
        
        if(gameState == GameStateGameOver){
            if (ofGetElapsedTimeMillis() - stepTimer > stepInterval ){
                gameState = GameStateReadyRoom;
                mainMessage = "";
                stepInterval = 1000;
                step = 0;
                stepTimer = ofGetElapsedTimeMillis();
            }
        }
        else if (gameState == GameStateReadyRoom){
            if (ofGetElapsedTimeMillis() - stepTimer > stepInterval ){
                step++;
                
                if (step > 16){//numSteps){
                    //stepInterval = 0;
                    step = 0;
                }
                stepTimer = ofGetElapsedTimeMillis();
            }
        }
        else{
            if (stepInterval){
                if (ofGetElapsedTimeMillis() - stepTimer > stepInterval ){
                    step++;
                    if (step > 0){
                        if (stepFunction != NULL) {
                            (this->*stepFunction)(step);
                        }
                    }
                    if (step > numSteps){
                        stepInterval = 0;
                    }
                    stepTimer = ofGetElapsedTimeMillis();
                }
            }
        }
    }
}

// server only function, i think
void agentController::pickedAgent(int agent) {
    
    if(agent == spyAccordingToServer){
        //sendMessage("agentDiscovered");
        mainMessage = "SPY CAPTURED!";
        sendMessage(mainMessage);
    }
    else {
        //sendMessage("agentNotDiscovered");
        mainMessage = "NOPE!";
        sendMessage(mainMessage);
    }
    gameState = GameStateGameOver;                                                                                          // gameState
    stepTimer = ofGetElapsedTimeMillis();
    stepInterval = 5000;
}


// server only function
void agentController::countScores(){
    
    int places[16];
    for (int p = 0; p < 16; p++) {
        places[p] = -1;
    }
    for(int i = 0; i < server.getLastID() + 1; i++) {   // getLastID is UID of all clients
        int lowestTime = 100000;
        for(int j = 0; j < server.getLastID() + 1; j++){ // getLastID is UID of all clients
            if (recordedTimes[j] <= lowestTime) {
                bool shouldRecord = true;
                for (int p = 0; p < 16; p++) {
                    if (places[p] == j) {
                        shouldRecord = false;
                    }
                }
                if (shouldRecord) {
                    lowestTime = recordedTimes[j];
                    places[i] = j;
                }
            }
        }
        ofLogNotice("PLACES") << ofToString(places[i]) + " is in " + ofToString(i) + " place with " + ofToString(recordedTimes[places[i]]) + "time";
    }
    for(int i = 0; i < server.getLastID() + 1; i++) { // getLastID is UID of all clients
        if (places[i] != 0) {
            if( server.isClientConnected(places[i] - 1) ) { // check and see if it's still around
                server.send(places[i]-1, placeString[i]);
            }
        }
        else {
            mainMessage = placeString[i];
        }
    }
}



#pragma mark - SENSORS

//--------------------------------------------------------------
void agentController::touchBegan(int x, int y, int id){
    
    switch (gameState) {
            
        case GameStateLogin:
            
            switch (loginState) {
                case LoginStateChoose:
                    if (y < centerY) {
                        int con = serverConnect();
                        if (con == -1){
                            loginState = LoginStateNoIP;
                            ofLogNotice("choose screen") << "no ip";
                        }
                        else if (con == 0) {
                            loginState = LoginStateFailed;
                        }
                        else {
                            ofLogNotice("choose server") << "yes!";
                            loginState = LoginStateServer;
                            
                            isServer = true;
                            gameState = GameStateReadyRoom;
                            stepInterval = 1000;
                            step = 0;
                            stepTimer = ofGetElapsedTimeMillis();
                        }
                    }
                    else {
                        loginState = LoginStateClient;
                    }
                    break;
                case LoginStateServer:
                    break;
                    
                case LoginStateClient:
                    if (y < height * .2) {
                        loginState = LoginStateChoose;
                    }
                    else if (y < height * .65){
                        if (x < width * .4) {
                            if (y < height * .5) { // inc 100's
                                loginCode >= 200 ? loginCode -= 200 : loginCode += 100;
                            }
                            else {
                                loginCode < 100 ? loginCode += 200 : loginCode -= 100;
                            }
                        }
                        else if (x > width *.4 && x < width * .6){
                            int tens = loginCode - ((loginCode / 100) * 100);
                            if (y < height * .5) { // inc 100's
                                tens >= 90 ? loginCode -= 90 : loginCode += 10;
                            }
                            else {
                                tens < 10 ? loginCode += 90 : loginCode -= 10;
                            }
                        }
                        else if (x > width * .6){
                            int tens = loginCode - ((loginCode / 100) * 100);
                            int ones = tens - ((tens / 10) * 10);
                            if (y < height * .5) { // inc 100's
                                ones >= 9 ? loginCode -= 9 : loginCode += 1;
                            }
                            else {
                                ones < 1 ? loginCode += 9 : loginCode -= 1;
                            }
                        }
                    }
                    else {
                        int con = clientConnect();
                        if (con == 0) {
                            loginState = LoginStateFailed;
                        }
                        else if (con == -1){
                            loginState = LoginStateNoIP;
                        }
                        else {
                            isClient = true;
                            gameState = GameStateReadyRoom;                                                                            // gameState  :  connected
                            ofLogNotice("+++ GameState updated:") << "Ready Room, setIPAddress()";
                            stepInterval = 1000;
                            step = 0;
                            stepTimer = ofGetElapsedTimeMillis();
                        }
                    }
                    break;
                    
                case LoginStateConnecting:
                    break;
                    
                case LoginStateFailed: case LoginStateNoIP: case LoginStateServerQuit:
                    loginState = LoginStateChoose;
                    break;
                    
                default:
                    break;
            }
            break;
            
        case GameStateReadyRoom:
            
            if (y < height * .2) {
                gameState = GameStateLogin;
                loginState = LoginStateChoose;
                if (isServer){stopServer(); isServer = 0;}
                if (isClient){client.close(); isClient = 0;}
            }
            else if (isServer && connectedAgents > 1){
                sendMessage("startGame");
                //sleep(250);
                startGame();
            }
            break;
            
        case GameStatePlaying:
            if (recordMode == RecordModeTouch) {
                turnState = TurnStateActionSuccess;                                                                         // turnState  :  action success
                recordMode = RecordModeNothing;        // turn off recording
                recordedTimes[0] = ofGetElapsedTimeMillis() - turnTime;
                ((testApp*) ofGetAppPtr())->vibrate(true);
                if (isClient) {
                    sendMessage(ofToString(recordedTimes[0]));
                }
            }
            break;
            
        case GameStateDeciding:
            if (isServer) {
                pickedAgent(0);
            }
            else if (isClient){
                sendMessage("pickedAgent");
            }
            break;
            
        default:
            break;
    }
    
	//sendMessage("touch down");
}

void agentController::touchMoved(int x, int y, int id) { }

void agentController::touchEnded(int x, int y, int id) { }

float agentController::getMaxSensorScale(){
    float max = 0.;
    if(fabs(deltaOrientation.b) > max) max = fabs(deltaOrientation.b);
    if(fabs(deltaOrientation.c) > max) max = fabs(deltaOrientation.c);
    if(fabs(deltaOrientation.d) > max) max = fabs(deltaOrientation.d);
    if(fabs(deltaOrientation.f) > max) max = fabs(deltaOrientation.f);
    if(fabs(deltaOrientation.g) > max) max = fabs(deltaOrientation.g);
    if(fabs(deltaOrientation.h) > max) max = fabs(deltaOrientation.h);
    return max;
}

void agentController::updateAccel(ofVec3f newAccel){
    
    if (newAccel.x != accel.x ) {
        
        accel = newAccel;
        normAccel = accel.getNormalized();
        
        accelIndex++;
        if (accelIndex > 127) {
            accelIndex = 0;
        }
        
        float alpha = 0.9f;
        
        filteredAccel.x = alpha * filteredAccel.x + (1 - alpha) * normAccel.x;
        filteredAccel.y = alpha * filteredAccel.y + (1 - alpha) * normAccel.y;
        filteredAccel.z = alpha * filteredAccel.z + (1 - alpha) * normAccel.z;
        
        userAccelerationArray[accelIndex] = filteredAccel;
        
        bool didIt = false;
        
//        if (recordMode == GameActionJump || recordMode == GameActionShake) {
//            if (accel.z > .5) {
//                didIt = true;
//            }
//        }
//
//        else if (recordMode == GameActionSpin) {
//            if (accel.y > .5) {
//                didIt = true;
//            }
//        }
        
        if (didIt) {
            turnState = TurnStateActionSuccess;                                                                        // turnState  :  action Success
            recordedTimes[0] = ofGetElapsedTimeMillis() - turnTime;
            ((testApp*) ofGetAppPtr())->vibrate(true);
            
            if (isClient) {
                sendMessage(ofToString(recordedTimes[0]));
            }
        }
    }
}


void agentController::logMatrix3x3(ofMatrix3x3 matrix){
    static int timeIndex;
    timeIndex++;
    if(timeIndex % 15 == 0){
        char b, c, d, f, g, h;
        b = c = d = f = g = h = ' ';
        if(matrix.b > 0) b = '+'; else if (matrix.b < 0) b = '-';
        if(matrix.c > 0) c = '+'; else if (matrix.c < 0) c = '-';
        if(matrix.d > 0) d = '+'; else if (matrix.d < 0) d = '-';
        if(matrix.f > 0) f = '+'; else if (matrix.f < 0) f = '-';
        if(matrix.g > 0) g = '+'; else if (matrix.g < 0) g = '-';
        if(matrix.h > 0) h = '+'; else if (matrix.h < 0) h = '-';
        ofLogNotice("") <<
        "\n[ " <<'1'<< " " << b << " " << c << " ]   [ " << matrix.a << " " << matrix.b << " " << matrix.c << " ]" <<
        "\n[ " << d << " " <<'1'<< " " << f << " ]   [ " << matrix.d << " " << matrix.e << " " << matrix.f << " ]" <<
        "\n[ " << g << " " << h << " " <<'1'<< " ]   [ " << matrix.g << " " << matrix.h << " " << matrix.i << " ]";
    }
}
void agentController::logMatrix4x4(ofMatrix4x4 matrix){
    static int timeIndex;
    timeIndex++;
    if(timeIndex % 15 == 0)
        ofLogNotice("") <<
        "\n[ " << matrix._mat[0].x << " " << matrix._mat[1].x << " " << matrix._mat[2].x << " ]" <<
        "\n[ " << matrix._mat[0].y << " " << matrix._mat[1].y << " " << matrix._mat[2].y << " ]" <<
        "\n[ " << matrix._mat[0].z << " " << matrix._mat[1].z << " " << matrix._mat[2].z << " ]";
}


void agentController::updateOrientation(ofMatrix3x3 newOrientationMatrix, ofMatrix3x3 newDeltaOrientationMatrix){
    orientation = newOrientationMatrix;
    deltaOrientation = newDeltaOrientationMatrix;
//    logMatrix3x3(deltaOrientation);
}



#pragma mark - DRAW

void agentController::draw() {
    agentView.draw(gameState, loginState, turnState, isServer, isSpy, step, stepInterval, stepTimer);
}

//bool agentController::processAcceleration() {
//    
//    bool foundHighZ;
//    bool foundLowZ;
//    
//    for (int i = 0; i < 128; i++) {
//        
//        if (userAccelerationArray[i].z > 1) {
//            foundHighZ = true;
//        }
//        if (userAccelerationArray[i].z < -1) {
//            foundLowZ = true;
//        }
//    }
//    
//    if (foundLowZ && foundHighZ) {
//        return 1;
//    }
//    else return 0;
//}

#pragma mark - SYSTEM

void agentController::setIpAddress(const char* ipAddress){
    
    if (ipAddress != NULL){
        if (ipAddress[0] != 0){
            localIP = std::string(ipAddress);
            ofLogNotice("OSC") << "OF LOCAL IP ADDRESS:" + localIP + " on port:" << ofToString(PORT);
            // open an outgoing connection to HOST:PORT
            // DO CLIENT
        }
    }
	else {
		ofLogNotice("OSC") << "Didn't receive IP address from ANDROID ENV";
	}
}


string agentController::getCodeFromInt(int num){
    
    string codeString = paddedString(num);
    
    char code[8];
    
    code[1] = ' ';
    code[2] = ' ';
    code[4] = ' ';
    code[5] = ' ';
    
    const char* last = codeString.c_str();
    code[0] = last[0];
    code[3] = last[1];
    code[6] = last[2];
    code[7] = '\0';
    
    return string(code);
}



string agentController::getCodeFromIp(){
    
    if (localIP.compare("error") == 0 || !localIP.length()) return "error";
    
    std::vector<std::string> result;
    
    result = ofSplitString(localIP,".");
    
    
    if (result[3].length() < 3){
        
        char code[8];
        
        code[1] = ' ';
        code[2] = ' ';
        code[4] = ' ';
        code[5] = ' ';
        
        const char* last = result[3].c_str();
        code[0] = '0';
        code[3] = last[0];
        code[6] = last[1];
        code[7] = '\0';
        
        return string(code);
        
    }
    
    else {
        char code[8];
        
        code[1] = ' ';
        code[2] = ' ';
        code[4] = ' ';
        code[5] = ' ';
        
        const char* last = result[3].c_str();
        code[0] = last[0];
        code[3] = last[1];
        code[6] = last[2];
        code[7] = '\0';
        
        return string(code);
    }
    
    
    
}

int agentController::serverConnect(){
    
    if (localIP.compare("error") == 0 || !localIP.length()) {
        ofLogNotice("TCP") << "SERVER FAILED ! NO IP";
        return -1;
    }
    
    if (server.setup(PORT)) {
        ofLogNotice("TCP") << "IS SERVER AT:" + localIP + " on port:" << ofToString(PORT);
        return 1;
    }
    
    else {
        server.close();
        ofLogNotice("TCP") << "SERVER FAILED !!";
        ofLogNotice("+++ GameState updated:") << "Waiting For Sign In  setIPAddress1";
        return 0;
    }
    
}

int agentController::clientConnect(){
    
    if (localIP.compare("error") == 0 || !localIP.length()) {
        ofLogNotice("TCP") << "CLIENT FAILED ! NO IP";
        return -1;
    }
    
    char serverString[16];
    std::vector<std::string> result;
    
    result = ofSplitString(localIP,".");
    
    int index = 0;
    for (int i = 0; i < 3; i++){
        for (int j = 0; j < result[i].length(); j++){
            serverString[index] = localIP.c_str()[index];
            index++;
        }
        
        serverString[index] = '.';
        index++;
    }
    
    serverString[index] = '\0';
    
    serverIP = std::string(serverString);
    
    serverIP += ofToString(loginCode);
    
    
    ofLogNotice("+++ Connecting to server:") << serverIP;
    
    
    if (client.setup (serverIP, PORT)){
        ofLogNotice("TCP") << "connect to server at " + serverIP + " port: " << ofToString(PORT) << "\n";
        mainMessage = "";  // "Agent"
        
        return 1;
    }
    
    return 0;
    
    
    
}


void agentController::pause(){
    exit();
}

void agentController::resume(){
	//setup();
	if (isServer){
		if (server.setup(PORT)){
			ofLogNotice("TCP") << "Successfully resumed Server";
            gameState = GameStateReadyRoom;                                                                            // gameState  :  connected
            stepInterval = 1000;
            step = 0;
            stepTimer = ofGetElapsedTimeMillis();
            
		}
	}
	if (isClient){
		if (!client.isConnected()){
            if (client.setup(serverIP, PORT)){
                ofLogNotice("TCP") << "Reconnected Client";
                // this is not flushed out. game could be in progress, not in ready room
                gameState = GameStateReadyRoom;                                                                         // gameState  :  connected
                stepInterval = 1000;
                step = 0;
                stepTimer = ofGetElapsedTimeMillis();
                
            }
		}
	}
}

void agentController::exit() {
	if (isServer){
        ofLogNotice("TCP") << "Shutting down Server";
        stopServer();
        gameState = GameStateLogin;                                                                            // gameState  :  disconnected
        ofLogNotice("+++ GameState updated:") << "Waiting For Sign In, exit()";
	}
	if (isClient){
		ofLogNotice("TCP") << "Shutting down Client";
		client.close();
        gameState = GameStateLogin;                                                                            // gameState  :  disconnected
        ofLogNotice("+++ GameState updated:") << "Waiting For Sign In, exit()";
	}
}
