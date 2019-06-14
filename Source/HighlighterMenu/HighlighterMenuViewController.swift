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
    @IBOutlet weak var pickedColorImage: UIImageView!
    
    var selectedColor: ((UIColor) -> ())?
    
    // MARK: - Constants -
    
    struct Constants {
        static let colorPickerStoryboardName = "StrokeFormatMenu"
        static let colorPickerViewControllerIdentifier = "colorPickerView"
        static let viewHeight = 124
        static let viewWidth = 250
        static let fontName = "SFProDisplay-Regular"
        static let fontSize: CGFloat = 18
    }
    
    private let strokeColors: [UIColor] = [.lightBlue, .lightGreen, .lightYellow, .lightOrange, .lightRed, .pink, .lightPurple, .customGray, .lightWhite]

    // MARK: - Initializers -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        colorCollectionView.reloadData()
    }


    @IBAction func selectCustomColorTouchUpInside(_ sender: Any) {
        guard let colorPickerViewController = UIStoryboard(name: Constants.colorPickerStoryboardName, bundle: Bundle(for: StrokeFormatMenuTableViewController.self)).instantiateViewController(withIdentifier: Constants.colorPickerViewControllerIdentifier) as? ColorPickerCollectionViewController else { return }
        
        colorPickerViewController.modalPresentationStyle = .popover
        colorPickerViewController.preferredContentSize = CGSize(width: 220, height: 350)
        
        colorPickerViewController.popoverPresentationController?.sourceRect = CGRect(x: 100, y: 0, width: 85, height: 40)
        colorPickerViewController.popoverPresentationController?.permittedArrowDirections = .any
        colorPickerViewController.popoverPresentationController?.sourceView = sender as? UIView
        
        colorPickerViewController.pickedColor = { color in
            let coloredEllipse = UIImage.ellipseWithColor(color, size: 19)
            self.pickedColorImage.image = coloredEllipse
        }
        
        present(colorPickerViewController, animated: true, completion: nil)
    }
}

extension HighlighterMenuViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - Collection View delegates -
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return strokeColors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.Constants.cellIdentifier, for: indexPath) as? ColorCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let color = strokeColors[indexPath.row]
        cell.colorImage = color
//        currentColor = color
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let color = strokeColors[indexPath.row]
        selectedColor?(color)
//        currentColor = color
        let coloreEllipse = UIImage.ellipseWithColor(strokeColors[indexPath.row], size: 19)
        self.pickedColorImage.image = coloreEllipse
        
    }
}
