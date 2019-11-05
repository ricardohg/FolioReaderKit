//
//  ColorPickerView.swift
//  ShapeTool
//
//  Created by Santiago Carmona on 27/10/19.
//  Copyright © 2019 Santiago Carmona. All rights reserved.
//

import UIKit

protocol ColorPickerViewDelegate: class {
    func colorPickerView(_ colorPickerView: ColorPickerView, didSelect color: UIColor)
    func colorPickerView(_ colorPickerView: ColorPickerView, didTouchUpInside button: UIButton)
}

class ColorPickerView: UIView {
    
    // MARK: - IBOutlets
    @IBOutlet weak var colorCollectionView: UICollectionView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet weak var pickedColorImage: UIImageView!
    
    // MARK: - Vars & Constants
    weak var delegate: ColorPickerViewDelegate?
    
    private let colors: [UIColor] = [
        UIColor(red: 0.29, green: 0.56, blue: 0.89, alpha: 1),
        UIColor(red: 0.32, green: 0.7, blue: 0.39, alpha: 1),
        UIColor(red: 0.97, green: 0.81, blue: 0.11, alpha: 1),
        UIColor(red: 0.95, green: 0.48, blue: 0.07, alpha: 1),
        UIColor(red: 0.95, green: 0.28, blue: 0.28, alpha: 1),
        UIColor(red: 0.94, green: 0.55, blue: 0.73, alpha: 1),
        UIColor(red: 0.41, green: 0.42, blue: 0.83, alpha: 1),
        UIColor(red: 0.43, green: 0.43, blue: 0.43, alpha: 1),
        UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
    ]
            
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func picked(color: UIColor) {
           let coloreEllipse = UIImage.ellipseWithColor(color, size: 19, border: nil)
           self.pickedColorImage.image = coloreEllipse
           delegate?.colorPickerView(self, didSelect: color)
       }
    
    private func commonInit() {
        let view = Bundle(for: ColorPickerView.self).loadNibNamed("ColorPickerView", owner: self, options: nil)?.first as! UIView
        addSubview(view)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setupColorsCollectionView()
    }
    
    private func setupColorsCollectionView() {
        let nib = UINib(nibName: "ColorCollectionViewCell", bundle: Bundle(for: ColorCollectionViewCell.self))
        colorCollectionView.register(nib, forCellWithReuseIdentifier: ColorCollectionViewCell.Constants.cellIdentifier)
        colorCollectionView.reloadData()
    }
    
    private func colorButton() -> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        button.layer.cornerRadius = button.frame.width / 2
        button.widthAnchor.constraint(equalToConstant: 22).isActive = true
        button.heightAnchor.constraint(equalToConstant: 22).isActive = true
        button.addTarget(self, action: #selector(didSelectColor), for: .touchUpInside)
        return button
    }
    
    @objc private func didSelectColor(sender: UIButton) {
        guard let color = sender.backgroundColor else {
            return
        }
        picked(color: color)
    }
    
    @IBAction private func selectCustomColorTouchUpInside(_ sender: UIButton) {
        delegate?.colorPickerView(self, didTouchUpInside: sender)
    }
}

extension ColorPickerView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - Collection View delegates -
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.Constants.cellIdentifier, for: indexPath) as? ColorCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let color = colors[indexPath.row]
        cell.colorImage = color
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let color = colors[indexPath.row]
        picked(color: color)
    }
}
