#include "ofMain.h"
#include "testApp.h"

int main(){
//	ofSetupOpenGL(1024,768,OF_FULLSCREEN);			// <-------- setup the GL context
//    
//	ofRunApp(new testApp);
//    BOOL isRetina, isiPad;
//    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
//        if ([[UIScreen mainScreen] scale] > 1)
//            isRetina = true;
//    }
//    if ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)])
//        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
//            isiPad = true;
//    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && [[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [UIScreen mainScreen].scale > 1)
//    {
//        isRetina = true;
//        isiPad = true;
//    }
//    [pool release];
//    int width;
//    int height;
//    if (isRetina && isiPad){
//        width = 1536;
//        height = 2048;
//    }
//    else if (!isRetina && !isiPad){
//        width = 320;
//        height = 480;
//    }
//    else if (isRetina && !isiPad){
//        width = 640;
//        height = 960;
//    }
//    else if (!isRetina && isiPad){
//        width = 768;
//        height = 1024;
//    }
    //ofAppiPhoneWindow * iOSWindow = new ofAppiPhoneWindow();
   // ofSetupOpenGL(iOSWindow, width, height, OF_FULLSCREEN);
    ofSetupOpenGL(1024,768,OF_FULLSCREEN);
    
    ofxiOSGetOFWindow()->enableRetina();
    
    ofRunApp(new testApp);
}
