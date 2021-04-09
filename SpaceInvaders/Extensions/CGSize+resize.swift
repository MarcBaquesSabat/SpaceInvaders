//
//  CGSize+resize.swift
//  SpaceInvaders
//
//  Created by Guillermo Fernandez on 25/03/2021.
//

import Foundation
import UIKit

extension CGSize {
    mutating func resize(to percent: CGFloat) {
        guard percent < 1 else { return }

        self.width *= percent
        self.height *= percent
    }
}
