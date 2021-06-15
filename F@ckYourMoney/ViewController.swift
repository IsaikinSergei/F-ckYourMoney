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
    
    @IBOutlet weak var limitLabel: UILabel!
    @IBOutlet weak var howManyCanSpend: UILabel!
    @IBOutlet weak var spendByCheck: UILabel!
    @IBOutlet weak var displaylabel: UILabel!
    @IBOutlet weak var allSpending: UILabel!
    
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
        leftLabels()
        
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
    // MARK: - добавляем логику для кнопок выбора категорий
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
        // вызываем функцию обновления всех лэйблов
        leftLabels()
        
        // перезагружаем(обновляем) таблицу после нажатия на кнопку категории и записи в БД Realm
        tableView.reloadData()
    }
    
    // MARK: - добавляем alertController и логику по нажатию на кнопку "Установить лимит"
    @IBAction func limitPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Установить лимит", message: "Введите сумму и количество дней", preferredStyle: .alert)
        let alertInstall = UIAlertAction(title: "Установить", style: .default) { action in
            
            
            let tfsum = alertController.textFields?[0].text
            
            let tfday = alertController.textFields?[1].text
            
            // делаем проверку на nil чтобы избежать падения приложения
            guard tfday != "" && tfsum != "" else { return }
            
            self.limitLabel.text = tfsum
            
            if let day = tfday {
                let dateNow = Date()
                let lastDay: Date = dateNow.addingTimeInterval(60*60*24*Double(day)!)
                
                // создаем переменную которая будет содержать все значения базы данных Limit
                let limit = self.realm.objects(Limit.self)
                
                // делаем проверку, если значений лимита нет, то делаем запись в БД, иначе делаем перезапись значения лимита в БД
                if limit.isEmpty == true {
                    // создаем экземпляр клссаа(модели данных)
                    let value = Limit(value: [self.limitLabel.text!, dateNow, lastDay])
                    
                    // делаем запись в базу данных Realm
                    try! self.realm.write {
                        self.realm.add(value)
                    }
                } else {
                    try! self.realm.write {
                        limit[0].limitSum = self.limitLabel.text!
                        limit[0].limitDate = dateNow as NSDate
                        limit[0].limitLastDay = lastDay as NSDate
                    }
                }
            }
            // вызываем функцию leftLabels для того, чтобы после установления лимит обновлялись и другие лэйблы
            self.leftLabels()
        }
        
        alertController.addTextField { (money) in
            money.placeholder = "Сумма"
            money.keyboardType = .asciiCapableNumberPad
        }
        
        alertController.addTextField { (day) in
            day.placeholder = "Количество дней"
            day.keyboardType = .asciiCapableNumberPad
        }
        
        let alertCancel = UIAlertAction(title: "Отмена", style: .default) { _ in }
        
        // вызываем наши действия по нажатию на кноки Alert контроллера
        alertController.addAction(alertInstall)
        alertController.addAction(alertCancel)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - добавляем метод работы с лэйблами и их значениями
    func leftLabels() {
        
        let limit = self.realm.objects(Limit.self)
        
        limitLabel.text = limit[0].limitSum
        
        let calendar = Calendar.current
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        let firstDay = limit[0].limitDate as Date
        let lastDay = limit[0].limitLastDay as Date
        
        let firstComponents = calendar.dateComponents([.year, .month, .day], from: firstDay)
        let lastComponents = calendar.dateComponents([.year, .month, .day], from: lastDay)
        
        let startDate = formatter.date(from: "\(firstComponents.year!)/\(firstComponents.month!)/\(firstComponents.day!) 00:00")
        let endDate = formatter.date(from: "\(lastComponents.year!)/\(lastComponents.month!)/\(lastComponents.day!) 23:59")
        
        let filteredLimit: Int = realm.objects(Spending.self).filter("self.date >= %@ && self.date <= %@", startDate, endDate).sum(ofProperty: "cost")
        
        spendByCheck.text = "\(filteredLimit)"
        
        // добавляем логику вычисления значений лэйблов
        let a = Int(limitLabel.text!)!
        let b = Int(spendByCheck.text!)!
        let c = a - b
        
        howManyCanSpend.text = "\(c)"
        
        let allSpend: Int = realm.objects(Spending.self).sum(ofProperty: "cost")
        allSpending.text = "\(allSpend)"
        
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let editingRow = spendingArray[indexPath.row]
            
            // удаляем запись из базы данных Realm
            try! self.realm.write {
                self.realm.delete(editingRow)
                // вызываем функцию leftLabels после удаления записи из таблицы и БД для обновления всех лэйблов
                leftLabels()
                
                // перезагружаем(обновляем) таблицу после смахивания влево и нажатия на кнопку Delete
                tableView.reloadData()
            }
        }
    }
}

