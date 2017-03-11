//
//  FullPageCollectionViewLayout.swift
//  HelloWorld
//
//  Created by Shunji Li on 3/10/17.
//  Copyright © 2017 shunji_li. All rights reserved.
//

import UIKit
class FullPageCollectionViewLayout: UICollectionViewFlowLayout {
  
  override init() {
    super.init()
    scrollDirection = .horizontal
    minimumLineSpacing = 10
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

