//
//  Shadertoy_ScreensaverView.m
//  Shadertoy-Screensaver
//
//  Created by Lauri Saikkonen on 14.7.2023.
//

#import "Shadertoy_ScreensaverView.h"

#import <OpenGL/gl.h>
#import <OpenGL/glu.h>

@implementation Shadertoy_ScreensaverView
{
    //NSOpenGLContext *openGLContext;
    NSOpenGLView *glView;
}

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    NSLog( @"Shadertoy: Hello from initWithFrame" );
    if (self) {
        //[self setAnimationTimeInterval:1/30.0];
        NSOpenGLPixelFormatAttribute attrs[] =
        {
            NSOpenGLPFAAccelerated,
            NSOpenGLPFADoubleBuffer,
            NSOpenGLPFAColorSize, 24,
            NSOpenGLPFAAlphaSize, 8,
            NSOpenGLPFADepthSize, 24,
            NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersionLegacy,
            0
        };

        NSOpenGLPixelFormat *format = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
        self.openGLContext = [[NSOpenGLContext alloc] initWithFormat:format shareContext:nil];
        [self.openGLContext setView:self];
        glView = [[NSOpenGLView alloc] initWithFrame:NSZeroRect 
                                   pixelFormat:format];
		
        if (!glView)
        {             
            NSLog( @"Shadertoy: Couldn't initialize OpenGL view." );
            return nil;
        } 

        [self addSubview:glView]; 
        [self setUpOpenGL];

        [self setAnimationTimeInterval:1/30.0];
        NSLog(@"Shadertoy: Setup successful");
    }
    
    /*NSOpenGLPixelFormatAttribute attrs[] = {
        NSOpenGLPFAAccelerated,
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFAColorSize, 24,
        NSOpenGLPFAAlphaSize, 8,
        NSOpenGLPFADepthSize, 24,
        NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersionLegacy,
        0
    };

    NSOpenGLPixelFormat *format = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];

    NSOpenGLContext *context = [[NSOpenGLContext alloc] initWithFormat:format shareContext:nil];

    self.openGLContext = context;*/

    return self;
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
    NSLog(@"Shadertoy: drawRect");
    [super drawRect:rect];
    [self.openGLContext makeCurrentContext];

    glClearColor(1.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glLoadIdentity();

    glBegin(GL_TRIANGLES);
        glColor3f(1.0, 0.0, 0.0); // Red
        glVertex3f(0.0, 1.0, 0.0); // Top
        glColor3f(0.0, 1.0, 0.0); // Green
        glVertex3f(-1.0, -1.0, 0.0); // Bottom Left
        glColor3f(0.0, 0.0, 1.0); // Blue
        glVertex3f(1.0, -1.0, 0.0); // Bottom Right
    glEnd();

    glFlush();
    [self.openGLContext flushBuffer];
    [self.openGLContext update];
    /*if (self.previousFrame) {
        [self.previousFrame drawInRect:[self bounds]];
    }

    [self.myColor set];
    if (self.shouldFill) {
        [self.myPath fill];
    } else {
        [self.myPath stroke];
    }*/
}

- (BOOL)isOpaque {
    return NO;
}


- (void) animateOneFrame
{
    /*NSBezierPath *path;
    NSRect rect;
    NSSize size;
    float red, green, blue, alpha;
    int shapeType;
    size = [self bounds].size;
    // Calculate random width and height
    rect.size = NSMakeSize( SSRandomFloatBetween( size.width / 100.0, 
                                                    size.width / 10.0 ), 
                            SSRandomFloatBetween( size.height / 100.0, 
                                                    size.height / 10.0 ));
                                                    // Calculate random origin point
    rect.origin = SSRandomPointForSizeWithinRect( rect.size, [self bounds] );
        // Decide what kind of shape to draw
    shapeType = SSRandomIntBetween( 0, 2 );
    
    switch (shapeType)
    {
        case 0: // rect
        path = [NSBezierPath bezierPathWithRect:rect];
        break;
        
        case 1: // oval
        path = [NSBezierPath bezierPathWithOvalInRect:rect];
        break;
        case 2: // arc
        default:
        {
            float startAngle, endAngle, radius;
            NSPoint point;
                
            startAngle = SSRandomFloatBetween( 0.0, 360.0 );
            endAngle = SSRandomFloatBetween( startAngle, 360.0 + startAngle );
            // Use the smallest value for the radius (either width or height)
            radius = rect.size.width <= rect.size.height ? 
                    rect.size.width / 2 : rect.size.height / 2;

            // Calculate our center point
            point = NSMakePoint( rect.origin.x + rect.size.width / 2,
                                rect.origin.y + rect.size.height / 2 );
                                // Construct the path
            path = [NSBezierPath bezierPath];
                
            [path appendBezierPathWithArcWithCenter: point
                                        radius: radius                            
                                    startAngle: startAngle
                                        endAngle: endAngle
                                        clockwise: SSRandomIntBetween( 0, 1 )];
        }
        break;
    }
    // Calculate a random color
    red = SSRandomFloatBetween( 0.0, 255.0 ) / 255.0;
    green = SSRandomFloatBetween( 0.0, 255.0 ) / 255.0;
    blue = SSRandomFloatBetween( 0.0, 255.0 ) / 255.0;
    alpha = SSRandomFloatBetween( 0.0, 255.0 ) / 255.0;


    self.myPath = path;
    self.myColor = [NSColor colorWithCalibratedRed:red
                                        green:green
                                        blue:blue
                                        alpha:alpha];

    // And finally draw it
    self.shouldFill = SSRandomIntBetween( 0, 1 ) == 0;

    // Render the current view to an image
    NSBitmapImageRep *rep = [self bitmapImageRepForCachingDisplayInRect:[self bounds]];
    [self cacheDisplayInRect:[self bounds] toBitmapImageRep:rep];
    self.previousFrame = [[NSImage alloc] initWithSize:[rep size]];
    [self.previousFrame addRepresentation:rep];*/

    // And request a redraw
    [self setNeedsDisplay:YES];

    //[self setNeedsDisplayInRect:[self bounds]];
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

- (void)setUpOpenGL
{  
  [self.openGLContext makeCurrentContext];
  glShadeModel( GL_SMOOTH );
  glClearColor( 0.0f, 0.0f, 0.0f, 0.0f );
  glClearDepth( 1.0f ); 
  glEnable( GL_DEPTH_TEST );
  glDepthFunc( GL_LEQUAL );
  glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST );
}

@end
