//
//  Tweet.h
//  TwitterSniffer
//
//  Created by Jiatian Li on 3/18/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
//#import "MapPin.h"

@interface Tweet : NSObject

@property (nonatomic, strong) NSString *handle, *text, *timestamp, *tweetId;
@property (nonatomic, strong) NSURL *avatarURL;
@property (nonatomic, strong) UIImage *avatar;
@property int indexAtPinArray;
//@property (nonatomic, strong) MapPin *pin;
@property CLLocationCoordinate2D location;


@end


//user’s twitter handle, the tweet’s text, timestamp, user’s avatar, etc.