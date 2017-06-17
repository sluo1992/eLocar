//
//  ViewControllerParkList.m
//  Locar
//
//  Created by apple on 2017/5/28.
//  Copyright © 2017年 CHENHAO Intelligent. All rights reserved.
//

#import "ViewControllerParkList.h"
#import "CellPark.h"

@interface ViewControllerParkList ()
{
    NSArray *parkList;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewControllerParkList

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.rowHeight = 80;
    parkList = [[HSCoreData sharedInstance] parkList];
}

#pragma mark - Table View Data Source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return parkList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"idCellPark";
    CellPark *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil)
    {
        cell = [[CellPark alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    // Config your cell
    CarLoc *aLoc = [parkList objectAtIndex:indexPath.row];
    if(aLoc.dataimage != nil && aLoc.dataimage.length > 0)
    {
        UIImage *image = [UIImage imageWithData:aLoc.dataimage];
        [cell.imagePark setImage:image];
    }
    else
    {
        [cell.imagePark setImage:[UIImage imageNamed:@"deficon"]];
    }
    [cell.imagePark.layer setMasksToBounds:YES];
    [cell.imagePark.layer setCornerRadius:8.0];
    [cell.labelTime setText:[NSString stringWithFormat:@"%ld    %@", indexPath.row + 1, aLoc.oftime]];
    [cell.textWhere setText:aLoc.where];
    
    UIView *bkView = [[UIView alloc] initWithFrame:cell.frame];
    UIColor *c = [UIColor colorWithRed:92/255.0 green:175/255.0 blue:69/255.0 alpha:1.0];
    [bkView setBackgroundColor:c];
    bkView.layer.masksToBounds = YES;
    bkView.layer.cornerRadius = 8.0f;
    cell.selectedBackgroundView = bkView;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CarLoc *aLoc = [parkList objectAtIndex:indexPath.row];
    [self showSegueWithObject:aLoc Identifier:@"showMapView"];
}


@end
