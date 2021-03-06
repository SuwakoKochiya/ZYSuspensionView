//
//  ZYTestManager.m
//  ZYSuspensionView
//
//  GitHub https://github.com/ripperhe
//  Created by ripper on 2016/12/9.
//  Copyright © 2016年 ripper. All rights reserved.
//

#import "ZYTestManager.h"
#import "ZYTestTableViewController.h"

NSString *const kTestTitleKey = @"title";
NSString *const kTestAutoCloseKey = @"autoClose";
NSString *const kTestActionKey = @"action";

@interface ZYTestManager ()<ZYSuspensionViewDelegate>

@property (nonatomic, weak) ZYSuspensionView *susView;
@property (nonatomic, strong) NSArray <NSDictionary *>*permanentTestItemArray;
@property (nonatomic, strong) NSMutableDictionary  <NSString *, NSDictionary *>*newTestItemDic;
@property (nonatomic, weak, nullable) UIViewController *testTableViewController;

@end


@implementation ZYTestManager

static ZYTestManager *_instance;

+ (instancetype)shareInstance
{
    if (!_instance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [[ZYTestManager alloc] init];
        });
    }
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

#pragma mark - getter
- (NSMutableDictionary *)newTestItemDic
{
    if (!_newTestItemDic) {
        _newTestItemDic = [NSMutableDictionary dictionary];
    }
    return _newTestItemDic;
}

#pragma mark - ZYSuspensionViewDelegate
- (void)suspensionViewClick:(ZYSuspensionView *)suspensionView
{
#if DEBUG
    if ([ZYSuspensionManager windowForKey:kZYTestTableControllerKey]) {
        ZYSuspensionContainer *window = (ZYSuspensionContainer *)[ZYSuspensionManager windowForKey:kZYTestTableControllerKey];
        if ([UIApplication sharedApplication].keyWindow == window) {
            window.zy_canBecomeKeyWindow = NO;
            [window.lastKeyWindow makeKeyWindow];
        }
        [ZYSuspensionManager destroyWindowForKey:kZYTestTableControllerKey];
        [ZYTestManager shareInstance].testTableViewController = nil;
    }else{
        ZYTestTableViewController *testTableViewVC = [[ZYTestTableViewController alloc] init];
        ZYSuspensionContainer *window = [[ZYSuspensionContainer alloc] initWithFrame:[UIScreen mainScreen].bounds];
        window.rootViewController = testTableViewVC;
        window.windowLevel -= 1;
        // 也许需要处理一些键盘输入的事件
        window.zy_canBecomeKeyWindow = YES;
        window.lastKeyWindow = [UIApplication sharedApplication].keyWindow;
        [window setHidden:NO];
        [ZYSuspensionManager saveWindow:window forKey:kZYTestTableControllerKey];
        [ZYTestManager shareInstance].testTableViewController = testTableViewVC;
    }
#endif
}

#pragma mark - API
+ (void)showSuspensionView
{
#if DEBUG
    if ([ZYTestManager shareInstance].susView) {
        return;
    }
    ZYSuspensionView *sus = [ZYSuspensionView defaultSuspensionViewWithDelegate:[ZYTestManager shareInstance]];
    [sus setTitle:@"Test" forState:UIControlStateNormal];
    [sus show];
    [ZYTestManager shareInstance].susView = sus;
#endif
}

+ (void)removeSuspensionView
{
#if DEBUG
    [[ZYTestManager shareInstance].susView removeFromScreen];
#endif
}

+ (void)setupPermanentTestItemArray:(NSArray <NSDictionary *>*)array
{
#if DEBUG
    [ZYTestManager shareInstance].permanentTestItemArray = array;
#endif
}

+ (void)addTestItemWithTitle:(NSString *)title autoClose:(BOOL)autoClose action:(void(^)())action
{
#if DEBUG
    if (title.length == 0 || !action) {
        return;
    }
    NSDictionary *dic = @{
                          kTestAutoCloseKey: @(autoClose),
                          kTestActionKey: action
                          };
    [[ZYTestManager shareInstance].newTestItemDic setObject:dic forKey:title];
#endif
}

+ (void)addTestItemWithTitle:(NSString *)title action:(void (^)())action
{
#if DEBUG
    [self addTestItemWithTitle:title autoClose:@YES action:action];
#endif
}


+ (void)closeTestTableViewController
{
#if DEBUG
    ZYSuspensionContainer *window = (ZYSuspensionContainer *)[ZYSuspensionManager windowForKey:kZYTestTableControllerKey];
    if ([UIApplication sharedApplication].keyWindow == window) {
        window.zy_canBecomeKeyWindow = NO;
        [window.lastKeyWindow makeKeyWindow];
    }
    [ZYSuspensionManager destroyWindowForKey:kZYTestTableControllerKey];
    [ZYTestManager shareInstance].testTableViewController = nil;
#endif
}

@end
