//
//  ShapeViewModel.swift
//  FolioReaderKit
//
//  Created by Santiago Carmona on 5/11/19.
//  Copyright © 2019 FolioReader. All rights reserved.
//

import UIKit

struct ShapeViewModel {
    enum ShapeType {
        case circle, triangle, rectangle, arrow
    }
    var `type`: ShapeType = .circle
    var fillColor: UIColor = .blue
    var borderColor: UIColor = .black
    var borderWidth: CGFloat = 0
}
