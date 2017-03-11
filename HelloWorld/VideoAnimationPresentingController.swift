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
    guard let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
        return
    }

    let mapVC = toVC as! MapViewController
    let container = transitionContext.containerView


    guard let _ = toVC.view.snapshotView(afterScreenUpdates: true) else { return }


    container.addSubview(toVC.view)

    mapVC.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    mapVC.collectionView.setNeedsLayout()
    mapVC.collectionView.layoutIfNeeded()
    let destinationFrame = mapVC.itemFrameForIndexPath(indexPath: self.indexPath)

    let duration = transitionDuration(using: transitionContext)
    var zoomTransform =  transformFromRect(from: destinationFrame, toRect: container.bounds)
    zoomTransform.tx = zoomTransform.tx * zoomTransform.a
    mapVC.collectionView.transform = zoomTransform
    UIView.animate(withDuration: duration, animations: {
      mapVC.collectionView.transform = CGAffineTransform.identity
    }) { completed in
      transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }

  }
}
