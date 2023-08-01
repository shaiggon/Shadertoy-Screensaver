//
//  Shadertoy_ScreensaverConfigSheet.m
//  Shadertoy-Screensaver
//
//  Created by Lauri Saikkonen on 26.7.2023.
//

#import "Shadertoy_ScreensaverConfigSheet.h"
#import <ScreenSaver/ScreenSaver.h>

@interface Shadertoy_ScreensaverConfigSheet ()

@end

@implementation Shadertoy_ScreensaverConfigSheet

static NSString * const MyModuleName = @"diracdrifter.Shadertoy-Screensaver";

- (void)windowDidLoad {
    [super windowDidLoad];

    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    NSUserDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];
    NSString *shadertoyShaderID = [defaults stringForKey:@"ShadertoyShaderID"];
    NSString *shadertoyApiKey = [defaults stringForKey:@"ShadertoyApiKey"];
    NSString *shaderJson = [defaults stringForKey:@"ShaderJSON"];
    NSLog(@"shaderJson in configsheet %@", shaderJson);
    [self.shadertoyShaderIDTextField setStringValue:shadertoyShaderID];
    [self.shadertoyAPIKeyTextField setStringValue:shadertoyApiKey];
}

- (IBAction)doneButtonClicked:(id)sender
{
    // Save current text
    NSUserDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];
    NSString *currentShaderID = [self.shadertoyShaderIDTextField stringValue];
    [defaults setObject:currentShaderID forKey:@"ShadertoyShaderID"];

    NSString *currentApiKey = [self.shadertoyAPIKeyTextField stringValue];
    [defaults setObject:currentApiKey forKey:@"ShadertoyApiKey"];

    NSString *requestUrl = [self createRequestString:currentShaderID apiKey:currentApiKey];

    [self.statusTextField setStringValue:@"Fetching shader"];

    [self fetchDataWithCompletion:^(NSData *data, NSError *error, NSHTTPURLResponse *response) {
        if (data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (response.statusCode != 200)
                {
                    [self.statusTextField setStringValue:@"Error from shadertoy"];
                }
                else
                {
                    [self.statusTextField setStringValue:@"Fetching shader was successful"];

                    NSString *shaderJson = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSLog(@"shaderJson: %@", shaderJson);
                    [defaults setObject:shaderJson forKey:@"ShaderJSON"];
                    [defaults synchronize];
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.statusTextField setStringValue:@"Error fetching shader"];
            });
        }
    } fullURL:requestUrl];

    [defaults synchronize];
}

- (IBAction)closeButtonClicked:(id)sender
{
    [[NSApplication sharedApplication] endSheet:self.window];
}

- (NSString *)createRequestString:(NSString*)url apiKey:(NSString*)apiKey
{
    NSString *baseUrl = @"https://www.shadertoy.com/api/v1/shaders/";
    NSString *urlWithShader = [baseUrl stringByAppendingString:url];
    NSString *urlWithApiKey = [[urlWithShader stringByAppendingString:@"?key="] stringByAppendingString:apiKey];

    return urlWithApiKey;
}

- (void)fetchDataWithCompletion:(void (^)(NSData *data, NSError *error, NSHTTPURLResponse *response))completion fullURL:(NSString*)fullURL {
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];

    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData *data,
                                                                NSURLResponse *response,
                                                                NSError *error) {
        NSHTTPURLResponse *r = (NSHTTPURLResponse *)response;
        completion(data, error, r);
    }];

    [task resume];
}

@end
