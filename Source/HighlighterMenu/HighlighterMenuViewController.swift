//
//  HighlighterMenuViewController.swift
//  FolioReaderKit
//
//  Created by Catalina Sanchez on 6/14/19.
//  Copyright © 2019 FolioReader. All rights reserved.
//

import Foundation
import UIKit

class HighlighterMenuViewController: UITableViewController {
    
    // MARK: - Properties -
    
    @IBOutlet weak var colorCollectionView: UICollectionView!
    
    var selectedColor: ((HighlightStyle) -> ())?
    var currentColor: HighlightStyle = .yellow
    
    // MARK: - Constants -
    
    struct Constants {
        static let colorPickerStoryboardName = "StrokeFormatMenu"
        static let colorPickerViewControllerIdentifier = "colorPickerView"
        static let viewHeight = 70
        static let viewWidth = 140
        static let fontName = "SFProDisplay-Regular"
        static let fontSize: CGFloat = 18
    }
    
    private let highlightColors: [HighlightStyle] = [.yellow, .green, .blue, .pink]
}

extension HighlighterMenuViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - Collection View delegates -
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return highlightColors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.Constants.cellIdentifier, for: indexPath) as? ColorCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let color = highlightColors[indexPath.row]
        
        if color == currentColor {
            cell.isSelected = true
        }
        
        cell.colorImage = HighlightStyle.colorForStyle(color.rawValue)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let color = highlightColors[indexPath.row]
        selectedColor?(color)
        currentColor = color
        
        if let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell {
            cell.isSelected = true
            let color = highlightColors[indexPath.row]
            
            cell.colorImage = HighlightStyle.colorForStyle(color.rawValue)
        }
        
        self.dismiss()
    }
}
