//
//  GGTouchView.m
//  事件传递和响应机制
//
//  Created by LGQ on 2018/4/17.
//  Copyright © 2018年 LGQ. All rights reserved.
//

#import "GGTouchView.h"

@implementation GGTouchView

/*
1.事件的产生
 ~ 在 APP 启动的时候，苹果会在 APP 主线程 RunLoop 内注册一个 Source1（基于 mach port）用来接收系统事件。 它有一个回调函数 __IOHIDEventSystemClientQueueCallback()
 ~ 当一个硬件事件（触摸、锁屏、摇晃）等发生后：
    首先由 IOKit.framework 生成一个 IOHIDEvent 事件并由 SpringBoard 接收
    SpringBoard 只接收按键（锁屏、静音等），触摸，加速，接近传感器等几种 Event，随后用 mach port 转发给需要的 APP 进程
    随后，Source1 就会触发回调，并调用 _UIApplicationHandleEventQueue() 进行应用内的分发
 ~ _UIApplicationHandleEventQueue() 是一个事件队列，它会将 IOHIDEvent 处理并包装成 UIEvent 进行处理或分发。通常，事件会被先发送到应用程序的主窗口（keyWindow）
 
2.事件传递，寻找合适的控件来处理事件
 ~ 首先调用 -hitTest:withEvent: 方法，判断当前控件是否能接收事件，触摸点是否在自己身上
 ~ 如果能，从后往前遍历子控件
 ~ 重复前面的两个步骤（之所以从后往前遍历，只是为了做一些循环优化。因为相比较之下，后添加的view在上面，降低循环次数。）
 ~ 如果没有合适的子控件，那么就认为自己最合适处理
 
3.事件响应
 ~ 找到最合适的视图控件后，会调用控件的 touches 方法来作具体的事件处理 touchesBegan…touchesMoved…touchedEnded…
 ~ 这些 touches 方法默认操作是：将事件沿着响应链向上传递，交给上一个响应者处理。（也是就是默认什么都不做，只传递给上层响应者）
 ~ 重写 touches 可以进行自定义操作，如果想让上一个响应者也响应事件，调用 [super touchesBegan:touches withEvent:event] 即可将事件向上传递
 ~ 如果 view 是控制器 VC 的根视图，view 会将事件响应传递给 VC（VC 继承自 UIResponder， 是响应链中的一个环节）
 ~ 根 VC 会将事件传递给 UIWindow，继续向上是 UIAppliction，如果 UIAppliction 也不响应事件，则将事件丢弃
*/






// 什么时候调用:只要事件一传递给一个控件，那么这个控件就会调用自己的这个方法
// 作用:寻找并返回最合适的view
// UIApplication -> [UIWindow hitTest:withEvent:]寻找最合适的view告诉系统
// point:当前手指触摸的点
// point:是方法调用者坐标系上的点
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
//    NSLog(@"判断！%@", self);
    
    //  1.判断下窗口能否接收事件
    /*  如果控件:
         不允许交互：userInteractionEnabled == NO；
         隐藏 hidden == YES；
         或者透明 alpha <= 0.01，
        则控件不能接收事件，其子控件也不能再接收事件
     */
    if (self.userInteractionEnabled == NO || self.hidden == YES ||  self.alpha <= 0.01) return nil;

    //  2.判断下点在不在窗口上
    //  不在窗口上
    if ([self pointInside:point withEvent:event] == NO) return nil;

    //  3.从后往前遍历子控件数组
    __block UIView *fitView = nil;
    [self.subviews enumerateObjectsWithOptions:(NSEnumerationReverse)
                                    usingBlock:^(UIView * obj, NSUInteger idx, BOOL *stop) {
        // 坐标系的转换，把自己控件上的点转换成子控件上的点
        CGPoint subviewP = [self convertPoint:point toView:obj];
        // 调用子控件的 -hitTest:withEvent: 方法
        fitView  = [obj hitTest:subviewP withEvent:event];
        if (fitView) {
            *stop = YES;
        }
    }];
    
    if (fitView) {
        return fitView;
    }

    // 4.没有找到更合适的view，也就是没有比自己更合适的view
    return self;
}

//  作用:判断下传入过来的点在不在方法调用者的坐标系上
//  point:是方法调用者坐标系上的点，可以重写此方法来更改控件接收事件的范围，如圆形范围、超出控件区域的的坐标
//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
// return NO;
//}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    NSLog(@"开始触摸！%@", self);
//    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    NSLog(@"正在移动...");
    // 想让控件随着手指移动而移动,监听手指移动
    // 获取UITouch对象
    UITouch *touch = [touches anyObject];
    // 获取当前点的位置
    CGPoint curP = [touch locationInView:self];
    // 获取上一个点的位置
    CGPoint preP = [touch previousLocationInView:self];
    // 获取它们x轴的偏移量,每次都是相对上一次
    CGFloat offsetX = curP.x - preP.x;
    // 获取y轴的偏移量
    CGFloat offsetY = curP.y - preP.y;
    // 修改控件的形变或者frame,center,就可以控制控件的位置
    // 形变也是相对上一次形变(平移)
    // CGAffineTransformMakeTranslation:会把之前形变给清空,重新开始设置形变参数
    // make:相对于最原始的位置形变
    // CGAffineTransform t:相对这个t的形变的基础上再去形变
    // 如果相对哪个形变再次形变,就传入它的形变
    self.transform = CGAffineTransformTranslate(self.transform, offsetX, offsetY);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    NSLog(@"触摸结束。");
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    NSLog(@"触摸被取消了。。。");
}

- (void)touchesEstimatedPropertiesUpdated:(NSSet<UITouch *> *)touches {
    
}



@end
