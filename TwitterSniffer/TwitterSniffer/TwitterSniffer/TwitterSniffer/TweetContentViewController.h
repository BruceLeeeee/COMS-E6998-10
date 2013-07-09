//
//  TweetContentViewController.h
//  TwitterSniffer
//
//  Created by Jiatian Li on 3/18/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "Tweet.h"

@interface TweetContentViewController : UIViewController

-(id)initWithTweet:(Tweet *)tweet;

@end
