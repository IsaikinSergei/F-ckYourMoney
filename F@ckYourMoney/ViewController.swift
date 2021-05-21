//
//  ViewController.swift
//  F@ckYourMoney
//
//  Created by Sergei Isaikin on 17.05.2021.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var displaylabel: UILabel!
    var stillTyping = false
    
    @IBOutlet var numberFromKeyboard: [UIButton]! {
        didSet {
            for button in numberFromKeyboard {
                button.layer.cornerRadius = 11
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    // MARK: - добавляем логику по нажатию на кнопки клавиатуры
    @IBAction func numberPressed(_ sender: UIButton) {
        let number = sender.currentTitle!
        
        // делаем проверку в displaylabel
        if stillTyping {
            if displaylabel.text!.count  < 10 {
                displaylabel.text = displaylabel.text! + number
            }
        } else {
            displaylabel.text = number
            stillTyping = true
        }
        
    }
    
}

