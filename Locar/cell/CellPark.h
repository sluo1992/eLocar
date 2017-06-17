//
//  CellPark.h
//  Locar
//
//  Created by apple on 2017/5/28.
//  Copyright © 2017年 CHENHAO Intelligent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellPark : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imagePark;
@property (weak, nonatomic) IBOutlet UILabel *labelTime;
@property (weak, nonatomic) IBOutlet UITextView *textWhere;

@end
