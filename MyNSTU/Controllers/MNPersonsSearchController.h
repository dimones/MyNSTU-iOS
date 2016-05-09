//
//  MNPersonsSearchController.h
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 05.09.15.
//  Copyright (c) 2015 Дмитрий Богомолов. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNPersonsSearchController : UIViewController

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *personsTable;
@end
