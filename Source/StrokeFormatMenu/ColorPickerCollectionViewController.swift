//
//  ColorPickerCollectionViewController.swift
//  FolioReaderKit
//
//  Created by Catalina Sanchez on 3/29/19.
//  Copyright © 2019 FolioReader. All rights reserved.
//

import Foundation
import UIKit

class ColorPickerCollectionViewController: UICollectionViewController {
    
    // MARK: - Properties -
    
    var colorPalette: [Any] = [Any]()
    var pickedColor: ((UIColor) -> ())?
    
    // MARK: - Initializers -
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let path = Bundle(for: ColorPickerCollectionViewController.self).path(forResource: "colorPalette", ofType: "plist"),
            let pListArray = NSArray(contentsOfFile: path) else {
                print("couldn't load color palette file")
                return
        }
        colorPalette = Array(pListArray)
    }
    
    
    // MARK: - CollectionView delegates -
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (colorPalette[section] as AnyObject).count
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return colorPalette.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as UICollectionViewCell
        
        let colorPaletteFileSection = colorPalette[indexPath.section] as? [String]
        
        guard let hexColor = colorPaletteFileSection?[indexPath.row] else { return cell }
        
        cell.backgroundColor = UIColor.hexStringToUIColor(hex: hexColor)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let colorPaletteFileSection = colorPalette[indexPath.section] as? [String]
        
        guard let hexColor = colorPaletteFileSection?[indexPath.row] else { return }
        
        let color = UIColor.hexStringToUIColor(hex: hexColor)
        pickedColor?(color)
        
        dismiss(animated: true, completion: nil)
    }
}
