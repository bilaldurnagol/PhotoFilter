//
//  CropVC.swift
//  PhotoFilter
//
//  Created by Bilal Durnagöl on 15.03.2021.
//

import UIKit
import RxSwift
import RxCocoa

class CropVC: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Lato-Light", size: 30)
        label.textAlignment = .center
        label.text = "Crop"
        label.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
        label.textColor = .label
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var collectionView: UICollectionView?
    
    private let layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 60, height: 60)
        return layout
    }()
    private let cropShapeLayer = CropShapeLayer(frame: .zero)
    
    var selectedImage = BehaviorSubject<UIImage>(value: UIImage())
    var filter: Filters?
    let disposeBag = DisposeBag()
    
    private var cropMenu: Observable<[CropMenu]> = {
        
        let oneOne = CropMenu(icon: UIImage(named: "1_1")!, title: "1:1", ratio: 1/1)
        let twoThree = CropMenu(icon: UIImage(named: "2_3")!, title: "2:3", ratio: 2/3)
        let threeTwo = CropMenu(icon: UIImage(named: "3_2")!, title: "3:2", ratio: 3/2)
        let threeFour = CropMenu(icon: UIImage(named: "3_4")!, title: "3:4", ratio: 3/4)
        let fourThree = CropMenu(icon: UIImage(named: "4_3")!, title: "4:3", ratio: 4/3)
        let fourFive = CropMenu(icon: UIImage(named: "4_5")!, title: "4:5", ratio: 4/5)
        let fiveFour = CropMenu(icon: UIImage(named: "5_4")!, title: "5:4", ratio: 5/4)
        let nineSixteen = CropMenu(icon: UIImage(named: "9_16")!, title: "9:16", ratio: 9/16)
        let sixteenNine = CropMenu(icon: UIImage(named: "16_9")!, title: "16:9", ratio: 16/9)
        return .just([oneOne, twoThree, threeTwo, threeFour, fourThree, fourFive, fiveFour, nineSixteen, sixteenNine])
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navBar()
        bottomToolbar()
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        imageView.addSubview(cropShapeLayer)
        customCollectionView()
        
        selectedImage.subscribe(onNext: {[weak self] image in
            self?.imageView.image = image
        }).disposed(by: disposeBag)
        
        cropMenu.bind(to: (collectionView?.rx
                            .items(cellIdentifier: CropCollectionViewCell.identifier, cellType: CropCollectionViewCell.self))!){ row, element, cell in
            cell.configure(icon: element.icon, title: element.title)
        }.disposed(by: disposeBag)
        
        
        collectionView?.rx.modelSelected(CropMenu.self).subscribe(onNext: {[weak self] model in
            self?.cropShapeLayer.ratio = model.ratio
            guard let points = self?.cropShapeLayer.imagePoint() else {return}
            self?.cropShapeLayer.doSetup(startX: points.minX, startY: points.minY)
            
        }).disposed(by: disposeBag)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let toolbarHeight = navigationController?.toolbar.frame.size.height else {return}
        let viewTop: CGFloat = view.safeAreaInsets.top
        titleLabel.frame = CGRect(x: 0, y: viewTop, width: view.width, height: 70)
        imageView.frame = CGRect(x: 0, y: viewTop, width: view.width, height: view.height - 60 - viewTop - toolbarHeight)
        collectionView?.frame = CGRect(x: 0, y: imageView.bottom, width: view.width, height: 55)
        cropShapeLayer.frame = imageView.bounds
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cropShapeLayer.image = imageView.image!
        cropShapeLayer.imageView = imageView
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
        collectionView?.register(CropCollectionViewCell.self,
                                 forCellWithReuseIdentifier: CropCollectionViewCell.identifier)
        collectionView?.showsHorizontalScrollIndicator = false
        guard let collectionView = collectionView else {return}
        view.addSubview(collectionView)
    }
    
    // toolbar
    private func bottomToolbar() {
        var barButtonArray = [UIBarButtonItem]()
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        barButtonArray.append(spacer)
        for i in 0..<3 {
            if i == 1 {
                barButtonArray.append(spacer)
                let label = UILabel(frame: .zero)
                label.text = "|"
                label.textAlignment = .center
                label.font = UIFont(name: "Lato-Light", size: 50)
                barButtonArray.append(UIBarButtonItem(customView: label))
                barButtonArray.append(spacer)
            }else {
                let button = UIButton(frame: .zero)
                if i == 0 {
                    button.setImage(UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 25, weight: .thin))), for: .normal)
                    button.tag = 1
                } else{
                    button.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 25, weight: .thin))), for: .normal)
                    button.tag = 2
                }
                button.tintColor = .label
                navigationController?.toolbar.barTintColor = UIColor.clear
                button.addTarget(self, action: #selector(didTapToolbarButton(_:)), for: .touchUpInside)
                barButtonArray.append(UIBarButtonItem(customView: button))
            }
        }
        barButtonArray.append(spacer)
        setToolbarItems(barButtonArray, animated: true)
        navigationController?.setToolbarHidden(false, animated: false)
    }
    
    
    //MARK:- Objc Funcs
    
    @objc private func didTapCancel() {
        //back to photo library
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapSave() {

    }
    
    @objc private func didTapToolbarButton(_ sender: UIButton) {
        if sender.tag == 1 {
            ///crop image
            guard let cropPoint = cropShapeLayer.shapeLayer.path?.boundingBoxOfPath,
                  let croppingImage = imageView.image else {return}
            
            FiltersService.shared.cropImage(inputImage: croppingImage, inputImageView: imageView, cropRect: cropPoint, completion: {croppedImage in
                let vc = EditsVC()
                var value = vc.selectedImage.value
                value.append(croppedImage)
                vc.selectedImage.accept(value)
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            })
        }else {
     
        }
    }
}

extension CropVC {
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            
            let previousLocation = touch.previousLocation(in: imageView)
            let location = touch.location(in: imageView)
            
            let inShapeLayer = cropShapeLayer.frame
            if inShapeLayer.contains(previousLocation) {
                guard let minX = cropShapeLayer.shapeLayer.path?.boundingBox.minX,
                      let minY = cropShapeLayer.shapeLayer.path?.boundingBox.minY else {return}
                
                let verticalDifference = location.y - previousLocation.y
                let horizontalDifference = location.x - previousLocation.x
                
                if abs(verticalDifference) > abs(horizontalDifference) {
                    cropShapeLayer.doSetup(startX: minX, startY: minY + verticalDifference)
                }else {
                    cropShapeLayer.doSetup(startX: minX + horizontalDifference, startY: minY)
                }
            }
        }
    }
}
