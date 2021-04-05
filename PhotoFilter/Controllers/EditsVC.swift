//
//  EditsVC.swift
//  PhotoFilter
//
//  Created by Bilal Durnagöl on 7.03.2021.
//

import UIKit
import RxSwift
import RxCocoa
import CoreImage

class EditsVC: UIViewController {
    
    private var collectionView: UICollectionView?
    
    private let layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 75, height: 60)
        return layout
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    var selectedImage = BehaviorRelay<[UIImage]>(value: [])
    var lastPhoto: Observable<UIImage?> {
        return selectedImage.map({$0.last})
    }
    
    private var editsMenu: Observable<[FilterMenu]> = {
        
        let crop = FilterMenu(icon: UIImage(systemName: "crop", withConfiguration: UIImage.SymbolConfiguration(weight: .thin)), name: Filters.Crop )
        let rotate = FilterMenu(icon: UIImage(systemName: "arrow.triangle.2.circlepath", withConfiguration: UIImage.SymbolConfiguration(weight: .thin)), name: Filters.Straighten)
        let contrast = FilterMenu(icon: UIImage(systemName: "circle.righthalf.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .thin)), name: Filters.Contrast)
        let brightness = FilterMenu(icon: UIImage(systemName: "sun.max", withConfiguration: UIImage.SymbolConfiguration(weight: .thin)), name: Filters.Brightness)
        let saturation = FilterMenu(icon: UIImage(systemName: "eyedropper", withConfiguration: UIImage.SymbolConfiguration(weight: .thin)), name: Filters.Saturation)
        let exposure = FilterMenu(icon: UIImage(systemName: "plusminus.circle", withConfiguration: UIImage.SymbolConfiguration(weight: .thin)), name: Filters.Exposure)
        let sharpen = FilterMenu(icon: UIImage(systemName: "arrowtriangle.up", withConfiguration: UIImage.SymbolConfiguration(weight: .thin)), name: Filters.Sharpen)
        let highlight = FilterMenu(icon: UIImage(systemName: "rays", withConfiguration: UIImage.SymbolConfiguration(weight: .thin)), name: Filters.Highlight)
        let shadow = FilterMenu(icon: UIImage(systemName: "shadow", withConfiguration: UIImage.SymbolConfiguration(weight: .thin)), name: Filters.Shadow)
        
        return .just([crop, rotate, brightness, contrast, saturation, exposure, sharpen, highlight, shadow])
    }()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navBar()
        customCollectionView()
        view.addSubview(imageView)
        
        lastPhoto.subscribe(onNext: { image in
            self.imageView.image = image
        }).disposed(by: disposeBag)

        guard let collectionView = collectionView else {return}
        editsMenu
            .bind(to: collectionView
                    .rx
                    .items(cellIdentifier: EditsCollectionViewCell.identifier,
                           cellType: EditsCollectionViewCell.self)) {row, element, cell in
                cell.configure(with: element)
            }.disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(FilterMenu.self).subscribe(onNext: {[weak self] model in
            guard let strongSelf = self else {return}
            switch model.name {
            case .Crop:
                let vc = CropVC()
                vc.selectedImage.onNext(strongSelf.imageView.image!)
                vc.filter = model.name
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav ,animated: true)
            default:
                let vc = FilterVC()
                vc.selectedImage.onNext(strongSelf.imageView.image!)
                vc.filter = model.name
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav ,animated: true)
            }
        }).disposed(by: disposeBag)
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height - 60)
        collectionView?.frame = CGRect(x: 0, y: imageView.bottom, width: view.width, height: 60)
    }
    
    //navigation bar buttons
    private func navBar() {
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel))
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapSave))
        
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = saveButton
    }
    
    private func customCollectionView() {
        // setup collection view
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.register(EditsCollectionViewCell.self,
                                 forCellWithReuseIdentifier: EditsCollectionViewCell.identifier)
        collectionView?.showsHorizontalScrollIndicator = false
        guard let collectionView = collectionView else {return}
        view.addSubview(collectionView)
    }
    
    //MARK:- Objc Funcs
    
    @objc private func didTapCancel() {
        //back to photo library
        let vc = PhotoLibraryVC()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    @objc private func didTapSave() {
        //save to filtered photo
        print("save")
    }
}
