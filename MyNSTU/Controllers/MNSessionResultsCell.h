//
//  MNSessionResultsCell.h
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 17.09.16.
//  Copyright © 2016 Дмитрий Богомолов. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNSessionResultsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *resultsType;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *markLabel;
@property (weak, nonatomic) IBOutlet UILabel *ectsLabel;
@property (weak, nonatomic) IBOutlet UILabel *ballsLabel;
- (void) setDataDict: (NSDictionary*) dict;
@end
