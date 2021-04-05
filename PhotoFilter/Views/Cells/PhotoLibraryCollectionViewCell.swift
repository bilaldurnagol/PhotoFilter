//
//  PhotoLibraryCollectionViewCell.swift
//  PhotoFilter
//
//  Created by Bilal Durnagöl on 5.03.2021.
//

import UIKit

class PhotoLibraryCollectionViewCell: UICollectionViewCell {
    static let identifier = "PhotoLibraryCollectionViewCell"
    
    private let imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor(red: 153/255, green: 135/255, blue: 49/255, alpha: 1.0).cgColor
        return imageView
    }()
    
    override var isSelected: Bool {
        didSet {
            imageView.layer.borderWidth = isSelected ? 3 : 0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }
    
    func configure(with image: UIImage?) {
        guard let image = image else {return}
        DispatchQueue.main.async {[weak self] in
            self?.imageView.image = image
        }
    }
}
