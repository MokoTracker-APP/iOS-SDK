//
//  MKLowPowerNoteSlider.m
//  MKEnhancedTracker
//
//  Created by aa on 2020/12/7.
//

#import "MKLowPowerNoteSlider.h"

@implementation MKLowPowerNoteSlider

- (instancetype)init{
    if (self = [super init]) {
        [self setThumbImage:[LOADIMAGE(@"sensitivityThumbIcon", @"png") resizableImageWithCapInsets:UIEdgeInsetsZero]
                   forState:UIControlStateNormal];
        [self setThumbImage:[LOADIMAGE(@"sensitivityThumbIcon", @"png") resizableImageWithCapInsets:UIEdgeInsetsZero]
                   forState:UIControlStateHighlighted];
        [self setMinimumTrackImage:[LOADIMAGE(@"sensitivityMaxTrackIcon", @"png") resizableImageWithCapInsets:UIEdgeInsetsZero]
                          forState:UIControlStateNormal];
        [self setMaximumTrackImage:[LOADIMAGE(@"sensitivityMinTrackIcon", @"png") resizableImageWithCapInsets:UIEdgeInsetsZero] forState:UIControlStateNormal];
    }
    return self;
}

@end
