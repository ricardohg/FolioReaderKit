//
//  EraserMenuViewController.swift
//  FolioReaderKit
//
//  Created by Catalina Sanchez on 4/15/19.
//  Copyright © 2019 FolioReader. All rights reserved.
//

import Foundation
import UIKit

class EraserMenuViewController: UIViewController {
    
    // MARK: - Properties -
    
    @IBOutlet weak var eraserThicknessSlider: UISlider!
    
    internal var selectedEraserThickness: ((Double) -> ())?
    
    
    // MARK: - Initializers -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setThumbImage()
    }
    
    // MARK: - UI Setup -
    
    func setThumbImage() {
        
        let thumbSize = (CGFloat(eraserThicknessSlider.value) * 16) + 16
        selectedEraserThickness?(Double(thumbSize))
        let thumbImage = UIImage.ellipseWithColor(.black, size: thumbSize)
        
        eraserThicknessSlider.setThumbImage(thumbImage, for: .normal)
        eraserThicknessSlider.setThumbImage(thumbImage, for: .highlighted)
    }
    
    // MARK: - Actions -
    
    @IBAction func eraserThicknessSliderValueDidChange(_ sender: Any) {
        setThumbImage()
    }
}
