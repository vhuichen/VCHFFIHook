//
//  VCHFFIHook.m
//  Demo
//
//  Created by vchan on 2022/4/15.
//  Copyright © 2022 sunnyxx. All rights reserved.
//

#import "VCHFFIHook.h"
#import "VCHFFIClosure.h"
#import <objc/runtime.h>
#import <ffi.h>
#import "ViewController.h"

@interface VCHFFIHookClassClosure : NSObject

@property (nonatomic, strong) NSMutableDictionary<NSString *, VCHFFIClosure *> *list;

@end

@implementation VCHFFIHookClassClosure

- (NSMutableDictionary *)list {
    if (_list == nil) {
        _list = NSMutableDictionary.dictionary;
    }
    return _list;
}

@end

@interface VCHFFIHook ()

@end

static NSMutableDictionary<NSString *, VCHFFIHookClassClosure *> *_hookList = nil;

@implementation VCHFFIHook

+ (NSDictionary *)hookList {
    if (_hookList == nil) {
        _hookList = NSMutableDictionary.dictionary;
    }
    return _hookList;
}

+ (BOOL)hookClass:(Class)aClass
     hookSelector:(SEL)sourceSelector
           target:(Class)target
   targetSelector:(SEL)targetSelector {
    Method sMethod = class_getInstanceMethod(aClass, sourceSelector);
    Method tMethod = class_getInstanceMethod(target, targetSelector);
    
    const char *sTypes = method_getTypeEncoding(sMethod);
    const char *tTypes = method_getTypeEncoding(tMethod);
    
    if (strcmp(sTypes, tTypes) != 0) {
        return NO;
    }
    
    VCHFFIHookClassClosure *classClosureCache = [self.hookList valueForKey:NSStringFromClass(aClass)];
    if (classClosureCache == nil) {
        classClosureCache = VCHFFIHookClassClosure.new;
        [self.hookList setValue:classClosureCache forKey:NSStringFromClass(aClass)];
    }
    
    VCHFFIClosure *closureCache = [classClosureCache.list valueForKey:NSStringFromSelector(sourceSelector)];
    if (closureCache == nil) {
        VCHFFIClosure *closure = [[VCHFFIClosure alloc] initWithHookClass:aClass
                                                             hookSelector:sourceSelector
                                                                   target:target
                                                           targetSelector:targetSelector
                                                              callbackImp:ffiClosureCalled];
        [classClosureCache.list setValue:closure forKey:NSStringFromSelector(sourceSelector)];
    }
    
    return YES;
}

void ffiClosureCalled(ffi_cif *cif, void *ret, void **args, void *userdata) {
    VCHFFIClosure *closure = (__bridge VCHFFIClosure *)userdata;
    
    ffi_call(cif, closure.targetImp, ret, args);
}

@end
