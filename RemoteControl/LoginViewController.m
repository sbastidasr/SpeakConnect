//
//  LoginViewController.m
//  RemoteControl
//
//  Created by Sebastian Bastidas on 6/15/15.
//  Copyright (c) 2015 Moshe Berman. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import "RCViewController.h"

#import "SignUpViewController.h"
#import <Parse/Parse.h>
#import "RCViewController.h"
#import "Helpers.h"

extern NSString *remoteControlForwardButtonTapped;
extern NSString *remoteControlBackwardButtonTapped;
extern NSString *remoteControlTogglePlayButtonTapped;
const int NumberOfSections4 = 1;

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation LoginViewController

- (void)loginButtonPressed:(id)sender {
    [PFUser logInWithUsernameInBackground:self.usernameField.text
                                 password:self.passwordField.text
     
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                            self.view.window.rootViewController = (RCViewController *)[sb instantiateViewControllerWithIdentifier:@"FirstVC"];
                                            
                                        } else {
                                            // The login failed. Check error to see why.
                                        }
                                    }];

    
    
 
    
}


 
 - (void)viewDidLoad {
 [super viewDidLoad];
     [self setColorsAndFonts];
 // Do any additional setup after loading the view.
 }
 - (BOOL)textFieldShouldReturn:(UITextField *)textField
 {
 [textField resignFirstResponder];
 
 return YES;
 }
 

 -(void)viewDidDisappear:(BOOL)animated{
 [[NSNotificationCenter defaultCenter] removeObserver:self];
 }
 
 
 - (void)didReceiveMemoryWarning {
 [super didReceiveMemoryWarning];
 // Dispose of any resources that can be recreated.
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
 
 
 -(void)addObserversForRemote{
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:remoteControlForwardButtonTapped object:nil];
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:remoteControlBackwardButtonTapped object:nil];
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:remoteControlTogglePlayButtonTapped object:nil];
 }
 
 
 
 
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 [self addObserversForRemote];
     
     PFUser *currentUser = [PFUser currentUser];
     UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
     if (currentUser) {
         self.view.window.rootViewController = (RCViewController *)[sb instantiateViewControllerWithIdentifier:@"FirstVC"];
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
 && (currentIndex.section < NumberOfSections4-1)){
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
 switch ([self.tableView indexPathForSelectedRow].row) {
 case 1:
 [Helpers say:@"Password Field"];
 break;
 
 case 0:
 [Helpers say:@"Username Field"];
 break;
 case 2:
 [Helpers say:@"Login"];
 break;
     case 3:
         [Helpers say:@"sign Up"];
         break;
 
 default:
 [Helpers say:selectedCell.textLabel.text];
 break;
 }
 
 }
 
 
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



#pragma mark - Remote Handling


-(void)segueFromSelectedCell{
    NSIndexPath *selectedRow = [self.tableView indexPathForSelectedRow];
    
    switch (selectedRow.row) {
        case 2:
          //login
            [self loginButtonPressed:self];
            break;
        case 3:
         //signup
        { UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
           SignUpViewController *viewController= (SignUpViewController *)[sb instantiateViewControllerWithIdentifier:@"SignUpVC"];
        [self.navigationController pushViewController:viewController animated:YES];

            
        }
            break;
        default:
            // [self performSegueWithIdentifier:@"AddFriends" sender:self];
            break;
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

