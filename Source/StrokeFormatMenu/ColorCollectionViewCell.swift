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
            guard colorImage != nil else { return }
            setColorImage(with: colorImage!)
        }
    }
    
    // MARK: - Constants -

    internal struct Constants {
        static let cellIdentifier = "ColorCollectionViewCell"
    }
    
    // MARK: - UI Setup -
    
    func setColorImage(with color: UIColor) {
        let coloredEllipse = UIImage.ellipseWithColor(color, size: 19)
        colorEllipse.image = coloredEllipse
    }

}
