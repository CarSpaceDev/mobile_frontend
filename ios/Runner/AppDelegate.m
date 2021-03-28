#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"

@import Firebase;
@implementation AppDelegate
- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    int flutter_native_splash = 1;
    [FIRApp configure];
    UIApplication.sharedApplication.statusBarHidden = false;

  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end