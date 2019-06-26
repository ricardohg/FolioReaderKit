//
//  ColorCollectionViewCell.swift
//  FolioReaderKit
//
//  Created by Catalina Sanchez on 3/21/19.
//  Copyright © 2019 FolioReader. All rights reserved.
//

import Foundation
import UIKit

class ColorCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties -
    
    @IBOutlet weak var colorEllipse: UIImageView!
    
    var colorImage: UIColor? {
        didSet {
            guard let colorImage = colorImage else { return }
            setColorImage(with: colorImage)
        }
    }
    
    var highlightStyle: HighlightStyle? {
        didSet {
            guard let highlightStyle = highlightStyle else { return }
            setImage(for: highlightStyle)
        }
    }
    
    // MARK: - Constants -

    internal struct Constants {
        static let cellIdentifier = "ColorCollectionViewCell"
    }
    
    // MARK: - UI Setup -
    
    private func setColorImage(with color: UIColor) {
        let coloredEllipse = UIImage.ellipseWithColor(color, size: 19)
        colorEllipse.image = coloredEllipse
    }
    
    private func setImage(for color: HighlightStyle) {
        switch color {
        case .yellow:
            colorEllipse.image = UIImage(readerImageNamed: "yellow-marker")
        case .green:
            colorEllipse.image = UIImage(readerImageNamed: "green-marker")
        case .blue:
            colorEllipse.image = UIImage(readerImageNamed: "blue-marker")
        case .pink:
            colorEllipse.image = UIImage(readerImageNamed: "pink-marker")
        case .underline:
            break
        }
    }
}
