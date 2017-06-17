//
//  CellSwitch.m
//  Locar
//
//  Created by apple on 2017/5/21.
//  Copyright © 2017年 CHENHAO Intelligent. All rights reserved.
//

#import "CellSwitch.h"

@implementation CellSwitch

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    [self.labelText setTextColor:[UIColor whiteColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
