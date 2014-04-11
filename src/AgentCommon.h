//
//  AgentCommon.h
//  DoubleAgent
//
//  Created by Robby on 4/11/14.
//
//

#ifndef DoubleAgent_AgentCommon_h
#define DoubleAgent_AgentCommon_h


#define NUM_MSG_STRINGS 20
#define PORT 3456
#define NUM_GESTURES 13
#define NUM_PLACES 8
#define NUM_TURNS 3  // per round
#define ACTION_TIME 3000  // 3 seconds to execute action
#define SENSOR_DATA_ARRAY_SIZE 128


typedef enum
{
	GameStateLogin,
    GameStateReadyRoom,
	GameStatePlaying,
    GameStateDeciding,
	GameStateGameOver
}
GameState;

typedef enum
{
    LoginStateChoose,
    LoginStateClient,
    LoginStateServer,
    LoginStateConnecting,
    LoginStateFailed,
    LoginStateNoIP,
    LoginStateServerQuit
}
LoginStateState;

typedef enum
{
    TurnStateNotActive,
    TurnStateReceivingScrambled,
    TurnStateAction,
    TurnStateActionSuccess,
    TurnStateWaiting
}
TurnState;

typedef enum
{
	RecordModeNothing,
    RecordModeTouch,
    RecordModeOrientation,
    RecordModeAccel,
    RecordModeGyro,
    RecordModeSound
}
RecordMode;


#endif
