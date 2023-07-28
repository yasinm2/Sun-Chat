//
//  WelcomeViewController.swift
//  Sun Chat
//  Created by Yasin Ağbulut on 21/07/2023

//
import UIKit
import CLTypingLabel

class WelcomeViewController: UIViewController {

    @IBOutlet weak var titleLabel: CLTypingLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = K.appName
       
    }

}

