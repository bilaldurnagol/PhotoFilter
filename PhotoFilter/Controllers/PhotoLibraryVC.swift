//
//  PhotoLibraryVC.swift
//  PhotoFilter
//
//  Created by Bilal Durnagöl on 5.03.2021.
//

import UIKit
import RxSwift
import RxCocoa
import Photos
import PhotosUI

class PhotoLibraryVC: UIViewController {
    
    private var collectionView: UICollectionView?
    
    private let layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let size = UIScreen.main.bounds.width/2-5
        layout.itemSize = CGSize(width: size, height: size)
        return layout
    }()
    
    private var allPhotos = PHFetchResult<PHAsset>()
    private let disposeBag = DisposeBag()
    private var barButtons = [UIButton]()
    private var selectedAsset: PHAsset?
    
    private let imageHandler = ImageEditHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PHPhotoLibrary.shared().register(self)
        UINavigationController().toolbar.setBackgroundImage(UIImage(),
                                                            forToolbarPosition: .any,
                                                            barMetrics: .default)
        UINavigationController().toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        UINavigationController().toolbar.isTranslucent = true
        UINavigationController().toolbar.backgroundColor = .clear
        
        navBar()
        customCollectionView()
        cameraToolbar()
        
        imageHandler.getPermissionIfNecessary(completion: {[weak self]result in
            if result {
                self?.imageHandler.fetchAssets(completion: {assets in
                    self?.allPhotos = assets
                })
            }
        })
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if NewUser.shared.isNewUser() {
            //Show Onboarding
            let vc = OnboardingVC()
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: false)
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    private func customCollectionView() {
        // setup collection view
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.register(PhotoLibraryCollectionViewCell.self,
                                 forCellWithReuseIdentifier: PhotoLibraryCollectionViewCell.identifier) 
        guard let collectionView = collectionView else {return}
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
    }
    //Custom bar button items
    private func navBar() {
        let buttonImageArray = ["square.grid.2x2.fill", "square.fill", "plus"]
        var barButtonArray = [UIBarButtonItem]()
        for i in 0..<3 {
            let button = UIButton(frame: .zero)
            button.tag = i+1
            button.setImage(UIImage(systemName: buttonImageArray[i], withConfiguration: UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 30, weight: .thin))), for: .normal)
            button.layer.borderColor = #colorLiteral(red: 0.6, green: 0.5294117647, blue: 0.1921568627, alpha: 1)
            button.addTarget(self, action: #selector(didTapNavBarButton(_:)), for: .touchUpInside)
            barButtons.append(button)
            let barButton = UIBarButtonItem(customView: button)
            barButtonArray.append(barButton)
        }
        navigationItem.setLeftBarButtonItems(barButtonArray, animated: true)
        
    }
    
    //add border in barbuttonitem
    private func styleButtons(tag: Int) {
        let tag = tag
        barButtons.forEach{ (button) in
            if button.tag == tag {
                button.layer.borderWidth = 2.5
                view.layoutIfNeeded()
            } else {
                button.layer.borderWidth = 0.0
            }
        }
    }
    
    //setup alert
    private func assetsAlert() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = .white
        alert.addAction(UIAlertAction(title: "Select More Photos", style: .default, handler: {_ in self.openAlbum()}))
        alert.addAction(UIAlertAction(title: "Change Settings", style: .default, handler: {_ in self.openAppSetings()}))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        present(alert, animated: true)
    }
    
    //MARK:- Alert Funcs
    
    //go to app settings
    private func openAppSetings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    private func openAlbum() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        if status == .limited {
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
        }
    }
    
    // camera toolbar
    private func cameraToolbar() {
        
        let button = UIButton(frame: .zero)
        button.setImage(UIImage(systemName: "largecircle.fill.circle", withConfiguration: UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 35))), for: .normal)
        button.tintColor = .label
        button.tag = 5
        button.addTarget(self, action: #selector(didTapToolbarButton(_:)), for: .touchUpInside)
        let buttonBarItem = UIBarButtonItem(customView: button)
        
        let label = UILabel(frame: .zero)
        label.text = "Switch to camera"
        let labelBarItem = UIBarButtonItem(customView: label)
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        setToolbarItems([buttonBarItem, labelBarItem, spacer], animated: true)
        navigationController?.setToolbarHidden(false, animated: false)
    }
    
    // edit toolbar
    private func editToolbar() {
        let iconArray = ["wand.and.stars.inverse", "slider.horizontal.3", "square.and.arrow.up", "trash"]
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
        space.width = 20
        var barButtonArray = [UIBarButtonItem]()
        for i in 0..<4 {
            let button = UIButton(frame: .zero)
            button.setImage(UIImage(systemName: iconArray[i], withConfiguration: UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 25, weight: .thin))), for: .normal)
            button.tintColor = .label
            button.tag = i+1
            button.addTarget(self, action: #selector(didTapToolbarButton(_:)), for: .touchUpInside)
            barButtonArray.append(UIBarButtonItem(customView: button))
            barButtonArray.append(space)
        }
        
        let cameraButton = UIButton(frame: .zero)
        cameraButton.setImage(UIImage(systemName: "largecircle.fill.circle", withConfiguration: UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 35))), for: .normal)
        cameraButton.tintColor = .label
        cameraButton.tag = 5
        cameraButton.addTarget(self, action: #selector(didTapToolbarButton(_:)), for: .touchUpInside)
        let cameraBarButton = UIBarButtonItem(customView: cameraButton)
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        barButtonArray.append(spacer)
        barButtonArray.append(cameraBarButton)
        setToolbarItems(barButtonArray, animated: true)
    }
    
    //delete toolbar
    private func deleteToolbar() {
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
                    button.setTitle("Delete", for: .normal)
                    button.tag = 6
                } else{
                    button.setTitle("Cancel", for: .normal)
                    button.tag = 7
                }
                button.tintColor = .label
                button.titleLabel?.font = UIFont(name: "Lato-Light", size: 24)
                button.addTarget(self, action: #selector(didTapToolbarButton(_:)), for: .touchUpInside)
                barButtonArray.append(UIBarButtonItem(customView: button))
            }
        }
        barButtonArray.append(spacer)
        setToolbarItems(barButtonArray, animated: true)
    }
    
    //MARK:- Objc Funcs
    @objc private func didTapNavBarButton(_ sender: UIButton) {
        //Clicked navigation bar button item
        styleButtons(tag: sender.tag)
        if sender.tag == 1 {
            layout.itemSize = CGSize(width: view.width/2-5, height: view.width/2-5)
        }else if sender.tag == 2 {
            layout.itemSize = CGSize(width: view.width, height: view.height/3)
        }else {
            assetsAlert()
        }
    }
    
    //Clicked toolbar button actions
    @objc private func didTapToolbarButton(_ sender: UIButton) {
        if sender.tag == 1 {
            //go to presets page
            let vc = PresetsVC()
            guard let selectedAsset = selectedAsset else {return}
            vc.selectedImage.onNext((selectedAsset.assetToImage()))
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }else if sender.tag == 2 {
            //go to edit page
            let vc = EditsVC()
            guard let selectedAsset = selectedAsset else {return}
            var value = vc.selectedImage.value
            value.append(selectedAsset.assetToImage())
            vc.selectedImage.accept(value)
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }else if sender.tag == 3 {
            
        }else if sender.tag == 4 {
            deleteToolbar()
        }else if sender.tag == 5 {
            //open camera
            let vc = UIImagePickerController()
            vc.sourceType = .camera
            vc.allowsEditing = false
            vc.cameraFlashMode = .off
            vc.delegate = self
            present(vc, animated: true)
            
        }else if sender.tag == 6 {
            //delete asset
            let arrayToDelete = NSArray(object: selectedAsset!)
            
            PHPhotoLibrary.shared().performChanges( {PHAssetChangeRequest.deleteAssets(arrayToDelete)}, completionHandler: {[weak self] success, error in
                DispatchQueue.main.async {
                    self?.cameraToolbar()
                }
            })
        }else {
            cameraToolbar()
        }
    }
}

extension PhotoLibraryVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoLibraryCollectionViewCell.identifier, for: indexPath) as! PhotoLibraryCollectionViewCell
        let asset = allPhotos[indexPath.row]
        cell.configure(with: asset.assetToImage())
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        editToolbar()
        selectedAsset = allPhotos[indexPath.row]
    }
}

extension PhotoLibraryVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            print("No image found")
            return
        }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        picker.dismiss(animated: true, completion: nil)
    }
}

extension PhotoLibraryVC: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        guard let change = changeInstance.changeDetails(for: allPhotos) else {
            return
        }
        DispatchQueue.main.sync {
            allPhotos = change.fetchResultAfterChanges
            collectionView?.reloadData()
        }
    }
}


//check user for onboarding
class NewUser {
    static let shared = NewUser()
    
    func isNewUser() -> Bool {
        return !UserDefaults.standard.bool(forKey: "isNewUser")
    }
    
    func setIsNotNewUser() {
        UserDefaults.standard.set(true, forKey: "isNewUser")
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
