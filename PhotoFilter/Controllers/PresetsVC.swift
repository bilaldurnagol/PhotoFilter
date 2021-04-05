//
//  PresetsVC.swift
//  PhotoFilter
//
//  Created by Bilal Durnagöl on 25.03.2021.
//

import UIKit
import RxSwift
import RxCocoa


class PresetsVC: UIViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Lato-Light", size: 30)
        label.textAlignment = .center
        label.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
        label.textColor = .label
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    private let layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return layout
    }()
    private var collectionView: UICollectionView?
    
    var selectedImage = BehaviorSubject<UIImage>(value: UIImage())
    let disposeBag = DisposeBag()
    
    private var presets: Observable<[Presets]> = {
        let chrome = Presets(name: "Chrome", preset: Preset.Chrome)
        let fade = Presets(name: "Fade", preset: Preset.Fade)
        let instant = Presets(name: "Instant", preset: Preset.Instant)
        let mono = Presets(name: "Mono", preset: Preset.Mono)
        let noir = Presets(name: "Noir", preset: Preset.Noir)
        let process = Presets(name: "Process", preset: Preset.Process)
        let tonal = Presets(name: "Tonal", preset: Preset.Tonal)
        let transfer = Presets(name: "Transfer", preset: Preset.Transfer)
        return .just([chrome, fade, instant, mono, noir, process, tonal, transfer])
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navBar()
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        customCollectionView()
        selectedImage.subscribe(onNext: {[weak self] in
            self?.imageView.image = $0
        }).disposed(by: disposeBag)
        presets.bind(to: (collectionView?.rx
                            .items(cellIdentifier: PresetsCollectionViewCell.identifier, cellType: PresetsCollectionViewCell.self))!){ row, element, cell in
            PresetsService.shared.applyPresets(to: self.imageView.image!, presets: element).subscribe(onNext: {image in
                cell.configure(to: image)
            }).disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)
        guard let orginalImage = imageView.image else {return}
        collectionView?.rx
            .modelSelected(Presets.self)
            .subscribe(onNext: {[weak self]model in
                PresetsService.shared.applyPresets(to: orginalImage, presets: model).subscribe(onNext: {[weak self]image in
                    self?.imageView.image = image
                    self?.titleLabel.text = model.name
                }).disposed(by: self!.disposeBag)
            }).disposed(by: disposeBag)
    
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        titleLabel.frame = CGRect(x: 0,
                                  y: view.safeAreaInsets.top,
                                  width: view.width,
                                  height: 70)
        imageView.frame = CGRect(x: 0,
                                 y: titleLabel.top,
                                 width: view.width,
                                 height: view.height/5*4)
        collectionView?.frame = CGRect(x: 10,
                                       y: imageView.bottom,
                                       width: view.width - 10,
                                       height: view.height/5 - view.safeAreaInsets.top)
        
        guard let layoutSize: CGFloat = collectionView?.height else {return}
        layout.itemSize = CGSize(width: layoutSize, height: layoutSize)
       
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
        collectionView?.register(PresetsCollectionViewCell.self,
                                 forCellWithReuseIdentifier: PresetsCollectionViewCell.identifier)
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
    }
}
