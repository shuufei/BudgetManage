//
//  CategoryDetailView.swift
//  BudgetManage
//
//  Created by shuuhei hanashiro on 2022/08/29.
//

import SwiftUI

struct CategoryDetailView: View {
    @EnvironmentObject private var budgetStore: BudgetStore
    @EnvironmentObject private var categoryTemplateStore: CategoryTemplateStore

    @Binding var selectedCategoryId: UUID?
    
    @State private var showDeleteConfirmAlert: Bool = false
    @State private var deletionTarget: Expense? = nil

    @State private var editTarget: Expense? = nil
    
    let budgetCategory: BudgetCategory
    
    private var expenses: [Expense] {
        self.budgetStore.selectedBudget?.expenses.filter {
            $0.categoryId == self.selectedCategoryId
        } ?? []
    }
    
    private func getFormattedDate(date: Date, includeTime: Bool = true) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "y年M月d日\(includeTime ? " HH:mm" : "")"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }

    var body: some View {
        List {
            Section {
                CategoryBudgetBar(
                    budgetCategory: self.budgetCategory
                )
                .listRowInsets(EdgeInsets(top: 12, leading: 12, bottom: 8, trailing: 12))
            }
            Section(header: Text("カテゴリ情報")) {
                HStack {
                    Text("予算額")
                    Spacer()
                    Text("¥\(self.budgetCategory.displayData().budgetAmount)")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("出費合計")
                    Spacer()
                    Text("¥\(self.budgetCategory.displayData().totalExpenseAmount)")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("残額")
                    Spacer()
                    Text("¥\(self.budgetCategory.displayData().balanceAmount)")
                        .foregroundColor(.secondary)
                }
            }
            Section(header: Text("出費")) {
                if self.expenses.count == 0 {
                    Text("出費がまだありません")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .listRowBackground(Color.black.opacity(0))
                        .foregroundColor(.secondary)
                }
                ForEach(self.expenses) { expense in
                    HStack {
                        Text(self.getFormattedDate(date: expense.date, includeTime: expense.includeTimeInDate))
                            .fixedSize(horizontal: true, vertical: true)
                        Spacer()
                        if !(expense.memo).isEmpty {
                            VStack(alignment: .trailing) {
                                Text("¥\(expense.amount)")
                                    .font(.callout)
                                Text(expense.memo)
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        } else {
                            Text("¥\(expense.amount)")
                                .font(.callout)
                        }
                    }
                    .lineLimit(1)
                    .swipeActions {
                        Button(role: .destructive) {
                            self.showDeleteConfirmAlert = true
                            self.deletionTarget = expense
                        } label: {
                            Text("削除")
                        }
                        Button(role: .none) {
                            self.editTarget = expense
                        } label: {
                            Text("編集")
                        }
                        .tint(.gray)
                    }
                    .alert("出費の削除", isPresented: self.$showDeleteConfirmAlert, presenting: self.deletionTarget) { expense in
                            Button("削除", role: .destructive) {
                                self.showDeleteConfirmAlert = false
                                self.deletionTarget  = nil
                                if var budget = self.budgetStore.selectedBudget {
                                    budget.expenses = budget.expenses.filter { $0.id != expense.id }
                                    // NOTE: https://developer.apple.com/forums/thread/676885
                                    DispatchQueue.main.async {
                                        self.budgetStore.selectedBudget = budget
                                    }
                                }
                            }
                    } message: { expense in
                        Text("出費の記録を削除しますか?")
                    }
                }
            }
        }
        .sheet(item: self.$editTarget) { editTarget in
            if var budget = self.budgetStore.selectedBudget, let expenseIndex = budget.expenses.firstIndex(where: { el in
                el.id == editTarget.id
            }), let expense = budget.expenses[expenseIndex] {
                EditExpenseModalView(expense: expense) { expense in
                    budget.expenses[expenseIndex] = expense
                    self.budgetStore.selectedBudget = budget
                }
            }
        }
        .onAppear {
            if #available(iOS 15, *) {
                UITableView.appearance().contentInset.top = -25
            }
        }
        .onDisappear {
            if #available(iOS 15, *) {
                UITableView.appearance().contentInset.top = .zero
            }
        }
    }
}

struct CategoryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryDetailView(
            selectedCategoryId: .constant(nil),
            budgetCategory: .uncategorized(UnCategorized(title: "", budgetAmount: 0), [])
        )
            .environmentObject(BudgetStore())
            .environmentObject(CategoryTemplateStore())
    }
}
