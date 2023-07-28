//
//  Shadertoy_ScreensaverConfigSheet.h
//  Shadertoy-Screensaver
//
//  Created by Lauri Saikkonen on 26.7.2023.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface Shadertoy_ScreensaverConfigSheet : NSWindowController

@property (nonatomic, weak) IBOutlet NSTextField *textField;
@property (weak) IBOutlet NSTextField *shadertoyUrlTextField;

@end

NS_ASSUME_NONNULL_END
