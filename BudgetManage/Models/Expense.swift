//
//  Expense.swift
//  BudgetManage
//
//  Created by shuuhei hanashiro on 2022/08/24.
//

import Foundation

struct Expense: Codable, Hashable, Identifiable {
    var id: UUID
    var date: Date
    var amount: Int
    var categoryId: String?
    var memo: String?
    
    init(date: Date, amount: Int, categoryId: String? = nil, memo: String? = nil) {
        self.id = UUID()
        self.date = date
        self.amount = amount
        self.categoryId = categoryId
        self.memo = memo
    }
}

extension Expense {
    static var sampleData = [
        Expense(date: Date(timeIntervalSince1970: 1660316400), amount: 10000),
        Expense(date: Date(timeIntervalSince1970: 1660316400 + daySeconds), amount: 5000, memo: "飲み代"),
        Expense(date: Date(timeIntervalSince1970: 1660316400 + (daySeconds * 2)), amount: 1000, memo: "食費"),
        Expense(date: Date(timeIntervalSince1970: 1660316400 + (daySeconds * 2)), amount: 2000, memo: "交通費"),
    ]
}
