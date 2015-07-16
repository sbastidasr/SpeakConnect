//
//  Helpers.m
//  RemoteControl
//
//  Created by Sebastian Bastidas on 6/17/15.
//  Copyright (c) 2015 Moshe Berman. All rights reserved.
//

#import "Helpers.h"

@implementation Helpers 


+(void)say:(NSString*)say{
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:say];
    AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];

    [synth speakUtterance:utterance];
    
}

@end
