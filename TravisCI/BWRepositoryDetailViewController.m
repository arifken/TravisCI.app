//
//  BWRepositoryDetailViewController.m
//  TravisCI
//
//  Created by Bradley Grzesiak on 1/11/12.
//  Copyright (c) 2012 Bendyworks. All rights reserved.
//

#import "BWRepositoryDetailViewController.h"
#import "BWAwesome.h"
#import <QuartzCore/QuartzCore.h>

@implementation BWRepositoryDetailViewController

@synthesize splashView;

- (void)awakeFromNib
{
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end