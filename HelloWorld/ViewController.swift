//
//  ViewController.swift
//  HelloWorld
//
//  Created by shunji_li on 10/29/16.
//  Copyright © 2016 shunji_li. All rights reserved.
//

import UIKit
import pop

private let gap: CGFloat = 16

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    swipeView = SwipeView(frame: .zero, gap: gap)

    setUpSwipeView()
    setUpGestureRecognizer()
  }

  var swipeView: SwipeView!

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if !hasFirstLayout {
      swipeView.frame = view.bounds
      swipeView.frame.origin.x = -gap/2
      swipeView.frame.size.width += gap
      hasFirstLayout = true
    }
  }


  @objc func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
    switch gestureRecognizer.state {
    case .began:
      swipeHeightBeforeTouch = swipeView.bounds.height
      contentOffsetPercentageBeforeTouch = (swipeView.contentOffset.x + swipeView.bounds.width/2) / swipeView.contentSize.width
      swipeView.isPagingEnabled = false
      let coordinateInSwipeView = gestureRecognizer.location(in: swipeView)
      switch swipeView.transitionState {
      case .expanded:
        swipeView.transitionState = .shrinking(initialContentOffset: swipeView.contentOffset.x, pageBeforeTransition: swipeView.page(at: coordinateInSwipeView))
      case .shrinked:
        swipeView.transitionState = .expanding(initialContentOffset: swipeView.contentOffset.x, pageBeforeTransition: swipeView.page(at: coordinateInSwipeView))
      default:
        break
      }
    case .changed:
      guard let swipeHeightBeforeTouch = swipeHeightBeforeTouch else { return }
      swipeView.frame.size.height = min(max(swipeHeightBeforeTouch - gestureRecognizer.translation(in: view).y, SwipeView.ShrinkedHeight), self.view.bounds.height)
      swipeView.frame.origin.y = view.bounds.height - swipeView.frame.size.height
    case .ended:
      switch swipeView.transitionState {
      case .expanding(_, _):
        expandSwipeViewToMaximum() { [weak self] in
          self?.swipeViewDidExpand()
        }
      case .shrinking(_, _):
        shrinkSwipeViewToMinimum(completion: { [weak self] in
          self?.swipeViewDidShrink()
        })
      default: break
      }
    default: break
    }
  }

  // MARK: Private

  private var hasFirstLayout: Bool = false
  private var translationThreshhold: CGFloat {
    return view.bounds.height * 0.7
  }

  private var swipeHeightBeforeTouch: CGFloat?
  private var contentOffsetPercentageBeforeTouch: CGFloat = 0
  fileprivate var panGestureRecognizer: UIPanGestureRecognizer!

  private func setUpSwipeView() {
    swipeView.dataSource = self
    swipeView.delegate = self
    view.addSubview(swipeView)
  }

  private func setUpGestureRecognizer() {
    // this pan gesture recognizer is to control the expanding and contracting of the swipe view
    let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gestureRecognizer:)))
    panGestureRecognizer.delegate = self
    swipeView.addGestureRecognizer(panGestureRecognizer)
    self.panGestureRecognizer = panGestureRecognizer
  }

  private func animateSwipeToDestinationFrame(completion: ((Void) -> Void)?) {
    switch swipeView.transitionState {
    case .shrinking(_, _):
      shrinkSwipeViewToMinimum { completion?() }
    case .expanding(_, _):
      expandSwipeViewToMaximum() { completion?() }
    default: break
    }
  }

  private func shrinkSwipeViewToMinimum(completion: ((Void) -> Void)?) {
    let popAnimation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
    popAnimation?.springBounciness = 5
    var finalFrame = self.swipeView.frame
    finalFrame.size.height = SwipeView.ShrinkedHeight
    finalFrame.origin.y = view.bounds.height - finalFrame.size.height
    popAnimation?.toValue = NSValue(cgRect: finalFrame)
    popAnimation?.completionBlock = { _ in
      completion?()
    }

    self.swipeView.pop_add(popAnimation, forKey: "size")

  }

  fileprivate func expandSwipeViewToMaximum(completion: ((Void) -> Void)?) {
    let popAnimation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
    popAnimation?.springBounciness = 5
    var finalFrame = self.swipeView.frame
    finalFrame.size.height = self.view.bounds.height
    finalFrame.origin.y = 0
    popAnimation?.toValue = NSValue(cgRect: finalFrame)
    popAnimation?.completionBlock = { _ in
      completion?()
    }

//    let pagingAnimation = POPBasicAnimation(propertyNamed: kPOPScrollViewContentOffset)
//    let targetX = CGFloat(index) * swipeView.bounds.width
//    pagingAnimation?.toValue = NSValue(cgPoint: CGPoint(x: targetX, y: 0))
    self.swipeView.pop_add(popAnimation, forKey: "size")
//    self.swipeView.pop_add(pagingAnimation, forKey: "paging")
  }

  fileprivate func swipeViewDidExpand() {
    self.swipeView.isPagingEnabled = true
    self.swipeView.transitionState = .expanded
  }

  fileprivate func swipeViewDidShrink() {
    self.swipeView.isPagingEnabled = false
    self.swipeView.transitionState = .shrinked
  }
}

extension ViewController: SwipeViewDataSource {

  func numberOfViews() -> Int {
    return 10
  }

  func view(at index: Int) -> UIView {
    let view = UIView()
    view.backgroundColor = index % 2 == 0 ? UIColor.yellow : UIColor.blue
    return view
  }
}

extension ViewController: UIGestureRecognizerDelegate, SwipeViewDelegate {

  func didSelect(at index: Int) {
    swipeView.transitionState = .expanding(initialContentOffset: swipeView.contentOffset.x, pageBeforeTransition: index)
    self.expandSwipeViewToMaximum() { [weak self] _ in
      self?.swipeViewDidExpand()
    }
  }

  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }

  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    if panGestureRecognizer == gestureRecognizer {
      return abs(panGestureRecognizer.translation(in: view).y) > abs(panGestureRecognizer.translation(in: view).x)
        && (swipeView.transitionState == .expanded || swipeView.transitionState == .shrinked)
    }

    if swipeView.panGestureRecognizer == gestureRecognizer {
      return abs(swipeView.panGestureRecognizer.translation(in: view).x) > abs(swipeView.panGestureRecognizer.translation(in: view).y)
    }

    return false
  }
  
}

