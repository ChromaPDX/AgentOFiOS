//
//  agentController.cpp
//  DoubleAgent
//
//  Created by Chroma Developer on 12/30/13.
//
//

#include "agentController.h"

#import "testApp.h"
//#import "ofxTimer.h"

string paddedString(int num){
    if (num >= 100)     return ofToString(num);
    else if (num >= 10) return "0" + ofToString(num);
    else                return "00" + ofToString(num);
}

void agentController::setup() {
    
    // GAME / PROGRAM
    updateState(StateWelcomeScreen);
    networkState = NetworkNone;
    turnNumber = 0;

    // TOUCHES
    width = ofGetWidth();
    height = ofGetHeight();
    centerX = ofGetWidth()/2.;
    centerY = ofGetHeight()/2.;
    
    agentView.setup();
    agentView.controller = this;
}

void agentController::draw() {
    agentView.draw(state, networkState, elapsedMillis, stateBeginTime, transitionActive, transitionDuration, transitionEndTime);
}

void agentController::pause(){
    exit();
}

void agentController::resume(){
	if (isServer)
		server.setup(PORT);
	if (isClient && !client.isConnected())
        clientConnect(serverIP);
}

void agentController::exit() {
    updateState(StateConnectionScreen);
}


#pragma mark NETWORK

void agentController::updateSlowTCP(){
    if(isServer){
        string clientString;
        clientString.push_back('$');
        clientString.push_back(avatarSelf);
        clientString.push_back(agentView.primaryColor+1);
        for(int i = 0; i < server.getLastID(); i++){
            if(server.isClientConnected(i)){
                clientString.push_back('$');
                clientString.push_back(avatarIcons[i]);
                clientString.push_back(avatarColors[i]);
            }
        }
        sendMessage(clientString);
//        sendMessage(ofToString(connectedAgents));   // send number of clients
    }
//    else if (isClient) { }
}


void agentController::updateTCP() {
    
	if (isServer){
        // simultaneously count connectedAgents
        // and check if anyone is sending a message
        connectedAgents = 1;
	    for(int i = 0; i < server.getLastID(); i++) { // getLastID is UID of all clients
            if( server.isClientConnected(i) ) { // check and see if it's still around
                connectedAgents++;
                // maybe the client is sending something
                Rx = server.receive(i);
                if (Rx.length()){
                	strcpy( receivedText, Rx.c_str() );
                    ofLogNotice("TCP") << "Agent:" + ofToString(i) + " : " + Rx;
                    if (strcmp(receivedText, "pickedAgent") == 0) {
                        // client's screen got touched during the end of game decision time
                        pickedAgent(i+1);
                    }
                    else if (Rx[0] == '$'){
                        // dollar sign encoding: connected players info, $cc$cc$cc$cc... etc.
                        // first char is avatar animal, second is color
                        // first element is server
                        if(Rx.size() == 3){
                            avatarIcons[i] = Rx[1];
                            avatarColors[i] = Rx[2];
                            printf("client connected! %d %d",avatarIcons[i], avatarColors[i]);
                        }
                    }
                    else {
                        // must be the client sending back performance data for turn gesture
                        recordedTimes[i+1] = ofToInt(Rx);
                    }
                }
            }
            else{
                // manage avatars, clear disconnected clients off the stack
                avatarIcons[i] = 0;
                avatarColors[i] = 0;
            }
	    }
	}
    else if (isClient){
        
    	if (!client.isConnected()){
            // client was once connected, but no longer. feel free to blame the server. this is a terrible restaurant.
    		client.close();
    		isClient = false;
    		connectedAgents = 0;
            networkState = NetworkLostConnection;
            updateState(StateWelcomeScreen);
    		return;
    	}
        
        Rx = client.receive();
        if (Rx.length()){
	    	ofLogNotice("TCP") << "Received From Server: " + Rx;
            strcpy( receivedText, Rx.c_str() );
            if (strcmp(receivedText, "stateStartGame") == 0) {
                updateState(StateStartGame);
            }
            else if (strcmp(receivedText, "execute") == 0) {
                execute(mainMessage);
            }
            else if (strcmp(receivedText, "spy") == 0) {
                isSpy = true;
                agentView.setIsSpy(isSpy);
            }
            else if (strcmp(receivedText, "notspy") == 0) {
                isSpy = false;
                agentView.setIsSpy(isSpy);
            }
            else if (strcmp(receivedText, "stateTurnComplete") == 0){
                useScrambledText = false;
                mainMessage = "TurnOVER BLA BLA not being displayed anyway";
                updateState(StateTurnComplete);
            }
            else if (strcmp(receivedText, "stateDecide") == 0) {
                ((testApp*) ofGetAppPtr())->vibrate(true);
                mainMessage = "OPERATIVE I.D.";  // "PICK"
                updateState(StateDecide);
            }
            else if (strcmp(receivedText, "WIN") == 0) {
                mainMessage = "SPY CAPTURED!";
                updateState(StateGameOver);
            }
            else if (strcmp(receivedText, "LOSE") == 0) {
                mainMessage = "NOPE!";
                updateState(StateGameOver);
            }
            else if (Rx[0] == '$'){
                // dollar sign encoding: connected players info, $cc$cc$cc$cc... etc.
                // first char is avatar animal, second is color
                // first element is server
                std::vector<std::string> players;
                players = ofSplitString(Rx,"$");
                printf("$ FIRST CHAR DOLLAR SIGN $\n");
                avatarNum = 0;
                for(int i = 0; i < players.size(); i++){
                    if(players[i].size() == 2){
                        avatarIcons[avatarNum] = players[i][0];
                        avatarColors[avatarNum] = players[i][1];
                        avatarNum++;
                    }
                }
                printf("UPDATED FRIEND COUNT: %d",avatarNum);
            }
            else {
                // improve this.
                // check receivedText against all the gesture commands
                bool wasTurnRelated = false;
                for (int g = 0; g < NUM_GESTURES; g++) {
                    if (strcmp(receivedText, actionString[g].c_str()) == 0) {
                        ((testApp*) ofGetAppPtr())->vibrate(true);
                        useScrambledText = true;  // everybody's appears scrambled to begin
                        animatedScrambleFont = true;
                        mainMessage = Rx;
                        wasTurnRelated = true;
                        updateState(StateTurnScramble);
                        turnNumber++;
                    }
                }
//                for (int g = 0; g < NUM_PLACES; g++) {
//                    if (strcmp(receivedText, placeString[g].c_str()) == 0) {
//                        useScrambledText = false;
//                        mainMessage = Rx;
//                        wasTurnRelated = true;
//                        state = StateTurnComplete;
//                        //turnState = TurnStateWaiting;                                                                           // turnState  :  waiting      (client)
//                    }
//                }
                if(!wasTurnRelated){  // nothing. can we count on this being a number? maybe.
                    connectedAgents = ofToInt(Rx);
                }
            }
        }
    }
}

bool agentController::isConnectedToWIFI(){
    if (localIP.compare("error") == 0 || !localIP.length())
        return false;
    return true;
}

bool agentController::serverConnect(){
    if(!isConnectedToWIFI()) return false;
    bool success = server.setup(PORT);
    if (!success)
        server.close();
    ofLogNotice("TCP") << "SERVER STATUS (0/1): " << isServer << " AT:" + localIP + " PORT:" << ofToString(PORT) << "\n";
    return success;
}

bool agentController::clientConnect(string IP){
    if(!isConnectedToWIFI()) return false;
    bool success = client.setup(IP, PORT);
    if (!success)
        client.close();
    ofLogNotice("TCP") << "CLIENT STATUS (0/1):" << isClient << " AT:" + IP + " PORT: " << ofToString(PORT) << "\n";
    return success;
}

string agentController::makeServerIPString(){
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
    string serverIP = std::string(serverString);
    serverIP += ofToString(loginCode);
    return serverIP;
}

void agentController::stopServer(){
	if (isServer){
        for(int i = 0; i < server.getLastID(); i++){ // getLastID is UID of all clients
            if( server.isClientConnected(i) )
                server.disconnectClient(i);
        }
        server.close();
        isServer = false;
	}
}

void agentController::sendMessage(string message){
	if (isServer){
	    for(int i = 0; i < server.getLastID(); i++){ // getLastID is UID of all clients
            if( server.isClientConnected(i) )  // check and see if it's still around
                server.send(i,message);
	    }
	}
	else if (isClient){
		client.send(message);
	}
}

#pragma mark GAME

void agentController::generateNewSpyRoles(){
    if (isServer){
        // random spy role from list of IDs, which includes disconnected clients, repeat, until selected a connected client
        do {
            spyAccordingToServer = rand() % (server.getLastID() + 1);
        } while (!server.isClientConnected(spyAccordingToServer - 1) && spyAccordingToServer != 0);
        
        // tell everyone that they are the spy or not the spy
        if(spyAccordingToServer == 0){ isSpy = true; agentView.setIsSpy(isSpy); }
        else { isSpy = false; agentView.setIsSpy(isSpy); }
        for(int i = 1; i < server.getLastID() + 1; i++){
            if(server.isClientConnected(i-1)){
                if( spyAccordingToServer == i) server.send(i-1, "spy");
                else server.send(i-1, "notspy");
            }
        }
    }
}

void agentController::serverInitiateRound(){
    // decide on a new gesture
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
}

bool agentController::actionHasOccurred(string message){
    for(int i = 0; i < NUM_TURNS; i++){
        if(strcmp(previousActions[i].c_str(), message.c_str()) == 0)
            return true;
    }
    return false;
}

void agentController::execute(string gesture){

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
    
    updateState(StateTurnGesture);
}

// server only function, i think
void agentController::pickedAgent(int agent) {
    
    if(agent == spyAccordingToServer){
        mainMessage = "WIN";
        sendMessage(mainMessage);
    }
    else {
        mainMessage = "LOSE";
        sendMessage(mainMessage);
    }
}


// server only function
void agentController::countScores(){

    server.sendToAll("stateTurnComplete");

//    int places[16];
//    for (int p = 0; p < 16; p++) {
//        places[p] = -1;
//    }
//    for(int i = 0; i < server.getLastID() + 1; i++) {   // getLastID is UID of all clients
//        int lowestTime = 100000;
//        for(int j = 0; j < server.getLastID() + 1; j++){ // getLastID is UID of all clients
//            if (recordedTimes[j] <= lowestTime) {
//                bool shouldRecord = true;
//                for (int p = 0; p < 16; p++) {
//                    if (places[p] == j) {
//                        shouldRecord = false;
//                    }
//                }
//                if (shouldRecord) {
//                    lowestTime = recordedTimes[j];
//                    places[i] = j;
//                }
//            }
//        }
//        ofLogNotice("PLACES") << ofToString(places[i]) + " is in " + ofToString(i) + " place with " + ofToString(recordedTimes[places[i]]) + "time";
//    }
//    for(int i = 0; i < server.getLastID() + 1; i++) { // getLastID is UID of all clients
//        if (places[i] != 0) {
//            if( server.isClientConnected(places[i] - 1) ) { // check and see if it's still around
//                server.send(places[i]-1, placeString[i]);
//            }
//        }
//        else {
//            mainMessage = placeString[i];
//        }
//    }
}


#pragma mark SCRIPTS

// transition program immediately into another scene.
// cusomize each type of transition

void agentController::updateState(ProgramState newState){
    state = newState;
    stateBeginTime = ofGetElapsedTimeMillis();
    
    if(state == StateWelcomeScreen);
    else if(state == StateConnectionScreen){
        if (isServer){ stopServer(); isServer = false; }
        if (isClient){ client.close(); isClient = false; }
    }
    else if(state == StateJoinScreen);
    else if(state == StateReadyRoom);
    else if(state == StateStartGame){       // initiated by server sendMessage("stateStartGame")
        if(isServer)
            generateNewSpyRoles();
    }
    else if(state == StateCountdown);
    else if(state == StateTurnScramble);   // server initiated by sendMessage(gesture)
    else if(state == StateTurnGesture);  // server initiated at the end of execute()
    else if(state == StateTurnComplete);    // server initiated by sendMessage("stateTurnComplete")
    else if(state == StateDecide);          // initiated by server sendMessage("stateDecide")
    else if(state == StateGameOver);        // initiated by server sendMessage "WIN" / "LOSE"
}

// call updateState() after a delay
void agentController::updateStateWithTransition(ProgramState newState, long delay){
    if(!transitionActive){
        transitionActive = true;
        transitionTarget = newState;
        transitionEndTime = elapsedMillis + delay;
        transitionDuration = delay;
    }
}

// the update loop. once/drawTime
// inside each block, update stuff first, then only at the end call updateState(newState)

void agentController::update() {
    elapsedMillis = ofGetElapsedTimeMillis();  // reduce calls to ofGetElapsedTimeMillis();
    
    // check if transitions are in process. advance if they have ended
    if(transitionActive){
        if(elapsedMillis > transitionEndTime){  // transition over
            updateState(transitionTarget);
            transitionActive = false;
        }
    }
    
    // script time-based transitions
    if(state == StateWelcomeScreen);
    else if(state == StateConnectionScreen);
    else if(state == StateJoinScreen);
    else if(state == StateReadyRoom);
    else if(state == StateStartGame){       // initiated by server sendMessage("stateStartGame")
        if(elapsedMillis > stateBeginTime + 5000){
            turnNumber = 0;
            updateState(StateCountdown);
        }
    }
    else if(state == StateCountdown){
        if(elapsedMillis > stateBeginTime + 5000){
            if (isServer){
                // setup new game
                turnNumber = 0;
                for(int i = 0; i < NUM_TURNS; i++)
                    previousActions[i] = "";
                // begin game
                serverInitiateRound();
                updateState(StateTurnScramble);
            }
        }
    }
    else if(state == StateTurnScramble){
        if(isServer && elapsedMillis > stateBeginTime + 1500){
            // delay by random amount
            // test feeling for duration
            //if(ofRandom(0, 40) == 0){
                sendMessage("execute");
                execute(mainMessage);
            //}
        }
    }
    else if(state == StateTurnGesture){
        if(elapsedMillis > stateBeginTime + ACTION_TIME)
            updateState(StateTurnComplete);
    }
    else if(state == StateTurnComplete){    // initiated by server sendMessage("stateTurnComplete")
        if(isServer && elapsedMillis > stateBeginTime + 3000){
            // increment turn
            turnNumber++;
            if(turnNumber < NUM_TURNS){
                serverInitiateRound();
                updateState(StateTurnScramble);
            }
            else{
                for(int i = 0; i < server.getLastID(); i++) {  // getLastID is UID of all clients
                    if( server.isClientConnected(i) ) { // check and see if it's still around
                        server.send(i,"stateDecide");
                    }
                }
                mainMessage = "OPERATIVE I.D.";  // everyone
                updateState(StateDecide);
            }
        }
    }
    else if(state == StateDecide);          // initiated by server sendMessage("stateDecide")
    else if(state == StateGameOver);        // initiated by server sendMessage "WIN" / "LOSE"

    
    ////////////////////////////////////////////////////////////
    // once / second updates
    if(oneSecond != ofGetSeconds()){   // only runs once/second
        oneSecond = ofGetSeconds();
        
        if(isClient || isServer){
            updateSlowTCP();
        }
        if(state == StateWelcomeScreen){
            agentView.setWIFIExist(isConnectedToWIFI());
        }
    }
    ////////////////////////////////////////////////////////////
        
    if (isClient || isServer) {
        
        updateTCP();
    }
}



//        if(turnState == TurnStateAction){
//            float turnProgress = (float)(ofGetElapsedTimeMillis() - turnTime) / ACTION_TIME;   // from 0 to 1
//            int index = SENSOR_DATA_ARRAY_SIZE*turnProgress;
//            if(index < 0) index = 0;
//            if(index >= SENSOR_DATA_ARRAY_SIZE) index = SENSOR_DATA_ARRAY_SIZE-1;
//            float maxScale = 4*getMaxSensorScale() + 1.;
//            recordedSensorData[(turnNumber-1)*SENSOR_DATA_ARRAY_SIZE + index] = maxScale;
//        }
//
        
        
//        if(gameState == GameStateGameOver){
//            if (ofGetElapsedTimeMillis() - stepTimer > stepInterval ){
//                gameState = GameStateReadyRoom;
//                mainMessage = "";
//                stepInterval = 1000;
//                step = 0;
//                stepTimer = ofGetElapsedTimeMillis();
//            }
//        }
//        else{
//            if (stepInterval){
//                if (ofGetElapsedTimeMillis() - stepTimer > stepInterval ){
//                    step++;
//                    if (step > 0){
//                        if (stepFunction != NULL) {
//                            (this->*stepFunction)(step);
//                        }
//                    }
//                    if (step > numSteps){
//                        stepInterval = 0;
//                    }
//                    stepTimer = ofGetElapsedTimeMillis();
//                }
//            }
//        }


#pragma mark SENSORS

//--------------------------------------------------------------
void agentController::touchBegan(int x, int y, int id){
    
    if(state == StateWelcomeScreen);
    else if(state == StateConnectionScreen);
    else if(state == StateJoinScreen){
        if(y > centerY){
            serverIP = makeServerIPString();
            isClient = clientConnect(serverIP);
            if(isClient){
                char identity[3];
                identity[0] = '$';
                identity[1] = avatarSelf;
                identity[2] = agentView.primaryColor+1;
                sendMessage(identity);
                mainMessage = "";  // "Agent"
                updateState(StateReadyRoom);                                                                          // gameState  :  connected
            }
            else {
                // deliver error message
            }
        }
        else if (x < width * .4) {
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
    else if(state == StateReadyRoom);
    else if(state == StateStartGame);       // initiated by server sendMessage("stateStartGame")
    else if(state == StateCountdown);
    else if(state == StateTurnScramble);
    else if(state == StateTurnGesture);
    else if(state == StateTurnComplete);    // initiated by server sendMessage("stateTurnComplete")
    else if(state == StateDecide);          // initiated by server sendMessage("stateDecide")
    else if(state == StateGameOver);        // initiated by server sendMessage "WIN" / "LOSE"

    
    // network states
//        NetworkNone,
//        NetworkHostAttempt,
//        NetworkHostSuccess,
//        NetworkJoinAttempt,
//        NetworkJoinSuccess,
//        NetworkLostConnection,      // try to make these 2 into 1
//        NetworkServerDisconnected   //

    switch (state) {
            
        case StateReadyRoom:
            
            // back button
            if (y < height * .2) {
                updateState(StateConnectionScreen);
            }
            // start game
            else if (isServer){
#warning change connectedAgents > 2
                if(connectedAgents > 1){
                    sendMessage("stateStartGame");
                    updateState(StateStartGame);
                }
                else{
                    // deliver message: "game requires at least 3 players"
                }
            }
            break;
            
        case StateTurnGesture:
            if (recordMode == RecordModeTouch) {
//                turnState = TurnStateActionSuccess;                                                                         // turnState  :  action success
                updateState(StateTurnComplete);  // should this be happening here? is that what "complete" means?
                recordMode = RecordModeNothing;        // turn off recording
                recordedTimes[0] = ofGetElapsedTimeMillis() - turnTime;
                ((testApp*) ofGetAppPtr())->vibrate(true);
                if (isClient) {
                    sendMessage(ofToString(recordedTimes[0]));
                }
            }
            break;
            
        case StateDecide:
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
}

void agentController::touchMoved(int x, int y, int id) { }

void agentController::touchEnded(int x, int y, int id) {
    
    if(state == StateWelcomeScreen){
        avatarSelf = ofRandom(1, 9);
        printf("AVATAR CHOSE: %d\n",avatarSelf);
        updateState(StateConnectionScreen);
    }
    else if(state == StateConnectionScreen){
        if(x < centerX){
            isServer = serverConnect();
            agentView.setIsServer(isServer);
            if(isServer){
                ofLogNotice("choose server") << "yes!";
                networkState = NetworkHostSuccess;
                updateStateWithTransition(StateReadyRoom, 500);
            }
            else {
                networkState = NetworkNone;
//                loginState = LoginStateFailed;
            }
        }
        if(x > centerX){
            updateStateWithTransition(StateJoinScreen, 500);
        }
    }
    else if(state == StateJoinScreen);
    else if(state == StateReadyRoom);
    else if(state == StateStartGame);       // initiated by server sendMessage("stateStartGame")
    else if(state == StateCountdown);
    else if(state == StateTurnScramble);
    else if(state == StateTurnGesture);
    else if(state == StateTurnComplete);    // initiated by server sendMessage("stateTurnComplete")
    else if(state == StateDecide);          // initiated by server sendMessage("stateDecide")
    else if(state == StateGameOver);        // initiated by server sendMessage "WIN" / "LOSE"

}

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
//            turnState = TurnStateActionSuccess;                                                                        // turnState  :  action Success
            recordedTimes[0] = ofGetElapsedTimeMillis() - turnTime;
            ((testApp*) ofGetAppPtr())->vibrate(true);
            
            if (isClient) {
                sendMessage(ofToString(recordedTimes[0]));
            }
        }
    }
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

#pragma mark SYSTEM

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
    char code[6];
    // spaces inbetween 3 number characters
    code[1] = ' ';
    code[3] = ' ';
    const char* last = codeString.c_str();
    code[0] = last[0];
    code[2] = last[1];
    code[4] = last[2];
    code[5] = '\0';
    return string(code);
}

string agentController::getCodeFromIp(){
    if (localIP.compare("error") == 0 || !localIP.length()) return "error";
    
    std::vector<std::string> result;
    result = ofSplitString(localIP,".");
    if (result[3].length() < 3){
        char code[6];
        // spaces inbetween 3 number characters
        code[1] = ' ';
        code[3] = ' ';
        const char* last = result[3].c_str();
        code[0] = '0';
        code[2] = last[0];
        code[4] = last[1];
        code[5] = '\0';
        return string(code);
    }
    else {
        char code[6];
        // spaces inbetween 3 number characters
        code[1] = ' ';
        code[3] = ' ';
        const char* last = result[3].c_str();
        code[0] = last[0];
        code[2] = last[1];
        code[4] = last[2];
        code[5] = '\0';
        return string(code);
    }
}
