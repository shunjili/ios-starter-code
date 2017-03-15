//
//  SwipeView.swift
//  HelloWorld
//
//  Created by shunji_li on 3/13/17.
//  Copyright © 2017 shunji_li. All rights reserved.
//

import UIKit

@objc protocol SwipeViewDelegate: UIScrollViewDelegate {
  func didSelect(at index: Int)
}

protocol SwipeViewDataSource: class {
  func numberOfViews() -> Int
  func view(at index: Int) -> UIView
}

class SwipeView: UIScrollView {

  static let ShrinkedHeight: CGFloat = 320
  static let ShrinkedPadding: CGFloat = 16
  static let ShrinkedCellWidth: CGFloat = 150

  init(frame: CGRect, gap: CGFloat) {
    self.gap = gap

    super.init(frame: frame)
    self.backgroundColor = UIColor.gray
    self.clipsToBounds = true

    isDirectionalLockEnabled = true
    setUpGestureRecognizer()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  var transitionState: SwipeTransitionState = .expanded

  weak var dataSource: SwipeViewDataSource? {
    didSet {
      reload()
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    if initialSize == nil {
      initialSize = bounds.size
    }
    layoutItemViews()
  }

  override var bounds: CGRect {
    didSet {
      layoutItemViews()
    }
  }

  func reload() {
    guard let dataSource = dataSource else { return }
    cellIndexMapping.removeAll()
    subviews.forEach { $0.removeFromSuperview() }
    for i in 0..<dataSource.numberOfViews() {
      let view = dataSource.view(at: i)
      cellIndexMapping[i] = view
      addSubview(view)
    }
    self.layoutItemViews()
  }

  func currentPage() -> Int {
    return Int(floor(contentOffset.x + bounds.width/2) / (currentCellSize().width + gap))
  }

  @objc func handleTap(gestureRecognizer: UITapGestureRecognizer) {
    let coordinate = gestureRecognizer.location(in: self)
    let index = Int(floor(coordinate.x / (currentCellSize().width + gap)))
    guard let delegate = delegate as? SwipeViewDelegate else { return }
    delegate.didSelect(at: index)
  }

  func page(at coordinate: CGPoint) -> Int {
    let index = Int(floor(coordinate.x / (currentCellSize().width + gap)))
    return index
  }

  // MARK: Private

  private let gap: CGFloat
  private var initialSize: CGSize?
  private var cellIndexMapping: [Int: UIView] = [:]
  private var contentOffSetXBeforeTransition: CGFloat = 0
  private var pageIndexBeforeTransition: Int = 0


  private func layoutItemViews() {
    guard let dataSource = dataSource else { return }

    let cellSize = currentCellSize()

    let height = bounds.height
    let width = (cellSize.width + gap) * CGFloat(dataSource.numberOfViews()) + (bounds.width - cellSize.width - gap)
    contentSize = CGSize(width: width, height: height)

    cellIndexMapping.forEach { index, view in
      view.frame = frameForView(at: index)
    }
    switch transitionState {
    case let .expanding(initialOffset, page):
      let targetContentOffset = (bounds.width) * CGFloat(page)
      contentOffset.x = intermediateValue(from: initialOffset, to: targetContentOffset, percentage: 1 - transitionPercentage())
    case let .shrinking(initialOffset, page):
      let targetContentOffset = (gap + SwipeView.ShrinkedCellWidth) * CGFloat(page)
      contentOffset.x = intermediateValue(from: initialOffset, to: targetContentOffset, percentage: transitionPercentage())
    default: break
    }
  }

  private func setUpGestureRecognizer() {
    let tagGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
    addGestureRecognizer(tagGestureRecognizer)
  }

  private func currentCellSize() -> CGSize {
    guard let initialSize = initialSize else { return .zero }
    let cellHeight = intermediateValue(from: initialSize.height, to: SwipeView.ShrinkedHeight - 2 * SwipeView.ShrinkedPadding, percentage: transitionPercentage())
    let cellWidth = intermediateValue(from: initialSize.width - gap, to: SwipeView.ShrinkedCellWidth, percentage: transitionPercentage())
    return CGSize(width: cellWidth, height: cellHeight)
  }

  private func frameForView(at index: Int) -> CGRect {
    let cellSize = currentCellSize()
    let origin = CGPoint(x: CGFloat(index) * (cellSize.width + gap) + gap/2, y: SwipeView.ShrinkedPadding * transitionPercentage())
    return CGRect(origin: origin, size: cellSize)
  }

  private func intermediateValue(from: CGFloat, to: CGFloat, percentage: CGFloat) -> CGFloat {
    return from + (to - from) * percentage
  }

  private func transitionPercentage() -> CGFloat {
    guard let initialHeight = initialSize?.height else { return 0 }
    let result =  (initialHeight - bounds.size.height) / (initialHeight - SwipeView.ShrinkedHeight)
    return result
  }
  
}
