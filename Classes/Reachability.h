/*
 * Reachability.h
 * Minimal SCNetworkReachability wrapper for nitoTV / ATV2/3
 * Replaces the missing Apple sample code Reachability.h/.m
 */

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

typedef enum {
    NotReachable = 0,
    ReachableViaWiFi,
    ReachableViaWWAN,
} NetworkStatus;

@interface Reachability : NSObject {
    SCNetworkReachabilityRef _reachabilityRef;
}

+ (instancetype)reachabilityForInternetConnection;
- (NetworkStatus)currentReachabilityStatus;

@end
