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
    
    internal var selectedStrokeThickness: ((Double) -> ())?
    internal var selectedStrokeColor: ((UIColor) -> ())?
    internal var selectedStrokeStyle: ((StrokeStyleType) -> ())?

    private lazy var strokeColors: [UIColor] = [.lightBlue(), .lightGreen(), .lightYellow(), .lightOrange(), .lightRed(), .pink(), .lightPurple(), .customGray(), .lightWhite()]
    
    enum StrokeStyleType: Int {
        case basicStroke
        case diagonalStroke
        case oddStroke
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
        
        setThumbImage()
        colorCollectionView.reloadData()
    }
    
    // MARK: - UI Setup -

    func setThumbImage() {
        let thumbImage = UIImage.ellipseWithColor(.black, size: nil)
        
        strokeTicknessSlider.setThumbImage(thumbImage, for: .normal)
        strokeTicknessSlider.setThumbImage(thumbImage, for: .highlighted)
    }
    
    // MARK: - Actions -
    
    @IBAction func strokeThicknessValueDidChange(_ sender: Any) {
        self.selectedStrokeThickness?(Double(strokeTicknessSlider.value))
    }
    
    @IBAction func selectCustomColorTouchUpInside(_ sender: Any) {
        print("Select a custom color")
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
        
        cell.colorImage = strokeColors[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedStrokeColor?(strokeColors[indexPath.row])
    }
}
