//
//  RCAppDelegate.m
//  RemoteControl
//
//  Created by Moshe Berman on 10/1/13.
//  Copyright (c) 2013 Moshe Berman. All rights reserved.
//

#import "RCAppDelegate.h"
#import <Parse/Parse.h>
#import <AVFoundation/AVFoundation.h>
#import "RCViewController.h"

@implementation RCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"14ce3c869f0159f10683bd91887fe7c1"];
    // Do some additional configuration if needed here
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator
     authenticateInstallation];

    
    //start audio session
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    if(![[AVAudioSession sharedInstance] setActive:YES error:nil]){
        NSLog(@"Failed to set up a session.");
    }
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    
    
//read hello world
  //  AVSpeechUtterance *utterance = [AVSpeechUtterance
    //                                speechUtteranceWithString:@"Hello world asdasd"];
  //  AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
 //   [synth speakUtterance:utterance];
   
    
    //Start parse
    [Parse enableLocalDatastore];
    // Initialize Parse.
    [Parse setApplicationId:@"n6unh8hSYU54eA5yUb7BNS0arvBSgByZ48Z1cj0U"
                  clientKey:@"SyuwmJhxzYQYDdlmFE0q6b28rJaB3C9FUpQGZj3c"];
    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    

    //Check if logged in.
    PFUser *currentUser = [PFUser currentUser];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if (currentUser) {
        self.window.rootViewController = (RCViewController *)[sb instantiateViewControllerWithIdentifier:@"FirstVC"];
    } else {
        self.window.rootViewController = (RCViewController *)[sb instantiateViewControllerWithIdentifier:@"LoginNavController"];
    }
    
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
