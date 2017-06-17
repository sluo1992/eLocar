//
//  ViewControllerMap.h
//  Locar
//
//  Created by apple on 2017/5/18.
//  Copyright © 2017年 CHENHAO Intelligent. All rights reserved.
//

#import "RootViewController.h"

@interface ViewControllerMap : RootViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate>

@property (retain, nonatomic) UIPopoverController *thePopoverController;

@end
