
//  FriendTVC.m
//  RemoteControl
//
//  Created by Sebastian Bastidas on 6/16/15.
//  Copyright (c) 2015 Moshe Berman. All rights reserved.
//


#import "FriendTVC.h"
#import "Helpers.h"
#import "MessageListTableViewController.h"

extern NSString *remoteControlForwardButtonTapped;
extern NSString *remoteControlBackwardButtonTapped;
extern NSString *remoteControlTogglePlayButtonTapped;

@interface FriendTVC ()
@property (strong, nonatomic) AVAudioPlayer *player;
@property BOOL isRecording;
@end

@implementation FriendTVC

const int NumberOfSections2 = 1;

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return NumberOfSections2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    return cell;
}

- (void)viewDidLoad {

    [super viewDidLoad];
    [self.tableView reloadData];
//    [self queryForTable];
    [self setStaticCells];
    [self playNewMessages];
    [self setColorsAndFonts];
}
-(void)playNewMessages{
    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
    [query whereKey:@"to" equalTo:[PFUser currentUser]];
    [query whereKey:@"from" equalTo:self.selectedFriend];
    [query whereKey:@"read" equalTo:@"no"];
    [query orderByDescending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)  {
            //objects brings all messages that comply
            if(objects.count>0) [Helpers say:@"Loading New Messages"];
            
            
            PFFile *message1 = objects.firstObject[@"message"];
                [message1 getDataInBackgroundWithBlock:^(NSData *message, NSError *error) {
                    if (!error) {
                         NSLog(@"1");
                        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
                        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
                        NSError *error;
                        audioPlayer = [[AVAudioPlayer alloc]initWithData:message error:&
                                       error];
                        audioPlayer.numberOfLoops = 0;
                       [NSThread sleepForTimeInterval:audioPlayer.duration];
                    
                        [audioPlayer play];
                        NSLog(@"2");
                        
                        objects.firstObject[@"read"]=@"yes";
                        [objects.firstObject saveInBackground];
                        
                    }
                    
                }];
            
        }
    }];
}


-(void)addObserversForRemote{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:remoteControlForwardButtonTapped object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:remoteControlBackwardButtonTapped object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:remoteControlTogglePlayButtonTapped object:nil];
}

-(void)setStaticCells{

    
    //set the correct names for static cells.
    NSIndexPath *newIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:newIndex];
    selectedCell.textLabel.text = [NSString stringWithFormat: @"Send Message to %@", self.selectedFriend[@"username"]];

    newIndex = [NSIndexPath indexPathForRow:1 inSection:0];
    selectedCell = [self.tableView cellForRowAtIndexPath:newIndex];
   selectedCell.textLabel.text = [NSString stringWithFormat: @"Play messages from %@", self.selectedFriend[@"username"]];

    
     newIndex = [NSIndexPath indexPathForRow:2 inSection:0];
     selectedCell = [self.tableView cellForRowAtIndexPath:newIndex];
     selectedCell.textLabel.text = @"Return to Previous screen";

}

///////////////////////////////////////////////////////////////////////////////
//////////////////////////////   CONTROL  CODE   //////////////////////////////
///////////////////////////////////////////////////////////////////////////////

-(void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self addObserversForRemote];

    }

-(void)selectNextRow{
    NSIndexPath *newIndex;
    NSIndexPath *currentIndex = [self.tableView indexPathForSelectedRow];
    NSInteger numberOfRowsInCurrentSection = [self tableView:self.tableView numberOfRowsInSection:currentIndex.section];
    
    
    if (currentIndex==nil){ //select 0,0 if nothing is selected
        newIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    
    else if (currentIndex.row<numberOfRowsInCurrentSection-1){
        newIndex = [NSIndexPath indexPathForRow:currentIndex.row+1 inSection:currentIndex.section];
    }
    else if ((currentIndex.row==numberOfRowsInCurrentSection-1)
             && (currentIndex.section < NumberOfSections2-1)){
        newIndex = [NSIndexPath indexPathForRow:0 inSection:currentIndex.section+1];
        
    }
    else{
        newIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    //select correct cell
    [self.tableView selectRowAtIndexPath:newIndex animated:YES scrollPosition:UITableViewScrollPositionNone];

}


-(void)readSelectedCell{
    //Read Cell
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
    [Helpers say:selectedCell.textLabel.text];
}

#pragma mark - Remote Handling

- (void)handleNotification:(NSNotification *)notification
{
    if ([notification.name isEqualToString:remoteControlForwardButtonTapped]) {
        /*Apple*/ // [self selectNextRow];
        /*Me*/         [self segueFromSelectedCell];
        NSLog(@"2 taps");
        
        
    } else if ([notification.name isEqualToString:remoteControlBackwardButtonTapped]) {
        /*Apple*/    //
        /*Me*/       [self.navigationController popViewControllerAnimated:YES];
        NSLog(@"3 taps");
    }
    else if ([notification.name isEqualToString:remoteControlTogglePlayButtonTapped]) {
        /*Apple*/    //segue into next
        /*Me*/        [self selectNextRow];
         [self readSelectedCell];
        NSLog(@"1 tap");
    }
}

- (IBAction)cellTapped:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint swipeLocation = [sender locationInView:self.tableView];
        NSIndexPath *swipedIndexPath = [self.tableView indexPathForRowAtPoint:swipeLocation];

        if( [[self.tableView indexPathForSelectedRow] isEqual:swipedIndexPath]){
            [self segueFromSelectedCell];
        } else{
            [self.tableView selectRowAtIndexPath:swipedIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            [self readSelectedCell];
        }
    }
}



-(void)viewWillAppear:(BOOL)animated
{  NSLog(@"viewWillappear");
}


#pragma mark - Recording
#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@synthesize recorder,recorderSettings,recorderFilePath;
@synthesize audioPlayer,audioFileName;


#pragma mark - View Controller Life cycle methods


#pragma mark - Audio Recording
- (IBAction)startRecording:(id)sender
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err)
    {
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return;
    }
    [audioSession setActive:YES error:&err];
    err = nil;
    if(err)
    {
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return;
    }
    
    recorderSettings = [[NSMutableDictionary alloc] init];
    [recorderSettings setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recorderSettings setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recorderSettings setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    [recorderSettings setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [recorderSettings setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [recorderSettings setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    // Create a new audio file
    audioFileName = @"messageRecorded";
    recorderFilePath = [NSString stringWithFormat:@"%@/%@.caf", DOCUMENTS_FOLDER, audioFileName] ;
    
    NSURL *url = [NSURL fileURLWithPath:recorderFilePath];
    err = nil;
    recorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recorderSettings error:&err];
    if(!recorder){
        NSLog(@"recorder: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Warning" message: [err localizedDescription] delegate: nil
                         cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    //prepare to record
    [recorder setDelegate:self];
    [recorder prepareToRecord];
    recorder.meteringEnabled = YES;
    
    BOOL audioHWAvailable = audioSession.inputIsAvailable;
    if (! audioHWAvailable) {
        UIAlertView *cantRecordAlert =
        [[UIAlertView alloc] initWithTitle: @"Warning"message: @"Audio input hardware not available"
                                  delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [cantRecordAlert show];
        return;
    }
    
    // start recording
    [recorder recordForDuration:(NSTimeInterval) 60];//Maximum recording time : 60 seconds default
    NSLog(@"Recroding Started");
}

- (IBAction)stopRecording:(id)sender
{
    [recorder stop];
    NSLog(@"Recording Stopped");
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag
{
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.caf", DOCUMENTS_FOLDER, audioFileName]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    PFFile *file = [PFFile fileWithName:@"message.caf" data:data];
    
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            PFObject *message = [PFObject objectWithClassName:@"Message"];
            message[@"from"] = [PFUser currentUser];
            message[@"to"] = self.selectedFriend;
            message[@"read"] = @"no";
            message[@"message"]=file;
            [message saveInBackground];
            [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) { [Helpers say:@"Message sent"];
                } else { [Helpers say:@"Error, FIle couldnt be sent"];}
            }];
        } else {
            [Helpers say:@"Error, FIle couldnt be sent"];
        }
    }];
    
}


#pragma mark - Audio Playing
- (IBAction)startPlaying:(id)sender
{
    NSLog(@"playRecording");
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.caf", DOCUMENTS_FOLDER, audioFileName]];
    NSError *error;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    audioPlayer.numberOfLoops = 0;
    [audioPlayer play];
    NSLog(@"playing");
}
- (IBAction)stopPlaying:(id)sender
{
    [audioPlayer stop];
    NSLog(@"stopped");
}


-(void)segueFromSelectedCell{
    NSIndexPath *selectedRow = [self.tableView indexPathForSelectedRow];
    
    switch (selectedRow.row) {
      //  case 0:
            //play status.
        //    break;
        case 0:
            if(self.isRecording){
                [Helpers say:@"Recording ended"];
                [self stopRecording:self];
                self.isRecording= NO;
                //[self startPlaying:self];
            }
            else{
                [Helpers say:@"Recording Started"];
                [self startRecording:self];
                self.isRecording = YES;
            }
            break;
        
        case 1:{
            
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                MessageListTableViewController *viewController= (MessageListTableViewController *)[sb instantiateViewControllerWithIdentifier:@"MessageListTableViewController"];
            viewController.selectedFriend=self.selectedFriend;
                [self.navigationController pushViewController:viewController animated:YES];

        }

            break;
        case 2:{
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
            
        default:
            // [self performSegueWithIdentifier:@"AddFriends" sender:self];
            break;
    }
}

////colors
-(void)setColorsAndFonts{
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationItem.title=@"SpeakConnect";
    self.tableView.backgroundColor=[UIColor colorWithRed:40.0/255.0  green:40.0/255.0 blue:40.0/255.0 alpha:1.0f];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor=[UIColor colorWithRed:40.0/255.0  green:40.0/255.0 blue:40.0/255.0 alpha:1.0f];
    UIFont *myFont = [ UIFont fontWithName: @"HelveticaNeue" size: 20.0 ];
    cell.textLabel.font  = myFont;
    if (indexPath.section==0){
        cell.textLabel.textColor=[UIColor colorWithRed:255.0/255.0  green:85.0/255.0 blue:135.0/255.0 alpha:1.0f];}
    else{
        cell.textLabel.textColor=[UIColor colorWithRed:85.0/255.0  green:215.0/255.0 blue:255.0/255.0 alpha:1.0f];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}




@end


