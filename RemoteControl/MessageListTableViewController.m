//
//  MessageListTableViewController.m
//  RemoteControl
//
//  Created by Sebastian Bastidas on 6/22/15.
//  Copyright (c) 2015 Moshe Berman. All rights reserved.
//
#import "UsersTVC.h"
#import "FriendTVC.h"
#import "AddFriendsViewController.h"
#import "Helpers.h"
#import "SettingsViewController.h"
#import "MessageListTableViewController.h"
#import <Parse/Parse.h>

extern NSString *remoteControlForwardButtonTapped;
extern NSString *remoteControlBackwardButtonTapped;
extern NSString *remoteControlTogglePlayButtonTapped;

@interface MessageListTableViewController ()
@property (strong, nonatomic) AVAudioPlayer *player;
@end

@implementation MessageListTableViewController

const int NumberOfSections6 = 2;

- (void)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
    [query whereKey:@"to" equalTo:[PFUser currentUser]];
    [query whereKey:@"from" equalTo:self.selectedFriend];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            // There was an error
        } else {
            self.theData=objects;
            [self.tableView reloadData];
        }
    }];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return NumberOfSections6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) return 1;
    if (section == 1) return self.theData.count;
    
    else return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell0" forIndexPath:indexPath];
        
    }else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell1" forIndexPath:indexPath];
        PFObject *message = self.theData[indexPath.row];
        NSDate *created = message.createdAt;
        
        NSLocale *locale = [NSLocale currentLocale];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"E MMM d yyyy" options:0 locale:locale];
        [formatter setDateFormat:dateFormat];
        [formatter setLocale:locale];
        cell.textLabel.text = [formatter stringFromDate:created];
    }
    return cell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.theData = @[];
    [self.tableView reloadData];
    [self queryForTable];
    [self setStaticCells];
    [self setColorsAndFonts];
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
    selectedCell.textLabel.text = @"Back";
}


///////////////////////////////////////////////////////////////////////////////
//////////////////////////////   CONTROL  CODE   //////////////////////////////
///////////////////////////////////////////////////////////////////////////////

-(void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //   [_player stop];
}

-(void)playSound{

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self addObserversForRemote];
    [self playSound];
    
    //read name of view
    [Helpers say:@"Message List"];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if (![PFUser currentUser]) {
        self.view.window.rootViewController = [sb instantiateViewControllerWithIdentifier:@"LoginNavController"];
    }
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
             && (currentIndex.section < NumberOfSections6-1)){
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

- (void)handleNotification:(NSNotification *)notification{
    if ([notification.name isEqualToString:remoteControlForwardButtonTapped]) {
        /*Apple*/ // [self selectNextRow];
        /*Me*/         [self segueFromSelectedCell];
        NSLog(@"2 taps");
        
        
    } else if ([notification.name isEqualToString:remoteControlBackwardButtonTapped]) {
        /*Apple*/    //
        /*Me*/    //   [self.navigationController popViewControllerAnimated:YES];
        NSLog(@"3 taps");
    }
    else if ([notification.name isEqualToString:remoteControlTogglePlayButtonTapped]) {
        /*Apple*/    //segue into next
        /*Me*/        [self selectNextRow];
        [self readSelectedCell];
        NSLog(@"1 tap");
    }
}

-(void)segueFromSelectedCell{
    NSIndexPath *selectedRow = [self.tableView indexPathForSelectedRow];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    switch (selectedRow.section) {
        case 0:
            
            if (selectedRow.row==0){
                [self.navigationController popViewControllerAnimated:YES];
                //go back.
            }
            break;
        case 1:
        {
            PFObject *message = self.theData[selectedRow.row];
            [self readMessageFromCell:message];
        
        }
            break;
        default:
            break;
    }
}

#pragma mark - Recording
#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@synthesize recorder,recorderSettings,recorderFilePath;
@synthesize audioPlayer,audioFileName;

-(void)readMessageFromCell:(PFObject *)message {
    PFFile *message1 = [message objectForKey:@"message"];
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
               [audioPlayer setDelegate:self];
            [audioPlayer play];
            NSLog(@"2");
        }
    }];
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

