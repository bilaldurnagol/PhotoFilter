//
//  PresetsCollectionViewCell.swift
//  PhotoFilter
//
//  Created by Bilal Durnagöl on 25.03.2021.
//

import UIKit

class PresetsCollectionViewCell: UICollectionViewCell {
    static let identifier = "PresetsCollectionViewCell"
    
    override var isSelected: Bool {
        didSet {
            imageView.layer.borderWidth = isSelected ? 3 : 0
        }
    }
    
    private let imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor(red: 153/255, green: 135/255, blue: 49/255, alpha: 1.0).cgColor
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageViewSize: CGFloat = contentView.height/5*4
        imageView.frame = CGRect(x: 0, y: 0, width: imageViewSize, height: imageViewSize)
        imageView.center = contentView.center
    }
    
    func configure(to image: UIImage) {
        imageView.image = image
    }
}
