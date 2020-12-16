#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "CBPeripheral+MKTracker.h"
#import "MKContactTrackerSDK.h"
#import "MKTrackerAdopter.h"
#import "MKTrackerCentralManager.h"
#import "MKTrackerInterface+MKConfig.h"
#import "MKTrackerInterface.h"
#import "MKTrackerModel.h"
#import "MKTrackerOperation.h"
#import "MKTrackerOperationDataAdopter.h"
#import "MKTrackerOperationID.h"
#import "MKTrackerPeripheral.h"
#import "MKTrackerSDKDefines.h"

FOUNDATION_EXPORT double MKTrackerPlusSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char MKTrackerPlusSDKVersionString[];

