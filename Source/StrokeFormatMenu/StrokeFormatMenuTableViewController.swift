//
//  StrokeFormatMenuTableViewController.swift
//  FolioReaderKit
//
//  Created by Catalina Sanchez on 3/20/19.
//  Copyright © 2019 FolioReader. All rights reserved.
//

import Foundation

class StrokeFormatMenuTableViewController: UITableViewController {
    
    // MARK: - Properties -
    
    @IBOutlet weak var strokeTicknessSlider: UISlider!
    @IBOutlet weak var colorCollectionView: UICollectionView!
    @IBOutlet weak var pickedColorImage: UIImageView!
    
    var selectedStrokeThickness: ((Double) -> ())?
    var selectedStrokeColor: ((UIColor) -> ())?
    var selectedStrokeStyle: ((StrokeStyleType) -> ())?
    
    var saveState: ((UIColor, Double) -> ())?
    
    static let viewHeight = 270
    static let viewWidth = 250
    
    var currentColor: UIColor = .black
    var currrentThinkness: Double = 3

    private let strokeColors: [UIColor] = [.lightBlue, .lightGreen, .lightYellow, .lightOrange, .lightRed, .pink, .lightPurple, .customGray, .lightWhite]
    
    enum StrokeStyleType: Int {
        case basicStroke
        case curvyStroke
    }
    
    // MARK: - Constants -

    private struct Constants {
        static let fontName = "SFProDisplay-Regular"
        static let fontSize: CGFloat = 18
    }
    
    // MARK: - Initializers -

    override func viewDidLoad() {
        super.viewDidLoad()
    
        let coloredEllipse = UIImage.ellipseWithColor(currentColor, size: 19)
        self.pickedColorImage.image = coloredEllipse
        self.strokeTicknessSlider.value = Float(currrentThinkness)
        
        setThumbImage()
        colorCollectionView.reloadData()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.saveState?(currentColor, currrentThinkness)
    }
    
    // MARK: - UI Setup -

    func setThumbImage() {
        let thumbImage = UIImage.ellipseWithColor(.black, size: nil)
        
        strokeTicknessSlider.setThumbImage(thumbImage, for: .normal)
        strokeTicknessSlider.setThumbImage(thumbImage, for: .highlighted)
    }
    
    // MARK: - Actions -
    
    @IBAction func strokeThicknessValueDidChange(_ sender: Any) {
        let thinkness = Double(strokeTicknessSlider.value)
        self.selectedStrokeThickness?(thinkness)
        currrentThinkness = thinkness
    }
    
    @IBAction func selectCustomColorTouchUpInside(_ sender: Any) {
        guard let colorPickerViewController = storyboard?.instantiateViewController(withIdentifier: "colorPickerView") as? ColorPickerCollectionViewController else { return }
        
        colorPickerViewController.modalPresentationStyle = .popover
        colorPickerViewController.preferredContentSize = CGSize(width: 220, height: 350)
        colorPickerViewController.popoverPresentationController?.sourceRect = CGRect(x: 100, y: 0, width: 85, height: 40)
        colorPickerViewController.popoverPresentationController?.permittedArrowDirections = .any
        colorPickerViewController.popoverPresentationController?.sourceView = sender as? UIView
        
        colorPickerViewController.pickedColor = { color in
            self.selectedStrokeColor?(color)
            self.currentColor = color
            let coloreEllipse = UIImage.ellipseWithColor(color, size: 19)
            self.pickedColorImage.image = coloreEllipse
        }
        
        present(colorPickerViewController, animated: true, completion: nil)
        
    }
    
    // MARK: - Table View delegates -

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {

        guard let headerView: UITableViewHeaderFooterView = view as? UITableViewHeaderFooterView else { return }
        
        headerView.textLabel?.textColor = .black
        headerView.textLabel?.font = UIFont(name: Constants.fontName, size: Constants.fontSize)
        headerView.contentView.backgroundColor = .white
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedStrokeStyle?(StrokeStyleType(rawValue: indexPath.row) ?? .basicStroke)
    }
}

extension StrokeFormatMenuTableViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
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
        currentColor = color
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let color = strokeColors[indexPath.row]
        selectedStrokeColor?(color)
        currentColor = color
        let coloreEllipse = UIImage.ellipseWithColor(strokeColors[indexPath.row], size: 19)
        self.pickedColorImage.image = coloreEllipse
        
    }
}
