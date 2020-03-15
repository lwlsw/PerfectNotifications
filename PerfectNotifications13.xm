#include "PerfectNotifications13.h"

// --------------------------------------------------------------------------
// --------------------- METHODS FOR CHOOSING COLORS ------------------------
// --------------------------------------------------------------------------

// Taken From https://stackoverflow.com/questions/11598043/get-slightly-lighter-and-darker-color-from-uicolor

static UIColor *getReadableTextColorBasedOnBackgroundColor(UIColor *backgroundColor)
{
    int d = 0;
	const CGFloat *rgb = CGColorGetComponents(backgroundColor.CGColor);
    double luminance = ( 0.299 * rgb[0] + 0.587 * rgb[1] + 0.114 * rgb[2]) / 255;

    if (luminance > 0.5) d = 0;
    else d = 255;

    return  [UIColor colorWithRed: d green: d blue: d alpha: 1.0];
}

static UIColor *lighterColorForColor(UIColor *c)
{
    CGFloat r, g, b, a;
	[c getRed: &r green: &g blue: &b alpha: &a];
    return [UIColor colorWithRed: MIN(r + 0.2, 1.0) green: MIN(g + 0.2, 1.0) blue: MIN(b + 0.2, 1.0) alpha: a];
}

static UIColor *darkerColorForColor(UIColor *c)
{
    CGFloat r, g, b, a;
    [c getRed: &r green: &g blue: &b alpha: &a];
    return [UIColor colorWithRed: MAX(r - 0.2, 0.0) green: MAX(g - 0.2, 0.0) blue: MAX(b - 0.2, 0.0) alpha: a];
}

static UIColor *getContrastColorBasedOnBackgroundColor(UIColor *backgroundColor)
{
	const CGFloat *rgb = CGColorGetComponents(backgroundColor.CGColor);
    double luminance = ( 0.299 * rgb[0] + 0.587 * rgb[1] + 0.114 * rgb[2]) / 255;

    if (luminance <= 0.5) return lighterColorForColor(backgroundColor);
    else return darkerColorForColor(backgroundColor);
}

@implementation UIImage (UIImageAverageColorAddition)

// Taken from @alextrob: https://github.com/alextrob/UIImageAverageColor

- (UIColor*)mergedColor
{
	CGSize size = {1, 1};
	UIGraphicsBeginImageContext(size);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetInterpolationQuality(ctx, kCGInterpolationMedium);
	[self drawInRect: (CGRect){.size = size} blendMode: kCGBlendModeCopy alpha: 1];
	uint8_t *data = (uint8_t *)CGBitmapContextGetData(ctx);
	UIColor *color = [UIColor colorWithRed: data[2] / 255.0f green: data[1] / 255.0f blue: data[0] / 255.0f alpha: 1];
	UIGraphicsEndImageContext();
	return color;
}

@end

// ------------------------------ DISABLE SHORTCUTS NOTIFICATIONS ------------------------------

%group disableNotificationsFromShortcutsGroup

	%hook NCNotificationDispatcher

	- (void)postNotificationWithRequest: (NCNotificationRequest*)arg1
	{
		if(![[arg1 sectionIdentifier] isEqualToString: @"com.apple.shortcuts"]) %orig;
	}

	%end

%end

// ------------------------------ ONE LIST OF NOTIFICATIONS ------------------------------

%group oneListNotificationsGroup

	%hook NCNotificationListSectionRevealHintView

	- (void)layoutSubviews
	{

	}

	%end

	%hook NCNotificationMasterList

	- (void)setNotificationListStalenessEventTracker: (NCNotificationListStalenessEventTracker*)arg1
	{

	}

	- (NCNotificationListStalenessEventTracker*)notificationListStalenessEventTracker
	{
		return nil;
	}

	- (BOOL)_isNotificationRequestForIncomingSection: (id)arg1
	{
		return YES;
	}

	- (BOOL)_isNotificationRequestForHistorySection: (id)arg1
	{
		return NO;
	}

	- (void)_migrateNotificationsFromList: (id)arg1 toList: (id)arg2 passingTest: (id)arg3 hideToList: (BOOL)arg4 clearRequests: (BOOL)arg5
	{

	}

	- (void)migrateNotifications
	{

	}

	%end

%end

// ------------------------------ EASY NOTOFICATION SWIPING ------------------------------

%group easyNotificationSwipingGroup

	%hook NCNotificationListCell

	- (double)_actionButtonTriggerDistanceForView: (id)arg
	{
		return 0;
	}

	%end

%end

// ------------------------------ HIDE DND NOTIFICATION ------------------------------

%group hideDNDNotificationGroup

	%hook DNDNotificationsService

	- (void)_queue_postOrRemoveNotificationWithUpdatedBehavior: (bool)arg1 significantTimeChange: (bool)arg2
	{
		
	}

	%end

%end

// ------------------------------ HIDE "NO OLDER NOTIFICATIONS" TEXT ------------------------------

%group hideNoOlderNotificationsGroup

	%hook NCNotificationListSectionRevealHintView

	-(void)setFrame:(CGRect)arg1
	{
		self.hidden = YES;
	}

	%end

%end

// ------------------------------ SHOW EXACT TIME PASSED IN NOTIFICATIONS ------------------------------

// ORIGINAL TWEAK @gilshahar7: https://github.com/gilshahar7/ExactTime

%group showExactTimePassedGroup

	%hook PLPlatterHeaderContentView

	-(void)_updateTextAttributesForDateLabel
	{
		%orig;
		
		NSDate *date = MSHookIvar<NSDate*>(self, "_date");
		NSInteger format = MSHookIvar<NSInteger>(self, "_dateFormatStyle");

		if(date && format == 1)
		{
			BSUIRelativeDateLabel *dateLabel = MSHookIvar<BSUIRelativeDateLabel*> (self, "_dateLabel");
			int timeSinceNow = (int)[date timeIntervalSinceNow];

			NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
			[dateFormatter setDateFormat: @"HH:mm"];
			
			bool isFuture = false;
			if (timeSinceNow > 0) isFuture = true;
			else timeSinceNow = timeSinceNow * -1;
			
			int minutes = (timeSinceNow % 3600) / 60;
			int hours = timeSinceNow / 3600;

			if(hours != 0 || minutes != 0)
			{
				dateLabel.text = @"";
				if(isFuture) dateLabel.text = [dateLabel.text stringByAppendingString: [NSString stringWithFormat: @"in"]];
				if(hours != 0) dateLabel.text = [dateLabel.text stringByAppendingString: [NSString stringWithFormat: @" %ih", hours]];
				if(minutes != 0) dateLabel.text = [dateLabel.text stringByAppendingString: [NSString stringWithFormat: @" %im", minutes]];
				if(!isFuture) dateLabel.text = [dateLabel.text stringByAppendingString: [NSString stringWithFormat: @" ago"]];
			}
			dateLabel.text = [[dateLabel.text stringByAppendingString: @" • "] stringByAppendingString: [dateFormatter stringFromDate: date]];
			
			[dateLabel sizeToFit];
		}
	}
		
	-(void)dateLabelDidChange:(id)arg1
	{
		%orig(arg1);
		[self _updateTextAttributesForDateLabel];
	}

	%end

%end

// --------------------------------------------------------------------------
// ------------------ COLORIZE NOTIFICATIONS & BANNERS ----------------------
// --------------------------------------------------------------------------

%group colorizeNotificationsGroup

	// Notifications on LockScreen and on Notifation Center
	%hook NCNotificationShortLookView

	- (void)drawRect: (CGRect)rect
	{
		%orig(rect);

		UIColor *backgroundColor;
		UIColor *borderColor;
		UIColor *textColor;

		if(colorizeBackground)
		{
			if(customBackgroundColorEnabled) backgroundColor = customBackgroundColor;
			else backgroundColor = [((UIButton*)self.iconButtons[0]).currentImage mergedColor];

			textColor = getReadableTextColorBasedOnBackgroundColor(backgroundColor);
			NCNotificationContentView *notificationContentView = MSHookIvar<NCNotificationContentView*>(self, "_notificationContentView");
			notificationContentView.primaryLabel.textColor = textColor;
			notificationContentView.primarySubtitleLabel.textColor = textColor;
		}
		if(colorizeBorder)
		{
			if(customBorderColorEnabled) borderColor = customBorderColor;
			else if(backgroundColor) borderColor = getContrastColorBasedOnBackgroundColor(backgroundColor);
			else borderColor = getContrastColorBasedOnBackgroundColor([((UIButton*)self.iconButtons[0]).currentImage mergedColor]);
		}

		for (UIView *sbview in [self subviews])
		{
			if([sbview isKindOfClass: %c(MTMaterialView)])
			{
				MTMaterialView *subview = (MTMaterialView*)sbview;

				subview.clipsToBounds = YES;
				subview.layer.cornerRadius = notificationCorner;
				
				if(colorizeBackground) subview.backgroundColor = backgroundColor;
				if(colorizeBorder)
				{
					subview.layer.borderColor = borderColor.CGColor;
					subview.layer.borderWidth = borderWidth;
				}
			}
		}
	}

	%end

	// When you 3D touch a notification
	%hook NCNotificationLongLookView

	- (void)drawRect: (CGRect)rect
	{
		%orig;

		if(colorizeBackground)
		{
			PLPlatterHeaderContentView *headerContentView = MSHookIvar<PLPlatterHeaderContentView*>(self, "_headerContentView");
			NCNotificationContentView *notificationContentView = MSHookIvar<NCNotificationContentView*>(self, "_notificationContentView");

			UIColor *backgroundColor;
			if(customBackgroundColorEnabled) backgroundColor = customBackgroundColor;
			else backgroundColor = [((UIButton*)self.iconButtons[0]).currentImage mergedColor];

			UIColor *textColor = getReadableTextColorBasedOnBackgroundColor(backgroundColor);

			headerContentView.titleLabel.textColor = textColor;
			notificationContentView.primaryLabel.textColor = textColor;
			notificationContentView.primarySubtitleLabel.textColor = textColor;

			headerContentView.clipsToBounds = YES;
			notificationContentView.clipsToBounds = YES;
			
			headerContentView.layer.cornerRadius = 12;
			notificationContentView.layer.cornerRadius = 12;

			headerContentView.backgroundColor = backgroundColor;
			notificationContentView.backgroundColor = backgroundColor;
		}
	}

	%end

	// Colorize the buttons left and right when you swipe a notification
	%hook NCNotificationListCellActionButtonsView

	- (void)layoutSubviews
	{
		%orig;
		if (!self) return;

		NCNotificationListCell *ncNotificationListCell = (NCNotificationListCell*)self.superview.superview.superview;
		NCNotificationShortLookView *ncNotificationShortlookView = ((NCNotificationShortLookView*)((NCNotificationViewControllerView*)ncNotificationListCell.contentViewController.view).contentView);

		UIColor *backgroundColor;
		UIColor *borderColor;

		if(colorizeBackground)
		{
			if(customBackgroundColorEnabled) backgroundColor = customBackgroundColor;
			else backgroundColor = [((UIButton*)ncNotificationShortlookView.iconButtons[0]).currentImage mergedColor];
		}
		if(colorizeBorder)
		{
			if(customBorderColorEnabled) borderColor = customBorderColor;
			else if(backgroundColor) borderColor = getContrastColorBasedOnBackgroundColor(backgroundColor);
			else borderColor = getContrastColorBasedOnBackgroundColor([((UIButton*)ncNotificationShortlookView.iconButtons[0]).currentImage mergedColor]);
		}

		for(NCNotificationListCellActionButton *button in self.buttonsStackView.arrangedSubviews)
		{
			MTMaterialView *backgroundView = (MTMaterialView*)button.backgroundView;
			
			if (!backgroundView || !backgroundColor) return;

			backgroundView.clipsToBounds = YES;
			backgroundView.layer.cornerRadius = notificationCorner;
			
			if(colorizeBackground) backgroundView.backgroundColor = backgroundColor;
			if(colorizeBorder)
			{
				backgroundView.layer.borderColor = borderColor.CGColor;
				backgroundView.layer.borderWidth = borderWidth;
			}
		}
	}

	%end

%end

%ctor
{
	@autoreleasepool
	{
		pref = [[HBPreferences alloc] initWithIdentifier: @"com.johnzaro.perfectnotifications13prefs"];
		[pref registerDefaults:
		@{
			@"disableNotificationsFromShortcuts": @NO,
			@"oneListNotifications": @NO,
			@"easyNotificationSwiping": @NO,
			@"hideDNDNotification": @NO,
			@"hideNoOlderNotifications": @NO,
			@"showExactTimePassed": @NO,
			@"colorizeBackground": @NO,
			@"customBackgroundColorEnabled": @NO,
			@"colorizeBorder": @NO,
			@"customBorderColorEnabled": @NO,
			@"borderWidth": @3,
			@"notificationCorner": @12
    	}];

		disableNotificationsFromShortcuts = [pref boolForKey: @"disableNotificationsFromShortcuts"];
		oneListNotifications = [pref boolForKey: @"oneListNotifications"];
		easyNotificationSwiping = [pref boolForKey: @"easyNotificationSwiping"];
		hideDNDNotification = [pref boolForKey: @"hideDNDNotification"];
		hideNoOlderNotifications = [pref boolForKey: @"hideNoOlderNotifications"];
		showExactTimePassed = [pref boolForKey: @"showExactTimePassed"];
		colorizeBackground = [pref boolForKey: @"colorizeBackground"];
		customBackgroundColorEnabled = [pref boolForKey: @"customBackgroundColorEnabled"];
		colorizeBorder = [pref boolForKey: @"colorizeBorder"];
		customBorderColorEnabled = [pref boolForKey: @"customBorderColorEnabled"];
		borderWidth = [pref integerForKey: @"borderWidth"];
		notificationCorner = [pref integerForKey: @"notificationCorner"];

		if(customBackgroundColorEnabled || customBorderColorEnabled)
		{
			NSDictionary *preferencesDictionary = [NSDictionary dictionaryWithContentsOfFile: @"/var/mobile/Library/Preferences/com.johnzaro.perfectnotifications13prefs.colors.plist"];
			if(preferencesDictionary)
			{
				customBackgroundColorString = [preferencesDictionary objectForKey: @"customBackgroundColor"];
				customBorderColorString = [preferencesDictionary objectForKey: @"customBorderColor"];
			}
			
			customBackgroundColor = [SparkColourPickerUtils colourWithString: customBackgroundColorString withFallback: @"#FF9400"];
			customBorderColor = [SparkColourPickerUtils colourWithString: customBorderColorString withFallback: @"#FF9400"];
		}

		if(disableNotificationsFromShortcuts) %init(disableNotificationsFromShortcutsGroup);
		if(oneListNotifications) %init(oneListNotificationsGroup);
		if(easyNotificationSwiping) %init(easyNotificationSwipingGroup);
		if(hideDNDNotification) %init(hideDNDNotificationGroup);
		if(hideNoOlderNotifications) %init(hideNoOlderNotificationsGroup);
		if(showExactTimePassed) %init(showExactTimePassedGroup);
		%init(colorizeNotificationsGroup);
	}
}
