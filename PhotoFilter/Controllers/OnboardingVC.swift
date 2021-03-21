//
//  OnboardingVC.swift
//  PhotoFilter
//
//  Created by Bilal Durnagöl on 5.03.2021.
//

import UIKit

class OnboardingVC: UIViewController {
    private let holderView = UIView()
    
    private let titles = ["SHOOT, EDIT & SHARE", "CAMERA", "TOOLS", "PUBLISH"]
    private let descriptions = ["The standard of mobile photography Anri cam is the premier way to shoot, edit, and share your photographs.",
                                "A powerful camera app with full control over your image. Quickly and simply adjust all parameters of your image",
                                "Exposure, Temperature, Contrast, Crop, Straighten, Fade, Vignette, and more allow you to define your look.",
                                "Share your photos to your  Instagram, Facebook, Twitter, Google, your camera roll, and more"]
    
    private let scrollView = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(holderView)
        
        for family in UIFont.familyNames {
            print("family:", family)
            for font in UIFont.fontNames(forFamilyName: family) {
                print("font:", font)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        holderView.frame = view.bounds
        configure()
    }
    
    private func configure() {
        //setup scrollview
        scrollView.frame = holderView.bounds
        holderView.addSubview(scrollView)
        
        for i in 0..<4 {
            
            let pageView = UIView(frame: CGRect(x: CGFloat(i) * holderView.width,
                                                y: 0,
                                                width: holderView.width,
                                                height: holderView.height))
            scrollView.addSubview(pageView)
            
            //title, image, button
            let imageView = UIImageView(frame: CGRect(x: pageView.width/3,
                                                      y: pageView.height/3.5,
                                                      width: pageView.width/3,
                                                      height: pageView.width/3)
            )
            
            let titleLabel = UILabel(frame: CGRect(x: 0,
                                                   y: imageView.bottom + pageView.height/6,
                                                   width: pageView.width,
                                                   height: 40)
            )
            
            let descriptionLabel = UILabel(frame: CGRect(x: 10,
                                                         y: titleLabel.bottom + 5,
                                                         width: pageView.width - 20,
                                                         height: 80))
            let button = UIButton(frame: CGRect(x: 30,
                                                y: pageView.height - pageView.height/13 - 20,
                                                width: pageView.width - 60,
                                                height: pageView.height/13)
            )
            
            titleLabel.textAlignment = .center
            titleLabel.font = UIFont(name: "Lato-Light", size: 30)
            pageView.addSubview(titleLabel)
            titleLabel.text = titles[i]
            
            descriptionLabel.textAlignment = .center
            descriptionLabel.font = UIFont(name: "Lato-Light", size: 18)
            descriptionLabel.numberOfLines = 0
            pageView.addSubview(descriptionLabel)
            descriptionLabel.text = descriptions[i]
            
            imageView.contentMode = .scaleAspectFit
            imageView.image = UIImage(named: "onboardIcon_\(i)")
            pageView.addSubview(imageView)
            
            button.setTitle("Next", for: .normal)
            button.backgroundColor = .label
            button.setTitleColor(.systemBackground, for: .normal)
            button.titleLabel?.font = UIFont(name: "Lato-Light", size: 25)
            if i == 0 {
                button.setTitle("Get Started", for: .normal)
            }
            button.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
            button.tag = i + 1
            pageView.addSubview(button)
        }
        scrollView.contentSize = CGSize(width: holderView.width * 4, height: 0)
        scrollView.isPagingEnabled = true
    }
    
    @objc private func didTapButton(_ button: UIButton) {
        //dismiss
        guard button.tag < 4 else {
            NewUser.shared.setIsNotNewUser()
            dismiss(animated: true, completion: nil)
            return
        }
        //scroll to next page
        scrollView.setContentOffset(CGPoint(x: holderView.width * CGFloat(button.tag), y: 0), animated: true)
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

