//
//  Shadertoy_ScreensaverView.h
//  Shadertoy-Screensaver
//
//  Created by Lauri Saikkonen on 14.7.2023.
//

#import <ScreenSaver/ScreenSaver.h>

@interface Shadertoy_ScreensaverView : ScreenSaverView

@property (strong) NSColor *myColor;
@property (strong) NSBezierPath *myPath;
@property BOOL shouldFill;
@property (strong) NSImage *previousFrame;
@property NSOpenGLContext *openGLContext;
@property GLuint program;
@property double time;

@end
