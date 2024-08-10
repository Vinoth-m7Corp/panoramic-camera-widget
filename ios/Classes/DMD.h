//
//  DMD.h
//  Dermandar Panorama
//
//  Created by Elias Khoury on 4/5/13.
//  Copyright (c) 2013 Dermandar (Offshore) S.A.L. All rights reserved.
//

#ifndef DMD_h
#define DMD_h

#ifdef DMD_ACTIVATE_ROTATOR_PLUGIN
#import "IRotator/IDMDRotator.h"
#endif

enum DMDCompassEvents
{
    kDMDCompassReady = 0,
    kDMDCompassInitializing,
    kDMDCompassNeedsCalibration,
    kDMDCompassInterference
};

enum DMDLensID
{
    kLensNone = 0,
    kLensBubblePix1,
    kLensIPro1,
    kLensManfrotto1,
    kLensMoment1,
    kLensMPow1,
    kLensNodal1,
    kLensOlloclip1,
    kLensFunipica1,
    kLens198D1,
    kLens98D1,
    kLensTorras1,
    kLens180S1,
    kLens160M1,
    kLens153C1,
    kLensBuiltInUltraWide1,
};

enum DMDCircleDetectionResult
{
    DMDCircleDetectionInvalidInput = 0,
    DMDCircleDetectionCircleNotFound,
    DMDCircleDetectionBad,
    DMDCircleDetectionGood
};

/*  estimation number of shots for each option were computed for iPhone 11 with/out fisheye lens
 *  (Handheld capture is sensor-dependent so values of Handheld mode are not guaranteed)
 */
enum DMDReducedShots
{
    //                              Handheld (values not guaranteed)                    Rotator (guaranteed)
    //                       Built-in wide Lens     Fisheye Lens (180S)     Built-in Lens           Fisheye Lens (180S)
    Normal_0_40 = 0, //     14 images                8 images              15 images                  8 images
    Reduced_0_20,    //      9 images                6 images              10 images                  7 images
    Reduced_0_10,    //      9 images                5 images              10 images                  6 images
    Reduced_0_07,    //      9 images                5 images              10 images                  5 images
    Extended_0_60,   //     19 images               11 images              20 images                 10 images
    Extended_0_65,   //     21 images               13 images              24 images                 15 images
    Extended_0_70,   //     24 images               15 images              30 images                 20 images
    Extended_0_75,   //     29 images.              16 images              36 images                 24 images
    Extended_0_80,   //     34 images.              18 images              40 images                 30 images
};

enum DMDExposureModes
{
    Auto = 0,
    Locked,
    LockedOnFirst,
    HDR,
};

enum VRKitRotatorSpeed
{
    VRKitRotatorSpeed10s = 0,
    VRKitRotatorSpeed20s,
    VRKitRotatorSpeed40s,
    VRKitRotatorSpeed60s,
    VRKitRotatorSpeedDefault,
};

typedef void (*DMDCircleDetectionCallback)(enum DMDCircleDetectionResult res, void *obj);

@protocol MonitorDelegate <NSObject>

@optional

- (void)preparingToShoot;
- (void)canceledPreparingToShoot;
- (void)takingPhoto;
- (void)photoTaken;
- (void)stitchingCompleted:(NSDictionary *)dict;
- (void)shootingCompleted;

- (void)deviceVerticalityChanged:(NSNumber *)isVertical;
- (void)compassEvent:(NSDictionary *)info;

- (void)rotatorConnected;
- (void)rotatorDisconnected;
- (void)rotatorStartedRotating;
- (void)rotatorFinishedRotating;
#ifdef DMD_ACTIVATE_ROTATOR_PLUGIN
- (void)rotatorFailedToConnect:(NSArray<DMDRotatorError *> *)errors;
#endif

- (void)exposureModeChanged:(NSNumber *)mode;

@end

@interface EngineManager : NSObject

@property(nonatomic, readonly) NSThread *thread;

@end

@interface Monitor : NSObject
{
    id<MonitorDelegate> delegate;
}

@property(nonatomic, assign) id<MonitorDelegate> delegate;
@property(nonatomic, readonly) EngineManager *engineMgr;
@property(nonatomic, assign) BOOL isShooting;

+ (Monitor *)instance;

/*
 *  input:
 *      true to activate the fix
 *      false to deactivate the fix
 *      use this option ONLY if you have a some artifacts while capturing HDR images on some devices
 *      this would make the capturing experience slower but it will fix the issue.
 *  hint:
 *      this function can be activated based on a specific device model/name.
 */
- (void)setHDRArtifactsFix:(BOOL)enabled;

/*
 *  input:
 *      true to activate the postprocessing
 *      false to deactivate the postprocessing
 */
- (void)setHDRPostProcessingStatus:(BOOL)enabled;

/*
 *  input:
 *      512x512x4 (RGBA_8888) logo as a raw data
 *      _min_zenith : specifies the minimum size of the top logo between 0..90 degrees, otherwise it is set to 0 (0=auto)
 *      _min_nadir  : specifies the minimum size of the bottom logo between 0..90 degrees, otherwise it is set to 0 (0=auto)
 *
 *  output:
 *      returns true when succeeded and false when it fails/not supported.
 */
- (BOOL)setLogo:(unsigned char *)logoData minZenith:(float)_min_zenith minNadir:(float)_min_nadir;

/*
 *  input:
 *      512x512x4 (RGBA_8888) logo as a raw data
 *      _min_zenith : specifies the minimum size of the top logo between 0..90 degrees, otherwise it is set to 0 (0=auto)
 *      _min_nadir  : specifies the minimum size of the bottom logo between 0..90 degrees, otherwise it is set to 0 (0=auto)
 *      _max_zenith : specifies the maximum size of the top logo between 0..90 degrees, otherwise it is set to 90 (90=no limits)
 *      _max_nadir  : specifies the maximum size of the bottom logo between 0..90 degrees, otherwise it is set to 90 (90=no limits)
 *
 *  output:
 *      returns true when succeeded and false when it fails/not supported.
 */
- (BOOL)setLogo:(unsigned char *)logoData minZenith:(float)_min_zenith minNadir:(float)_min_nadir maxZenith:(float)_max_zenith maxNadir:(float)_max_nadir;

///*
//*  input:
//*      512x512x4 (RGBA_8888) logo as a raw data
//*      _min_zenith  : specifies the min size of the top logo between 0..90 degrees, otherwise it is set to 0 (0=auto) should be less than or equal _max_zenith otherwise 0 applied
//*      _min_nadir   : specifies the min size of the bottom logo between 0..90 degrees, otherwise it is set to 0 (0=auto) should be less than or equal _max_nadir otherwise 0 applied
//*      _max_zenith  : specifies the max size of the top logo between 0..90 degrees, otherwise it is set to (90=auto) should be greater than or equal _min_zenith otherwise 90 applied
//*      _max_nadir   : specifies the size of the bottom logo between 0..90 degrees, otherwise it is set to (90=auto) should be greater than or equal _min_nadir otherwise 90 applied
//*
//*  output:
//*      returns true when succeeded and false when it fails/not supported.
//*/
//- (BOOL)setLogo:(unsigned char*)logoData minZenith:(float)_min_zenith minNadir:(float)_min_nadir maxZenith:(float)_max_zenith maxNadir:(float)_max_nadir;

/*
 * by default it is the first lens in enum DMDLensID
 */
- (void)setLens:(enum DMDLensID)lens;

/*
 *  method setCircleDetectionCallback:
 *
 *  to get the status of circle detection / when status is invalid input or circle not found engine should be restarted.
 *
 *  you must not put any blocking calls - heavy calculations - in this phase or it will affect the performance.
 *
 *  object (_Nullable): pass through object to be passed again when the callback function called.
 */
- (void)setCircleDetectionCallback:(DMDCircleDetectionCallback)callback withObject:(void *)object;

/*
 *  method getCurrentLensParams:
 *
 *  The best place to call this method is either after calling setLens or inside the DMDCircleDetectionCallback when it is called with DMDCircleDetectionGood/DMDCircleDetectionBad status.
 *
 *  returned dictionary contains 3 NSNumber objects that represent 3 float values of the following keys: "cx", "cy" and "radius"
 *  cx: the horizontal shift of the lens in pixels relative top-left of the screen.
 *  cy: the vertical   shift of the lens in pixels relative top-left of the screen.
 *  radius: radius of the circle relative to screen height.
 */
- (NSDictionary *)getCurrentLensParams;

/*
 *  this feature requires special licensing permissions.
 *  it allows to take less/more shots to complete capture panorama.
 *  for more details check enum DMDReducedShots definition
 */
- (BOOL)setReducedShots:(enum DMDReducedShots)mode;

/*
    setRotatorMode: will allow to enable/disable rotator mode.
    returns if the rotator mode is successfully activated or not.
 */
- (BOOL)setRotatorMode:(BOOL)enabled;

/*
 Deprecated: use ShooterView->setExposureHDR. for more details check setExposureHDR comments.
- (BOOL)setHDRMode:(BOOL)enabled;
*/

/*
    if HDR not supported this function will return false
 */
- (BOOL)isHDRSupported;

/*
    if built-in ultra-wide lens not supported this function will return false (false means either no
    ultra-wide lens or option is not allowed for your license)
*/
- (BOOL)isUltraWideSupported;

- (void)restart;
- (BOOL)startShooting;
- (BOOL)startShootingWithMaxFovX:(int)mFx;
- (void)stopShooting;   // resets & stops engine and camera.
- (void)finishShooting; // stops camera and engine, stitches if was shooting

// when generating equi with sphEqui=TRUE the height of the equi should be:
//      <=4096 when HD option is available
//      <=2048 when HD is not available
- (void)genEquiAt:(NSString *)fileName withHeight:(NSUInteger)height andWidth:(NSUInteger)width andMaxWidth:(NSUInteger)maxWidth sphericalEqui:(BOOL)sphEqui;
- (void)genEquiAt:(NSString *)fileName withHeight:(NSUInteger)height andWidth:(NSUInteger)width andMaxWidth:(NSUInteger)maxWidth;
- (void)genEquiAt:(NSString *)fileName withHeight:(NSUInteger)height andWidth:(NSUInteger)width andMaxWidth:(NSUInteger)maxWidth centerAt:(CGFloat)degrees;
- (void)genEquiAt:(NSString *)fileName withHeight:(NSUInteger)height andWidth:(NSUInteger)width andMaxWidth:(NSUInteger)maxWidth zenithLogo:(BOOL)zEnabled nadirLogo:(BOOL)nEnabled;
- (void)genEquiAt:(NSString *)fileName withHeight:(NSUInteger)height andWidth:(NSUInteger)width andMaxWidth:(NSUInteger)maxWidth centerAt:(CGFloat)degrees zenithLogo:(BOOL)zEnabled nadirLogo:(BOOL)nEnabled;
- (void)genEquiAt:(NSString *)fileName withHeight:(NSUInteger)height andWidth:(NSUInteger)width andMaxWidth:(NSUInteger)maxWidth centerAt:(CGFloat)degrees zenithLogo:(BOOL)zEnabled nadirLogo:(BOOL)nEnabled sphericalEqui:(BOOL)sphEqui;
- (void)genEquiAt:(NSString *)fileName withHeight:(NSUInteger)height andWidth:(NSUInteger)width andMaxWidth:(NSUInteger)maxWidth centerAt:(CGFloat)degrees zenithLogo:(BOOL)zEnabled nadirLogo:(BOOL)nEnabled sphericalEqui:(BOOL)sphEqui fill:(BOOL)blurFill;

#ifdef DMD_EXTENDED_API
- (void)genEquiRectAt:(NSString *)fileName withHeight:(NSUInteger)height;
#if defined(DMD_NONHDR_EXPORT) && defined(HDR_ENABLED)
// requires special licensing access...contact us for more details.
- (void)genEquiRectNonHDRAt:(NSString *)fileName withHeight:(NSUInteger)height;
#endif
#endif

// returns 4 double values represent the spherical equi crop parameters normalized between [0-0.5]
// under the following keys: @"left", @"top", @"right", @"bottom"
- (NSDictionary *)getSphericalEquiCropParameters;

- (NSDictionary *)getIndicators;
- (void)setSafeZoneLowerBound:(double)lb andUpperBound:(double)ub; // if you don't know what it does, don't call this function. Must be called as early as possible, BEFORE start shooting.
- (void)resetSafeZone;

- (void)printSDKLog;

/*
    This feature requires special licensing permissions:
    for both Pitch and Roll angles of YinYang/Custom indicators:
    - all input values would be in degrees
    - the range between ]0, maxPerfect[ indicates the perfect range to shoot
    - the range between [maxPerfect, maxGood[ indicates the good range to shoot
    - the range between [maxGood, stopLimit[ indicates the bad range where capture is not allowed
    - after stopLimit capture will stop automatically when more than 2 images were taken
    - default values: maxPerfect=2degrees, maxGood=10degrees when capturing with no lens and 20degrees when capturing with Fisheye/Ultrawide Lenses and stopLimit=45degrees
    - if input is not representing a good range, output would be false and default values would be in use, else the output would be true and the input values would be in use
    - call with maxPerfect=0, maxGood=0 and stopLimit=0 to use auto mode (default SDK behavior)
 */
- (BOOL)setIndicatorsLimit:(double)maxPerfect andMaxGood:(double)maxGood andStopLimits:(double)stopLimit;

/*
    This function allows to control the rotator rotation speed and can be set to one of the
    values allowed and available in the enum type VRKitRotatorSpeed.
 */
- (void)setRotatorSpeed:(enum VRKitRotatorSpeed)speed;

/*
    This function allows to use a plugin rotator to use an external rotator with DMD SDK
    for more information about how this feature work, please contact us
    requires special licensing feature to to work.
    WARNING:
        any call to this method should be done as early as possible or it should be followed by restart call
        if restart is not called, then the engine would be in an undefined state and this would cause executiom problems
 */
#ifdef DMD_ACTIVATE_ROTATOR_PLUGIN
- (void)setRotatorController:(id<IDMDRotator>)rotator;
#endif

- (bool)setRotatorCaptureDelay:(BOOL)enabled time:(int)timeMilliSeconds;

@end

@interface ShooterView : UIView

@property(nonatomic, readonly, getter=get_exposureControls) NSArray *exposureControls;
@property(nonatomic, readonly) UIButton *cameraToggleButton;

- (id)initWithFrame:(CGRect)frame andYinYang:(BOOL)showYinYang andCameraControls:(BOOL)showCameraControls;
- (id)initWithFrame:(CGRect)frame andYinYang:(BOOL)showYinYang;
- (void)setLowerYinYangPosition:(BOOL)enabled forFrame:(CGRect)frame;

- (void)setExposureLocked:(id)sender;
- (void)setExposureAuto:(id)sender;
- (void)setExposureLockedOnFirst:(id)sender;
/*
 *   Check Monitor->isHDRSupported for HDR support before calling this function...if isHDRSupport return false you have to set exposure mode to one of the following:
 *      - setExposureAuto
 *      - setExposureLocked
 *      - setExposureLockedOnFirst
 */
- (void)setExposureHDR:(id)sender;

- (void)setExportOriOn:(id)sender;
- (void)setExportOriOff:(id)sender;
- (void)setExportOriFolder:(NSString *)dir; // nil to save in camera roll, else saves with filename {dir}/{[[NSDate date] description]]}.jpg

- (void)setContinuousMode:(bool)enabled; // while using continuous rotator it is recommended to enable continuous mode.

#ifdef HD
- (BOOL)canShootHD;                 // tells whether the device supports HD mode
- (void)setResolutionSD:(id)sender; // standard definition - should be called before startShooting, must not be called while shooting
- (void)setResolutionHD:(id)sender; //    high definition - should be called before startShooting, must not be called while shooting
#endif
- (void)useWideAngleLens;      // deprecated: use setLens instead.
- (void)useStandardCameraLens; // deprecated: use setLens instead.

- (BOOL)setYinyangScale:(float)scale;

@end

#ifdef DMD_ACTIVATE_ROTATOR_PLUGIN
@interface VRKitRotatorPlugin : NSObject <IDMDRotator>

@end
#endif

#endif
