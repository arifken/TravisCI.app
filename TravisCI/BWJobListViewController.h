//
//  BWJobTableView.h
//  TravisCI
//
//  Created by Bradley Grzesiak on 1/6/12.
//  Refer to MIT-LICENSE file at root of project for copyright info
//

#import <UIKit/UIKit.h>

@class BWCDBuild, BWPhoneJobDetailViewController;

@interface BWJobListViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) UINib *jobCellNib;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) BWCDBuild *build;
@property (readonly, strong) BWPhoneJobDetailViewController *jobDetailViewController;

@end
