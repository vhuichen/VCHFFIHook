//
//  VCHFFIClosure.m
//  Demo
//
//  Created by vchan on 2022/4/15.
//  Copyright © 2022 vchan. All rights reserved.
//

#import "VCHFFIClosure.h"
#import <ffi.h>
#import "NSMethodSignature+VCHFFI.h"

@interface VCHFFIClosure () {
    Class sourceClass;
    Class targetClass;
    SEL sourceSelector;
    SEL targetSelector;
    
    CallbackImp callbackImp;
    
    ffi_cif cif;
    ffi_type **argumentTypes;
    ffi_closure *closure;
    IMP newIMP;
}

@end

@implementation VCHFFIClosure

- (instancetype)initWithHookClass:(Class)aClass
                     hookSelector:(SEL)sourceSelector
                           target:(Class)targetClass
                   targetSelector:(SEL)targetSelector
                      callbackImp:(CallbackImp)callbackImp {
    if (self = [super init]) {
        self->sourceClass = aClass;
        self->sourceSelector = sourceSelector;
        self->targetClass = targetClass;
        self->targetSelector = targetSelector;
        self->callbackImp = callbackImp;
        
        _targetImp = class_getMethodImplementation(targetClass, targetSelector);
        
        [self closureInit];
    }
    return self;
}

- (void)closureInit {
    Method method = class_getInstanceMethod(sourceClass, sourceSelector);
    const char *types = method_getTypeEncoding(method);
    NSMethodSignature *sign = [NSMethodSignature signatureWithObjCTypes:types];
    unsigned int nargs = (unsigned int)sign.numberOfArguments;
    
    argumentTypes = malloc(sizeof(ffi_type *) * nargs);
    argumentTypes[0] = &ffi_type_pointer;
    argumentTypes[1] = &ffi_type_pointer;
    for (int i = 2; i < nargs; i++) {
        argumentTypes[i] = [sign ffi_getArgumentTypeAtIndex:i];
    }
    // 初始化函数模板
    ffi_type *ffiReturnType = [sign ffi_methodReturnType];
    ffi_prep_cif(&cif, FFI_DEFAULT_ABI, nargs, ffiReturnType, argumentTypes);
    // 创建 closure 对象
    closure = ffi_closure_alloc(sizeof(ffi_closure), (void *)&newIMP);
    // 初始化 closure 对象
    ffi_prep_closure_loc(closure, &cif, callbackImp, (__bridge void *)self, NULL);
    
    method_setImplementation(method, newIMP);
}

@end
