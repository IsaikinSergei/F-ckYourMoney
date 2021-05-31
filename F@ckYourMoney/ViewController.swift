//
//  ViewController.swift
//  F@ckYourMoney
//
//  Created by Sergei Isaikin on 17.05.2021.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {

    let realm = try! Realm()
    var spendingArray: Results<Spending>!
    
    @IBOutlet weak var displaylabel: UILabel!
    var stillTyping = false
    
    @IBOutlet var numberFromKeyboard: [UIButton]! {
        didSet {
            for button in numberFromKeyboard {
                button.layer.cornerRadius = 11
            }
        }
    }
    
    var categoryName = ""
    var displayValue: Int = 1
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spendingArray = realm.objects(Spending.self)
        
    }

    // MARK: - добавляем логику по нажатию на кнопки клавиатуры
    @IBAction func numberPressed(_ sender: UIButton) {
        let number = sender.currentTitle!
        
        // делаем проверку в displaylabel
        if stillTyping {
            if displaylabel.text == "0" {
                displaylabel.text = ""
        }
            if displaylabel.text!.count < 15 {
                displaylabel.text = displaylabel.text! + number
            }
        } else {
            displaylabel.text = number
            stillTyping = true
        }
        
    }
    // MARK: - добавляем логику для кнопки "сброс"
    @IBAction func resetButton(_ sender: UIButton) {
        displaylabel.text = "0"
        stillTyping = false
    }
    
    @IBAction func categoryPressed(_ sender: UIButton) {
        categoryName = sender.currentTitle!
        displayValue = Int(displaylabel.text!)!
        displaylabel.text = "0"
        stillTyping = false
        
        // создаем экземпляр клссаа(модели данных)
        let value = Spending(value: ["\(categoryName)", displayValue])
        
        // делаем запись в базу данных Realm
        try! realm.write {
            realm.add(value)
        }
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spendingArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        let spending = spendingArray[indexPath.row]
        
        cell.recordCategory.text = spending.category
        cell.recordCost.text = "\(spending.cost)"
        
        // перебираем картинки для каждой категории с помощью конструкции switch
        switch spending.category {
        case "Еда": cell.recordImage.image = #imageLiteral(resourceName: "Category_Еда")
        case "Одежда": cell.recordImage.image = #imageLiteral(resourceName: "Category_Одежда")
        case "Связь": cell.recordImage.image = #imageLiteral(resourceName: "Category_Связь")
        case "Досуг": cell.recordImage.image = #imageLiteral(resourceName: "Category_Досуг")
        case "Красота": cell.recordImage.image = #imageLiteral(resourceName: "Category_Красота")
        case "Авто": cell.recordImage.image = #imageLiteral(resourceName: "Category_Авто")
        default: cell.recordImage.image = #imageLiteral(resourceName: "Display")
        }
        
        return cell
    }
    
    
}


