//
//  ViewController.m
//  VCHFFIHook
//
//  Created by vchan on 2022/4/12.
//

#import "ViewController.h"
#import "VCHFFIHook.h"

@interface VCHSark : NSObject

@end

@implementation VCHSark

- (void)fooWithBar:(int)bar baz:(int)baz {
    NSLog(@"原来的方法：%d", bar + baz);
}

@end


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    BOOL isSuccess = [VCHFFIHook hookClass:self.class
                              hookSelector:@selector(fooWithBarDDD:)
                                    target:self.class
                            targetSelector:@selector(fooWithBarDDDHook:)];
    if (isSuccess) {
        NSLog(@"vhuichan hook success");
    }
    
    isSuccess = [VCHFFIHook hookClass:VCHSark.class
                         hookSelector:@selector(fooWithBar:baz:)
                               target:self.class
                       targetSelector:@selector(fooWithBar:baz:)];
    if (isSuccess) {
        NSLog(@"vhuichan hook success");
    }
    
    [self test:3];
}

- (void)test:(int)i {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        int value = [(ViewController *)[NSClassFromString(@"ViewController") new] fooWithBarDDD:i];
        [VCHSark.new fooWithBar:i baz:i + 1];
        
        NSLog(@"vhuichen fooWithBarDDD hook %d %d", i, value);
    });
}

- (int)fooWithBarDDD:(int)bar {
    return bar * 2;
}

- (int)fooWithBarDDDHook:(int)bar {
    return bar * bar;
}

- (void)fooWithBar:(int)bar baz:(int)baz {
    NSLog(@"hook fooWithBar：%d", bar * baz);
}


@end
