
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
}
- (void)willEnterForeground:(NSNotification*)notification;
@property(nonatomic,assign)bool started;

@property (retain) NSString *firstImagePath;
@property (retain) NSString *originalsFolderPath;
@property (nonatomic, strong) FlutterMethodChannel *channel;
@property (nonatomic, assign) CGRect initialFrame;
@property (nonatomic, strong) NSTimer *timerInfo;

@end

@implementation ShooterViewController

ShooterView *sv=nil;
UIView *aView=nil;

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
        NSString *method = call.method;
        if ([method isEqualToString:@"startShooting"]) {
            [weakSelf startShooting];
            result(nil);
        } else if ([method isEqualToString:@"finishShooting"]) {
            [weakSelf finishShooting];
            result(nil);
        } else if ([method isEqualToString:@"onResume"]) {
            result(nil);
        } else if ([method isEqualToString:@"onPause"]) {
            result(nil);
        } else if ([method isEqualToString:@"setShowGuide"]) {
            result(nil);
        } else if ([method isEqualToString:@"setOutputHeight"]) {
            result(nil);
        } else if ([method isEqualToString:@"updateFrame"]) {
            NSDictionary* args = call.arguments;
            CGFloat height = [args[@"height"] floatValue];
            CGFloat width = [args[@"width"] floatValue];
            CGRect newFrame = CGRectMake(0, 0, width, height);
            [weakSelf updateFrame:newFrame];
            result(nil);
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];
}

void lensDetectionCallback(enum DMDCircleDetectionResult res, void* obj)
{
}

- (void)updateFrame:(CGRect)newFrame {
    _initialFrame = newFrame;
    CGRect frame = _initialFrame;
    sv.frame = calculateShooterViewFrame(frame);
    aView.frame = frame;
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
}


-(void) startDMDSDKSafe
{
    [self checkCameraPermissions];
}

- (void)startDMDSDK
{
    sv = nil;
    self.timerInfo = nil;
    aView = nil;
    
    CGRect frame = _initialFrame;
    aView = [[UIView alloc] initWithFrame:frame];
    aView.backgroundColor = [UIColor blackColor];
    
    self.started = false;
    
    tookPhoto = NO;
    [Monitor instance].delegate = self;
    
    // The yin yang height size depends on the device screen width
    const int yinYangSize = CGRectGetWidth(frame) * 0.4814;

    CGRect shooterViewFrame = calculateShooterViewFrame(frame);

    sv = [[ShooterView alloc] initWithFrame:shooterViewFrame andYinYang:YES andCameraControls:NO];
    
    CGRect maskFrame = CGRectMake(0, yinYangSize, CGRectGetWidth(frame), CGRectGetHeight(frame));
    UIView *maskView = [[UIView alloc] initWithFrame:maskFrame];
    maskView.backgroundColor = [UIColor blackColor];

    sv.layer.mask = maskView.layer;
    
    [[Monitor instance] setCircleDetectionCallback:lensDetectionCallback withObject:(__bridge void *)(self)];
    
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

    
    [self.view addSubview:aView];
    
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
    [self leaveShooter];
    [self stopPrintTimer];
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
    
}

- (void)hdrToggle:(id)sender
{
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
    if (self.started) {
        NSLog(@"Panoramic Camera Plugin: Warning - The camera is already initialized");
        return;
    }
    [self start:nil];
}

- (void)finishShooting
{
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
    [self startPrintTimer];
    tookPhoto = NO;
    self.started = [[Monitor instance] startShooting];
}

- (void)restart:(id)sender
{
    [[Monitor instance] setLens:[DMDLensSelector currentLensID]];
	[[Monitor instance] restart];
    [self startPrintTimer];
    self.started=false;
}
- (void)stop:(id)sender
{
    [self stopPrintTimer];
	[[Monitor instance] finishShooting];
    tookPhoto=NO;
    self.started=false;
}
- (void)leaveShooter
{
    [self stopPrintTimer];
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
                        [self stopPrintTimer];
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
    self.timerInfo = [NSTimer scheduledTimerWithTimeInterval:0.25
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
    NSDictionary *ind = [[Monitor instance] getIndicators];
    [_channel invokeMethod:@"onUpdateIndicators" arguments:ind];
}

- (void)onLensSelectionFinished {
    
    CGRect frame  = [[UIScreen mainScreen] bounds];
    self.started=false;
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
    [_channel invokeMethod:@"rotatorConnected" arguments:nil];
}

- (void)rotatorDisconnected {
    [_channel invokeMethod:@"rotatorDisconnected" arguments:nil];
}

- (void)rotatorStartedRotating {
    [_channel invokeMethod:@"rotatorStartedRotating" arguments:nil];
}

- (void)rotatorFinishedRotating {
    [_channel invokeMethod:@"rotatorFinishedRotating" arguments:nil];
}

CGRect calculateShooterViewFrame(CGRect frame) {
    // The yin yang height size depends on the device screen width
    const int yinYangSize = CGRectGetWidth(frame) * 0.4814;
    CGRect shooterViewFrame = CGRectMake(0, -yinYangSize, CGRectGetWidth(frame), CGRectGetHeight(frame) + yinYangSize);
    return shooterViewFrame;
}

@end
