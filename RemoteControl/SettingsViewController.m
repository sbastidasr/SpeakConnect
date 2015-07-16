//
//  SettingsViewController.m
//  RemoteControl
//
//  Created by Sebastian Bastidas on 6/20/15.
//  Copyright (c) 2015 Moshe Berman. All rights reserved.
//

#import "SettingsViewController.h"
#import "FriendTVC.h"
#import "Helpers.h"

extern NSString *remoteControlForwardButtonTapped;
extern NSString *remoteControlBackwardButtonTapped;
extern NSString *remoteControlTogglePlayButtonTapped;
@interface SettingsViewController ()

@end

@implementation SettingsViewController

const int NumberOfSections3 = 1;

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return NumberOfSections3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
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
    selectedCell.textLabel.text = [NSString stringWithFormat: @"Logout"];

    //set the correct names for static cells.
    newIndex = [NSIndexPath indexPathForRow:1 inSection:0];
    selectedCell = [self.tableView cellForRowAtIndexPath:newIndex];
    selectedCell.textLabel.text = [NSString stringWithFormat: @"Return"];

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
             && (currentIndex.section < NumberOfSections3-1)){
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




-(void)segueFromSelectedCell{
    NSIndexPath *selectedRow = [self.tableView indexPathForSelectedRow];
    
    switch (selectedRow.row) {
        case 0:
            [PFUser logOut];
            [self.navigationController popViewControllerAnimated:YES];

            
            break;
            case 1:
             [self.navigationController popViewControllerAnimated:YES];
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
    UIFont *myFont = [ UIFont fontWithName: @"HelveticaNeue" size: 22.0 ];
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
