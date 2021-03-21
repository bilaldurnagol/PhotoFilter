//
//  EditsCollectionViewCell.swift
//  PhotoFilter
//
//  Created by Bilal Durnagöl on 7.03.2021.
//

import UIKit

class EditsCollectionViewCell: UICollectionViewCell {
    static let identifier = "EditsCollectionViewCell"
    
    private let imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .label
        return imageView
    }()
    private let label: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.textColor = .label
        label.font = UIFont(name: "Lato-Light", size: 10)
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
        superview?.layoutSubviews()
        let size = contentView.height/6*3
        imageView.frame = CGRect(x: 0, y: 0, width: size, height: size)
        imageView.center = contentView.center
        label.frame = CGRect(x: 0, y: imageView.bottom, width: contentView.width, height: 12)
    }
    
    func configure(with menu: FilterMenu?) {
        imageView.image = menu?.icon
        label.text = menu?.name.rawValue
    }
}
