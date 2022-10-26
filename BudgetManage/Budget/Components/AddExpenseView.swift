//
//  AddExpenseView.swift
//  BudgetManage
//
//  Created by shuuhei hanashiro on 2022/08/28.
//

import SwiftUI

struct AddExpenseView: View {
    @EnvironmentObject private var budgetStore: BudgetStore
    @EnvironmentObject private var categoryTemplateStore: CategoryTemplateStore
    var categoryId: UUID?
    var onAdd: () -> Void
    
    @ObservedObject private var amount = NumbersOnly()
    @State private var expenseDate = Date()
    @State private var memo = ""
    @State private var includeTime: Bool = true
    @State private var selectedCategoryId: UUID?
    
    private let UNCATEGORIZED_UUID_FOR_PICKER = UUID()
    
    private var theme: Theme? {
        if let category = self.budgetStore.selectedBudget?.categories.first(where: { category in category.id == self.categoryId }), let categoryTemplate = self.categoryTemplateStore.categories.first(where: { categoryTemplate in categoryTemplate.id == category.categoryTemplateId }) {
            return categoryTemplate.theme
        }
        return nil
    }
    
    private var budgetCategories: [BudgetCategory.CategoryDisplayData] {
        if let categories = self.budgetStore.selectedBudget?.categories {
            return getBudgetCategorieDisplayDataList(categories: categories, categoryTemplates: self.categoryTemplateStore.categories)
        }
        return []
    }
    
    private func add() {
        let amount = Int(self.amount.value) ?? 0;
        if var budget = self.budgetStore.selectedBudget {
            budget.expenses.append(
                Expense(
                    date: self.expenseDate,
                    amount: amount,
                    categoryId: self.categoryId ?? self.selectedCategoryId,
                    memo: self.memo,
                    includeTimeInDate: self.includeTime
                )
            )
            self.budgetStore.selectedBudget = budget
        }
        self.onAdd()
    }
    var body: some View {
        List {
            Section(header: Text("金額")) {
                AmountTextField(value: self.$amount.value, theme: self.theme)
            }
            Section(header: Text("出費日")) {
                DatePicker("日時", selection: self.$expenseDate, displayedComponents: self.includeTime ? [.date, .hourAndMinute] : .date)
                    .foregroundColor(.secondary)
                Toggle(isOn: self.$includeTime) {
                    Text("時間を含める")
                        .foregroundColor(.secondary)
                }
            }
            Section {
                if self.categoryId == nil, let categories = self.budgetCategories, categories.count >= 1 {
//                    REF: https://stackoverflow.com/questions/65924526/deselecting-item-from-a-picker-swiftui
                    Picker("カテゴリ", selection: Binding(self.$selectedCategoryId, deselectTo: self.UNCATEGORIZED_UUID_FOR_PICKER)) {
                        Text("リセット").tag(self.UNCATEGORIZED_UUID_FOR_PICKER)
                        
                        ForEach(categories, id: \.categoryId) { category in
                            CategoryTemplateLabel(
                                title: category.title,
                                mainColor: category.mainColor,
                                accentColor: category.accentColor
                            ).tag(category.categoryId)
                        }
                    }
                }
                TextField("メモ", text: self.$memo)
                    .modifier(TextFieldClearButton(text: self.$memo))
            }
            Button {
                self.add()
            } label: {
                HStack(alignment: .center) {
                    Image(systemName: "plus")
                    Text("追加")
                        .padding(.vertical, 4)
                }
                .frame(maxWidth: .infinity)
            }
            .disabled(self.amount.value.isEmpty)
            .buttonStyle(.borderedProminent)
            .tint(self.theme?.mainColor ?? .blue)
            .listRowBackground(Color.red.opacity(0))
            .listRowInsets(EdgeInsets())
        }
    }
}

fileprivate extension Binding where Value: Equatable {
    init(_ source: Binding<Value>, deselectTo value: Value) {
        self.init(get: { source.wrappedValue },
                  set: { source.wrappedValue = $0 == source.wrappedValue ? value : $0 }
        )
    }
}
