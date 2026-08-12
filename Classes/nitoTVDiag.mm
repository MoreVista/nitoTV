#import <Foundation/Foundation.h>
#import <objc/runtime.h>

// 未捕捉例外を /var/root/Media/nitotv.log に記録する。
// これで「unrecognized selector」などの例外理由とバックトレースが取れる。
static void ntvUncaughtExceptionHandler(NSException *exception) {
    NSString *line = [NSString stringWithFormat:
        @"[nitoTV][EXCEPTION] name=%@ reason=%@\nbacktrace=%@\n",
        [exception name], [exception reason], [exception callStackSymbols]];
    NSString *logPath = @"/var/root/Media/nitotv.log";
    NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:logPath];
    if (!fh) {
        [@"" writeToFile:logPath atomically:NO encoding:NSUTF8StringEncoding error:nil];
        fh = [NSFileHandle fileHandleForWritingAtPath:logPath];
    }
    [fh seekToEndOfFile];
    [fh writeData:[line dataUsingEncoding:NSUTF8StringEncoding]];
    [fh closeFile];
}

// バンドルがロードされた瞬間に実行される純粋 C コンストラクタ
// Logos に依存しないため、%subclass の前に確実に動く
__attribute__((constructor(101))) static void nitoTVDiagInit(void) {
    NSSetUncaughtExceptionHandler(&ntvUncaughtExceptionHandler);

    // まず fwrite で書く (NSFoundation が使える前でも動く)
    FILE *f = fopen("/var/root/Media/nitotv.log", "a");
    if (f) {
        fputs("[nitoTV] constructor(101): bundle loaded!\n", f);
        fclose(f);
    }

    // NSFoundation が使えるなら追加情報を記録
    NSString *logPath = @"/var/root/Media/nitotv.log";
    NSString *line = [NSString stringWithFormat:
        @"[nitoTV] BRBaseAppliance: %s, nitoTVAppliance: %s\n",
        objc_getClass("BRBaseAppliance") ? "OK" : "NOT FOUND",
        objc_getClass("nitoTVAppliance") ? "registered" : "not yet"
    ];
    NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:logPath];
    if (!fh) {
        [@"" writeToFile:logPath atomically:NO encoding:NSUTF8StringEncoding error:nil];
        fh = [NSFileHandle fileHandleForWritingAtPath:logPath];
    }
    [fh seekToEndOfFile];
    [fh writeData:[line dataUsingEncoding:NSUTF8StringEncoding]];
    [fh closeFile];
}
