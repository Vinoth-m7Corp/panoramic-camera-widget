//
//  DMD.h
//  Dermandar Panorama
//
//  Created by Elias Khoury on 4/5/13.
//  Copyright (c) 2013 Dermandar (Offshore) S.A.L. All rights reserved.
//

#ifndef DMD_h
#define DMD_h

enum DMDCompassEvents {
	kDMDCompassReady=0,
	kDMDCompassInitializing,
	kDMDCompassNeedsCalibration,
	kDMDCompassInterference
};

enum DMDLensID {
    kLensNone=0,
};

enum DMDCircleDetectionResult {
    DMDCircleDetectionInvalidInput = 0,
    DMDCircleDetectionCircleNotFound,
    DMDCircleDetectionBad,
    DMDCircleDetectionGood
};

enum DMDReducedShots
{
    Normal_0_40=0,
    Reduced_0_20,
    Reduced_0_10,
    Reduced_0_07,
};

enum DMDExposureModes
{
    Auto=0,
    Locked,
    LockedOnFirst,
    HDR,
};

typedef void (*DMDCircleDetectionCallback)(enum DMDCircleDetectionResult res, void* obj);

@protocol MonitorDelegate <NSObject>

@optional

- (void)preparingToShoot;
- (void)canceledPreparingToShoot;
- (void)takingPhoto;
- (void)photoTaken;
- (void)stitchingCompleted:(NSDictionary*)dict;
- (void)shootingCompleted;

- (void)deviceVerticalityChanged:(NSNumber*)isVertical;
- (void)compassEvent:(NSDictionary*)info;

- (void)rotatorConnected;
- (void)rotatorDisconnected;
- (void)rotatorStartedRotating;
- (void)rotatorFinishedRotating;

- (void)exposureModeChanged:(NSNumber*)mode;

@end




@interface EngineManager : NSObject

@property (nonatomic, readonly) NSThread *thread;

@end




@interface Monitor : NSObject
{
	id<MonitorDelegate> delegate;
}

@property (nonatomic, assign) id<MonitorDelegate> delegate;
@property (nonatomic, readonly) EngineManager *engineMgr;
@property (nonatomic, assign) BOOL isShooting;

+ (Monitor*)instance;

/*
 *  input:
 *      512x512x4 (RGBA_8888) logo as a raw data
 *      _min_zenith : specifies the size of the top logo between 0..90 degrees, otherwise it is set to 0 (0=auto)
 *      _min_nadir  : specifies the size of the bottom logo between 0..90 degrees, otherwise it is set to 0 (0=auto)
 *
 *  output:
 *      returns true when succeeded and false when it fails/not supported.
 */
- (BOOL)setLogo:(unsigned char*)logoData minZenith:(float)_min_zenith minNadir:(float)_min_nadir;

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
- (void)setCircleDetectionCallback:(DMDCircleDetectionCallback)callback withObject:(void*)object;

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
- (NSDictionary*)getCurrentLensParams;

/*
 *  this feature requires special licensing permissions.
 *  it allows to take less shots to complete capture panorama.
 *  Normal_0_40: will take shots in normal mode (standard number of shots would be applied depending on the device.
 *  Reduced_0_20: will take less shots than Normal_0_40. (that may affect the quality).
 *  Reduced_0_10: will take even less shots than Reduced_0_20. (that may affect the quality).
 *  Reduced_0_07: will take even less shots than Reduced_0_10. (that may affect the quality).
 */
- (void)setReducedShots:(enum DMDReducedShots)mode;

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
- (void)stopShooting;// resets & stops engine and camera.
- (void)finishShooting;// stops camera and engine, stitches if was shooting

// when generating equi with sphEqui=TRUE the height of the equi should be:
//      <=4096 when HD option is available
//      <=2048 when HD is not available
- (void)genEquiAt:(NSString*)fileName withHeight:(NSUInteger)height andWidth:(NSUInteger)width andMaxWidth:(NSUInteger)maxWidth sphericalEqui:(BOOL)sphEqui;
- (void)genEquiAt:(NSString*)fileName withHeight:(NSUInteger)height andWidth:(NSUInteger)width andMaxWidth:(NSUInteger)maxWidth;
- (void)genEquiAt:(NSString*)fileName withHeight:(NSUInteger)height andWidth:(NSUInteger)width andMaxWidth:(NSUInteger)maxWidth centerAt:(CGFloat)degrees;
- (void)genEquiAt:(NSString*)fileName withHeight:(NSUInteger)height andWidth:(NSUInteger)width andMaxWidth:(NSUInteger)maxWidth zenithLogo:(BOOL)zEnabled nadirLogo:(BOOL)nEnabled;
- (void)genEquiAt:(NSString*)fileName withHeight:(NSUInteger)height andWidth:(NSUInteger)width andMaxWidth:(NSUInteger)maxWidth centerAt:(CGFloat)degrees zenithLogo:(BOOL)zEnabled nadirLogo:(BOOL)nEnabled;
- (void)genEquiAt:(NSString*)fileName withHeight:(NSUInteger)height andWidth:(NSUInteger)width andMaxWidth:(NSUInteger)maxWidth centerAt:(CGFloat)degrees zenithLogo:(BOOL)zEnabled nadirLogo:(BOOL)nEnabled sphericalEqui:(BOOL)sphEqui;

// returns 4 double values represent the spherical equi crop parameters normalized between [0-0.5]
// under the following keys: @"left", @"top", @"right", @"bottom"
- (NSDictionary *)getSphericalEquiCropParameters;

- (NSDictionary *)getIndicators;
- (void)setSafeZoneLowerBound:(double)lb andUpperBound:(double)ub; //if you don't know what it does, don't call this function. Must be called as early as possible, BEFORE start shooting.
- (void)resetSafeZone;

@end

@interface ShooterView : UIView

@property (nonatomic, readonly, getter = get_exposureControls) NSArray *exposureControls;
@property (nonatomic, readonly) UIButton *cameraToggleButton;

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
- (void)setExportOriFolder:(NSString*)dir;//nil to save in camera roll, else saves with filename {dir}/{[[NSDate date] description]]}.jpg

- (void)setContinuousMode:(bool)enabled; // while using continuous rotator it is recommended to enable continuous mode.

#ifdef HD
- (BOOL)canShootHD;//tells whether the device supports HD mode
- (void)setResolutionSD:(id)sender;//standard definition - should be called before startShooting, must not be called while shooting
- (void)setResolutionHD:(id)sender;//    high definition - should be called before startShooting, must not be called while shooting
#endif
- (void)useWideAngleLens;//deprecated: use setLens instead.
- (void)useStandardCameraLens;//deprecated: use setLens instead.

@end




#endif
