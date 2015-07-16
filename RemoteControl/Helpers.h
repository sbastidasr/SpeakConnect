//
//  Helpers.h
//  RemoteControl
//
//  Created by Sebastian Bastidas on 6/17/15.
//  Copyright (c) 2015 Moshe Berman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface Helpers : NSObject <AVSpeechSynthesizerDelegate>


+(void)say:(NSString*)say;
@end
