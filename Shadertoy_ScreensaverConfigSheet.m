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
    NSString *shadertoyUrl = [defaults stringForKey:@"ShadertoyUrl"];
    [self.shadertoyUrlTextField setStringValue:shadertoyUrl];
}

- (IBAction)doneButtonClicked:(id)sender
{
    // Save current text
    NSUserDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];
    NSString *currentUrl = [self.shadertoyUrlTextField stringValue];
    [defaults setObject:currentUrl forKey:@"ShadertoyUrl"];

    [defaults synchronize];

    [[NSApplication sharedApplication] endSheet:self.window];
}

@end
