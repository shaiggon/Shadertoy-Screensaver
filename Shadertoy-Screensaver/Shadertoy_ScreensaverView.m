//
//  Shadertoy_ScreensaverView.m
//  Shadertoy-Screensaver
//
//  Created by Lauri Saikkonen on 14.7.2023.
//

#import "Shadertoy_ScreensaverView.h"

#import <OpenGL/gl3.h>

void checkError(int lineNumber);

#define GLLog(...) checkError(__LINE__)

@implementation Shadertoy_ScreensaverView
{
    NSOpenGLView *glView;
}

static NSString * const MyModuleName = @"diracdrifter.Shadertoy-Screensaver";

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    NSLog( @"Hello from initWithFrame" );
    if (self) {
        ScreenSaverDefaults *defaults;

        defaults = [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];

        self.time = 0.0;
        self.iFrame = 0;

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

        NSOpenGLPixelFormat *format = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
        self.openGLContext = [[NSOpenGLContext alloc] initWithFormat:format shareContext:nil];
        [self.openGLContext setView:self];
        glView = [[NSOpenGLView alloc] initWithFrame:NSZeroRect 
                                   pixelFormat:format];
        
        if (!glView)
        {             
            NSLog( @"Couldn't initialize OpenGL view." );
            return nil;
        } 

        [self addSubview:glView]; 
        [self setUpOpenGL];

        self.program = glCreateProgram();

        GLLog();

        GLuint vertexShader = compileShader(GL_VERTEX_SHADER, [self loadShader:@"vertexshader.glsl"]);

        NSString *header = [self createShadertoyHeader];

        // Uncomment to get shader from file
        //NSDictionary *shaderInfo = [self JSONFromFile:@"shader.json"];
        //NSString *shadertoyCode = [self getShaderStringFromJSON:shaderInfo];

        // TODO: Add failsafe by loading shader from disk instead

        NSLog(@"before getting default");
        NSString *shadertoyJson = [defaults stringForKey:@"ShaderJSON"];
        NSLog(@"shadertoyJson %@", shadertoyJson);

        NSDictionary *shaderInfo = [self JSONFromString:shadertoyJson];

        // TODO Remove this
        NSDictionary *shaderfrominfo = [shaderInfo objectForKey:@"Shader"];
        NSLog(@"shader version: %@", [shaderfrominfo objectForKey:@"ver"]);

        NSString *shadertoyCode = [self getShaderStringFromJSON:shaderInfo];

        NSLog(@"shadertoyCode: %@", shadertoyCode);

        //NSString *fragmentShaderString = [header stringByAppendingString:[self loadShader:@"fragmentshader.glsl"]];
        NSString *fragmentShaderString = [header stringByAppendingString:shadertoyCode];
        GLuint fragmentShader = compileShader(GL_FRAGMENT_SHADER, fragmentShaderString);

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

        GLuint vbo;
        GLuint vao;
        glGenVertexArrays(1, &vao);
        glGenBuffers(1, &vbo);

        self.vertexArrayObject = vao;
        self.vertexBufferObject = vbo;

        NSLog(@"Gl version: %s", glGetString(GL_VERSION));

        [self setAnimationTimeInterval:1/30.0];
        NSLog(@"Setup successful");
    }
    
    return self;
}

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
    NSLog(@"Start animation");
}

- (void)stopAnimation
{
    [super stopAnimation];
    NSLog(@"Stop animation");
}

- (void)drawRect:(NSRect)rect
{
    //NSLog(@"drawRect");
    [super drawRect:rect];
    [self.openGLContext makeCurrentContext];

    GLfloat vertices[] = {
        -1.0f,  1.0f,
        -1.0f, -1.0f,
        1.0f, -1.0f,
        1.0f,  1.0f
    };

    glBindVertexArray(self.vertexArrayObject);
    GLLog();
    
    glBindBuffer(GL_ARRAY_BUFFER, self.vertexBufferObject);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    GLLog();

    glClearColor(1.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    GLLog();

    glUseProgram(self.program);
    GLLog();

    glUniform1f(glGetUniformLocation(self.program, "iTime"), (GLfloat)((float)self.time));
    GLLog();

    glUniform1f(glGetUniformLocation(self.program, "iFrame"), (GLint)self.iFrame);
    glUniform1f(glGetUniformLocation(self.program, "iFrameRate"), (GLfloat)((float)(1.0 / self.animationTimeInterval)));
    glUniform1f(glGetUniformLocation(self.program, "iTimeDelta"), (GLfloat)((float)(self.animationTimeInterval)));

    GLint iResolutionLocation = glGetUniformLocation(self.program, "iResolution");
    float width = self.bounds.size.width;
    float height = self.bounds.size.height;

    glUniform3f(iResolutionLocation, width, height, 1.0);

    GLint posAttrib = glGetAttribLocation(self.program, "position");
    glVertexAttribPointer(posAttrib, 2, GL_FLOAT, GL_FALSE, 0, (void*)0);
    glEnableVertexAttribArray(posAttrib);
    
    GLLog();

    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    glFlush();
    GLLog();

    glDisableVertexAttribArray(posAttrib);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    //glDeleteBuffers(1, &self.vertexBufferObject);
    glBindVertexArray(0);
    //glDeleteVertexArrays(1, &self.vertexArrayObject);
    GLLog();

    [self.openGLContext flushBuffer];
    [self.openGLContext update];
}

- (BOOL)isOpaque {
    return NO;
}

- (void) animateOneFrame
{
    // If not accurately called at animationTimeInterval this could mess with the timing
    self.time += self.animationTimeInterval;
    self.iFrame += 1;

    [self setNeedsDisplay:YES];
}

- (BOOL)hasConfigureSheet
{
    return YES;
}

- (NSWindow*)configureSheet
{
    ScreenSaverDefaults *defaults;

    defaults = [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];

    // TODO: This might not be a good idea
    if (!self.configSheet) {
        self.configSheet = [[Shadertoy_ScreensaverConfigSheet alloc] initWithWindowNibName:@"Shadertoy_ScreensaverConfigSheet"];
    }

    return self.configSheet.window;
}

- (void)setUpOpenGL
{  
  [self.openGLContext makeCurrentContext];
        GLLog();
  glClearColor( 0.0f, 0.0f, 0.0f, 0.0f );
        GLLog();
  glClearDepth( 1.0f ); 
        GLLog();
  glEnable( GL_DEPTH_TEST );
        GLLog();
  glDepthFunc( GL_LEQUAL );
        GLLog();
}

- (NSString*)createShadertoyHeader
{
    NSString *header = @"#version 410 core"
                        "\nuniform vec3 iResolution;\n"
                        "uniform float iTime;\n"
                        "void mainImage( out vec4 c, in vec2 f );\n"
                        "\nout vec4 shadertoy_out_color;\n"
                        "void main( void ){"
                        "vec4 color = vec4(1e20);"
                        "mainImage( color, (gl_FragCoord.xy + vec2(1.0)) * 0.5 );"
                        "shadertoy_out_color = vec4(color.xyz,1.0);"
                        "}\n";
    return header;
}

- (NSString *)getShaderStringFromJSON:(NSDictionary *)shaderInfo
{
    NSDictionary *shader = [shaderInfo objectForKey:@"Shader"];
    //NSLog(@"shader version: %@", [shader objectForKey:@"ver"]);
    NSDictionary *renderPass = [[shader objectForKey:@"renderpass"] objectAtIndex:0];
    NSString *code = [renderPass objectForKey:@"code"];
    return code;
}

// Read from string instead
- (NSDictionary *)JSONFromFile:(NSString *)name
{
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:name ofType:nil];
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"colors" ofType:@"json"];
    //NSError *error;
    //NSString *jsonString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    //NSLog(@"jsonString: %@", jsonString);
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

- (NSDictionary *)JSONFromString:(NSString *)jsonString
{
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

@end
