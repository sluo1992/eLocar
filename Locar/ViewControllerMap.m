//
//  ViewControllerMap.m
//  Locar
//
//  Created by apple on 2017/5/18.
//  Copyright © 2017年 CHENHAO Intelligent. All rights reserved.
//

#import "ViewControllerMap.h"
#import <MapKit/MapKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import "JZLocationConverter.h"

@interface ViewControllerMap ()<MKMapViewDelegate, UIActionSheetDelegate, AMapLocationManagerDelegate,MAMapViewDelegate>
{
    CarLoc *ofLocation;
    CarLoc *prevLocation;
    CarLoc *nextLocation;
    
    BOOL isShowParkImage;
}

@property (weak, nonatomic) IBOutlet UIView *viewMap;
@property (retain, nonatomic) MAMapView *mapView;
@property (retain, nonatomic) NSMutableArray *annotations;
@property (nonatomic, strong) AMapLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UILabel *labelDistance;
@property (weak, nonatomic) IBOutlet UIButton *btPrev;
@property (weak, nonatomic) IBOutlet UIButton *btNext;
@property (weak, nonatomic) IBOutlet UILabel *labelWhere;
@property (weak, nonatomic) IBOutlet UILabel *labelWhen;
@property (weak, nonatomic) IBOutlet UIButton *btNav;
@property (weak, nonatomic) IBOutlet UIButton *btImage;
@property (weak, nonatomic) IBOutlet UIButton *btTimer;
@property (weak, nonatomic) IBOutlet UIImageView *imagePark;
@end

@implementation ViewControllerMap
/*  折线图
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay{
    MAPolylineRenderer *polylineView = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
    
    if(mapView == self.mapView) {
        polylineView.lineWidth   = 8.f;
        polylineView.strokeColor = [UIColor blueColor];
    } else {
        polylineView.lineWidth   = 16.f;
        [polylineView loadStrokeTextureImage:[UIImage imageNamed:@"custtexture"]];
    }
    
    return polylineView;
}
*/
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.btPrev.layer.masksToBounds = YES;
    self.btPrev.layer.cornerRadius = 4.0;
    self.btNext.layer.masksToBounds = YES;
    self.btNext.layer.cornerRadius = 4.0;
    
    isShowParkImage = NO;
    [self.imagePark setHidden:YES];
    
    [self configLocationManager];
    ///初始化地图
    self.mapView = [[MAMapView alloc] initWithFrame:self.viewMap.bounds];
    ///把地图添加至view
    [self.viewMap addSubview:_mapView];
    
    self.mapView.layer.masksToBounds = YES;
    self.mapView.layer.cornerRadius = 8.0;
    if(self.transObj != nil)
    {
        [self setLocation:self.transObj];
        
    }
    
   
/*
    //构造折线数据对象
    CLLocationCoordinate2D commonPolylineCoords[4];
    commonPolylineCoords[0].latitude = 39.832136;
    commonPolylineCoords[0].longitude = 116.34095;
    
    commonPolylineCoords[1].latitude = 39.832136;
    commonPolylineCoords[1].longitude = 116.42095;
    
    commonPolylineCoords[2].latitude = 39.902136;
    commonPolylineCoords[2].longitude = 116.42095;
    
    commonPolylineCoords[3].latitude = 39.902136;
    commonPolylineCoords[3].longitude = 116.44095;
    
    //构造折线对象
    MAPolyline *commonPolyline = [MAPolyline polylineWithCoordinates:commonPolylineCoords count:4];
    
    //在地图上添加折线对象
    [_mapView addOverlay: commonPolyline];
    
*/

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.mapView addAnnotations:self.annotations];
    [self.mapView showAnnotations:self.annotations edgePadding:UIEdgeInsetsMake(20, 20, 20, 80) animated:YES];
    
    [self startLocation];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [self stopLocation];
}

#pragma mark ----------ActionSheet 按钮点击-------------
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
            //照一张
        {
            UIImagePickerController *imgPicker=[[UIImagePickerController alloc] init];
            [imgPicker setSourceType:UIImagePickerControllerSourceTypeCamera];
            [imgPicker setDelegate:self];
            [imgPicker setAllowsEditing:YES];
            [self presentViewController:imgPicker animated:YES completion:^{
            }];
            break;
        }
        case 1:
            //搞一张
        {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            {
                UIImagePickerController *m_imagePicker = [[UIImagePickerController alloc] init];
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
                {
                    m_imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    m_imagePicker.delegate = self;
                    //        [m_imagePicker.navigationBar.subviews];
                    [m_imagePicker setAllowsEditing:YES];
                    //m_imagePicker.allowsImageEditing = NO;
                    [self presentViewController:m_imagePicker animated:YES completion:nil];
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:
                                          @"Error accessing photo library!" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
                    [alert show];
                }
            }
            else
            {
                UIImagePickerController *m_imagePicker = [[UIImagePickerController alloc] init];
                if ([UIImagePickerController isSourceTypeAvailable:
                     UIImagePickerControllerSourceTypePhotoLibrary])
                {
                    m_imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    m_imagePicker.delegate = self;
                    [m_imagePicker setAllowsEditing:YES];
                    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:m_imagePicker];
                    [self setThePopoverController:popover];
                    
                    [self.thePopoverController presentPopoverFromRect:CGRectMake(0, 0, 500, 300) inView:self.
                     view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"Error accessing photo library!"
                                                                  delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
                    [alert show];
                }
                /*
                 // We are using an iPad
                 UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                 imagePickerController.delegate = self;
                 UIPopoverController *popoverController=[[UIPopoverController alloc] initWithContentViewController:imagePickerController];
                 popoverController.delegate = self;
                 [popoverController presentPopoverFromRect:((UIButton *)sender).bounds inView:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];*/
            }
            break;
        }
        default:
            break;
    }
}
#pragma mark ----------图片选择完成-------------
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone || picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        [picker dismissViewControllerAnimated:NO completion:^{
            ;
        }];
    }
    else //
    {
        CATransition *trans = [CATransition animation];
        [trans setDuration:0.25f];
        [trans setType:@"flip"];
        [trans setSubtype:kCATransitionFromLeft];
        
        [self.thePopoverController dismissPopoverAnimated:YES];
    }
    NSLog(@"image :%@", image);
    NSData *dataImage = UIImageJPEGRepresentation(image, 1.0);
    NSLog(@"data image :%lu", (unsigned long)dataImage.length);
    // [UIImage imageWithData:me.logo]
    // NSData *dataObj = UIImageJPEGRepresentation(defLogo, 1.0);
    UIImage *logo = [self buildImage:image forSize:640.0];
    NSLog(@"LOGO :%@", logo);
    NSData *dataLogo = UIImageJPEGRepresentation(logo, 1.0);
    NSLog(@"data logo :%lu", (unsigned long)dataLogo.length);
    
    [ofLocation setDataimage:dataLogo];
    if([[HSCoreData sharedInstance] dbAddCarLocation:ofLocation])
    {
        [self.btImage setImage:[UIImage imageNamed:@"icon-image"] forState:UIControlStateNormal];
        [self.imagePark setImage:image];
        [self.imagePark setHidden:NO];
        isShowParkImage = YES;
        
        [_Master speak:@"停车位置已设置" flag:@"image"];
    }
}

- (UIImage *)buildImage:(UIImage*)image forSize:(CGFloat)size
{
    CGFloat w = image.size.width;
    CGFloat h = image.size.height;
    
    if(w <= size && h <= size) return image;
    
    CGFloat nw, nh;
    if(w > h)
    {
        nw = size;
        nh = h / w * size;
    }
    else
    {
        nh = size;
        nw = w / h * size;
    }
    
    CGSize newSize = CGSizeMake(nw, nh);
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if(picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary)
    {
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            [picker dismissViewControllerAnimated:NO completion:^{
                ;
            }];
        }
        else
        {
            [self.thePopoverController dismissPopoverAnimated:NO];
        }
    }
    else
    {
        [picker dismissViewControllerAnimated:NO completion:^{
            ;
        }];
    }
}


- (void)setLocation:(CarLoc *)aLoc
{
    [self.labelDistance setText:@"正在计算距离..."];
    ofLocation = aLoc;
    prevLocation = [[HSCoreData sharedInstance] prevLocation:aLoc.storeID];
    nextLocation = [[HSCoreData sharedInstance] nextLocation:aLoc.storeID];
    [self.btPrev setHidden:(prevLocation == nil)];
    [self.btNext setHidden:(nextLocation == nil)];
    
    [self.labelWhere setText:aLoc.where];
    [self.labelWhen setText:[NSString stringWithFormat:@"%@   %@", aLoc.storeID == nil ? @"" : aLoc.storeID, aLoc.oftime]];
    
    if(aLoc.dataimage != nil && aLoc.dataimage.length > 0)
    {
        [self.btImage setImage:[UIImage imageNamed:@"icon-image"] forState:UIControlStateNormal];
        UIImage *image = [UIImage imageWithData:ofLocation.dataimage];
        [self.imagePark setImage:image];
    }
    else
    {
        [self.btImage setImage:[UIImage imageNamed:@"icon-shot"] forState:UIControlStateNormal];
        [self.imagePark setImage:nil];
    }
    [self.imagePark setHidden:YES];
    isShowParkImage = NO;
    /*添加annotation*/
    self.annotations = [NSMutableArray array];
    CLLocationCoordinate2D coordinates[1] = {ofLocation.location.coordinate};
    for (int i = 0; i < 1; ++i)
    {
        MAPointAnnotation *a1 = [[MAPointAnnotation alloc] init];
        a1.coordinate = coordinates[i];
        a1.title      = [NSString stringWithFormat:@"anno: %d", i];
        [self.annotations addObject:a1];
    }
    self.mapView.centerCoordinate = ofLocation.location.coordinate;// CLLocationCoordinate2DMake(39.907728, 116.397968);
    [self.mapView setZoomLevel:15.1 animated:YES];
    
}

#pragma mark - btnClick
- (IBAction)onNav:(id)sender
{
    [_Master speak:@"请选择导航地图" flag:@"map"];
    [self actionSheet:ofLocation.location.coordinate];
}


- (IBAction)onPrevLocation:(id)sender
{
    [self stopLocation];
    [self startLocation];
    
    [self setLocation:prevLocation];
    
}

- (IBAction)onNextLocation:(id)sender
{
    [self stopLocation];
    [self startLocation];
    
    [self setLocation:nextLocation];
}

- (IBAction)onTimer:(id)sender
{
    
}

- (IBAction)onImage:(id)sender
{
    if(isShowParkImage)
    {
    }
    else
    {
        if(ofLocation.dataimage != nil && ofLocation.dataimage.length > 0)
        {
            [self.btImage setImage:[UIImage imageNamed:@"icon-image"] forState:UIControlStateNormal];
        }
        else
        {
            UIActionSheet *as=[[UIActionSheet alloc]initWithTitle:@"设置停车场景" delegate:self
                                                cancelButtonTitle:@"取消"
                                           destructiveButtonTitle:@"拍照"
                                                otherButtonTitles:@"从相册中选择",
                               nil];
            [as showInView:self.view];
        }
    }
    isShowParkImage = !isShowParkImage;
    [self.imagePark setHidden:!isShowParkImage];
}


#pragma mark - Action Handle

- (void)configLocationManager
{
    self.locationManager = [[AMapLocationManager alloc] init];
    
    [self.locationManager setDelegate:self];

    //设置不允许系统暂停定位
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    
    //设置允许在后台定位
    [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    
    //设置允许连续定位逆地理
    [self.locationManager setLocatingWithReGeocode:NO];
}

- (void)startLocation
{
    //开始进行连续定位
    [self.locationManager startUpdatingLocation];
}

- (void)stopLocation
{
    //停止定位
    [self.locationManager stopUpdatingLocation];
}


/* 实现代理方法：*/
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation                                                 reuseIdentifier:pointReuseIndetifier];
        }
        annotationView.canShowCallout = YES;
        annotationView.animatesDrop = YES;
        annotationView.draggable = YES;
        annotationView.rightCalloutAccessoryView  = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        annotationView.pinColor  = [self.annotations indexOfObject:annotation] % 3;
        return annotationView;
    }
    return nil;
}

#pragma mark - AMapLocationManager Delegate

- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%s, amapLocationManager = %@, error = %@", __func__, [manager class], error);
}

- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode
{
    NSLog(@"location:{lat:%f; lon:%f; accuracy:%f; reGeocode:%@}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy, reGeocode.formattedAddress);
    
    NSTimeInterval locationAge = -[location.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0)
    {
        return;
    }
    //判断水平精度是否有效
    if (location.horizontalAccuracy < 0)
    {
        return;
    }
    //根据业务需求，进行水平精度判断，获取所需位置信息（100可改为业务所需值）
    //if(location.horizontalAccuracy < 100)
    {
        // 计算的距离
        CLLocationDistance dis = [location distanceFromLocation:ofLocation.location];
        
        if([HSAppData isUsingMetric])
        {
            if(dis > 1000)
            {
                [self.labelDistance setText:[NSString stringWithFormat:@"%.1f千米", dis / 1000.0]];
            }
            else
            {
                [self.labelDistance setText:[NSString stringWithFormat:@"%.1f米", dis]];
            }
        }
        else
        {
            double ft = dis * 3.2808399;
            if(ft > 5280)
            {
                [self.labelDistance setText:[NSString stringWithFormat:@"%.1f英里", ft / 5280.0]];
            }
            else
            {
                [self.labelDistance setText:[NSString stringWithFormat:@"%.1f英尺", ft]];
            }
        }
    }
}


- (void)actionSheet:(CLLocationCoordinate2D)coord
{
    __block NSString *urlScheme = nil;
    __block NSString *appName = @"Locar";
    __block CLLocationCoordinate2D coordinate = coord;// [JZLocationConverter wgs84ToGcj02:coord];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择地图" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    //这个判断其实是不需要的
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"http://maps.apple.com/"]])
    {
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"苹果地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
            MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil]];
            
            [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                           launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
        }];
        
        [alert addAction:action];
    }
    
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]])
    {
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"百度地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            NSString *urlString = [[NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=目的地&mode=driving&coord_type=gcj02",coordinate.latitude, coordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSLog(@"%@",urlString);
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            
        }];
        
        [alert addAction:action];
    }
    
    
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]])
    {
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"高德地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            NSString *urlString = [[NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=%@&lat=%f&lon=%f&dev=0&style=2",appName,urlScheme,coordinate.latitude, coordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSLog(@"%@",urlString);
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            
        }];
        
        [alert addAction:action];
    }
    
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]])
    {
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"谷歌地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            NSString *urlString = [[NSString stringWithFormat:@"comgooglemaps://?x-source=%@&x-success=%@&saddr=&daddr=%f,%f&directionsmode=driving",appName,urlScheme,coordinate.latitude, coordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSLog(@"%@",urlString);
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            
        }];
        
        [alert addAction:action];
    }
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}

@end
