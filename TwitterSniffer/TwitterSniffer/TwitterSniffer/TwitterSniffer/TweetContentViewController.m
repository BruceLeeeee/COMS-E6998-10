//
//  TweetContentViewController.m
//  TwitterSniffer
//
//  Created by Jiatian Li on 3/18/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "TweetContentViewController.h"

@interface TweetContentViewController()
@property (nonatomic, strong) Tweet *tweet;
@property (nonatomic, strong) UIWebView *webview;
//@property (strong, nonatomic) NSLock *tweetArrayLock;
@end

@implementation TweetContentViewController

@synthesize tweet = _tweet;
@synthesize webview = _webview;
//@synthesize tweetArrayLock = _tweetArrayLock;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithTweet:(Tweet *)tweet
{
    self = [super init];
    if (self)
    {
        _tweet = tweet;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

//http://mobile.tutsplus.com/tutorials/iphone/ios-sdk_twitter-framework_twrequest/

- (void)retweetPressed:(id)sender
{
    NSLog(@"retweet");
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
        if (granted) {
            NSLog(@"success");
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            if (accounts.count) {
                ACAccount *twitterAccount = [accounts objectAtIndex:0];
                NSString *tmp = @"http://api.twitter.com/1/statuses/retweet/";
                NSString *urlString = [[tmp stringByAppendingString:_tweet.tweetId] stringByAppendingString:@".json"];
                NSURL *url = [NSURL URLWithString:urlString];
                TWRequest *request = [[TWRequest alloc] initWithURL:url parameters:nil requestMethod:TWRequestMethodPOST];
                [request setAccount:twitterAccount];
                [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    
                }];
            }
        } else {
            NSLog(@"The user does not grant us permission to access its Twitter account(s).");
        }
    }];
} 


-(void)favoritePressed:(id)sender
{
    NSLog(@"favorite");
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
        if (granted) {
            NSLog(@"success");
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            if (accounts.count) {
                ACAccount *twitterAccount = [accounts objectAtIndex:0];
                NSString *tmp = @"https://api.twitter.com/1/favorites/create/";
                NSString *urlString = [[tmp stringByAppendingString:_tweet.tweetId] stringByAppendingString:@".json"];
                NSURL *url = [NSURL URLWithString:urlString];
                TWRequest *request = [[TWRequest alloc] initWithURL:url parameters:nil requestMethod:TWRequestMethodPOST];
                [request setAccount:twitterAccount];
                [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    
                }];
            }
        } else {
            NSLog(@"The user does not grant us permission to access its Twitter account(s).");
        }
    }];
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = [UIColor whiteColor];
    self.view = contentView;
    
    CGFloat width = contentView.frame.size.width;
    CGFloat height = contentView.frame.size.height;
    
    CGRect labelRect = CGRectMake(width * .8 / 2, 0, width * .4, height * .1);
    UILabel *handle = [[UILabel alloc] initWithFrame:labelRect];
    handle.text = self.tweet.handle;
    [self.view addSubview:handle];
    
    labelRect = CGRectMake(width * .8 / 2, 0 + height * .1, width * .4, height * .1);
    UILabel *timestamp = [[UILabel alloc] initWithFrame:labelRect];
    timestamp.text = self.tweet.timestamp;
    [timestamp setLineBreakMode:UILineBreakModeCharacterWrap];
    [self.view addSubview:timestamp];

    CGRect imageRect = CGRectMake(width * .05, height * .005, width * .3, height * .2);
    UIImageView *avatar = [[UIImageView alloc] initWithFrame:imageRect];
    avatar.image = self.tweet.avatar;
    [self.view addSubview:avatar];
    
    labelRect = CGRectMake(width * .1, height * .2, width * .8, height * .5);
    UILabel *text = [[UILabel alloc] initWithFrame:labelRect];
    text.text = self.tweet.text;
    [text setLineBreakMode:UILineBreakModeCharacterWrap];
    [text setNumberOfLines:10];
    [self.view addSubview:text];
    
    UIButton *favoriteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [favoriteButton addTarget:self 
               action:@selector(favoritePressed:)
     forControlEvents:UIControlEventTouchDown];
    [favoriteButton setTitle:@"favorite" forState:UIControlStateNormal];
    favoriteButton.frame = CGRectMake(80.0, 310.0, 160.0, 40.0);
    [self.view addSubview:favoriteButton];
    
    UIButton *retweetButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [retweetButton addTarget:self 
                       action:@selector(retweetPressed:)
             forControlEvents:UIControlEventTouchDown];
    [retweetButton setTitle:@"retweet" forState:UIControlStateNormal];
    retweetButton.frame = CGRectMake(80.0, 360.0, 160.0, 40.0);
    [self.view addSubview:retweetButton];
    
    /*LevelView *levelView = [[LevelView alloc] initWithFrame:applicationFrame viewController:self];
    [self.view addSubview:levelView];*/
}



//http://www.cocoanetics.com/2012/05/twitter-framework-tutorial/
/*
- (void)_retweetMessage:(TwitterMessage *)message
{
    NSString *retweetString = [NSString stringWithFormat:@"http://api.twitter.com/1/statuses/retweet/%@.json", message.identifier];
    NSURL *retweetURL = [NSURL URLWithString:retweetString];
    TWRequest *request = [[TWRequest alloc] initWithURL:retweetURL parameters:nil requestMethod:TWRequestMethodPOST];
    request.account = _usedAccount;
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (responseData)
        {
            NSError *parseError = nil;
            id json = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&amp;parseError];
            
            if (!json)
            {
                NSLog(@"Parse Error: %@", parseError);
            }
            else
            {
                NSLog(@"%@", json);
            }
        }
        else
        {
            NSLog(@"Request Error: %@", [error localizedDescription]);
        }
    }];
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    /*NSString* embedHTML = @"\
    <html>\
    <head>\
    <title>My Awesome Page</title>\
    </head>\
    <body>\
    <p align=\"center\">%@</p>\
    <br>\
    <p align=\"center\">%@</p>\
    </body>\
    </html>";
    //NSString* html = [NSString stringWithFormat:embedHTML, self.tweet.handle, [[self view] frame].size.width, [[self view] frame].size.height];
    NSString* html = [NSString stringWithFormat:embedHTML, self.tweet.handle, self.tweet.text];
    self.webview = [[UIWebView alloc] initWithFrame:[[self view] frame]];
    [self.view addSubview:self.webview];
    [self.webview loadHTMLString:html baseURL:nil];*/
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
