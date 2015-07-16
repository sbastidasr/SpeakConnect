//
//  MessageListTableViewController.h
//  RemoteControl
//
//  Created by Sebastian Bastidas on 6/22/15.
//  Copyright (c) 2015 Moshe Berman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageListTableViewController : UITableViewController

@property PFUser *selectedFriend;
@property NSArray *theData;




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
