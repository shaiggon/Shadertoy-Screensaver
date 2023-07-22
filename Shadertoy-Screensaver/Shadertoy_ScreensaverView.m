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
        self.time = 0.0;
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

        self.program = glCreateProgram();

        /*GLuint vertexShader = compileShader(GL_VERTEX_SHADER, [self loadShaderAbsolutePath:@"/Users/laurisaikkonen/code/random/Shadertoy-Screensaver/Shadertoy-Screensaver/vertexshader.glsl"]);
        GLuint fragmentShader = compileShader(GL_FRAGMENT_SHADER, [self loadShaderAbsolutePath:@"/Users/laurisaikkonen/code/random/Shadertoy-Screensaver/Shadertoy-Screensaver/fragmentshader.glsl"]);*/

        GLuint vertexShader = compileShader(GL_VERTEX_SHADER, [self loadShader:@"vertexshader.glsl"]);
        GLuint fragmentShader = compileShader(GL_FRAGMENT_SHADER, [self loadShader:@"fragmentshader.glsl"]);

        glAttachShader(self.program, vertexShader);
        glAttachShader(self.program, fragmentShader);
        glLinkProgram(self.program);
        glUseProgram(self.program);

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

- (NSString *)loadShaderAbsolutePath:(NSString *)path
{
    NSError *error;
    NSString *shaderString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    NSArray *resourceFiles = [bundle pathsForResourcesOfType:@"glsl" inDirectory:nil];
    NSLog(@"Resource files: %@", resourceFiles);
    NSLog(@"path: %@", [[NSBundle mainBundle] resourcePath]);
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        NSLog(@"shader path: %@", path);
        return nil;
    }
    return shaderString;
}

- (NSString *)loadShader:(NSString *)name
{
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:name ofType:nil];
    NSLog(@"path: %@", path);
    NSError *error;
    NSString *shaderString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        NSLog(@"shader name: %@", name);
        return nil;
    }
    return shaderString;
}

GLuint compileShader(GLenum type, NSString *source)
{
    GLuint shader = glCreateShader(type);
    const char *sourceUTF8 = [source UTF8String];
    glShaderSource(shader, 1, &sourceUTF8, NULL);
    glCompileShader(shader);

    GLint status;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
    if (status == GL_FALSE) {
        GLchar message[256];
        glGetShaderInfoLog(shader, sizeof(message), 0, &message[0]);
        NSString *messageString = [NSString stringWithUTF8String:message];
        NSLog(@"Failed to compile shader: %@", messageString);
        return 0;
    }

    return shader;
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

    GLfloat vertices[] = {
        -1.0f,  1.0f,
        -1.0f, -1.0f,
        1.0f, -1.0f,
        1.0f,  1.0f
    };

    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);


    /*glClearColor(1.0, 0.0, 0.0, 1.0);
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

    glFlush();*/

    glClearColor(1.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glUseProgram(self.program);

    //GLfloat time = self.animationTimeInterval;
    glUniform1f(glGetUniformLocation(self.program, "time"), (GLfloat)((float)self.time));

    glEnableVertexAttribArray(0);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, (void*)0);
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    glDisableVertexAttribArray(0);

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
    self.time += 1.0 / 30.0;
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
