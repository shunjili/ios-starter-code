//
//  MapViewController.swift
//  HelloWorld
//
//  Created by shunji_li on 3/11/17.
//  Copyright © 2017 shunji_li. All rights reserved.
//

import UIKit
import MapKit

protocol MapViewControllerDelegate: class {
  func didSelectItem(at indexPath: IndexPath)
}

class MapViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor.green
    self.fullPageLayout = FullPageCollectionViewLayout()
    self.navigationController?.navigationBar.isTranslucent = false
    collectionView = MemoriesCollectionView(frame: .zero, collectionViewLayout: fullPageLayout)
    mapView = MKMapView(frame: .zero)
    view.addSubview(mapView)
    setUpCollectionView()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    if !initialLayout {
      fullPageLayout.itemSize = CGSize(width: 150, height: 150 / view.bounds.width * view.bounds.height)
      collectionView.frame.size.height = fullPageLayout.itemSize.height + 24
      collectionView.frame.size.width = view.bounds.width
      collectionView.frame.origin.y = view.bounds.height - collectionView.frame.height
      mapView.frame.size.height = collectionView.frame.origin.y
      mapView.frame.size.width = view.bounds.width
      initialLayout = true
    }
  }

  weak var delegate: MapViewControllerDelegate?

  func itemFrameForIndexPath(indexPath: IndexPath) -> CGRect {
    let item = collectionView.cellForItem(at: indexPath)!
    return self.view.convert(item.frame, from: item.superview)
  }

  var collectionView: UICollectionView!
  var mapView: MKMapView!

  fileprivate var fullPageLayout: FullPageCollectionViewLayout!
  private var initialLayout: Bool = false
  private var heightBeforeTransition: CGFloat?
  private var currentItemIndex: Int = 0

  private func setUpCollectionView() {
    view.addSubview(collectionView)
    collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    collectionView.dataSource = self
    collectionView.clipsToBounds = true
    collectionView.delegate = self
  }

}

extension MapViewController: UICollectionViewDataSource {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 10
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    cell.backgroundColor = indexPath.item % 2 == 0 ? UIColor.yellow : UIColor.blue
    return cell
  }
  
}

extension MapViewController: UICollectionViewDelegate {

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    self.delegate?.didSelectItem(at: indexPath)
    self.dismiss(animated: true, completion: nil)
  }
}
