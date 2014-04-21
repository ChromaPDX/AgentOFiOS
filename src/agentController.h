//
//  agentController.h
//  DoubleAgent
//
//  Created by Chroma Developer on 12/30/13.
//
//

#ifndef __DoubleAgent__agentController__
#define __DoubleAgent__agentController__

#include "ofMain.h"
//#include "ofxOsc.h"
#include "ofxNetwork.h"

#include "AgentCommon.h"
#include "AgentView.h"

class agentController {
	
public:
    
    // NETWORKING
    void setIpAddress(const char *ipAddress);
    
    // SENSORS
    void updateAccel(ofVec3f newAccel);
    void updateOrientation(ofMatrix3x3 newOrientationMatrix, ofMatrix3x3 newDeltaOrientationMatrix);
//    bool gestureCompleted;
    
    // OPENFRAMEWORKS
    void setup();
    void update();
    void draw();
    void exit();
	void pause();
	void resume();
    void touchBegan(int x, int y, int id);
    void touchMoved(int x, int y, int id);
    void touchEnded(int x, int y, int id);
    
// all the things i needed to make public to break out the display function
    string getCodeFromIp();
    string getCodeFromInt(int num);
    int loginCode = 0;

    bool preGameCountdownSequence;

    float recordedSensorData[SENSOR_DATA_ARRAY_SIZE * 3];

    unsigned long long turnTime;  // beginning of each turn. for calculating reaction time

    string mainMessage;   // the action command, used for display and orientation within the game loop

    bool animatedScrambleFont;    // turns to false on everybody's phone the moment the execute function happens

    int connectedAgents;  // client stores from server server.getNumClients()

    ofMatrix3x3 orientation; // device orientation

    bool useScrambledText;    // (true: display spyMess, false: mainMessage) dynamically switches on DAs phone, and everybody elses, remains true on DAs phone during execute function

    char avatarSelf = 1;  // your own avatar
    // storing your friends' avatar information
    char avatarIcons[256];
    char avatarColors[256];
    short avatarNum;

private:
    
    // these are duplicated from the View. presently required for touch. try to get these out of here
    int width, height;
    int centerX, centerY;  // screen Coords

    // NETWORKING
	ofxTCPServer server;
	ofxTCPClient client;
	std::string localIP;
	std::string serverIP;
    string makeServerIPString();
    string Rx;
    bool isClient = false;
    bool isServer = false;
    void updateTCP();  // packet sniffer, server and client
    void updateSlowTCP();  // packet sniffer, server and client, only called once per second
    void updateOnceASecond();
    void sendMessage(string message);   // if client, send to server.  if server, send to all clients
    int oneSecond;  // tracking time, preventing updateSlowTCP() redundant calls
    
    bool isConnectedToWIFI();
    // SENSORS
	ofVec3f accel, normAccel;
    ofVec3f filteredAccel;
    ofVec3f userAccelerationArray[SENSOR_DATA_ARRAY_SIZE];
    int accelIndex = 0;  // filter array index
    float getMaxSensorScale(); // grab max value from deltaOrientation;
    //updated sensor
    ofMatrix3x3 deltaOrientation;  // change in orientation. at rest, is the identity matrix
    
    void logMatrix3x3(ofMatrix3x3 matrix);
    void logMatrix4x4(ofMatrix4x4 matrix);
    
    // STUFF RELATED TO DOUBLE AGENT
    ProgramState state = StateWelcomeScreen;
    NetworkState networkState = NetworkNone;
//    GameState gameState;
//    TurnState turnState;
//    int step;  // game loop interval. used for countdowns and rounds, increments to 3 for countdown, increments to TURNS*3 for rounds
//    int numSteps;  // sets the ceiling of each countdown and round. 3 for countdowns, TURNS*3 for rounds
//    unsigned long stepInterval;  // period between a step
//    unsigned long long stepTimer;  // timestamp beginning of a step to offset against
    int turnNumber;   // resets to 0 each new round
    string placeString[NUM_PLACES] = {"DATA SENT","DATA SENT","DATA SENT","DATA SENT","DATA SENT","DATA SENT","DATA SENT","DATA SENT"};//{"1st","2nd","3rd","4th","5th","6th","7th","8th"};
    string actionString[NUM_GESTURES] = {"NOTHING","JUMP","TOUCH SCREEN","SHAKE PHONE","SPIN","HIGH FIVE\nNEIGHBOR","POINT AT\nAN AGENT","FREEZE","CROUCH","STAND ON\nONE LEG","TOUCH PHONE\nWITH NOSE","RAISE\nA HAND","RUN IN PLACE"};
    bool actionHasOccurred(string message);     // prevent repeating actions per round
    string previousActions[NUM_TURNS];  // prevent repeating actions per round, history of moves. gets cleared every round start
    
    unsigned long long recordedTimes[16];  // index [0] is always for self. server utilizes all the rest of the indexes, correlates to clientID
    
    RecordMode recordMode;  // GameAction type   // is 0 being used properly?
    bool isSpy;    // set when client receives "spy" or "notspy"
//    int pickerAccordingToServer;  // not used anymore
    int spyAccordingToServer;
    
    void serverInitiateRound();
    
//    typedef void (*StepFunctionPtr)(int);
//    void (agentController::*stepFunction)(int);
//    void (agentController::*updateFunction)() = NULL;

//    void dramaticallyRevealYourRole();
    void updateState(ProgramState newState);
        long stateBeginTime;
    void updateStateWithTransition(ProgramState newState, long delay);
        long transitionEndTime;
        long transitionDuration;
        bool transitionActive = false;
        ProgramState transitionTarget;
    void generateNewSpyRoles();   // initiated by server with "startGame"

    void execute(string gesture);   // the moment a turn begins, timers start
    void countScores();       // server only
    void pickedAgent(int agent);
    
    // LOG IN DATA
    
    bool clientConnect(string serverIP);
    bool serverConnect();
    
    void stopServer();
    
    void drawLoginScreen();
//    LoginStateState loginState = LoginStateChoose;
    int hostIp;
    float screenScale;
    
    // OF / UI / UX
    int mouseX, mouseY;
    char receivedText[128];
       
    AgentView agentView;
    long elapsedMillis;
};

#endif /* defined(__DoubleAgent__agentController__) */
