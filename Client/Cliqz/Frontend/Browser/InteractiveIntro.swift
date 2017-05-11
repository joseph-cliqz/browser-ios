//
//  InteractiveIntro.swift
//  Client
//
//  Created by Sahakyan on 11/11/16.
//  Copyright © 2016 Mozilla. All rights reserved.
//

import Foundation
import SnapKit

// TODO: Quick implementation should be redesigned and refactored

enum HintType {
	case antitracking
	case cliqzSearch
	case unknown
}

class InteractiveIntro {

	var shouldShowAntitrackingHint = true {
		didSet {
			SettingsPrefs.updateShowAntitrackingHintPref(shouldShowAntitrackingHint)
		}
	}
	var shouldShowCliqzSearchHint = true {
		didSet {
			SettingsPrefs.updateShowCliqzSearchHintPref(shouldShowCliqzSearchHint)
		}
	}

	func updateHintPref(_ type: HintType, value: Bool) {
		switch type {
		case .antitracking:
			shouldShowAntitrackingHint = value
		case .cliqzSearch:
			shouldShowCliqzSearchHint = value
		default:
			debugPrint("Wront Hint Type")
		}
	}

	static let sharedInstance = InteractiveIntro()
	
	init() {
		shouldShowAntitrackingHint = SettingsPrefs.getShowAntitrackingHintPref()
		shouldShowCliqzSearchHint = SettingsPrefs.getShowCliqzSearchHintPref()
	}
	
	func reset() {
		self.shouldShowAntitrackingHint = true
		self.shouldShowCliqzSearchHint = true
	}
}

class InteractiveIntroViewController: UIViewController {

	fileprivate var contentView: UIView? = nil
	fileprivate var currentHintType: HintType = .unknown

	fileprivate static let blurryBackgroundViewTag = 1
	fileprivate static let titleFontSize: CGFloat = 30.0
	fileprivate static let descriptionFontSize: CGFloat = 18.0

	override var shouldAutorotate : Bool {
		return false
	}

	override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
		return UIInterfaceOrientationMask.portrait
	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		guard let contentView = self.contentView else {
			return
		}
		let bgView = contentView.viewWithTag(InteractiveIntroViewController.blurryBackgroundViewTag)
		switch self.currentHintType {
		case .antitracking:
			bgView?.layer.mask = self.antitrackingMaskLayer()
		case .cliqzSearch:
			bgView?.layer.mask = self.cliqzSearchMaskLayer()
		default:
			debugPrint("Wrong Type")
		}
	}

	func showHint(_ type: HintType) {
		self.currentHintType = type
		switch type {
		case .antitracking:
			showAntitrackingHint()
		case .cliqzSearch:
			showCliqzSearchHint()
		default:
			debugPrint("Wrong type")
		}
	}

	fileprivate func showCliqzSearchHint() {
		contentView = UIView()
		self.contentView!.backgroundColor = UIColor.clear
		self.view.addSubview(self.contentView!)
		
		let blurrySemiTransparentView = UIView(frame:self.view.bounds)
		blurrySemiTransparentView.backgroundColor = UIColor(rgb: 0x2d3e50).withAlphaComponent(0.9)
		self.contentView!.addSubview(blurrySemiTransparentView)
		blurrySemiTransparentView.tag = InteractiveIntroViewController.blurryBackgroundViewTag
		blurrySemiTransparentView.layer.mask = self.cliqzSearchMaskLayer()

		let title = UILabel()
		title.text = NSLocalizedString("Result Cards", tableName: "Cliqz", comment: "Cliqz search hint title")
		title.font = UIFont.systemFont(ofSize: InteractiveIntroViewController.titleFontSize)
		title.textColor = UIColor.white
		self.contentView!.addSubview(title)
		let description = UILabel()
		self.contentView!.addSubview(description)
		description.text = NSLocalizedString("Relevant results are shown instantly during search.", tableName: "Cliqz", comment: "Cliqz search hint description")
		description.textColor = UIColor.white
		description.font = UIFont.systemFont(ofSize: InteractiveIntroViewController.descriptionFontSize)
		description.numberOfLines = 0
		let button = UIButton()
		button.setTitle("OK", for: UIControlState())
		button.setTitleColor(UIColor.white, for: UIControlState())
		button.layer.borderColor = UIColor.white.cgColor
		button.layer.borderWidth = 2
		button.layer.cornerRadius = 6
		button.backgroundColor = UIColor.clear
		button.addTarget(self, action: #selector(closeHint), for: .touchUpInside)
		self.contentView!.addSubview(button)
		
		self.contentView!.snp_makeConstraints { (make) in
			make.top.left.right.bottom.equalTo(self.view)
		}
		
		title.snp_makeConstraints { (make) in
			make.left.equalTo(self.contentView!).offset(15)
			make.right.equalTo(self.contentView!)
			make.top.equalTo(self.contentView!.snp_bottom).offset(-200)
			make.height.equalTo(40)
		}
		
		description.snp_makeConstraints { (make) in
			make.left.equalTo(self.contentView!).offset(15)
			make.right.equalTo(self.contentView!)
			make.top.equalTo(title.snp_bottom)
			make.bottom.equalTo(button.snp_top)
		}
		
		blurrySemiTransparentView.snp_makeConstraints { (make) in
			make.top.left.right.bottom.equalTo(contentView!)
		}
		
		button.snp_makeConstraints { (make) in
			make.centerX.equalTo(self.contentView!)
			make.bottom.equalTo(self.contentView!).offset(-20)
			make.width.equalTo(80)
			make.height.equalTo(40)
		}
	}
	
	fileprivate func showAntitrackingHint() {
		contentView = UIView()
		self.contentView!.backgroundColor = UIColor.clear
		self.view.addSubview(self.contentView!)

		let blurrySemiTransparentView = UIView(frame:self.view.bounds)
		blurrySemiTransparentView.backgroundColor = UIColor(rgb: 0x2d3e50).withAlphaComponent(0.9)
		self.contentView!.addSubview(blurrySemiTransparentView)
		blurrySemiTransparentView.tag = InteractiveIntroViewController.blurryBackgroundViewTag
		blurrySemiTransparentView.layer.mask = self.antitrackingMaskLayer()

		let title = UILabel()
		title.text = NSLocalizedString("Control Center", tableName: "Cliqz", comment: "Control Center hint title")
		title.font = UIFont.systemFont(ofSize: InteractiveIntroViewController.titleFontSize)
		title.textColor = UIColor.white
		title.textAlignment = .center
		self.contentView!.addSubview(title)
		let description = UILabel()
		self.contentView!.addSubview(description)
		description.text = NSLocalizedString("Customize the protection of your data to your needs.", tableName: "Cliqz", comment: "Control Center hint description")
		description.textColor = UIColor.white
		description.font = UIFont.systemFont(ofSize: InteractiveIntroViewController.descriptionFontSize)
		description.numberOfLines = 0
		description.textAlignment = .center
		let button = UIButton()
		button.setTitle("OK", for: UIControlState())
		button.setTitleColor(UIColor.white, for: UIControlState())
		button.layer.borderColor = UIColor.white.cgColor
		button.layer.borderWidth = 2
		button.layer.cornerRadius = 6
		button.backgroundColor = UIColor.clear
		button.addTarget(self, action: #selector(closeHint), for: .touchUpInside)
		self.contentView!.addSubview(button)
        
        //The two options
        
        //labels
        let option1_label = UILabel()
        option1_label.text = NSLocalizedString("Protection enabled", tableName: "Cliqz", comment: "Control Center Option 1")
        option1_label.font = UIFont.systemFont(ofSize: InteractiveIntroViewController.descriptionFontSize)
        option1_label.textColor = UIColor.white
        option1_label.textAlignment = .left
        
        
        let option2_label = UILabel()
        option2_label.text = NSLocalizedString("Protection disabled", tableName: "Cliqz", comment: "Control Center Option 2")
        option2_label.font = UIFont.systemFont(ofSize: InteractiveIntroViewController.descriptionFontSize)
        option2_label.textColor = UIColor.white
        option2_label.textAlignment = .left
        
        
        //images
        let option1_img_bg = UIView()
        option1_img_bg.backgroundColor = UIColor.white
        option1_img_bg.layer.cornerRadius = 10
        option1_img_bg.clipsToBounds = true
        
        let option1_icon = UIImageView()
        option1_icon.image = CliqzURLBarView.antitrackingGreenIcon
        option1_img_bg.addSubview(option1_icon)
        
        let option2_img_bg = UIView()
        option2_img_bg.backgroundColor = UIColor.white
        option2_img_bg.layer.cornerRadius = 10
        option2_img_bg.clipsToBounds = true
        
        let option2_icon = UIImageView()
        option2_icon.image = CliqzURLBarView.antitrackingOrangeIcon
        option2_img_bg.addSubview(option2_icon)
        
        
        let option1_container = UIView()
        option1_container.addSubview(option1_img_bg)
        option1_container.addSubview(option1_label)
        
        let option2_container = UIView()
        option2_container.addSubview(option2_img_bg)
        option2_container.addSubview(option2_label)
        
        
        self.contentView?.addSubview(option1_container)
        self.contentView?.addSubview(option2_container)


		self.contentView!.snp_makeConstraints { (make) in
			make.top.left.right.bottom.equalTo(self.view)
		}

		title.snp_makeConstraints { (make) in
			make.centerX.equalTo(self.contentView!)
            make.height.equalTo(70)
            make.bottom.equalTo(description.snp_topMargin)
		}

		description.snp_makeConstraints { (make) in
			make.center.equalTo(self.contentView!)
			make.left.right.equalTo(self.contentView!).inset(14)
			make.height.equalTo(60)
		}
        
        option1_container.snp_makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.top.equalTo(description.snp_bottomMargin).offset(6)
            make.width.equalTo(180)
            make.height.equalTo(44)
        }
        
        option1_img_bg.snp_makeConstraints { (make) in
            make.height.equalTo(CliqzURLBarView.antitrackingButtonSize.height)
            make.width.equalTo(CliqzURLBarView.antitrackingButtonSize.width)
            make.left.centerY.equalTo(option1_container)
        }
        
        option1_label.snp_makeConstraints { (make) in
            make.height.equalTo(option1_container)
            make.left.equalTo(option1_img_bg.snp_rightMargin).offset(18)
            make.top.equalTo(option1_container)
        }
        
        option1_icon.snp_makeConstraints { (make) in
            make.center.equalTo(option1_img_bg)
        }
        
        option2_container.snp_makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.top.equalTo(option1_container.snp_bottomMargin).offset(6)
            make.width.equalTo(180)
            make.height.equalTo(44)
        }
        
        option2_img_bg.snp_makeConstraints { (make) in
            make.height.equalTo(CliqzURLBarView.antitrackingButtonSize.height)
            make.width.equalTo(CliqzURLBarView.antitrackingButtonSize.width)
            make.left.centerY.equalTo(option2_container)
        }
        
        option2_label.snp_makeConstraints { (make) in
            make.height.equalTo(option2_container)
            make.left.equalTo(option2_img_bg.snp_rightMargin).offset(18)
            make.top.equalTo(option2_container)
        }
        
        option2_icon.snp_makeConstraints { (make) in
            make.center.equalTo(option2_img_bg)
        }
        
		blurrySemiTransparentView.snp_makeConstraints { (make) in
			make.top.left.right.bottom.equalTo(contentView!)
		}

		button.snp_makeConstraints { (make) in
			make.centerX.equalTo(self.contentView!)
			make.bottom.equalTo(self.contentView!).offset(-20)
			make.width.equalTo(80)
			make.height.equalTo(40)
		}
	}
    

	private func cliqzSearchMaskLayer() -> CAShapeLayer {
		let path = UIBezierPath()
		let arcRadius: CGFloat = self.view.frame.size.width / 2 - 15
		path.move(to: CGPoint(x: 0, y: 0))
		path.addLine(to: CGPoint(x: self.view.frame.size.width, y: 0))
		path.addLine(to: CGPoint(x: self.view.frame.size.width, y: 30))
		let center = CGPoint(x: arcRadius + 30, y: arcRadius + 15)
		path.addArc(withCenter: center, radius: arcRadius, startAngle: 0, endAngle: 0.04, clockwise: false)
		path.addLine(to: CGPoint(x: self.view.frame.size.width, y: self.view.frame.size.height))
		path.addLine(to: CGPoint(x: 0, y: self.view.frame.size.height))
		path.close()
		let maskLayer = CAShapeLayer()
		maskLayer.path = path.cgPath
		return maskLayer
	}

	fileprivate func antitrackingMaskLayer() -> CAShapeLayer {
		let path = UIBezierPath()
		let arcRadius: CGFloat = 80
		path.move(to: CGPoint(x: 0, y: 0))
		path.addLine(to: CGPoint(x: self.view.frame.size.width - arcRadius, y: 0))
		path.addArc(withCenter: CGPoint(x: self.view.frame.size.width, y: 0), radius: arcRadius, startAngle: 0, endAngle: 1.57, clockwise: false)
		path.addLine(to: CGPoint(x: self.view.frame.size.width, y: self.view.frame.size.height))
		path.addLine(to: CGPoint(x: 0, y: self.view.frame.size.height))
		path.close()
		let maskLayer = CAShapeLayer()
		maskLayer.path = path.cgPath
		return maskLayer
	}

	@objc fileprivate func closeHint() {
		self.contentView?.removeFromSuperview()
		self.contentView = nil
		self.dismiss(animated: true, completion: nil)
	}
}
