//
//  ShooterViewController.m
//  engine_demo
//
//  Created by Elias Khoury on 5/2/12.
//  Copyright (c) 2012 Dermandar (Offshore) S.A.L. . All rights reserved.
//

//#define CAPTURE_VIDEO_FRAME

#import "ShooterViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <OpenGLES/ES2/gl.h>

#import "DMDNavigationControllerPortrait.h"
#import "DMDLensSelector.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "DMDUIImageToRGBA8888.h"
#import <Photos/Photos.h>

#include <sys/types.h>
#include <sys/sysctl.h>

#define TAG_CAMERAVIEW 11
#define TAG_ACTIVITYVIEW 12

@interface ShooterViewController () <DMDLensSelectionDelegate, CBCentralManagerDelegate>
{
    BOOL tookPhoto;
    BOOL hideYinYang;
    CBCentralManager *bluetoothManager;
}
- (void)willEnterForeground:(NSNotification*)notification;
@property(nonatomic,assign)bool started;
@property(nonatomic,assign)bool continuousMode;
@property(nonatomic,assign)BOOL isRotatorMode;
@property(nonatomic,assign)BOOL isRotatorConnected;
@property(nonatomic,assign)BOOL isHDROn;

@property (retain) NSString *firstImagePath;
@property (retain) NSString *originalsFolderPath;
@property (nonatomic, strong) FlutterMethodChannel *channel;
@property (nonatomic, assign) CGRect initialFrame;
@property (nonatomic, strong) NSTimer *timerInfo;

@end

@implementation ShooterViewController

ShooterView *sv=nil;
UITextField* textField=nil;
NSDictionary* settings=nil;
UIView *aView=nil;
UIButton *btnSelectLens = nil;
UIButton *ivRotatorSwitch = nil;
UIView *circleView = nil;
UIImageView *btnHDR = nil;
@synthesize isRotatorConnected = _isRotatorConnected;
@synthesize isHDROn = _isHDROn;

- (instancetype)initWithMethodChannel:(FlutterMethodChannel *)channel frame:(CGRect)frame {
    self = [super init];
    if (self) {
        _initialFrame = frame;
        _channel = channel;
        [self setupMethodChannel];
    }
    return self;
}

- (void)setupMethodChannel {
    __weak typeof(self) weakSelf = self;
    [_channel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
        if ([@"startShooting" isEqualToString:call.method]) {
            [weakSelf startShooting];
            result(nil);
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];
}

void lensDetectionCallback(enum DMDCircleDetectionResult res, void* obj)
{
}

- (void)checkCameraPermissions
{
    [label setHidden:YES];
    
    [label setText:@"Camera access is required.\nPlease enable Camera access from\nSettings > Privacy > Camera"];
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusNotDetermined) {
        __weak typeof(self) weakSelf = self;
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(self) strongSelf = weakSelf;
                    if (strongSelf) {
                        [strongSelf startDMDSDK];
                    }
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(self) strongSelf = weakSelf;
                    if (strongSelf) {
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                                 message:@"Camera access is required"
                                                                                          preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
                        [alertController addAction:okAction];
                        [strongSelf presentViewController:alertController animated:YES completion:nil];
                    }
                });
            }
        }];
    } else if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                 message:@"Camera access is required. Please enable Camera access from Settings > Privacy > Camera"
        preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [self startDMDSDK];
    }
}


- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBManagerStatePoweredOn) {
        [self checkCameraPermissions];
    }
    else if (central.state == CBManagerStateUnauthorized) {
        [label setHidden:NO];
        [label setText:@"Bluetooth access is required.\nPlease enable Bluetooth access from\nSettings > theVRkit > Bluetooth"];
    }
    else if (central.state == CBManagerStatePoweredOff) {
        [label setHidden:NO];
        [label setText:@"Bluetooth should be turned on.\nPlease turn on Bluetooth from\nSettings > Bluetooth"];
    }
    else {
        [label setHidden:NO];
    }
}


-(void) startDMDSDKSafe
{
    if(!bluetoothManager&&self.isRotatorMode) {
        bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    else if(!self.isRotatorMode) {
        [self checkCameraPermissions];
    }
}

- (void)startDMDSDK
{
    sv = nil;
    textField = nil;
    settings = nil;
    self.timerInfo = nil;
    aView = nil;
    btnSelectLens = nil;
    ivRotatorSwitch = nil;
    circleView = nil;
    btnHDR = nil;
    
    _isRotatorConnected = NO;
    _isHDROn = NO;
    
    CGRect frame = _initialFrame;
    aView = [[UIView alloc] initWithFrame:frame];
    aView.backgroundColor = [UIColor blackColor];
    [aView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    
    self.isRotatorMode = NO;
    
    self.isRotatorMode = [[Monitor instance] setRotatorMode:self.isRotatorMode];
    self.started = false;
    self.continuousMode = false;
    
    tookPhoto = NO;
    [Monitor instance].delegate = self;
    
    hideYinYang = NO;
    
    // The yin yang height size depends on the device screen width
    const int yinYangSize = CGRectGetWidth(frame) * 0.4814;

    CGRect shooterViewFrame = CGRectMake(0, -yinYangSize, CGRectGetWidth(frame), CGRectGetHeight(frame) + yinYangSize);


    sv = [[ShooterView alloc] initWithFrame:shooterViewFrame andYinYang:!hideYinYang andCameraControls:NO];
    
    CGRect maskFrame = CGRectMake(0, yinYangSize, CGRectGetWidth(frame), CGRectGetHeight(frame));
    UIView *maskView = [[UIView alloc] initWithFrame:maskFrame];
    maskView.backgroundColor = [UIColor blackColor];

    sv.layer.mask = maskView.layer;
    
    [[Monitor instance] setCircleDetectionCallback:lensDetectionCallback withObject:(__bridge void *)(self)];
    
    [sv setContinuousMode:self.continuousMode];
    sv.tag = TAG_CAMERAVIEW;
    
    [_channel invokeMethod:@"onCameraStarted" arguments:nil];
    
#ifdef HD
    if ([sv canShootHD]) {
        NSLog(@"Shooting in High Definition");
        [sv setResolutionHD:nil];
    } else {
        NSLog(@"Shooting in Standard Definition");
        [sv setResolutionSD:nil];
    }
#endif
    
    NSString *panoDir = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"originals"];
    [[NSFileManager defaultManager] removeItemAtPath:panoDir error:NULL];
    [[NSFileManager defaultManager] createDirectoryAtPath:panoDir withIntermediateDirectories:YES attributes:nil error:NULL];
    self.originalsFolderPath = panoDir;
    [sv setExportOriFolder:panoDir];    //nil for camera roll.
    
#ifdef AMS_DEBUG
    [sv setExportOriFolder:nil];
    [sv setExportOriOn:nil];
#else
    [sv setExportOriOff:nil];
#endif
    
    [aView addSubview:sv];

    // [self startPrintTimer];
    
    btnSelectLens = [[UIButton alloc] init];
    [btnSelectLens.layer setMasksToBounds:YES];
    [btnSelectLens.layer setCornerRadius:15.0];
    [btnSelectLens.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [btnSelectLens setTitle:[DMDLensSelector currentLensName] forState:UIControlStateNormal];
    [btnSelectLens setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnSelectLens setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.35]];
    [btnSelectLens sizeToFit];
    [btnSelectLens setFrame:CGRectMake(frame.size.width - btnSelectLens.bounds.size.width - 20, frame.size.height - btnSelectLens.bounds.size.height - 30, btnSelectLens.bounds.size.width + 10, btnSelectLens.bounds.size.height)];
    [btnSelectLens addTarget:self action:@selector(openLensSelector:) forControlEvents:UIControlEventTouchUpInside];
    
    ivRotatorSwitch = [[UIButton alloc] init];
    [ivRotatorSwitch.layer setMasksToBounds:YES];
    [ivRotatorSwitch.layer setCornerRadius:15.0];
    [ivRotatorSwitch setTitle:self.isRotatorMode ? @"Rotator" : @"Handheld" forState:UIControlStateNormal];
    [ivRotatorSwitch setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.35]];
    [ivRotatorSwitch sizeToFit];
    float sc = 1.0;
    [ivRotatorSwitch setFrame:CGRectMake(frame.size.width - ivRotatorSwitch.bounds.size.width * sc - 10, frame.size.height - btnSelectLens.bounds.size.height - ivRotatorSwitch.bounds.size.height * sc - 10 - 30, ivRotatorSwitch.bounds.size.width * sc, ivRotatorSwitch.bounds.size.height * sc)];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rotatorToggle:)];
    singleTap.numberOfTapsRequired = 1;
    [ivRotatorSwitch setUserInteractionEnabled:YES];
    [ivRotatorSwitch addGestureRecognizer:singleTap];
    
    float sc2 = (1.0 / 3.0);
    btnHDR = [[UIImageView alloc] init];
    [btnHDR setImage:[UIImage imageNamed:_isHDROn ? @"hdr_on" : @"hdr_off"]];
    [btnHDR sizeToFit];
    [btnHDR setFrame:CGRectMake(frame.size.width - btnHDR.bounds.size.width * sc2 - 10, frame.size.height - btnSelectLens.bounds.size.height - ivRotatorSwitch.bounds.size.height - btnHDR.bounds.size.height * sc2 - 10 - 10 - 30, btnHDR.bounds.size.width * sc2, btnHDR.bounds.size.height * sc2)];
    UITapGestureRecognizer *singleTapHDR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hdrToggle:)];
    singleTapHDR.numberOfTapsRequired = 1;
    [btnHDR setUserInteractionEnabled:YES];
    [btnHDR addGestureRecognizer:singleTapHDR];
    [btnHDR setHidden:(!self.isRotatorMode) || (!([self ramQuantity] > 2000) || ([DMDLensSelector currentLensID] == kLensNone))];
    
    [self.view addSubview:aView];
    // [self.view addSubview:btnSelectLens];
    // [self.view addSubview:ivRotatorSwitch];
    // [self.view addSubview:btnHDR];
    
    [self drawDefaultCircle];
}



UILabel *label = nil;

- (void)loadView
{
    CGRect frame = _initialFrame;
    UIView *view = [[UIView alloc] initWithFrame:frame];
    [view setBackgroundColor:[UIColor blackColor]];
    self.view = view;
}


- (void)dealloc
{
    if (circleView) {
        [circleView removeFromSuperview];
        circleView = nil;
    }
    [self leaveShooter];
    
    // Clean up any notifications or observers if necessary
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self startDMDSDKSafe];
}



- (void)rotatorToggle:(id)sender
{
    if(self.started)
        [self stop:nil];
    self.isRotatorMode = !self.isRotatorMode;
    self.isRotatorMode = [[Monitor instance] setRotatorMode:self.isRotatorMode];
    [ivRotatorSwitch setTitle:self.isRotatorMode?@"Rotator":@"Handheld" forState:UIControlStateNormal];
    
    if(!self.isRotatorMode && _isHDROn)
        [self hdrToggle:nil];
    
    if(btnHDR)
        [btnHDR setHidden:(!self.isRotatorMode) || (!([self ramQuantity] > 2000) || ([DMDLensSelector currentLensID] == kLensNone))];
}

- (void)hdrToggle:(id)sender
{
    if(self.started)
        [self stop:nil];
    _isHDROn = !_isHDROn;
    if(_isHDROn)
        [sv setExposureHDR:nil];
    else
        [sv setExposureAuto:nil];
    [btnHDR setImage:[UIImage imageNamed:_isHDROn?@"hdr_on":@"hdr_off"]];
}

- (NSString *) applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = paths.firstObject;
    return basePath;
}

- (void)userTapped:(UITapGestureRecognizer*)tgr
{
    self.started=!self.started;
    if(self.started)
        [self start:nil];
    else if(!tookPhoto)
        [self restart:nil];
    else
        [self stop:nil];
}

- (void)startShooting
{
    self.started=!self.started;
    if(self.started)
        [self start:nil];
    else if(!tookPhoto)
        [self restart:nil];
    else
        [self stop:nil];
}

- (void)openLensSelector:(id)sender
{
    DMDLensSelector *ls=[[DMDLensSelector alloc] initWithDelegate:self];
    DMDNavigationControllerPortrait *nav=[[DMDNavigationControllerPortrait alloc] initWithRootViewController:ls];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:^{
        
    }];
}

- (void)drawDefaultCircle
{
    NSDictionary* dict=[[Monitor instance] getCurrentLensParams];
    if(circleView){
        [circleView removeFromSuperview];
        circleView = nil;
    }
    float cx=-[[dict objectForKey:@"cx"] floatValue], cy=[[dict objectForKey:@"cy"] floatValue], radius=[[dict objectForKey:@"radius"] floatValue];
    if(radius) {
        float sqh=[sv bounds].size.height*radius*2;
        
        circleView = [[UIView alloc] initWithFrame:CGRectMake(([sv bounds].size.width-sqh)*0.5f + ([sv bounds].size.width)*cx, ([sv bounds].size.height-sqh)*0.5f + ([sv bounds].size.height)*cy, sqh, sqh)];
        circleView.alpha = 0.75;
        circleView.layer.borderWidth = 2;
        circleView.layer.borderColor = [UIColor yellowColor].CGColor;
        circleView.layer.cornerRadius = radius*sqh;
        circleView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        [sv addSubview:circleView];
        [circleView setUserInteractionEnabled:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.view viewWithTag:TAG_CAMERAVIEW].hidden = NO;
    [self restart:nil];
    
    [self drawDefaultCircle];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate
{
	return NO;
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
	return UIInterfaceOrientationPortrait;
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskPortrait;
}

- (void)willEnterForeground:(NSNotification*)notification
{
	[self restart:nil];
}

- (void)start:(id)sender
{
    // [self startPrintTimer];
    if (self.isRotatorMode && !_isRotatorConnected) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
        message:@"Rotator disconnected!"
        preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alert animated:YES completion:nil];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [alert dismissViewControllerAnimated:YES completion:nil];
        });
        
        self.started = false;
        return;
    }
    
    tookPhoto = NO;
    self.started = [[Monitor instance] startShooting];
}

- (void)restart:(id)sender
{
    // [self startPrintTimer];
    [[Monitor instance] setLens:[DMDLensSelector currentLensID]];
    self.isRotatorMode = [[Monitor instance] setRotatorMode: self.isRotatorMode];
	[[Monitor instance] restart];
    self.started=false;
}
- (void)stop:(id)sender
{
    // [self stopPrintTimer];
	[[Monitor instance] finishShooting];
    tookPhoto=NO;
    [_channel invokeMethod:@"finishShooting" arguments:nil];
}
- (void)leaveShooter
{
    // [self stopPrintTimer];
    [[Monitor instance] setDelegate:nil];
	[[Monitor instance] stopShooting];
    [_channel invokeMethod:@"leaveShooter" arguments:nil];
}

- (void)preparingToShoot
{
    [_channel invokeMethod:@"preparingToShoot" arguments:nil];
}
- (void)canceledPreparingToShoot
{
    [_channel invokeMethod:@"canceledPreparingToShoot" arguments:nil];
}
- (void)takingPhoto
{
    [_channel invokeMethod:@"takingPhoto" arguments:nil];
}
- (void)photoTaken
{
    tookPhoto=YES;
    [_channel invokeMethod:@"photoTaken" arguments:nil];
}

- (void)shootingCanceled
{
    [_channel invokeMethod:@"shootingCanceled" arguments:nil];
}

- (void)shootingCompleted
{
    if (@available(iOS 13.0, *)) {
        UIActivityIndicatorView *av = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        av.tag = TAG_ACTIVITYVIEW;
        [av startAnimating];
        av.center = self.view.center;
        [self.view addSubview:av];
    }
    [_channel invokeMethod:@"shootingCompleted" arguments:nil];
}

- (unsigned int) ramQuantity
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char*)malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    
    if ([platform hasPrefix:@"iPod4"])              return 256; //ipod4
    if ([platform hasPrefix:@"iPod5"])              return 512; //ipod5
    if ([platform hasPrefix:@"iPod7"])              return 1024;//ipod6
    
    if ([platform hasPrefix:@"iPhone2"])            return 256;//3GS
    if ([platform hasPrefix:@"iPhone3"])            return 512;//4
    if ([platform hasPrefix:@"iPhone4"])            return 512;//4S
    if ([platform hasPrefix:@"iPhone5"])            return 1024;//5
    if ([platform hasPrefix:@"iPhone6"])            return 1024;//5S
    if ([platform hasPrefix:@"iPhone7"])            return 1024;//6 & 6+
    if ([platform hasPrefix:@"iPhone8"])            return 2048;//6S & 6S+ & SE
    if ([platform hasPrefix:@"iPhone9"])            return 2048;//7 & 7+
    
    if ([platform hasPrefix:@"iPad2"])              return 512; //iPad 2 & Mini
    if ([platform hasPrefix:@"iPad3"])              return 1024;//iPad Retina
    if ([platform hasPrefix:@"iPad4"])              return 1024;//iPad Air & Mini2 & Mini3
    if ([platform hasPrefix:@"iPad5"])              return 2048;//iPad Air2 & Mini4
    
    return 2048;
}

- (void)stitchingCompleted:(NSDictionary*)dict
{    
    NSString *docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *equiPath = nil;
    
    int ch = [DMDLensSelector currentLensID] == kLensNone ? 800 : 512;
    equiPath = [docsDir stringByAppendingPathComponent:@"equi_z_n_both.jpg"];
    NSString *img = [[NSBundle mainBundle] pathForResource:@"logo" ofType:@"jpg"];
    unsigned char* logoData = [DMDUIImageToRGBA8888 uiImageToRGBA8888:[UIImage imageWithContentsOfFile:img]];
    [[Monitor instance] setLogo:logoData minZenith:0 minNadir:0];
    free(logoData), logoData = 0;
    [[Monitor instance] genEquiAt:equiPath withHeight:ch andWidth:0 andMaxWidth:0 zenithLogo:true nadirLogo:true];
    
    @autoreleasepool {
        NSData *imageData = [NSData dataWithContentsOfFile:equiPath];
        if (imageData) {
            UIImage *image = [UIImage imageWithData:imageData];
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetCreationRequest *creationRequest = [PHAssetCreationRequest creationRequestForAssetFromImage:image];
            } completionHandler:^(BOOL success, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self restart:nil];
                    
                    if (success) {
                        [self->_channel invokeMethod:@"onFinishGeneratingEqui" arguments:equiPath];
                    } else if (error) {
                        NSLog(@"Error saving photo: %@", error);
                    }
                });
            }];
        }
    }
    
    [[self.view viewWithTag:TAG_ACTIVITYVIEW] removeFromSuperview];
    
}


- (void)compassEvent:(NSDictionary*)info
{
}

- (void)startPrintTimer {
    self.timerInfo = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                       target:self
                                                     selector:@selector(printIndicatorValues)
                                                     userInfo:nil
                                                      repeats:YES];
}

- (void)stopPrintTimer {
    [self.timerInfo invalidate];
    self.timerInfo = nil;
}

- (void)printIndicatorValues
{
    // getIndicators is not supported for the current plan, if it were supported this method should be called to be able to receive the percentage of progress
	NSDictionary *ind = [[Monitor instance] getIndicators];
	NSLog(@"%.2f    %.2f    %.2f    %@    %d",
         [[ind objectForKey:@"roll"] doubleValue],
         [[ind objectForKey:@"pitch"] doubleValue],
         [[ind objectForKey:@"percentage"] doubleValue],
         ([[ind objectForKey:@"orientation"] intValue]==-1?@"LTR":@"RTL"),// -1=LTR 1=RTL
         [[ind objectForKey:@"fovx"] intValue]
    );
    [_channel invokeMethod:@"onUpdateIndicators" arguments:ind];
}

- (void)onLensSelectionFinished {
    
    [btnSelectLens setTitle:[DMDLensSelector currentLensName] forState:UIControlStateNormal];
    [btnSelectLens sizeToFit];
    CGRect frame  = [[UIScreen mainScreen] bounds];
    [btnSelectLens setFrame:CGRectMake(frame.size.width - btnSelectLens.bounds.size.width - 20, frame.size.height - btnSelectLens.bounds.size.height - 30, btnSelectLens.bounds.size.width + 10, btnSelectLens.bounds.size.height)];
    self.started=false;
    //[[Monitor instance] setLens:[DMDLensSelector currentLensID]];
    [self restart:nil];
    [self drawDefaultCircle];
    [_channel invokeMethod:@"onLensSelectionFinished" arguments:nil];
}

- (void)onLensSelectionClosed {
    [_channel invokeMethod:@"onLensSelectionClosed" arguments:nil];
}

- (void)deviceVerticalityChanged:(NSNumber *)isVertical {
    [_channel invokeMethod:@"deviceVerticalityChanged" arguments:@([isVertical intValue])];
}

- (void)rotatorConnected {
    _isRotatorConnected = YES;
    [_channel invokeMethod:@"rotatorConnected" arguments:nil];
}

- (void)rotatorDisconnected {
    _isRotatorConnected = NO;
    [_channel invokeMethod:@"rotatorDisconnected" arguments:nil];
}

- (void)rotatorStartedRotating {
    [_channel invokeMethod:@"rotatorStartedRotating" arguments:nil];
}

- (void)rotatorFinishedRotating {
    [_channel invokeMethod:@"rotatorFinishedRotating" arguments:nil];
}

@end
