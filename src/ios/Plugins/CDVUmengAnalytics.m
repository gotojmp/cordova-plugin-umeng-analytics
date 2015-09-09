#import "CDVUmengAnalytics.h"
#import "MobClick.h"

@implementation CDVUmengAnalytics
- (id)settingForKey:(NSString*)key
{
    return [self.commandDelegate.settings objectForKey:[key lowercaseString]];
}

- (id)settingForKey:(NSString*)key withDefault:(NSString*)def
{
    NSString* value= [self.commandDelegate.settings objectForKey:[key lowercaseString]];
    if (!value) {
        value=def;
    }
    return value;
}

- (void)pluginInitialize
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
    
}

- (void)onPageStart:(CDVInvokedUrlCommand*)command{
    NSString* pageName=[self getPageName:command ];
    [MobClick beginLogPageView:pageName];

}

- (void)onPageEnd:(CDVInvokedUrlCommand*)command{
    NSString* pageName=[self getPageName:command ];
   [MobClick endLogPageView:pageName];
}

- (id)getPageName:(CDVInvokedUrlCommand*)command{
    NSString* pageName=command.arguments[0];
    if (!pageName||pageName.length<=0) {
        pageName=@"umeng_unknown_page";
    }
    return pageName;
}

- (void)finishLaunching:(NSNotification *)notification
{
    NSString* setting;
    
    setting  = @"UmengAnalyticsDebugMode";
    if ([self settingForKey:setting]) {
        BOOL logEnabled=[[self settingForKey:setting] boolValue];
        if (logEnabled) {
            [MobClick setLogEnabled:YES];
        }else{
            [MobClick setLogEnabled:NO];
        }
    }
    NSString* appkey;
    NSString* channelId;
    setting=@"UMENG_APPKEY";
    appkey=[self settingForKey:setting];
    setting=@"UMENG_CHANNEL";
    channelId=[self settingForKey:setting];
    [MobClick setAppVersion:XcodeAppVersion];
    [MobClick startWithAppkey:appkey reportPolicy:BATCH   channelId:channelId];
    [MobClick updateOnlineConfig];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineConfigCallBack:) name:UMOnlineConfigDidFinishedNotification object:nil];
}

- (void)onlineConfigCallBack:(NSNotification *)note {
    
    NSLog(@"online config has fininshed and note = %@", note.userInfo);
}
@end
