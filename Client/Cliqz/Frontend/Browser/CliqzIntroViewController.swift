//
//  CliqzIntroViewController.swift
//  Client
//
//  Created by Mahmoud Adam on 11/8/16.
//  Copyright © 2016 Mozilla. All rights reserved.
//

import UIKit

class CliqzIntroViewController: UIViewController {
    fileprivate let cliqzNameView = UIImageView()
    fileprivate let cliqzLogoView = UIImageView()
    fileprivate let subtitleLabel = UILabel()
    fileprivate let brandingLabel = UILabel()
    fileprivate let startButton = UIButton()
    fileprivate var durationStartTime = 0.0
    weak var delegate: IntroViewControllerDelegate?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
        
        // Images
        cliqzNameView.image = UIImage(named: "introCliqz")
        self.view.addSubview(cliqzNameView)
        
        cliqzLogoView.image = UIImage(named: "introLogo")
        self.view.addSubview(cliqzLogoView)
        
        // Labels
        subtitleLabel.text = NSLocalizedString("SEARCH ENGINE \n IN THE BROWSER", tableName: "Cliqz", comment: "subtitle label for onBorading")
        subtitleLabel.textColor = UIColor(colorString: "A8A8A8")
        subtitleLabel.numberOfLines = 2
        subtitleLabel.textAlignment = .right
        subtitleLabel.font = UIFont(name: "Gotham-Book", size: 16.0)
        self.view.addSubview(subtitleLabel)
        
        brandingLabel.text = NSLocalizedString("Faster and safer", tableName: "Cliqz", comment: "Brading label for onBorading")
        brandingLabel.textColor = UIColor(colorString: "333333")
        subtitleLabel.font = UIFont.systemFont(ofSize: 16.0)
        self.view.addSubview(brandingLabel)


        // startButton
        startButton.addTarget(self, action: #selector(startBrowsing), for: .touchUpInside)
        let buttonTitle = NSLocalizedString("Let's start!", tableName: "Cliqz", comment: "Start buttun title for onBorading")
        let buttonColor = UIColor(colorString: "45C2CC")
        startButton.setTitle(buttonTitle, for: UIControlState())
        startButton.backgroundColor = UIColor.clear
        startButton.layer.cornerRadius = 20.0
        startButton.layer.borderWidth = 1
        startButton.layer.borderColor = buttonColor.cgColor
        startButton.setTitleColor(buttonColor, for: .normal)
        self.view.addSubview(startButton)
        
        // setup view constraints
        self.setupConstraints()
        
        // logging Onboarding event
        TelemetryLogger.sharedInstance.logEvent(.Onboarding("show", 0, nil))
        durationStartTime = Date.getCurrentMillis()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    fileprivate func setupConstraints() {
        cliqzLogoView.snp_makeConstraints { make in
            make.centerX.equalTo(self.view)
            make.centerY.equalTo(self.view).dividedBy(2.0)
        }
        
        cliqzNameView.snp_makeConstraints { make in
            make.centerX.centerY.equalTo(self.view)
        }
        
        subtitleLabel.snp_makeConstraints { make in
            make.right.equalTo(self.cliqzNameView.snp_right)
            make.top.equalTo(self.cliqzNameView.snp_bottom).offset(10)
        }
        
        brandingLabel.snp_makeConstraints { make in
            make.centerX.equalTo(self.view)
            make.centerY.equalTo(self.view).multipliedBy(1.6)
        }

        startButton.snp_makeConstraints { make in
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-30)
            make.height.equalTo(40)
            make.width.equalTo(150)
        }
        
    }
    
    @objc fileprivate func startBrowsing() {
        self.dismiss(animated: true, completion: nil)
        delegate?.introViewControllerDidFinish()

        // Cliqz: logged Onboarding event
        let duration = Int(Date.getCurrentMillis() - durationStartTime)
        TelemetryLogger.sharedInstance.logEvent(.Onboarding("click", 0, duration))
    }

}
