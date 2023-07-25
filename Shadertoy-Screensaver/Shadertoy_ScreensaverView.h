//
//  Shadertoy_ScreensaverView.h
//  Shadertoy-Screensaver
//
//  Created by Lauri Saikkonen on 14.7.2023.
//

#import <ScreenSaver/ScreenSaver.h>

@interface Shadertoy_ScreensaverView : ScreenSaverView

@property NSOpenGLContext *openGLContext;
@property GLuint program;
@property double time;
@property GLuint vertexArrayObject;
@property GLuint vertexBufferObject;

@end
