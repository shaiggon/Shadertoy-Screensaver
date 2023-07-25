//
//  Shadertoy_ScreensaverView.m
//  Shadertoy-Screensaver
//
//  Created by Lauri Saikkonen on 14.7.2023.
//

#import "Shadertoy_ScreensaverView.h"

#import <OpenGL/gl3.h>
#import <OpenGL/glu.h>

void checkError(int lineNumber);

#define GLLog(...) checkError(__LINE__)

// Define a function pointer type for our function
//typedef void (*glGenVertexArraysProc)(GLsizei, GLuint*);
//typedef void (*glBindVertexArrayProc)(GLsizei);

// Get a pointer to the glGenVertexArrays and glBindVertexArray functions
//glGenVertexArraysProc glGenVertexArrays = NSOpenGLGetProcAddress("glGenVertexArrays");
//glBindVertexArrayProc glBindVertexArray = NSOpenGLGetProcAddress("glBindVertexArray");

@implementation Shadertoy_ScreensaverView
{
    NSOpenGLView *glView;
}

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    NSLog( @"Shadertoy: Hello from initWithFrame" );
    if (self) {
        self.time = 0.0;
        NSOpenGLPixelFormatAttribute attrs[] =
        {
            NSOpenGLPFAAccelerated,
            NSOpenGLPFADoubleBuffer,
            NSOpenGLPFAColorSize, 24,
            NSOpenGLPFAAlphaSize, 8,
            NSOpenGLPFADepthSize, 24,
            NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion4_1Core,
            0
        };

        GLLog();

        NSOpenGLPixelFormat *format = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
        self.openGLContext = [[NSOpenGLContext alloc] initWithFormat:format shareContext:nil];
        [self.openGLContext setView:self];
        glView = [[NSOpenGLView alloc] initWithFrame:NSZeroRect 
                                   pixelFormat:format];
        
        //[self.openGLContext makeCurrentContext];
		
        if (!glView)
        {             
            NSLog( @"Shadertoy: Couldn't initialize OpenGL view." );
            return nil;
        } 
        GLLog();


        [self addSubview:glView]; 
        GLLog();
        [self setUpOpenGL];
        GLLog();

        self.program = glCreateProgram();
        GLLog();


        GLuint vertexShader = compileShader(GL_VERTEX_SHADER, [self loadShader:@"vertexshader.glsl"]);
        GLuint fragmentShader = compileShader(GL_FRAGMENT_SHADER, [self loadShader:@"fragmentshader.glsl"]);


        glAttachShader(self.program, vertexShader);
        glAttachShader(self.program, fragmentShader);
        glLinkProgram(self.program);

        GLint success = 0;
        glGetProgramiv(self.program, GL_LINK_STATUS, &success);
        if (!success) {
            GLchar infoLog[512];
            glGetProgramInfoLog(self.program, 512, NULL, infoLog);
            NSLog(@"Failed to link shader program: %s", infoLog);
        }

        glUseProgram(self.program);

        NSLog(@"Gl version: %s", glGetString(GL_VERSION));

        /*GLuint vao = self.vertexArrayObject;
        GLuint vbo = self.vertexBuffer;
        glGenVertexArrays(1, &vao);
        glGenBuffers(1, &vbo);

        self.vertexArrayObject = vao;
        self.vertexBuffer = vbo;*/
        
        // Somewhere in your setup code
        /*if (glDebugMessageCallback) {
            NSLog(@"Register OpenGL debug callback ");
            glEnable(GL_DEBUG_OUTPUT_SYNCHRONOUS);
            glDebugMessageCallback(MessageCallback, nullptr);
            GLuint unusedIds = 0;
            glDebugMessageControl(GL_DONT_CARE,
                                  GL_DONT_CARE,
                                  GL_DONT_CARE,
                                  0,
                                  &unusedIds,
                                  true);
        }*/

        [self setAnimationTimeInterval:1/30.0];
        NSLog(@"Shadertoy: Setup successful");
    }
    
    return self;
}

/*void MessageCallback(GLenum source, GLenum type, GLuint id, GLenum severity, GLsizei length, const GLchar* message, const void* userParam)
{
    fprintf(stderr, "GL CALLBACK: %s type = 0x%x, severity = 0x%x, message = %s\n",
            (type == GL_DEBUG_TYPE_ERROR ? "** GL ERROR **" : ""),
            type, severity, message);
}*/

// Print errors until no errors in line
void checkError(int lineNumber)
{
    GLenum err = glGetError();
    while (err != GL_NO_ERROR) {
        NSLog(@"OpenGL error: %d, on line %d", err, lineNumber);
        err = glGetError();
    }
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
    NSError *error;
    NSString *shaderString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        NSLog(@"shader name: %@", name);
        NSLog(@"shader path: %@", path);
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
    

    //glBindVertexArray(self.vertexArrayObject);
    // VAO
    GLuint vertexArrayObject;
    glGenVertexArrays(1, &vertexArrayObject);
    glBindVertexArray(vertexArrayObject);

    GLLog();

    //self.checkError;
    
    // VBO
    GLuint vertexBufferObject;
    glGenBuffers(1, &vertexBufferObject);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferObject);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    GLLog();

    glClearColor(1.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    GLLog();
    
    //self.checkError;

    glUseProgram(self.program);
    GLLog();

    glUniform1f(glGetUniformLocation(self.program, "iTime"), (GLfloat)((float)self.time));
    GLLog();

    //GLint iResolutionLocation = glGetUniformLocation(self.program, "iResolution");
    //float width = self.bounds.size.width;
    //float height = self.bounds.size.height;
    //glUniform3f(iResolutionLocation, width, height, 1.0);
    
    //self.checkError;

    GLint posAttrib = 0; //glGetAttribLocation(self.program, "position");
    //glBindBuffer(GL_ARRAY_BUFFER, self.vertexBuffer);
    glVertexAttribPointer(posAttrib, 2, GL_FLOAT, GL_FALSE, 0, (void*)0);
    glEnableVertexAttribArray(posAttrib);
    
    GLLog();
    //self.checkError;

    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    glFlush();
    GLLog();

    //glDisableVertexAttribArray(0);

    //glBindVertexArray(0);

    //self.checkError;

    glDisableVertexAttribArray(posAttrib);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glDeleteBuffers(1, &vertexBufferObject);
    glBindVertexArray(0);
    glDeleteVertexArrays(1, &vertexArrayObject);
    GLLog();

    [self.openGLContext flushBuffer];
    [self.openGLContext update];
}


- (BOOL)isOpaque {
    return NO;
}


- (void) animateOneFrame
{
    self.time += self.animationTimeInterval;

    [self setNeedsDisplay:YES];
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
        GLLog();
  //glShadeModel( GL_SMOOTH );
        GLLog();
  glClearColor( 0.0f, 0.0f, 0.0f, 0.0f );
        GLLog();
  glClearDepth( 1.0f ); 
        GLLog();
  glEnable( GL_DEPTH_TEST );
        GLLog();
  glDepthFunc( GL_LEQUAL );
        GLLog();
  //glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST );
        GLLog();
}

@end
