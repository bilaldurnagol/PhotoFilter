//
//  BrightnessFilterVC.swift
//  PhotoFilter
//
//  Created by Bilal Durnagöl on 8.03.2021.
//

import UIKit
import Photos
import RxSwift
import RxCocoa

class FilterVC: UIViewController {
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
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let rotateButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(systemName: "crop.rotate", withConfiguration: UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 30, weight: .thin))), for: .normal)
        button.tintColor = .label
        button.isHidden = true
        return button
    }()
    
    private let controlSlider: UISlider = {
        let slider = UISlider()
        slider.maximumValue = 1.0
        slider.minimumValue = 0.0
        slider.value = 0.0
        slider.minimumTrackTintColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.3)
        slider.maximumTrackTintColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.3)
        slider.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.2)
        
        return slider
    }()
    var labelValue = PublishSubject<Float>()
    var selectedImage = BehaviorSubject<UIImage>(value: UIImage())
    var filter: Filters?
    let disposeBag = DisposeBag()
    
    var rotateCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navBar()
        bottomToolbar()
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(controlSlider)
        view.addSubview(rotateButton)
        configure()
        
        rotateButton.addTarget(self, action: #selector(didTapRotateButton), for: .touchUpInside)
        
        guard let image = imageView.image, let filter = filter  else {return}
        controlSlider.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        
        controlSlider.rx.value
            .subscribe(onNext: {[weak self] value in
                self?.labelValue.onNext(value)
            })
            .disposed(by: disposeBag)
        
        labelValue.map({
            return $0
        }).subscribe(onNext: {[weak self] value in
            FiltersService.shared.applyFilter(to: image, value: value, filter: filter)
                .subscribe(onNext: {[weak self] image in
                    DispatchQueue.main.async {
                        self?.imageView.image = image
                    }
                }).disposed(by: self!.disposeBag)
        }).disposed(by: disposeBag)
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let toolbarHeight = navigationController?.toolbar.frame.size.height else {return}
        titleLabel.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: 70)
        imageView.frame = view.bounds
        controlSlider.frame = CGRect(x: 0, y: view.height - 100 - toolbarHeight, width: view.width, height: 100)
        rotateButton.frame = CGRect(x: view.width - 50, y: controlSlider.top + 1, width: 40, height: 40)
    }
    
    //setup image controlslider
    private func configure() {
        selectedImage.subscribe(onNext: {[weak self] image in
            self?.imageView.image = image
        }).disposed(by: disposeBag)
        guard let filter = filter else {return}
        if filter.rawValue == "Straighten" {
            rotateButton.isHidden = false
        }
        titleLabel.text = filter.rawValue
        controlSlider.value = filter.def
        controlSlider.minimumValue = filter.min
        controlSlider.maximumValue = filter.max
    }
    
    //navigation bar buttons
    private func navBar() {
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel))
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapSave))
        
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = saveButton
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
        //save to filtered photo
    }
    
    @objc private func didTapToolbarButton(_ sender: UIButton) {
        if sender.tag == 1 {
            let vc = EditsVC()
            var value = vc.selectedImage.value
            value.append(imageView.image!)
            vc.selectedImage.accept(value)
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }else {
     
        }
    }
    
    @objc private func didTapRotateButton() {
        rotateCount += 1
        
        guard let orientation = UIImage.Orientation.init(rawValue: rotateCount) else {return}
        FiltersService.shared.rotateImage(to: imageView.image!, orientation: orientation, comletion: { image in
            self.imageView.image = image
        })
    }
}


/*
 family: Lato
 font: Lato-Regular
 font: Lato-Italic
 font: Lato-Hairline
 font: Lato-HairlineItalic
 font: Lato-Light
 font: Lato-LightItalic
 font: Lato-Bold
 font: Lato-BoldItalic
 font: Lato-Black
 font: Lato-BlackItalic
 */
