//
//  ColorCollectionViewCell.swift
//  FolioReaderKit
//
//  Created by Santiago Carmona on 4/11/19.
//  Copyright © 2019 FolioReader. All rights reserved.
//

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
    
    // MARK: - Constants -

    internal struct Constants {
        static let cellIdentifier = "ColorCollectionViewCell"
    }
    
    // MARK: - UI Setup -
    
    private func setColorImage(with color: UIColor) {
        if self.isSelected {
            let coloredEllipse = UIImage.ellipseWithColor(color, size: 19, border: .black)
            colorEllipse.image = coloredEllipse
        } else {
            let coloredEllipse = UIImage.ellipseWithColor(color, size: 19, border: nil)
            colorEllipse.image = coloredEllipse
        }
    }

}
