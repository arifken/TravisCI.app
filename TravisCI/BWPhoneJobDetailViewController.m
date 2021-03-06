//
//  BWJobDetailViewController.m
//  TravisCI
//
//  Created by Bradley Grzesiak on 1/11/12.
//  Refer to MIT-LICENSE file at root of project for copyright info
//

#import "BWPhoneJobDetailViewController.h"
#import "BWJob+All.h"
#import "BWEnumerableTableViewController.h"

@interface BWPhoneJobDetailViewController()
@property (nonatomic, assign) BOOL shouldUnsubscribeFromLogUpdates;
- (void)stopObservingJob;
- (void)startObservingJob;
@end

@implementation BWPhoneJobDetailViewController
@synthesize finishedLabel;
@synthesize durationLabel;
@synthesize commitLabel;
@synthesize compareLabel;
@synthesize authorLabel;
@synthesize messageLabel;
@synthesize configLabel;
@synthesize logTitle;
@synthesize logSubtitle;

@synthesize job, number;
@synthesize shouldUnsubscribeFromLogUpdates;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)configureLogView
{
    [self.logTitle setText:[self.job lastLogLine]];
    [self.logSubtitle setText:[self.job logSubtitle]];
}

- (void)configureView
{
    [self.finishedLabel setText:[self.job finishedText]];
    [self.durationLabel setText:[self.job durationText]];
    [self.commitLabel setText:self.job.commit];
    [self.compareLabel setText:self.job.compare];
    [self.authorLabel setText:self.job.author];
    [self.messageLabel setText:self.job.message];
    [self.configLabel setText:self.job.configString];

    [self setTitle:[NSString stringWithFormat:@"Job #%@", self.job.number]];

    [self configureLogView];
}

- (void)awakeFromNib
{
    [self.tableView setAccessibilityLabel:@"Job Detail"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.shouldUnsubscribeFromLogUpdates = YES;
    [self startObservingJob];
    [self.job fetchDetailsIfNeeded];
    [self.job subscribeToLogUpdates];
    [self configureView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopObservingJob];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    if (self.shouldUnsubscribeFromLogUpdates) {
        [self.job unsubscribeFromLogUpdates];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([@"job" isEqualToString:keyPath]) {
        [self configureView];
    } else if ([@"log" isEqualToString:keyPath]) {
        [self configureLogView];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.shouldUnsubscribeFromLogUpdates = NO;
    UIViewController *vc = [segue destinationViewController];
    if ([@"message" isEqualToString:segue.identifier]) {
        UITextView *textView = (UITextView *)vc.view;
        [textView setText:self.job.message];
    } else if ([@"compare" isEqualToString:segue.identifier]) {
        UIWebView *webView = (UIWebView *)vc.view;
        NSURL *url = [NSURL URLWithString:self.job.compare];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [webView loadRequest:request];
    } else if ([@"config" isEqualToString:segue.identifier]) {
        ((BWEnumerableTableViewController *)vc).data = self.job.config;
    } else if ([@"log" isEqualToString:segue.identifier]) {
        [vc setValue:self.job forKey:@"job"];
        UITextView *textView = (UITextView *)vc.view;
        [textView setText:self.job.log];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3) {
        [self askToViewSafariForCompare];
        [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    }
}

- (void)askToViewSafariForCompare
{
    NSString *msg = @"This will quit TravisCI and open Safari.";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"View in Safari?" message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"View in Safari", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSURL *url = [NSURL URLWithString:self.job.compare];
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    [self setFinishedLabel:nil];
    [self setDurationLabel:nil];
    [self setCommitLabel:nil];
    [self setCompareLabel:nil];
    [self setAuthorLabel:nil];
    [self setMessageLabel:nil];
    [self setConfigLabel:nil];
    [self setLogTitle:nil];
    [self setLogSubtitle:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation { return YES; }


#pragma mark -
#pragma mark job methods

- (void)startObservingJob
{
    [self addObserver:self forKeyPath:@"job" options:NSKeyValueObservingOptionNew context:nil];
    [job addObserver:self forKeyPath:@"log" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)stopObservingJob
{
    [self removeObserver:self forKeyPath:@"job"];
    [job removeObserver:self forKeyPath:@"log"];
}

@end
