/*
 * Reachability.m
 * Minimal SCNetworkReachability wrapper for nitoTV / ATV2/3
 *
 * ATV2/3 は常にWiFi接続のため、WWAN ケースは保険として残している。
 * Apple の公式 Reachability サンプルと同じ API を持つが、
 * 通知機能・runloop 登録は省略した最小実装。
 */

#import "Reachability.h"
#import <arpa/inet.h>
#import <netinet/in.h>

@implementation Reachability

- (void)dealloc {
    if (_reachabilityRef != NULL) {
        CFRelease(_reachabilityRef);
    }
    [super dealloc];
}

+ (instancetype)reachabilityForInternetConnection {
    struct sockaddr_in zeroAddr;
    bzero(&zeroAddr, sizeof(zeroAddr));
    zeroAddr.sin_len    = sizeof(zeroAddr);
    zeroAddr.sin_family = AF_INET;

    Reachability *r = [[self alloc] init];
    r->_reachabilityRef = SCNetworkReachabilityCreateWithAddress(
        kCFAllocatorDefault, (struct sockaddr *)&zeroAddr);
    return [r autorelease];
}

- (NetworkStatus)currentReachabilityStatus {
    if (_reachabilityRef == NULL) return NotReachable;

    SCNetworkReachabilityFlags flags = 0;
    if (!SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)) {
        return NotReachable;
    }

    /* 到達不能 */
    if (!(flags & kSCNetworkReachabilityFlagsReachable)) {
        return NotReachable;
    }

    /* 接続が必要（まだ接続されていない） */
    if (flags & kSCNetworkReachabilityFlagsConnectionRequired) {
        return NotReachable;
    }

#if TARGET_OS_IPHONE
    /* WWAN (3G/LTE) – ATV には存在しないが互換性のため残す */
    if (flags & kSCNetworkReachabilityFlagsIsWWAN) {
        return ReachableViaWWAN;
    }
#endif

    return ReachableViaWiFi;
}

@end
