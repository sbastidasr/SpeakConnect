//
//  FriendTVC.h
//  RemoteControl
//
//  Created by Sebastian Bastidas on 6/16/15.
//  Copyright (c) 2015 Moshe Berman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <AVFoundation/AVFoundation.h>

@interface FriendTVC : UITableViewController <AVAudioRecorderDelegate>
@property PFUser *selectedFriend;

//recorderstuff.

@property(nonatomic,strong) AVAudioRecorder *recorder;
@property(nonatomic,strong) NSMutableDictionary *recorderSettings;
@property(nonatomic,strong) NSString *recorderFilePath;
@property(nonatomic,strong) AVAudioPlayer *audioPlayer;
@property(nonatomic,strong) NSString *audioFileName;

- (IBAction)startRecording:(id)sender;
- (IBAction)stopRecording:(id)sender;

- (IBAction)startPlaying:(id)sender;
- (IBAction)stopPlaying:(id)sender;

@end