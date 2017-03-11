//
//  ViewController.swift
//  HelloWorld
//
//  Created by shunji_li on 10/29/16.
//  Copyright © 2016 shunji_li. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor.green
    self.fullPageLayout = FullPageCollectionViewLayout()
    self.navigationController?.navigationBar.isTranslucent = false
    collectionView = MemoriesCollectionView(frame: .zero, collectionViewLayout: fullPageLayout)
    
    setUpCollectionView()
    setUpPanGestureRecognizer()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    if !initialLayout {
      collectionView.frame = view.bounds
      fullPageLayout.itemSize = collectionView.bounds.size
      initialLayout = true
    }
  }
  
  private var collectionView: UICollectionView!
  fileprivate var fullPageLayout: FullPageCollectionViewLayout!
  private var initialLayout: Bool = false
  private var heightBeforeTransition: CGFloat?
  private var currentItemIndex: Int = 0
  
  private func setUpCollectionView() {
    view.addSubview(collectionView)
    collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.clipsToBounds = true
  }
  
  private func setUpPanGestureRecognizer() {
    let gestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(updateCollectionViewFrame))
    view.addGestureRecognizer(gestureRecognizer)
  }
  
  @objc private func updateCollectionViewFrame(recognizer : UIPinchGestureRecognizer) {
    switch recognizer.state {
    case .began:
      heightBeforeTransition = collectionView.frame.height
      currentItemIndex = Int(floor(collectionView.contentOffset.x/(fullPageLayout.itemSize.width + fullPageLayout.minimumLineSpacing)))
    case .changed:
      guard let heightBeforeTransition = heightBeforeTransition else { return }

      // calculate the new collection view frame
      let percentage = min(max(heightBeforeTransition * recognizer.scale / view.bounds.height, 0.3), 1)
      var collectionViewFrame = collectionView.frame
      collectionViewFrame.size.height = view.bounds.height * percentage
      
      // calcualte the new item size at the current height
      let newItemHeight = collectionViewFrame.height - 30 * (1-percentage)/0.7
      let newItemWidth = view.bounds.width - (view.bounds.width - 100) * (1 - percentage)/0.7
      fullPageLayout.itemSize = CGSize(width: newItemWidth, height: newItemHeight)
      
      collectionView.frame = collectionViewFrame
      collectionView.frame.origin.y = view.bounds.height - collectionView.frame.height
      collectionView.contentOffset.x = (fullPageLayout.itemSize.width + fullPageLayout.minimumLineSpacing) * CGFloat(currentItemIndex)
    default: break
    }
  }
}

extension ViewController: UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 10
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    cell.backgroundColor = indexPath.item % 2 == 0 ? UIColor.yellow : UIColor.blue
    return cell
  }
  
}

extension ViewController: UICollectionViewDelegate {
  
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    guard scrollView.frame.size == view.bounds.size else { return }
    let index = floor((scrollView.contentOffset.x + view.bounds.width/2 + velocity.x * 200) / (view.bounds.width + fullPageLayout.minimumLineSpacing))
    targetContentOffset.pointee.x = index * (fullPageLayout.minimumLineSpacing + view.bounds.width)
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    print("selected me")
  }
}


