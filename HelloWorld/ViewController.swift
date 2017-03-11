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
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    if !initialLayout {
      collectionView.frame = view.bounds
      fullPageLayout.itemSize = collectionView.bounds.size
      initialLayout = true
    }
  }
  
  private var initialLayout: Bool = false
  private var heightBeforeTransition: CGFloat?
  private var currentItemIndex: Int = 0

  fileprivate var fullPageLayout: FullPageCollectionViewLayout!
  fileprivate var presentingAnimationController = VideoAnimationPresentingController()
  fileprivate var dismissAnimationController = VideoAnimationDismissController()
  fileprivate var collectionView: UICollectionView!
  fileprivate var mapVC: MapViewController?

  private func setUpCollectionView() {
    view.addSubview(collectionView)
    collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.clipsToBounds = true
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
    let mapVC = self.mapVC ?? MapViewController()
    mapVC.delegate = self
    presentingAnimationController.indexPath = indexPath
    mapVC.modalPresentationStyle = .custom
    mapVC.transitioningDelegate = self
    self.present(mapVC, animated: true, completion: nil)
  }
}

extension ViewController: MapViewControllerDelegate {
  func didSelectItem(at indexPath: IndexPath) {
    self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    self.presentingAnimationController.indexPath = indexPath
    self.dismissAnimationController.indexPath = indexPath
    self.view.setNeedsLayout()
    self.view.layoutIfNeeded()
  }
}

extension ViewController: UIViewControllerTransitioningDelegate {

  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return presentingAnimationController
  }

  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {

    return dismissAnimationController
  }
}

