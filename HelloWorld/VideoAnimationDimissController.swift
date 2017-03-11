//
//  VideoAnimationDimissController.swift
//  HelloWorld
//
//  Created by shunji_li on 3/11/17.
//  Copyright © 2017 shunji_li. All rights reserved.
//

import UIKit

//
//  VideoAnimationController.swift
//  HelloWorld
//
//  Created by shunji_li on 3/11/17.
//  Copyright © 2017 shunji_li. All rights reserved.
//

import UIKit

class VideoAnimationDismissController: NSObject, UIViewControllerAnimatedTransitioning {

  var indexPath: IndexPath = IndexPath(item: 0, section: 0)

  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return TimeInterval(floatLiteral: 0.4)
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) ,
      let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
        return
    }

    let mapVC = fromVC as! MapViewController
    let container = transitionContext.containerView
    let originalFrame = mapVC.itemFrameForIndexPath(indexPath: self.indexPath)
    let destinationFrame = container.bounds

    guard let snapShot = fromVC.view.snapshotView(afterScreenUpdates: true) else { return }
    guard let _ = toVC.view.snapshotView(afterScreenUpdates: true) else { return }

    container.addSubview(snapShot)


    let duration = transitionDuration(using: transitionContext)

    UIView.animate(withDuration: duration, animations: {
      var zoomTransform: CGAffineTransform = transformFromRect(from: originalFrame, toRect: destinationFrame)
      zoomTransform.tx = zoomTransform.tx * zoomTransform.a
      zoomTransform.ty = zoomTransform.ty * zoomTransform.d
      snapShot.transform = zoomTransform
    }) { completed in
      snapShot.removeFromSuperview()
      transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }

  }
}

func transformFromRect(from: CGRect, toRect to: CGRect) -> CGAffineTransform {
  let transform = CGAffineTransform(translationX: to.midX-from.midX, y: to.midY-from.midY)
  return transform.scaledBy(x: to.width/from.width, y: to.height/from.height)
}

