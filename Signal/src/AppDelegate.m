#import "AppDelegate.h"
#import "AppStoreRating.h"
#import "CategorizingLogger.h"
#import "CodeVerificationViewController.h"
#import "OWSContactsManager.h"
#import "DebugLogger.h"
#import "Environment.h"
#import "NotificationsManager.h"
#import "PreferencesUtil.h"
#import "PushManager.h"
#import "Release.h"
#import "TSAccountManager.h"
#import "TSMessagesManager.h"
#import "TSPreKeyManager.h"
#import "TSSocketManager.h"
#import "TextSecureKitEnv.h"
#import "VersionMigrations.h"
#import "UIColor+HexValue.h"
#import "BaseWindow.h"
#import <Reachability/Reachability.h>
#import "SignalsNavigationController.h"
#import <DTTJailbreakDetection/DTTJailbreakDetection.h>
#import "PasscodeHelper.h"
#import "MedxPasscodeManager.h"
#import "TOPasscodeViewController.h"
#ifdef TESTFLIGHT
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#endif

static NSString *const kStoryboardName                  = @"Storyboard";
static NSString *const kInitialViewControllerIdentifier = @"UserInitialViewController";
static NSString *const kURLSchemeSGNLKey                = @"sgnl";
static NSString *const kURLHostVerifyPrefix             = @"verify";

@interface AppDelegate ()

@property (nonatomic, retain) UIWindow *blankWindow;
@property (nonatomic, copy) void (^onUnlock)();
@property PasscodeHelper *passcodeHelper;

@end

@implementation AppDelegate

#pragma mark Detect updates - perform migrations

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupAppearance];
    [[PushManager sharedManager] registerPushKitNotificationFuture];

    if (getenv("runningTests_dontStartApp")) {
        return YES;
    }

    // Initializing logger
    CategorizingLogger *logger = [CategorizingLogger categorizingLogger];
    [logger addLoggingCallback:^(NSString *category, id details, NSUInteger index){
    }];
    
#ifdef TESTFLIGHT
    [Fabric with:@[[Crashlytics class]]];
#endif

    // Setting up environment
    [Environment setCurrent:[Release releaseEnvironmentWithLogging:logger]];

    if ([TSAccountManager isRegistered]) {
        [Environment.getCurrent.contactsManager doAfterEnvironmentInitSetup];
    }
    [Environment.getCurrent initCallListener];

    [self setupTSKitEnv];

    BOOL loggingIsEnabled;

#ifdef DEBUG
    // Specified at Product -> Scheme -> Edit Scheme -> Test -> Arguments -> Environment to avoid things like
    // the phone directory being looked up during tests.
    loggingIsEnabled = TRUE;
    [DebugLogger.sharedLogger enableTTYLogging];
#elif RELEASE
    loggingIsEnabled = Environment.preferences.loggingIsEnabled;
#endif
    [self verifyBackgroundBeforeKeysAvailableLaunch];

    if (loggingIsEnabled) {
        [DebugLogger.sharedLogger enableFileLogging];
    }

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kStoryboardName bundle:[NSBundle mainBundle]];
    UIViewController *viewController =
        [storyboard instantiateViewControllerWithIdentifier:kInitialViewControllerIdentifier];

    self.window                    = [[BaseWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
    
    self.passcodeHelper = [[PasscodeHelper alloc] init];

    [VersionMigrations performUpdateCheck]; // this call must be made after environment has been initialized because in
                                            // general upgrade may depend on environment

    // Accept push notification when app is not open
    NSDictionary *remoteNotif = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotif) {
        DDLogInfo(@"Application was launched by tapping a push notification.");
        [self application:application didReceiveRemoteNotification:remoteNotif];
    }

    [self prepareScreenshotProtection];
    
    // jailbreak
    if ([DTTJailbreakDetection isJailbroken]) {
        self.window.hidden = YES;
        self.blankWindow.hidden = NO;
        [self.blankWindow makeKeyAndVisible];
        NSLog(@"device is jailbroken");
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                 message:@"This app is only supported on unmodified versions of iOS."
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *action) {
                                                                 exit(0);
                                                             }];
        [alertController addAction:cancelAction];
        [self.blankWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
        return YES;
    }
    
    // lockout
    if ([MedxPasscodeManager isLockoutEnabled]) {
        // stop loading app as user is locked out
        self.blankWindow.hidden = NO;
        NSLog(@"app is locked out");
        
        // show alert about lockout
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"The app has been disabled due to too many invalid passcode attempts. Please delete and reinstall the app to regain access" preferredStyle:UIAlertControllerStyleAlert];
        [self.blankWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
        return YES;
    }
    
    if ([MedxPasscodeManager isPasscodeEnabled]) {
        [self removeScreenProtection];
    }

    if ([TSAccountManager isRegistered]) {
        if (application.applicationState == UIApplicationStateInactive) {
            [TSSocketManager becomeActiveFromForeground];
        } else if (application.applicationState == UIApplicationStateBackground) {
            [TSSocketManager becomeActiveFromBackgroundExpectMessage:NO];
        } else {
            DDLogWarn(@"The app was launched in an unknown way");
        }

        [[PushManager sharedManager] validateUserNotificationSettings];
        [TSPreKeyManager refreshPreKeys];
    }

    [AppStoreRating setupRatingLibrary];
    
    // setup activity timeout
    [[NSNotificationCenter defaultCenter] addObserverForName:@"ActivityTimeoutExceeded" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self presentPasscodeEntry];
    }];
    
    // setup reachability
    [self setupReachability];
    
    return YES;
}

- (void)setupTSKitEnv {
    [TextSecureKitEnv sharedEnv].contactsManager = [Environment getCurrent].contactsManager;
    [[TSStorageManager sharedManager] setupDatabase];
    [TextSecureKitEnv sharedEnv].notificationsManager = [[NotificationsManager alloc] init];
}

- (void)setupReachability {
    // Allocate a reachability object
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Set the blocks
    reach.reachableBlock = ^(Reachability *reachability) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"REACHABLE");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"InternetNowReachable" object:nil];
        });
    };
    
    reach.unreachableBlock = ^(Reachability *reachability) {
        NSLog(@"UNREACHABLE");
    };
    
    [reach startNotifier];
}

- (void)application:(UIApplication *)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [PushManager.sharedManager.pushNotificationFutureSource trySetResult:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
#ifdef DEBUG
    DDLogWarn(@"We're in debug mode, and registered a fake push identifier");
    [PushManager.sharedManager.pushNotificationFutureSource trySetResult:@"aFakePushIdentifier"];
#else
    [PushManager.sharedManager.pushNotificationFutureSource trySetFailure:error];
#endif
}

- (void)application:(UIApplication *)application
    didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [PushManager.sharedManager.userNotificationFutureSource trySetResult:notificationSettings];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    if ([url.scheme isEqualToString:kURLSchemeSGNLKey]) {
        if ([url.host hasPrefix:kURLHostVerifyPrefix] && ![TSAccountManager isRegistered]) {
            id signupController = [Environment getCurrent].signUpFlowNavigationController;
            if ([signupController isKindOfClass:[UINavigationController class]]) {
                UINavigationController *navController = (UINavigationController *)signupController;
                UIViewController *controller          = [navController.childViewControllers lastObject];
                if ([controller isKindOfClass:[CodeVerificationViewController class]]) {
                    CodeVerificationViewController *cvvc = (CodeVerificationViewController *)controller;
                    NSString *verificationCode           = [url.path substringFromIndex:1];

                    cvvc.challengeTextField.text = verificationCode;
                    [cvvc verifyChallengeAction:nil];
                } else {
                    DDLogWarn(@"Not the verification view controller we expected. Got %@ instead",
                              NSStringFromClass(controller.class));
                }
            }
        } else {
            DDLogWarn(@"Application opened with an unknown URL action: %@", url.host);
        }
    } else {
        DDLogWarn(@"Application opened with an unknown URL scheme: %@", url.scheme);
    }
    return NO;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if (getenv("runningTests_dontStartApp")) {
        return;
    }
    // prevent becoming active if locked out or jailbroken
    if ([DTTJailbreakDetection isJailbroken] || [MedxPasscodeManager isLockoutEnabled]) { return; }
    
    if ([TSAccountManager isRegistered]) {
        // We're double checking that the app is active, to be sure since we can't verify in production env due to code
        // signing.
        [TSSocketManager becomeActiveFromForeground];
        [[Environment getCurrent].contactsManager verifyABPermission];
    }

    [self removeScreenProtection];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    UIBackgroundTaskIdentifier __block bgTask = UIBackgroundTaskInvalid;
    bgTask                                    = [application beginBackgroundTaskWithExpirationHandler:^{

    }];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      if ([TSAccountManager isRegistered]) {
          dispatch_sync(dispatch_get_main_queue(), ^{
              if (![[UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController isKindOfClass:[TOPasscodeViewController class]]) {
                  [self protectScreen];
              }
            [[[Environment getCurrent] signalsViewController] updateInboxCountLabel];
          });
          [TSSocketManager resignActivity];
      }

      [application endBackgroundTask:bgTask];
      bgTask = UIBackgroundTaskInvalid;
    });
}

- (void)application:(UIApplication *)application
    performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem
               completionHandler:(void (^)(BOOL succeeded))completionHandler {
    BOOL passcodeNeeded = [self removeScreenProtection];
    if (passcodeNeeded) {
        // pin needs to be input before proceeding so this action is stored for later
        self.onUnlock = ^void() {
            [[Environment getCurrent].signalsViewController composeNew];
        };
        completionHandler(NO);
        return;
    }
    if ([TSAccountManager isRegistered]) {
        [[Environment getCurrent].signalsViewController composeNew];
        completionHandler(YES);
    } else {
        UIAlertController *controller =
            [UIAlertController alertControllerWithTitle:NSLocalizedString(@"REGISTER_CONTACTS_WELCOME", nil)
                                                message:NSLocalizedString(@"REGISTRATION_RESTRICTED_MESSAGE", nil)
                                         preferredStyle:UIAlertControllerStyleAlert];

        [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *_Nonnull action){

                                                     }]];
        [[Environment getCurrent]
                .signalsViewController.presentedViewController presentViewController:controller
                                                                            animated:YES
                                                                          completion:^{
                                                                            completionHandler(NO);
                                                                          }];
    }
}

- (void)prepareScreenshotProtection {
    self.blankWindow = ({
        UIWindow *window              = [[UIWindow alloc] initWithFrame:self.window.bounds];
        window.hidden                 = YES;
        window.opaque                 = YES;
        window.userInteractionEnabled = YES;
        window.windowLevel            = CGFLOAT_MAX;
        window.backgroundColor        = UIColor.ows_materialBlueColor;

//        UIViewController *vc = [[UIStoryboard storyboardWithName:@"Launch Screen" bundle:nil] instantiateInitialViewController];


// There appears to be no more reliable way to get the launchscreen image from an asset bundle
        NSDictionary *dict = @{
            @"320x480" : @"LaunchImage-700",
            @"320x568" : @"LaunchImage-700-568h",
            @"375x667" : @"LaunchImage-800-667h",
            @"414x736" : @"LaunchImage-800-Portrait-736h"
        };

        NSString *key = [NSString stringWithFormat:@"%dx%d",
                                                   (int)[UIScreen mainScreen].bounds.size.width,
                                                   (int)[UIScreen mainScreen].bounds.size.height];
        UIImage *launchImage = [UIImage imageNamed:dict[key]];
        UIImageView *imgView = [[UIImageView alloc] initWithImage:launchImage];
        UIViewController *vc = [[UIViewController alloc] initWithNibName:nil bundle:nil];
        vc.view.frame        = [[UIScreen mainScreen] bounds];
        imgView.frame        = [[UIScreen mainScreen] bounds];
        [vc.view addSubview:imgView];
        [vc.view setBackgroundColor:[UIColor ows_blackColor]];
        window.rootViewController = vc;

        window;
    });
}

- (void)protectScreen {
    [MedxPasscodeManager storeLastActivityTime:[NSDate date]];
    if (Environment.preferences.screenSecurityIsEnabled) {
        self.blankWindow.hidden = NO;
    }
}

- (BOOL)removeScreenProtection {
    // get time when user exited the app and present passcode prompt if needed
    NSNumber *timeout = [MedxPasscodeManager inactivityTimeout];
    BOOL shouldShowPasscode = [MedxPasscodeManager lastActivityTime].timeIntervalSinceNow < -timeout.intValue || [MedxPasscodeManager passcode].length < MedxMinimumPasscodeLength;
    if ([MedxPasscodeManager isPasscodeEnabled] && shouldShowPasscode) {
        [self presentPasscodeEntry];
    }
    if ([MedxPasscodeManager isLockoutEnabled]) {
        return shouldShowPasscode;
    }
    if (Environment.preferences.screenSecurityIsEnabled) {
        self.blankWindow.hidden = YES;
    }
    return shouldShowPasscode;
}

- (void)presentPasscodeEntry {
    if ([[UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController isKindOfClass:[TOPasscodeViewController class]]) {
        // no need to present again
        return;
    }
    if ([UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController != nil) {
        [[UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController dismissViewControllerAnimated:false completion:nil];
    }
    BOOL forcePasscodeChange = [MedxPasscodeManager passcode].length < MedxMinimumPasscodeLength;
    PasscodeHelperAction type = forcePasscodeChange ? PasscodeHelperActionChangePasscode : PasscodeHelperActionCheckPasscode;
    TOPasscodeViewController *vc = [self.passcodeHelper initiateAction:type from:UIApplication.sharedApplication.keyWindow.rootViewController completion:^{
        if (self.onUnlock != nil) {
            self.onUnlock();
            self.onUnlock = nil; // not needed anymore
        }
    }];
    if (forcePasscodeChange) {
        vc.passcodeView.titleLabel.text = @"Enter your old passcode. You will be required to change your passcode to match the new security requirements.";
    }
}

- (void)setupAppearance {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[SignalsNavigationController class]]] setBarTintColor:[UIColor ows_materialBlueColor]];
    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[SignalsNavigationController class]]] setTintColor:[UIColor whiteColor]];

    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTintColor:[UIColor ows_materialBlueColor]];


    [[UIToolbar appearance] setTintColor:[UIColor ows_materialBlueColor]];
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[SignalsNavigationController class]]] setTintColor:[UIColor whiteColor]];

    NSShadow *shadow = [NSShadow new];
    [shadow setShadowColor:[UIColor clearColor]];

    NSDictionary *navbarTitleTextAttributes = @{
        NSForegroundColorAttributeName : [UIColor whiteColor],
        NSShadowAttributeName : shadow,
    };

    [[UISwitch appearance] setOnTintColor:[UIColor ows_materialBlueColor]];

    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[SignalsNavigationController class]]] setTitleTextAttributes:navbarTitleTextAttributes];
}

#pragma mark Push Notifications Delegate Methods

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[PushManager sharedManager] application:application didReceiveRemoteNotification:userInfo];
}
- (void)application:(UIApplication *)application
    didReceiveRemoteNotification:(NSDictionary *)userInfo
          fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [[PushManager sharedManager] application:application
                didReceiveRemoteNotification:userInfo
                      fetchCompletionHandler:completionHandler];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [[PushManager sharedManager] application:application didReceiveLocalNotification:notification];
}

- (void)application:(UIApplication *)application
    handleActionWithIdentifier:(NSString *)identifier
          forLocalNotification:(UILocalNotification *)notification
             completionHandler:(void (^)())completionHandler {
    [[PushManager sharedManager] application:application
                  handleActionWithIdentifier:identifier
                        forLocalNotification:notification
                           completionHandler:completionHandler];
}

- (void)application:(UIApplication *)application
    handleActionWithIdentifier:(NSString *)identifier
          forLocalNotification:(UILocalNotification *)notification
              withResponseInfo:(NSDictionary *)responseInfo
             completionHandler:(void (^)())completionHandler {
    [[PushManager sharedManager] application:application
                  handleActionWithIdentifier:identifier
                        forLocalNotification:notification
                            withResponseInfo:responseInfo
                           completionHandler:completionHandler];
}

/**
 *  Signal requires an iPhone to be unlocked after reboot to be able to access keying material.
 */
- (void)verifyBackgroundBeforeKeysAvailableLaunch {
    if ([self applicationIsActive]) {
        return;
    }

    if (![[TSStorageManager sharedManager] databasePasswordAccessible]) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody            = NSLocalizedString(@"PHONE_NEEDS_UNLOCK", nil);
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        exit(0);
    }
}

- (BOOL)applicationIsActive {
    UIApplication *app = [UIApplication sharedApplication];

    if (app.applicationState == UIApplicationStateActive) {
        return YES;
    }

    return NO;
}

@end
