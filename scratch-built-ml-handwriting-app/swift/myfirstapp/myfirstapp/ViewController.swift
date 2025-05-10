//
//  ViewController.swift
//  myfirstapp
//
//  Created by HANYU WANG on 2024/05/11.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var pokerFaceImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "WechatIMG209"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var smileFaceImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "WechatIMG210"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.backgroundColor = UIColor.lightGray
        button.titleLabel?.font = UIFont.systemFont(ofSize: 40)
        return button
        
    }()
    
    private var isSmiling: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置布局
        self.pokerFaceImageView.frame = self.view.bounds
        self.smileFaceImageView.frame = self.view.bounds
        
        // 添加视图
        self.view.addSubview(self.pokerFaceImageView)
        self.view.addSubview(self.smileFaceImageView)
        
        //按钮
        //设置布局
        let buttonHeight: CGFloat = 110
        self.button.frame = CGRect(x: 0, y: self.view.frame.height - buttonHeight, width: self.view.frame.width, height: buttonHeight)
        
        //设置按钮标题
        self.button.setTitle("🙁", for: UIControl.State.normal)
        self.button.setTitle("😁", for: UIControl.State.selected)
        
        //设置点击事件
        self.button.addTarget(self, action: #selector(didClickButton(button: )), for: UIControl.Event.touchUpInside)
        
        //添加视图
        self.view.addSubview(self.button)
        
        update(isSmiling: false)
    }
    
    private func update(isSmiling: Bool) {
        if isSmiling{
            self.pokerFaceImageView.isHidden = true
            self.smileFaceImageView.isHidden = false
            self.button.isSelected = true
        }else{
            self.pokerFaceImageView.isHidden = false
            self.smileFaceImageView.isHidden = true
            self.button.isSelected = false
        }
    }
    
    @objc private func didClickButton(button: UIButton){
        update(isSmiling: !button.isSelected)
    }
    
}
