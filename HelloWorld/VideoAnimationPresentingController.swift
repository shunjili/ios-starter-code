//
//  VideoAnimationController.swift
//  HelloWorld
//
//  Created by shunji_li on 3/11/17.
//  Copyright © 2017 shunji_li. All rights reserved.
//

import UIKit

class VideoAnimationPresentingController: NSObject, UIViewControllerAnimatedTransitioning {

  var indexPath: IndexPath = IndexPath(item: 0, section: 0)

  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return TimeInterval(floatLiteral: 0.4)
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) ,
      let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
        return
    }

    let mapVC = toVC as! MapViewController
    let container = transitionContext.containerView

    let originalFrame = container.bounds

    guard let snapShot = fromVC.view.snapshotView(afterScreenUpdates: true) else { return }
    guard let _ = toVC.view.snapshotView(afterScreenUpdates: true) else { return }
    snapShot.frame = originalFrame
    snapShot.layer.masksToBounds = true

    container.addSubview(toVC.view)
    container.addSubview(snapShot)

    mapVC.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    mapVC.collectionView.setNeedsLayout()
    mapVC.collectionView.layoutIfNeeded()
    let destinationFrame = mapVC.itemFrameForIndexPath(indexPath: self.indexPath)

    let duration = transitionDuration(using: transitionContext)

    mapVC.collectionView.transform = transformFromRect(from: destinationFrame, toRect: container.bounds)
    UIView.animate(withDuration: duration, animations: { 
      snapShot.transform = transformFromRect(from: originalFrame, toRect: destinationFrame)
      snapShot.alpha = 0.0
      mapVC.collectionView.transform = CGAffineTransform.identity
    }) { completed in
      snapShot.removeFromSuperview()
      transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }

  }
}
