//
//  Shadertoy_ScreensaverView.h
//  Shadertoy-Screensaver
//
//  Created by Lauri Saikkonen on 14.7.2023.
//

#import <ScreenSaver/ScreenSaver.h>
#import "../Shadertoy_ScreensaverConfigSheet.h"

@interface Shadertoy_ScreensaverView : ScreenSaverView

@property NSOpenGLContext *openGLContext;
@property GLuint program;

@property double time;
@property int iFrame;

@property GLuint vertexArrayObject;
@property GLuint vertexBufferObject;

@property Shadertoy_ScreensaverConfigSheet *configSheet;
//@property IBOutlet id configSheet;

@end
