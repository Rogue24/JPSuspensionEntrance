//
//  JPPopInteraction.h
//  JPSuspensionEntrance
//
//  Created by 周健平 on 2018/6/14.
//  Copyright © 2018 周健平. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^JPEdgeLeftPanBegan)(UIScreenEdgePanGestureRecognizer *edgeLeftPanGR);
typedef void (^JPEdgeLeftPanChanged)(CGFloat persent, UIScreenEdgePanGestureRecognizer *edgeLeftPanGR);
typedef void (^JPEdgeLeftPanWillEnded)(BOOL isToFinish, UIScreenEdgePanGestureRecognizer *edgeLeftPanGR);
typedef void (^JPEdgeLeftPanEnded)(BOOL isFinish, UIScreenEdgePanGestureRecognizer *edgeLeftPanGR);

/**
 * 左边沿的手势交互对象
 */
@interface JPPopInteraction : UIPercentDrivenInteractiveTransition
@property (nonatomic, assign) BOOL interaction;
@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *edgeLeftPanGR;
@property (nonatomic, copy) JPEdgeLeftPanBegan panBegan;
@property (nonatomic, copy) JPEdgeLeftPanChanged panChanged;
@property (nonatomic, copy) JPEdgeLeftPanWillEnded panWillEnded;
@property (nonatomic, copy) JPEdgeLeftPanEnded panEnded;
@end
