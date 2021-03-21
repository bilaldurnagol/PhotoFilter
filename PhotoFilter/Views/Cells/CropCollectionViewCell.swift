//
//  CropCollectionViewCell.swift
//  PhotoFilter
//
//  Created by Bilal Durnagöl on 18.03.2021.
//

import UIKit


class CropCollectionViewCell: UICollectionViewCell {
    static let identifier = "CropCollectionViewCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .label
        label.font = UIFont(name: "Lato-Light", size: 15)
        return label
    }()
    
  
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size = contentView.height/2
        imageView.frame = CGRect(x: (contentView.width - size)/2, y: 10, width: size, height: size)
    
        label.frame = CGRect(x: 0, y: imageView.bottom, width: contentView.width, height: contentView.height - size - 10)
    }
    
    func configure(icon: UIImage, title: String) {
        imageView.image = icon
        label.text = title
    }
}
