#import <Cephei/HBPreferences.h>
#import "SparkColourPickerUtils.h"

HBPreferences *pref;

BOOL disableNotificationsFromShortcuts;
BOOL oneListNotifications;
BOOL easyNotificationSwiping;
BOOL hideDNDNotification;
BOOL hideNoOlderNotifications;
BOOL showExactTimePassed;

BOOL colorizeBackground;
BOOL customBackgroundColorEnabled;
NSString *customBackgroundColorString;
UIColor *customBackgroundColor;

BOOL colorizeBorder;
BOOL customBorderColorEnabled;
NSString *customBorderColorString;
UIColor *customBorderColor;

NSInteger notificationCorner;
NSInteger borderWidth;

@interface PLPlatterHeaderContentView: UIView
- (void)_updateTextAttributesForDateLabel;
@property(getter=_titleLabel, nonatomic, readonly) UILabel *titleLabel;
@property(getter=_dateLabel, nonatomic, readonly) UILabel *dateLabel;
@end

@interface PLPlatterView : UIView
@end

@interface PLTitledPlatterView : PLPlatterView
@end

@interface NCNotificationContentView: UIView
@property(setter=_setPrimaryLabel:, getter=_primaryLabel, nonatomic, retain) UILabel *primaryLabel;                         //@synthesize primaryLabel=_primaryLabel - In the implementation block
@property(setter=_setPrimarySubtitleLabel:, getter=_primarySubtitleLabel, nonatomic, retain) UILabel *primarySubtitleLabel; //@synthesize primarySubtitleLabel=_primarySubtitleLabel - In the implementation block
@property(getter=_secondaryLabel, nonatomic, readonly) UILabel *secondaryLabel;
@end

@interface NCNotificationRequest : NSObject
- (NSString *)sectionIdentifier;
@end

@interface BSUIRelativeDateLabel
@property(assign, nonatomic) NSString *text;
- (void)sizeToFit;
@end

@interface NCNotificationListStalenessEventTracker : NSObject
@end

@interface NCNotificationMasterList : NSObject
@property (nonatomic,retain) NCNotificationListStalenessEventTracker * notificationListStalenessEventTracker;
-(void)setNotificationListStalenessEventTracker:(NCNotificationListStalenessEventTracker *)arg1;
-(NCNotificationListStalenessEventTracker *)notificationListStalenessEventTracker;
-(BOOL)_isNotificationRequestForIncomingSection:(id)arg1;
-(BOOL)_isNotificationRequestForHistorySection:(id)arg1;
-(void)_migrateNotificationsFromList:(id)arg1 toList:(id)arg2 passingTest:(/*^block*/id)arg3 hideToList:(BOOL)arg4 clearRequests:(BOOL)arg5;
-(void)migrateNotifications;
@end

@interface NCNotificationShortLookView: PLTitledPlatterView
@property(nonatomic, copy) NSArray *iconButtons;
@end

@interface NCNotificationLongLookView : UIView
@property(nonatomic, copy) NSArray *iconButtons;
@property(nonatomic, copy) UIView *customContentView;
@end

@interface NCNotificationViewController : UIViewController
@end

@interface MTMaterialView : UIView
@property(nonatomic, retain) NSString *groupNameBase;
@end

@interface NCNotificationListCellActionButton : UIControl
@property(nonatomic, retain) MTMaterialView *backgroundView;
@end

@interface NCNotificationListCellActionButtonsView : UIView
@property(nonatomic, retain) UIStackView *buttonsStackView;
@end

@interface NCNotificationViewControllerView : UIView
@property(assign, nonatomic) PLPlatterView *contentView;
@end

@interface NCNotificationShortLookViewController : UIViewController
@end

@interface NCNotificationListCell : UICollectionViewCell
@property(nonatomic, retain) NCNotificationViewController *contentViewController;
@property(nonatomic, retain) NCNotificationListCellActionButtonsView *leftActionButtonsView;
@end

@interface NCNotificationListSectionRevealHintView : UIView
@property (nonatomic, assign, readwrite, getter = isHidden) BOOL hidden;
@end