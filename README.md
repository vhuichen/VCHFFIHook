# VCHFFIHook
libffi hook

#### libffi
`FFI` 的全名是 Foreign Function Interface (外部函数接口)   
libffi 提供了一套底层接口，在知道函数签名的情况下，可以根据相关接口完成函数调用；

#### 调用惯例(Calling Convention)
函数调用是通过堆栈体现出来的，在调用函数时，需要按照约定将相关的参数入栈，
而这种约定就叫做：调用惯例(Calling Convention)  
也就是说只要我们按照这个约定存放函数调用时使用的参数，就可实现函数调用的效果；  
libffi 也就是实现了这样的一个功能。

### libffi 调用任意 OC 方法
实现步骤：  
1. 通过 libffi 创建 closure 闭包  
2. 交换函数指针，调用原始方法，因为 imp 已经修改，最终会调用到闭包中  
3. 在闭包回调函数里面，将 imp 替换成新的，将消息通过 ffi_call 发送出去

**换句话说通过 libffi 的闭包功能，再加上 OC 提供给我们的 runtime ，一样也可以实现任意方法的 hook 功能；同时也为热修复提供了基础能力。**

#### 创建闭包并交换 IMP
~~~
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
    ffi_type *ffiReturnType = [sign ffi_methodReturnType];
    // 初始化函数模板
    ffi_prep_cif(&cif, FFI_DEFAULT_ABI, nargs, ffiReturnType, argumentTypes);
    // 创建 closure 对象
    closure = ffi_closure_alloc(sizeof(ffi_closure), (void *)&newIMP);
    // 绑定 closure 对象
    ffi_prep_closure_loc(closure, &cif, callbackImp, (__bridge void *)self, NULL);
    
    method_setImplementation(method, newIMP);
}
~~~
1. ffi_type 表示参数类型
2. ffi_prep_cif 负责初始化函数模板（相当于函数签名）
3. ffi_closure_alloc 分配空间
4. ffi_prep_closure_loc 绑定闭包数据

#### 将闭包回调转发到新的IMP上
~~~
void ffiClosureCalled(ffi_cif *cif, void *ret, void **args, void *userdata) {
    VCHFFIClosure *closure = (__bridge VCHFFIClosure *)userdata;
    //更换新的imp 
    IMP imp = class_getMethodImplementation(closure->targetClass, closure->targetSelector);
    
    ffi_call(cif, imp, ret, args);
}
~~~

#### 缓存
ffi 生成的闭包数据必须缓存起来，这里写了个类单独处理闭包相关逻辑。  
考虑到每个类可以 hook 多个方法，每个方法又必须对应一个闭包，所以缓存结构就是一个哈希表，key 表示 class，value 表示多个方法的集合，集合也是一个哈希表，key表示方法名，value表示对应的闭包；

#### 遗留问题
1. 闭包释放时要怎么销毁内存