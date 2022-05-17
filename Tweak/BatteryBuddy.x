//
//  BatteryBuddy.x
//  BatteryBuddy
//
//  Created by Alexandra (@thatcluda)
//

#import "BatteryBuddy.h"

%group BatteryBuddy

%hook _UIBatteryView

- (BOOL)_shouldShowBolt {
	return NO;
}

- (UIColor *)fillColor {
	return [%orig colorWithAlphaComponent:0.25];
}

- (CGFloat)chargePercent { // update face corresponding the battery percentage
	CGFloat orig = %orig;
	int actualPercentage = orig * 100;

	if (actualPercentage <= 20 && !isCharging)
		[statusBarBatteryIconView setImage:[UIImage imageWithContentsOfFile:@"/Library/BatteryBuddy/statusBarSad.png"]];
	else if (actualPercentage <= 49 && !isCharging)
		[statusBarBatteryIconView setImage:[UIImage imageWithContentsOfFile:@"/Library/BatteryBuddy/statusBarNeutral.png"]];
	else if (actualPercentage > 49 && !isCharging)
		[statusBarBatteryIconView setImage:[UIImage imageWithContentsOfFile:@"/Library/BatteryBuddy/statusBarHappy.png"]];
	else if (isCharging)
		[statusBarBatteryIconView setImage:[UIImage imageWithContentsOfFile:@"/Library/BatteryBuddy/statusBarHappy.png"]];

	[self updateIconColor];

	return orig;
}

- (long long)chargingState { // refresh icons when charging state changed
	long long orig = %orig;

	if (orig == 1) isCharging = YES;
	else isCharging = NO;

	[self refreshIcon];
	
	return orig;
}

- (void)_updateFillLayer { // update the icon
	%orig;
	[self chargingState];
}

%new
- (void)refreshIcon {
	// remove existing images
	statusBarBatteryIconView = nil;
	statusBarBatteryChargerView = nil;
	for (UIImageView* imageView in [self subviews]) {
		[imageView removeFromSuperview];
	}

	// face
	if (!statusBarBatteryIconView) {
		statusBarBatteryIconView = [[UIImageView alloc] initWithFrame:[self bounds]];
		[statusBarBatteryIconView setContentMode:UIViewContentModeScaleAspectFill];
		[statusBarBatteryIconView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		if (![statusBarBatteryIconView isDescendantOfView:self]) [self addSubview:statusBarBatteryIconView];
	}

	// charger
	if (!statusBarBatteryChargerView && isCharging) {
		statusBarBatteryChargerView = [[UIImageView alloc] initWithFrame:[self bounds]];
		[statusBarBatteryChargerView setContentMode:UIViewContentModeScaleAspectFill];
		[statusBarBatteryChargerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[statusBarBatteryChargerView setImage:[UIImage imageWithContentsOfFile:@"/Library/BatteryBuddy/statusBarCharger.png"]];
		if (![statusBarBatteryChargerView isDescendantOfView:self]) [self addSubview:statusBarBatteryChargerView];
	}

	[self chargePercent];
}

%new
- (void)updateIconColor {
	statusBarBatteryIconView.image = [statusBarBatteryIconView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	statusBarBatteryChargerView.image = [statusBarBatteryChargerView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	if (![[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
		[statusBarBatteryIconView setTintColor:[UIColor labelColor]];
		[statusBarBatteryChargerView setTintColor:[UIColor labelColor]];
	} else {
		[statusBarBatteryIconView setTintColor:[UIColor blackColor]];
		[statusBarBatteryChargerView setTintColor:[UIColor blackColor]];
	}
}

%end

%hook CSBatteryFillView

- (void)didMoveToWindow { // add lockscreen battery icons
	%orig;

	[[self superview] setClipsToBounds:NO];

	// face
	if (!lockscreenBatteryIconView) {
		lockscreenBatteryIconView = [[UIImageView alloc] initWithFrame:[self bounds]];
		[lockscreenBatteryIconView setContentMode:UIViewContentModeScaleAspectFill];
		[lockscreenBatteryIconView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[lockscreenBatteryIconView setImage:[UIImage imageWithContentsOfFile:@"/Library/BatteryBuddy/lockscreenHappy.png"]];
	}
	lockscreenBatteryIconView.image = [lockscreenBatteryIconView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	[lockscreenBatteryIconView setTintColor:[UIColor whiteColor]];
	if (![lockscreenBatteryIconView isDescendantOfView:[self superview]]) [[self superview] addSubview:lockscreenBatteryIconView];

	// charger
	if (!lockscreenBatteryChargerView) {
		lockscreenBatteryChargerView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.origin.x - 25, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height)];
		[lockscreenBatteryChargerView setContentMode:UIViewContentModeScaleAspectFill];
		[lockscreenBatteryChargerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[lockscreenBatteryChargerView setImage:[UIImage imageWithContentsOfFile:@"/Library/BatteryBuddy/lockscreenCharger.png"]];
	}
	lockscreenBatteryChargerView.image = [lockscreenBatteryChargerView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	[lockscreenBatteryChargerView setTintColor:[UIColor whiteColor]];
	if (![lockscreenBatteryChargerView isDescendantOfView:[self superview]]) [[self superview] addSubview:lockscreenBatteryChargerView];
}

%end

%end

%ctor {
	%init(BatteryBuddy);
}
