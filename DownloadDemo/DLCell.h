//
//  DLCell.h
//  DownloadDemo
//
//  Created by Carmine on 2018/7/10.
//  Copyright © 2018年 Carmine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DLCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@end
