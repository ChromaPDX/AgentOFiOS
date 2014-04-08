#include "testApp.h"


#include <ifaddrs.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <net/if.h>
#include <netdb.h>


const char* getIPAddress() {
    
//        char buf[256];
//        if(gethostname(buf,sizeof(buf)))
//            return NULL;
//        struct hostent* he = gethostbyname(buf);
//        if(!he)
//            return NULL;
//        for(int i=0; he->h_addr_list[i]; i++) {
//            char* ip = inet_ntoa(*(struct in_addr*)he->h_addr_list[i]);
//            if(ip != (char*)-1) return ip;
//        }
//        return NULL;
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address.UTF8String;
    
}

//--------------------------------------------------------------
void testApp::setup(){
    
    lastAttitude = ofMatrix3x3(1,0,0,  0,1,0,  0,0,1);

    if (!motionManager) {
        
        motionManager = [[CMMotionManager alloc] init];
        
        ofLogNotice("CORE_MOTION") << "INIT CORE MOTION";
    }
    if (motionManager){
        
        if([motionManager isDeviceMotionAvailable]){
            
            ofLogNotice("CORE_MOTION") << "MOTION MANAGER IS AVAILABLE";
            
            motionManager.deviceMotionUpdateInterval = 1.0/45.0;
            
            [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *deviceMotion, NSError *error) {
                
                CMRotationMatrix a = deviceMotion.attitude.rotationMatrix;
                                
                attitude =
                ofMatrix3x3(a.m11, a.m21, a.m31,
                            a.m12, a.m22, a.m32,
                            a.m13, a.m23, a.m33);
                
                normalized = attitude * lastAttitude;  // results in the identity matrix plus perturbations between polling cycles
                correctNormalization();  // if near 0 or 1, force into 0 and 1
            
                agent.updateOrientation(attitude, normalized);  // send data to game controller
                
                lastAttitude = attitude;   // store last polling cycle to compare next time around
                lastAttitude.transpose(); //getInverse(attitude);  // transpose is the same as inverse for orthogonal matrices. and much easier
                
            }];
        }
    }
    else {
        ofLogError("MOTION NOT AVAILABLE");
    }

    
    agent.setup();
    
    
    agent.setIpAddress(getIPAddress());
    

}

void testApp::correctNormalization(){
    
    float BOUNDS = 0.01;
    
    if(normalized.a < BOUNDS && normalized.a > -BOUNDS ) normalized.a = 0.0;
    else if(normalized.a < 1+BOUNDS && normalized.a > 1-BOUNDS ) normalized.a = 1.0;
    if(normalized.b < BOUNDS && normalized.b > -BOUNDS ) normalized.b = 0.0;
    else if(normalized.b < 1+BOUNDS && normalized.b > 1-BOUNDS ) normalized.b = 1.0;
    if(normalized.c < BOUNDS && normalized.c > -BOUNDS ) normalized.c = 0.0;
    else if(normalized.c < 1+BOUNDS && normalized.c > 1-BOUNDS ) normalized.c = 1.0;
    if(normalized.d < BOUNDS && normalized.d > -BOUNDS ) normalized.d = 0.0;
    else if(normalized.d < 1+BOUNDS && normalized.d > 1-BOUNDS ) normalized.d = 1.0;
    if(normalized.e < BOUNDS && normalized.e > -BOUNDS ) normalized.e = 0.0;
    else if(normalized.e < 1+BOUNDS && normalized.e > 1-BOUNDS ) normalized.e = 1.0;
    if(normalized.f < BOUNDS && normalized.f > -BOUNDS ) normalized.f = 0.0;
    else if(normalized.f < 1+BOUNDS && normalized.f > 1-BOUNDS ) normalized.f = 1.0;
    if(normalized.g < BOUNDS && normalized.g > -BOUNDS ) normalized.g = 0.0;
    else if(normalized.g < 1+BOUNDS && normalized.g > 1-BOUNDS ) normalized.g = 1.0;
    if(normalized.h < BOUNDS && normalized.h > -BOUNDS ) normalized.h = 0.0;
    else if(normalized.h < 1+BOUNDS && normalized.h > 1-BOUNDS ) normalized.h = 1.0;
    if(normalized.i < BOUNDS && normalized.i > -BOUNDS ) normalized.i = 0.0;
    else if(normalized.i < 1+BOUNDS && normalized.i > 1-BOUNDS ) normalized.i = 1.0;
    
}

ofMatrix3x3 testApp::multMatrices(ofMatrix3x3 m1, ofMatrix3x3 m2){
    ofMatrix3x3 answer =
    ofMatrix3x3(m1.a*m2.a + m1.b*m2.d + m1.c*m2.g,  m1.a*m2.b + m1.b*m2.e + m1.c*m2.h,  m1.a*m2.c + m1.b*m2.f + m1.c*m2.i,
                m1.d*m2.a + m1.e*m2.d + m1.f*m2.g,  m1.d*m2.b + m1.e*m2.e + m1.f*m2.h,  m1.d*m2.c + m1.e*m2.f + m1.f*m2.i,
                m1.g*m2.a + m1.h*m2.d + m1.i*m2.g,  m1.g*m2.b + m1.h*m2.e + m1.i*m2.h,  m1.g*m2.c + m1.h*m2.f + m1.i*m2.i);
    return answer;
}

ofMatrix3x3 testApp::getInverse(ofMatrix3x3 x){
	float determinant;
	determinant = x.a*x.e*x.i + x.b*x.f*x.g + x.c*x.d*x.h
    - x.c*x.e*x.g - x.b*x.d*x.i - x.a*x.f*x.h;
    
	ofMatrix3x3 co = ofMatrix3x3((x.e*x.i-x.f*x.h),-(x.d*x.i-x.g*x.f), (x.d*x.h-x.g*x.e),
                                 -(x.b*x.i-x.h*x.c), (x.a*x.i-x.g*x.c),-(x.a*x.h-x.g*x.b),
							     (x.b*x.f-x.c*x.e),-(x.a*x.f-x.c*x.d), (x.a*x.e-x.d*x.b));
    
	ofMatrix3x3 adj = ofMatrix3x3(co.a, co.d, co.g,
							      co.b, co.e, co.h,
							      co.c, co.f, co.i);
    
	float d = 1/determinant;
    
	ofMatrix3x3 inverse = ofMatrix3x3(adj.a*d, adj.b*d, adj.c*d,
									  adj.d*d, adj.e*d, adj.f*d,
									  adj.g*d, adj.h*d, adj.i*d);
	return inverse;
}

void testApp::log2Matrices3x3(ofMatrix3x3 m1, ofMatrix3x3 m2){
    static int timeIndex;
    timeIndex++;
    if(timeIndex % 10 == 0)
        ofLogNotice("") <<
        "\n[ " << m1.a << " " << m1.b << " " << m1.c << " ]   [ " << m2.a << " " << m2.b << " " << m2.c << " ]" <<
        "\n[ " << m1.d << " " << m1.e << " " << m1.f << " ]   [ " << m2.d << " " << m2.e << " " << m2.f << " ]" <<
        "\n[ " << m1.g << " " << m1.h << " " << m1.i << " ]   [ " << m2.g << " " << m2.h << " " << m2.i << " ]";
}


void testApp::logAttitude(){
    static int timeIndex;
    timeIndex++;
    if(timeIndex % 10 == 0)
        ofLogNotice("") <<
        "\n[ " << attitude.a << " " << attitude.b << " " << attitude.c << " ]   [ " << lastAttitude.a << " " << lastAttitude.b << " " << lastAttitude.c << " ]   [ " << normalized.a << " " << normalized.b << " " << normalized.c << " ]" <<
        "\n[ " << attitude.d << " " << attitude.e << " " << attitude.f << " ]   [ " << lastAttitude.d << " " << lastAttitude.e << " " << lastAttitude.f << " ]   [ " << normalized.d << " " << normalized.e << " " << normalized.f << " ]" <<
        "\n[ " << attitude.g << " " << attitude.h << " " << attitude.i << " ]   [ " << lastAttitude.g << " " << lastAttitude.h << " " << lastAttitude.i << " ]   [ " << normalized.g << " " << normalized.h << " " << normalized.i << " ]";
}

void testApp::logMatrix3x3(ofMatrix3x3 matrix){
    static int timeIndex;
    timeIndex++;
    if(timeIndex % 10 == 0)
        ofLogNotice("") <<
        "\n[ " << matrix.a << " " << matrix.b << " " << matrix.c << " ]" <<
        "\n[ " << matrix.d << " " << matrix.e << " " << matrix.f << " ]" <<
        "\n[ " << matrix.g << " " << matrix.h << " " << matrix.i << " ]";
}


void testApp::logMatrix4x4(ofMatrix4x4 matrix){
    static int timeIndex;
    timeIndex++;
    if(timeIndex % 10 == 0)
        ofLogNotice("") <<
        "\n[ " << matrix._mat[0].x << " " << matrix._mat[1].x << " " << matrix._mat[2].x << " ]" <<
        "\n[ " << matrix._mat[0].y << " " << matrix._mat[1].y << " " << matrix._mat[2].y << " ]" <<
        "\n[ " << matrix._mat[0].z << " " << matrix._mat[1].z << " " << matrix._mat[2].z << " ]";
}

void something(){
    
    ((testApp*)ofGetAppPtr())->cppUpdateMatrix();
    
    
}

void testApp::cppUpdateMatrix(){
    
}
//--------------------------------------------------------------
void testApp::update(){
    agent.update();
}

//--------------------------------------------------------------
void testApp::draw(){
    agent.draw();
}

//--------------------------------------------------------------
void testApp::exit(){
    ofLogNotice("PROGRAM:") << " exit()";
    agent.exit();
}

//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs & touch){
    agent.touchBegan(touch.x, touch.y, touch.id);
}

//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs & touch){
    agent.touchMoved(touch.x, touch.y, touch.id);
}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs & touch){
    agent.touchEnded(touch.x, touch.y, touch.id);
}

//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void testApp::touchCancelled(ofTouchEventArgs & touch){
    
}

void testApp::vibrate(bool on){
    if (on){
         AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

//--------------------------------------------------------------
void testApp::lostFocus(){
    ofLogNotice("PROGRAM:") << " pause()";
    agent.pause();
}

//--------------------------------------------------------------
void testApp::gotFocus(){
    ofLogNotice("PROGRAM:") << " resume()";
    agent.resume();
}

//--------------------------------------------------------------
void testApp::gotMemoryWarning(){

}

//--------------------------------------------------------------
void testApp::deviceOrientationChanged(int newOrientation){

}


