//
//  AppDelegate.m
//  TransitionToHEIC
//
//  Created by 索晓晓 on 2024/9/14.
//

#import "AppDelegate.h"

@interface AppDelegate ()


@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (void)windowWillClose:(NSNotification *)notification {
    // 如果这是应用的最后一个窗口，可以在这里退出应用
    NSApplication *app = [NSApplication sharedApplication];
    if (app.windows.count == 0) {
        [app terminate:nil];
    }
}



@end
