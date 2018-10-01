#import "AdjustSdkPlugin.h"

static NSString *const CHANNEL_API_NAME = @"com.adjust/api";
static NSString *const CHANNEL_DEEPLINK_NAME = @"com.adjust/deeplink";

@interface AdjustSdkPlugin ()
@property(nonatomic, retain) FlutterMethodChannel *channel;
@property(nonatomic, retain) FlutterMethodChannel *deeplinkChannel;
@end

@implementation AdjustSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:CHANNEL_API_NAME
                                     binaryMessenger:[registrar messenger]];
    FlutterMethodChannel* deeplinkChannel = [FlutterMethodChannel
                                             methodChannelWithName:CHANNEL_DEEPLINK_NAME
                                             binaryMessenger:[registrar messenger]];
    AdjustSdkPlugin* instance = [[AdjustSdkPlugin alloc] init];
    instance.channel = channel;
    instance.deeplinkChannel = deeplinkChannel;
    [registrar addMethodCallDelegate:instance channel:channel];
    [registrar addMethodCallDelegate:instance channel:deeplinkChannel];
}

// TODO: check if needed
- (void)dealloc {
    [self.channel setMethodCallHandler:nil];
    [self.deeplinkChannel setMethodCallHandler:nil];
    self.channel = nil;
    self.deeplinkChannel = nil;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        [self getPlatformVersion:result];
    } else if ([@"onCreate" isEqualToString:call.method]) {
        [self onCreate:call withResult:result];
    } else if ([@"onResume" isEqualToString:call.method]) {
        [Adjust trackSubsessionStart];
    } else if ([@"onPause" isEqualToString:call.method]) {
        [Adjust trackSubsessionEnd];
    } else if ([@"trackEvent" isEqualToString:call.method]) {
        [self trackEvent:call withResult:result];
    } else if ([@"setIsEnabled" isEqualToString:call.method]) {
        [self setIsEnabled:call withResult:result];
    } else if ([@"sendFirstPackages" isEqualToString:call.method]) {
        [self sendFirstPackages:call withResult:result];
    } else if ([@"gdprForgetMe" isEqualToString:call.method]) {
        [self gdprForgetMe:call withResult:result];
    } else if ([@"getAttribution" isEqualToString:call.method]) {
        [self getAttribution:call withResult:result];
    } else if ([@"getIdfa" isEqualToString:call.method]) {
        [self getIdfa:call withResult:result];
    } else if ([@"setOfflineMode" isEqualToString:call.method]) {
        [self setOfflineMode:call withResult:result];
    } else if ([@"setPushToken" isEqualToString:call.method]) {
        [self setPushToken:call withResult:result];
    } else if ([@"appWillOpenUrl" isEqualToString:call.method]) {
        [self appWillOpenUrl:call withResult:result];
    } else if ([@"addSessionCallbackParameter" isEqualToString:call.method]) {
        NSString *key = call.arguments[@"key"];
        NSString *value = call.arguments[@"value"];
        if (!([self isFieldValid:key]) || !([self isFieldValid:value])) {
            return;
        }
        [Adjust addSessionCallbackParameter:key value:value];
    } else if ([@"removeSessionCallbackParameter" isEqualToString:call.method]) {
        NSString *key = call.arguments[@"key"];
        if (!([self isFieldValid:key])) {
            return;
        }
        [Adjust removeSessionCallbackParameter:key];
    } else if ([@"resetSessionCallbackParameters" isEqualToString:call.method]) {
        [Adjust resetSessionCallbackParameters];
    } else if ([@"addSessionPartnerParameter" isEqualToString:call.method]) {
        NSString *key = call.arguments[@"key"];
        NSString *value = call.arguments[@"value"];
        if (!([self isFieldValid:key]) || !([self isFieldValid:value])) {
            return;
        }
        [Adjust addSessionPartnerParameter:key value:value];
    } else if ([@"removeSessionPartnerParameter" isEqualToString:call.method]) {
        NSString *key = call.arguments[@"key"];
        if (!([self isFieldValid:key])) {
            return;
        }
        [Adjust removeSessionPartnerParameter:key];
    } else if ([@"resetSessionPartnerParameters" isEqualToString:call.method]) {
        [Adjust resetSessionPartnerParameters];
    } else if ([@"isEnabled" isEqualToString:call.method]) {
        BOOL isEnabled = [Adjust isEnabled];
        result(@(isEnabled));
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)getPlatformVersion:(FlutterResult)result {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
}

- (void)onCreate:(FlutterMethodCall*)call withResult:(FlutterResult)result {
    NSString *appToken         = call.arguments[@"appToken"];
    NSString *environment      = call.arguments[@"environment"];
    NSString *logLevel         = call.arguments[@"logLevel"];
    NSString *sdkPrefix        = call.arguments[@"sdkPrefix"];
    NSString *defaultTracker   = call.arguments[@"defaultTracker"];
    
    BOOL allowSuppressLogLevel = NO;
    
    NSString *userAgent             = call.arguments[@"userAgent"];
    NSString *secretId              = call.arguments[@"secretId"];
    NSString *info1                 = call.arguments[@"info1"];
    NSString *info2                 = call.arguments[@"info2"];
    NSString *info3                 = call.arguments[@"info3"];
    NSString *info4                 = call.arguments[@"info4"];
    
    NSString *delayStart            = call.arguments[@"delayStart"];
    NSString *isDeviceKnown         = call.arguments[@"isDeviceKnown"];
    NSString *eventBufferingEnabled = call.arguments[@"eventBufferingEnabled"];
    NSString *sendInBackground      = call.arguments[@"sendInBackground"];
    
    if ([self isFieldValid:logLevel]) {
        if ([ADJLogger logLevelFromString:[logLevel lowercaseString]] == ADJLogLevelSuppress) {
            allowSuppressLogLevel = YES;
        }
    }
    
    ADJConfig *adjustConfig = [ADJConfig configWithAppToken:appToken
                                                environment:environment
                                      allowSuppressLogLevel:allowSuppressLogLevel];
    
    if ([self isFieldValid:logLevel]) {
        [adjustConfig setLogLevel:[ADJLogger logLevelFromString:[logLevel lowercaseString]]];
    }
    
    if ([self isFieldValid:eventBufferingEnabled]) {
        [adjustConfig setEventBufferingEnabled:[eventBufferingEnabled boolValue]];
    }
    
    if ([self isFieldValid:sdkPrefix]) {
        [adjustConfig setSdkPrefix:sdkPrefix];
    }
    
    if ([self isFieldValid:defaultTracker]) {
        [adjustConfig setDefaultTracker:defaultTracker];
    }
    
    if ([self isFieldValid:sendInBackground]) {
        [adjustConfig setSendInBackground:[sendInBackground boolValue]];
    }
    
    if ([self isFieldValid:userAgent]) {
        [adjustConfig setUserAgent:userAgent];
    }
    
    if ([self isFieldValid:delayStart]) {
        [adjustConfig setDelayStart:[delayStart doubleValue]];
    }
    
    if ([self isFieldValid:isDeviceKnown]) {
        [adjustConfig setIsDeviceKnown:[isDeviceKnown boolValue]];
    }
    
    if ([self isFieldValid:secretId]
        && [self isFieldValid:info1]
        && [self isFieldValid:info2]
        && [self isFieldValid:info3]
        && [self isFieldValid:info4]) {
        [adjustConfig setAppSecret:[[NSNumber numberWithLongLong:[secretId longLongValue]] unsignedIntegerValue]
                             info1:[[NSNumber numberWithLongLong:[info1 longLongValue]] unsignedIntegerValue]
                             info2:[[NSNumber numberWithLongLong:[info2 longLongValue]] unsignedIntegerValue]
                             info3:[[NSNumber numberWithLongLong:[info3 longLongValue]] unsignedIntegerValue]
                             info4:[[NSNumber numberWithLongLong:[info4 longLongValue]] unsignedIntegerValue]];
    }
    
    // needed for callbacks
    [adjustConfig setDelegate:self];
    
    [Adjust appDidLaunch:adjustConfig];
    [Adjust trackSubsessionStart];
    
    result(nil);
}

- (void)trackEvent:(FlutterMethodCall*)call withResult:(FlutterResult)result {
    NSString *eventToken = call.arguments[@"eventToken"];
    NSString *revenue = call.arguments[@"revenue"];
    NSString *currency = call.arguments[@"currency"];
    NSString *receipt = call.arguments[@"receipt"];
    NSString *transactionId = call.arguments[@"transactionId"];
    NSString *isReceiptSet = call.arguments[@"isReceiptSet"];
    NSString *callbackParametersJsonStr = call.arguments[@"callbackParameters"];
    NSString *partnerParametersJsonStr = call.arguments[@"partnerParameters"];
   
    ADJEvent *adjustEvent = [ADJEvent eventWithEventToken:eventToken];
    
    // callbackParameters //////////////
    if(callbackParametersJsonStr != nil) {
        id callbackParametersJson = [NSJSONSerialization
                                           JSONObjectWithData:[callbackParametersJsonStr dataUsingEncoding:NSUTF8StringEncoding]
                                           options:0 error:NULL];
        
        for (id key in callbackParametersJson) {
            NSString *value = [callbackParametersJson objectForKey:key];
            [adjustEvent addCallbackParameter:key value:value];
        }
    }

    // partnerParameters //////////////
    if(partnerParametersJsonStr != nil) {
        id partnerParametersJson = [NSJSONSerialization
                                          JSONObjectWithData:[partnerParametersJsonStr dataUsingEncoding:NSUTF8StringEncoding]
                                          options:0 error:NULL];
        
        for (id key in partnerParametersJson) {
            NSString *value = [partnerParametersJson objectForKey:key];
            [adjustEvent addPartnerParameter:key value:value];
        }
    }
    
    if ([self isFieldValid:revenue]) {
        double revenueValue = [revenue doubleValue];
        [adjustEvent setRevenue:revenueValue currency:currency];
    }
    
    // Deprecated
    // Transaction ID and receipt
    BOOL isTransactionIdSet = NO;
    
    if ([self isFieldValid:isReceiptSet]) {
        if ([isReceiptSet boolValue]) {
            [adjustEvent setReceipt:[receipt dataUsingEncoding:NSUTF8StringEncoding] transactionId:transactionId];
        } else {
            if ([self isFieldValid:transactionId]) {
                [adjustEvent setTransactionId:transactionId];
                isTransactionIdSet = YES;
            }
        }
    }
    
    if (NO == isTransactionIdSet) {
        if ([self isFieldValid:transactionId]) {
            [adjustEvent setTransactionId:transactionId];
        }
    }
    
    [Adjust trackEvent:adjustEvent];
    
    result(nil);
}

- (void)setIsEnabled:(FlutterMethodCall*)call withResult:(FlutterResult)result {
    NSString *isEnabled = call.arguments[@"isEnabled"];
    if ([self isFieldValid:isEnabled]) {
        [Adjust setEnabled:[isEnabled boolValue]];
    }
    result(nil);
}

- (void)sendFirstPackages:(FlutterMethodCall*)call withResult:(FlutterResult)result {
    [Adjust sendFirstPackages];
    result(nil);
}

- (void)gdprForgetMe:(FlutterMethodCall*)call withResult:(FlutterResult)result {
    [Adjust gdprForgetMe];
    result(nil);
}

- (void)setOfflineMode:(FlutterMethodCall*)call withResult:(FlutterResult)result {
    NSString *isOfflineMode = call.arguments[@"isOffline"];
    if ([self isFieldValid:isOfflineMode]) {
        [Adjust setOfflineMode:[isOfflineMode boolValue]];
    }
    result(nil);
}

- (void)setPushToken:(FlutterMethodCall*)call withResult:(FlutterResult)result {
    NSString *token = call.arguments[@"token"];
    if ([self isFieldValid:token]) {
        [Adjust setDeviceToken:[token dataUsingEncoding:NSUTF8StringEncoding]];
    }
    result(nil);
}

- (void)appWillOpenUrl:(FlutterMethodCall*)call withResult:(FlutterResult)result {
    NSString *urlString = call.arguments[@"url"];
    
    if (urlString == nil) {
        return;
    }
    
    NSURL *url;
    
    if ([NSString instancesRespondToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)]) {
        url = [NSURL URLWithString:[urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
#pragma clang diagnostic pop
    
    [Adjust appWillOpenUrl:url];
}

- (void)getAttribution:(FlutterMethodCall*)call withResult:(FlutterResult)result {
    ADJAttribution *attribution = [Adjust attribution];
    
    if (attribution == nil) {
        return;
    }
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [self addValueOrEmpty:attribution.trackerToken withKey:@"trackerToken" toDictionary:dictionary];
    [self addValueOrEmpty:attribution.trackerName withKey:@"trackerName" toDictionary:dictionary];
    [self addValueOrEmpty:attribution.network withKey:@"network" toDictionary:dictionary];
    [self addValueOrEmpty:attribution.campaign withKey:@"campaign" toDictionary:dictionary];
    [self addValueOrEmpty:attribution.creative withKey:@"creative" toDictionary:dictionary];
    [self addValueOrEmpty:attribution.adgroup withKey:@"adgroup" toDictionary:dictionary];
    [self addValueOrEmpty:attribution.clickLabel withKey:@"clickLabel" toDictionary:dictionary];
    [self addValueOrEmpty:attribution.adid withKey:@"adid" toDictionary:dictionary];
    
    result(dictionary);
}

- (void)getIdfa:(FlutterMethodCall*)call withResult:(FlutterResult)result {
    NSString* idfa = [Adjust idfa];
    result(idfa);
}

//////////// CALLBACK METHODS ///////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
- (void)adjustAttributionChanged:(ADJAttribution *)attribution {
    id keys[] = { @"trackerToken", @"trackerName", @"network", @"campaign", @"adgroup", @"creative", @"clickLabel", @"adid" };
    id values[] = { [attribution trackerToken], [attribution trackerName], [attribution network], [attribution campaign], [attribution adgroup], [attribution creative], [attribution clickLabel], [attribution adid] };
    NSUInteger count = sizeof(values) / sizeof(id);
    NSDictionary *adjustAttributionMap = [NSDictionary dictionaryWithObjects:values
                                                           forKeys:keys
                                                             count:count];
    
    [self.channel invokeMethod:@"attribution-change" arguments:adjustAttributionMap];
}

- (void)adjustEventTrackingSucceeded:(ADJEventSuccess *)eventSuccessResponseData {
    id keys[] = { @"message", @"timestamp", @"adid", @"eventToken", @"jsonResponse" };
    id values[] = { [eventSuccessResponseData message], [eventSuccessResponseData timeStamp], [eventSuccessResponseData adid], [eventSuccessResponseData eventToken], [self toJson:[eventSuccessResponseData jsonResponse]] };
    NSUInteger count = sizeof(values) / sizeof(id);
    NSDictionary *adjustSessionSuccessMap = [NSDictionary dictionaryWithObjects:values
                                                                        forKeys:keys
                                                                          count:count];
    
    [self.channel invokeMethod:@"event-success" arguments:adjustSessionSuccessMap];
}

- (void)adjustEventTrackingFailed:(ADJEventFailure *)eventFailureResponseData {
    NSString *willRetryString = [eventFailureResponseData willRetry] ? @"true" : @"false";
    id keys[] = { @"message", @"timestamp", @"adid", @"eventToken", @"willRetry", @"jsonResponse" };
    id values[] = { [eventFailureResponseData message], [eventFailureResponseData timeStamp], [eventFailureResponseData adid], [eventFailureResponseData eventToken], willRetryString, [self toJson:[eventFailureResponseData jsonResponse]] };
    NSUInteger count = sizeof(values) / sizeof(id);
    NSDictionary *adjustSessionSuccessMap = [NSDictionary dictionaryWithObjects:values
                                                                        forKeys:keys
                                                                          count:count];
    
    [self.channel invokeMethod:@"event-fail" arguments:adjustSessionSuccessMap];
}

- (void)adjustSessionTrackingSucceeded:(ADJSessionSuccess *)sessionSuccessResponseData {
    id keys[] = { @"message", @"timestamp", @"adid", @"jsonResponse" };
    id values[] = { [sessionSuccessResponseData message], [sessionSuccessResponseData timeStamp], [sessionSuccessResponseData adid],
        [self toJson:[sessionSuccessResponseData jsonResponse]] };
    NSUInteger count = sizeof(values) / sizeof(id);
    NSDictionary *adjustSessionSuccessMap = [NSDictionary dictionaryWithObjects:values
                                                                     forKeys:keys
                                                                       count:count];
    
    [self.channel invokeMethod:@"session-success" arguments:adjustSessionSuccessMap];
}

- (void)adjustSessionTrackingFailed:(ADJSessionFailure *)sessionFailureResponseData {
    NSString *willRetryString = [sessionFailureResponseData willRetry] ? @"true" : @"false";
    id keys[] = { @"message", @"timestamp", @"adid", @"willRetry", @"jsonResponse" };
    id values[] = { [sessionFailureResponseData message], [sessionFailureResponseData timeStamp], [sessionFailureResponseData adid], willRetryString,
        [self toJson:[sessionFailureResponseData jsonResponse]] };
    NSUInteger count = sizeof(values) / sizeof(id);
    NSDictionary *adjustFailureSuccessMap = [NSDictionary dictionaryWithObjects:values
                                                                        forKeys:keys
                                                                          count:count];
    
    [self.channel invokeMethod:@"session-fail" arguments:adjustFailureSuccessMap];
}

- (BOOL)adjustDeeplinkResponse:(NSURL *)deeplink {
    // call non-native flutter part and ask whether deepling should be launched
    // and return that value
    id keys[] = { @"uri" };
    id values[] = { [deeplink absoluteString] };
    NSUInteger count = sizeof(values) / sizeof(id);
    NSDictionary *deeplinkUriParamsMap = [NSDictionary dictionaryWithObjects:values
                                                                        forKeys:keys
                                                                          count:count];
    
    [self.deeplinkChannel invokeMethod:@"should-launch-uri" arguments:deeplinkUriParamsMap result:^(id  _Nullable result) {
        BOOL launchDeeplink;
        if(result == nil) {
            launchDeeplink = false;
        } else if ([result isMemberOfClass:[FlutterMethodNotImplemented class]]) {
            launchDeeplink = false;
        } else if ([result isMemberOfClass:[FlutterError class]]) {
            launchDeeplink = false;
        }
        launchDeeplink = result;
    }];
    
    // ...pretty sure this does not work like this.
    // probably a callback back to the native part is needed
    // return launchDeeplink;
    return true;
}

//////////// HELPER METHODS ///////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isFieldValid:(NSObject *)field {
    if (field == nil) {
        return NO;
    }
    
    // Check if its an instance of the singleton NSNull
    if ([field isKindOfClass:[NSNull class]]) {
        return NO;
    }
    
    // If field can be converted to a string, check if it has any content.
    NSString *str = [NSString stringWithFormat:@"%@", field];
    if (str != nil) {
        if ([str length] == 0) {
            return NO;
        }
    }
    
    return YES;
}

- (void)addValueOrEmpty:(NSObject *)value
                withKey:(NSString *)key
           toDictionary:(NSMutableDictionary *)dictionary {
    if (nil != value) {
        [dictionary setObject:[NSString stringWithFormat:@"%@", value] forKey:key];
    } else {
        [dictionary setObject:@"" forKey:key];
    }
}

-(NSString*)toJson:(id)object
{
    NSError *writeError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&writeError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
///////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

@end
