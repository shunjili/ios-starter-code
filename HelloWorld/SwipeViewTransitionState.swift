//
//  SwipeViewTransitionState.swift
//  HelloWorld
//
//  Created by shunji_li on 3/14/17.
//  Copyright © 2017 shunji_li. All rights reserved.
//

import UIKit

enum SwipeTransitionState {
  case expanded
  case expanding(
    initialContentOffset: CGFloat,
    pageBeforeTransition: Int
  )
  case shrinking(
    initialContentOffset: CGFloat,
    pageBeforeTransition: Int
  )
  case shrinked

  static func == (lhs: SwipeTransitionState, rhs: SwipeTransitionState) -> Bool {
    switch (lhs, rhs) {
    case (.expanded, .expanded),
         (.shrinked, .shrinked),
         (.expanding(_, _), .expanding(_, _)),
         (.shrinking(_, _), .shrinking(_, _)):
      return true
    default:
      return false
    }
  }
}
