//
//  ShapeMenuViewController.swift
//  FolioReaderKit
//
//  Created by Santiago Carmona on 30/10/19.
//  Copyright © 2019 FolioReader. All rights reserved.
//

import UIKit

class ShapeMenuViewController: UIViewController {
    
    // MARK: - IBOutlets -
    
    @IBOutlet weak private var shapeStackView: UIStackView!
    @IBOutlet weak private var backgroundTitleLabel: UILabel!
    @IBOutlet weak private var backgroundColorPickerView: ColorPickerView!
    @IBOutlet weak private var borderColorPickerView: ColorPickerView!
    @IBOutlet weak private var borderSlider: UISlider!
    
    // MARK: - Vars & Constants -
    
    var createShape: ((ShapeViewModel) -> Void)?
    var changeShape: ((ShapeViewModel) -> Void)?
    var dismissed: (() -> Void)?
    var viewModel: ShapeViewModel = .init()
    
    // MARK: - Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupShapeStackView()
        setupBackgroundColorPickerView()
        setupBorderColorPickerView()
        setupBorderSlider()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dismissed?()
    }
    
    private func setupShapeStackView() {
        shapeStackView.arrangedSubviews.forEach { (view) in
            view.layer.borderWidth = 1.0
            view.layer.borderColor = UIColor.gray.cgColor
        }
    }
    
    private func setupBackgroundColorPickerView() {
        backgroundColorPickerView.delegate = self
    }
    
    private func setupBorderColorPickerView() {
        borderColorPickerView.delegate = self
    }
    
    private func setupBorderSlider() {
        let thumbImage = UIImage.ellipseWithColor(.black, size: nil, border: nil)
        
        borderSlider.setThumbImage(thumbImage, for: .normal)
        borderSlider.setThumbImage(thumbImage, for: .highlighted)
    }
    
    @IBAction private func createCircle(_ sender: Any) {
        viewModel.type = .circle
        createShape?(viewModel)
    }
    
    @IBAction private func createTriangle(_ sender: Any) {
        viewModel.type = .triangle
        createShape?(viewModel)
    }
    
    @IBAction private func createSquare(_ sender: Any) {
        viewModel.type = .rectangle
        createShape?(viewModel)
    }
    
    @IBAction private func createArrow(_ sender: Any) {
        viewModel.type = .arrow
        createShape?(viewModel)
    }
    
    @IBAction private func changeBorderWidth(_ sender: UISlider) {
        viewModel.borderWidth = CGFloat(sender.value)
        changeShape?(viewModel)
    }
}


extension ShapeMenuViewController: ColorPickerViewDelegate {
    func colorPickerView(_ colorPickerView: ColorPickerView, didSelect color: UIColor) {
        if colorPickerView === backgroundColorPickerView {
            viewModel.fillColor = color
        } else if colorPickerView === borderColorPickerView {
            viewModel.borderColor = color
        }
        changeShape?(viewModel)
    }
    
    func colorPickerView(_ colorPickerView: ColorPickerView, didTouchUpInside button: UIButton) {
        let storyboard = UIStoryboard(name: "StrokeFormatMenu", bundle: Bundle(for: StrokeFormatMenuTableViewController.self))
        guard let colorPickerViewController =
            storyboard.instantiateViewController(withIdentifier: "colorPickerView") as? ColorPickerCollectionViewController else { return }
        
        colorPickerViewController.modalPresentationStyle = .popover
        colorPickerViewController.preferredContentSize = CGSize(width: 220, height: 370)
        colorPickerViewController.popoverPresentationController?.sourceRect = CGRect(x: 100, y: 0, width: 85, height: 40)
        colorPickerViewController.popoverPresentationController?.permittedArrowDirections = .any
        colorPickerViewController.popoverPresentationController?.sourceView = button
        
        colorPickerViewController.pickedColor = { color in
            colorPickerView.picked(color: color)
        }
        
        present(colorPickerViewController, animated: true, completion: nil)
    }
}
