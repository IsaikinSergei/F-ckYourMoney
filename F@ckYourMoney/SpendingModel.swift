//
//  SpendingModel.swift
//  F@ckYourMoney
//
//  Created by Sergei Isaikin on 28.05.2021.
//

import RealmSwift

// MARK: - Создаем модель данных

class Spending: Object {
    
    @objc dynamic var category = ""
    @objc dynamic var cost = 1
    @objc dynamic var date = NSDate()
}
