//
//  ViewControllerConfig.m
//  Locar
//
//  Created by apple on 2017/5/18.
//  Copyright © 2017年 CHENHAO Intelligent. All rights reserved.
//

#import "ViewControllerConfig.h"
#import "CellText.h"
#import "CellSwitch.h"

@interface ViewControllerConfig ()<UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewControllerConfig

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.rowHeight = 60;
    // 不显示多余的分割线
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:view];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    CareMsg(msgBleDeviceFound);
    CareMsg(msgBleDeviceGone);
}

- (void)onNotifyMsg:(NSNotification *)notification
{
    [super onNotifyMsg:notification];
    
    NSString *msg = [NSString stringWithString:notification.name];
    
    NSLog(@"on notify : %@", msg);
    if([msg isEqualToString:msgBleDeviceFound])
    {
        [self.tableView reloadData];
    }
    else if([msg isEqualToString:msgBleDeviceGone])
    {
        [self.tableView reloadData];
    }
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor *c = [UIColor colorWithRed:92/255.0 green:175/255.0 blue:69/255.0 alpha:1.0];
    switch (indexPath.row)
    {
        case 0:
        {
            static NSString *cellId = @"idCellSwitch";
            CellSwitch *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
            if (cell == nil)
            {
                cell = [[CellSwitch alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            }
            // Config your cell
            [cell.labelText setTextColor:[UIColor whiteColor]];
            [cell.labelText setText:@"开启轨迹记录"];
            [cell.swSwitch setOn:[HSAppData getTrackOn]];
            [cell.swSwitch setTag:indexPath.row];
            [cell.swSwitch addTarget:self action:@selector(onSwitch:) forControlEvents:UIControlEventValueChanged];
            
            UIView *bkView = [[UIView alloc] initWithFrame:cell.frame];
            [bkView setBackgroundColor:c];
            bkView.layer.masksToBounds = YES;
            bkView.layer.cornerRadius = 8.0f;
            cell.selectedBackgroundView = bkView;
            
//            UIView *bkView = [[UIView alloc] initWithFrame:cell.frame];
//            [bkView setBackgroundColor:[UIColor purpleColor]];
//            CGRect frame = CGRectInset(cell.frame, 2.0, 2.0);
//            UIView *inView = [[UIView alloc] initWithFrame:frame];
//            [inView setBackgroundColor:[UIColor orangeColor]];
//            [bkView addSubview:inView];
//            cell.selectedBackgroundView = bkView;
            
            return cell;
            break;
        }
        case 1:
        {
            static NSString *cellId = @"idCellSwitch";
            CellSwitch *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
            if (cell == nil)
            {
                cell = [[CellSwitch alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            }
            // Config your cell
            [cell.labelText setTextColor:[UIColor whiteColor]];
            [cell.labelText setText:@"开启位置消息提醒"];
            [cell.swSwitch setOn:[HSAppData getGpsAlert]];
            [cell.swSwitch setTag:indexPath.row];
            [cell.swSwitch addTarget:self action:@selector(onSwitch:) forControlEvents:UIControlEventValueChanged];
            
            UIView *bkView = [[UIView alloc] initWithFrame:cell.frame];
            [bkView setBackgroundColor:c];
            bkView.layer.masksToBounds = YES;
            bkView.layer.cornerRadius = 8.0f;
            cell.selectedBackgroundView = bkView;
            return cell;
            break;
        }
        case 2:
        {
            static NSString *cellId = @"idCellSwitch";
            CellSwitch *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
            if (cell == nil)
            {
                cell = [[CellSwitch alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            }
            // Config your cell
            [cell.labelText setTextColor:[UIColor whiteColor]];
            [cell.labelText setText:@"开启定时器提醒"];
            [cell.swSwitch setOn:[HSAppData getTimerAlert]];
            [cell.swSwitch setTag:indexPath.row];
            [cell.swSwitch addTarget:self action:@selector(onSwitch:) forControlEvents:UIControlEventValueChanged];
            
            UIView *bkView = [[UIView alloc] initWithFrame:cell.frame];
            [bkView setBackgroundColor:c];
            bkView.layer.masksToBounds = YES;
            bkView.layer.cornerRadius = 8.0f;
            cell.selectedBackgroundView = bkView;
            return cell;
            break;
        }
        case 3:
        {
            static NSString *cellId = @"idCellSwitch";
            CellSwitch *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
            if (cell == nil)
            {
                cell = [[CellSwitch alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            }
            // Config your cell
            [cell.labelText setTextColor:[UIColor whiteColor]];
            [cell.labelText setText:@"开启语音报播提醒"];
            [cell.swSwitch setOn:[HSAppData getAudioAlert]];
            [cell.swSwitch setTag:indexPath.row];
            [cell.swSwitch addTarget:self action:@selector(onSwitch:) forControlEvents:UIControlEventValueChanged];
            
            UIView *bkView = [[UIView alloc] initWithFrame:cell.frame];
            [bkView setBackgroundColor:c];
            bkView.layer.masksToBounds = YES;
            bkView.layer.cornerRadius = 8.0f;
            cell.selectedBackgroundView = bkView;
            return cell;
            break;
        }
        case 4:
        {
            static NSString *cellId = @"idCellText";
            CellText *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
            if (cell == nil)
            {
                cell = [[CellText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            }
            // Config your cell
            [cell.labelText setTextColor:[UIColor whiteColor]];
            [cell.labelText setText:@"距离单位"];
            [cell.labelValue setText:[HSAppData isUsingMetric] ? @"公里" : @"英里"];
            
            UIView *bkView = [[UIView alloc] initWithFrame:cell.frame];
            [bkView setBackgroundColor:c];
            bkView.layer.masksToBounds = YES;
            bkView.layer.cornerRadius = 8.0f;
            cell.selectedBackgroundView = bkView;
            return cell;
            break;
        }
        case 5:
        {
            static NSString *cellId = @"idCellText";
            CellText *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
            if (cell == nil)
            {
                cell = [[CellText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            }
            // Config your cell
            [cell.labelText setTextColor:[UIColor whiteColor]];
            [cell.labelText setText:@"解除蓝牙绑定"];
            [cell.labelValue setText:[MasterBle isBindBle] ? [NSString stringWithFormat:@"已绑定-%@", [HSAppData getBindBleName]] : @"尚未绑定设备"];
            
            UIView *bkView = [[UIView alloc] initWithFrame:cell.frame];
            [bkView setBackgroundColor:c];
            bkView.layer.masksToBounds = YES;
            bkView.layer.cornerRadius = 8.0f;
            cell.selectedBackgroundView = bkView;
            return cell;
            break;
        }
        case 6:
        {
            static NSString *cellId = @"idCellText";
            CellText *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
            if (cell == nil)
            {
                cell = [[CellText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            }
            // Config your cell
            [cell.labelText setTextColor:[UIColor whiteColor]];
            [cell.labelText setText:@"清除历史数据"];
            [cell.labelValue setText:[MasterBle isBindBle] ? [NSString stringWithFormat:@"已绑定-%@", [HSAppData getBindBleName]] : @"尚未绑定设备"];
            
            UIView *bkView = [[UIView alloc] initWithFrame:cell.frame];
            [bkView setBackgroundColor:c];
            bkView.layer.masksToBounds = YES;
            bkView.layer.cornerRadius = 8.0f;
            cell.selectedBackgroundView = bkView;
            return cell;
            break;
        }
            
        default:
            break;
    }
    
    return nil;
}

- (void)onSwitch:(id)sender
{
    UISwitch *sw = (UISwitch *)sender;
    if(sw != nil)
    {
        switch (sw.tag)
        {
            case 0:
                [HSAppData setTrackOn:sw.isOn];
                [self.tableView reloadData];
                break;
            case 1:
                [HSAppData setGpsAlert:sw.isOn];
                [self.tableView reloadData];
                break;
            case 2:
                [HSAppData setTimerAlert:sw.isOn];
                [self.tableView reloadData];
                break;
            case 3:
                [HSAppData setAudioAlert:sw.isOn];
                [self.tableView reloadData];
                break;
                
            default:
                break;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row)
    {
        case 4:
            
            break;
        case 5:
            if([MasterBle isBindBle])
            {
                UIActionSheet *as=[[UIActionSheet alloc]initWithTitle:@"确定解除当前绑定的蓝牙设备？" delegate:self
                                                    cancelButtonTitle:@"确定"
                                               destructiveButtonTitle:@"取消"
                                                    otherButtonTitles:nil];
                [as showInView:self.view];
            }
            break;
        case 6:
            
            break;
            
        default:
            break;
    }
//    NSArray *listLoc = [[HSDataStore sharedInstance] getObjectById:@"listLoc"];
//    NSLog(@"%@", listLoc);
}

#pragma mark ----------ActionSheet 按钮点击-------------
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 1:
            //照一张
        {
            [HSAppData setBindBleAddr:@"" andName:@""];
            [self.tableView reloadData];
            [MasterBle disconnect];
            
            [NSTimer scheduledTimerWithTimeInterval:1 target:[Master sharedInstance].bleMaster selector:@selector(delayScanTimer) userInfo:nil repeats:NO];
            break;
        }
        default:
            break;
    }
}

@end
