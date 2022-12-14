//
//  BudgetListModalView.swift
//  BudgetManage
//
//  Created by shuuhei hanashiro on 2022/08/23.
//

import SwiftUI

struct BudgetListModalView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var budgetStore: BudgetStore
    
    @Binding var showBudgetList: Bool

    @State private var openedCreateBudgetModal: Bool = false
    @State private var showDeleteConfirmAlert: Bool = false
    @State private var deletionTarget: Budget? = nil
    
    @State private var editTarget: Budget? = nil

    func getFormattedBudgetAmout(budgetAmount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(
            from: NSNumber(value: budgetAmount)
        ) ?? "0"
        return "¥\(formatted)"
    }
    
    var body: some View {
        NavigationView {
            List {
                if self.budgetStore.budgets.count == 0 {
                    Text("予算が登録されていません")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.black.opacity(0))
                }
                ForEach(self.budgetStore.budgets) { budget in
                    Button(role: .none) {
                        for (index, element) in self.budgetStore.budgets.enumerated() {
                            self.budgetStore.budgets[index].isActive = element.id == budget.id ? true : false
                        }
                        self.showBudgetList = false
                    } label: {
                        HStack {
                            if budget.isActive ?? false {
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .foregroundColor(.green)
                                    .frame(width: 20, height: 20)
                            } else {
                                Text("")
                                    .frame(width: 20)
                            }
                            Text(budget.title)
                                .lineLimit(1)
                            Spacer()
                            Text(self.getFormattedBudgetAmout(budgetAmount: budget.budgetAmount))
                                .foregroundColor(.secondary)
                        }
                    }
                    .foregroundColor(self.colorScheme == .dark ? .white : .black)
                    .swipeActions {
                        Button {
                            self.showDeleteConfirmAlert = true
                            self.deletionTarget = budget
                        } label: {
                            Text("削除")
                        }
                        .tint(.red)
                        Button(role: .none) {
                            self.editTarget = budget
                        } label: {
                            Text("編集")
                        }
                        .tint(.gray)
                    }
                }
            }
            .navigationTitle("予算一覧")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") {
                        self.showBudgetList = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        self.openedCreateBudgetModal = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: self.$openedCreateBudgetModal) {
                CreateBudgetModalViewProvider(
                    openedCreateBudgetModal: self.$openedCreateBudgetModal
                )
            }
            .alert("予算の削除", isPresented: self.$showDeleteConfirmAlert, presenting: self.deletionTarget) { budget in
                    Button("削除", role: .destructive) {
                        var tmpBudgets = self.budgetStore.budgets.filter { $0.id != budget.id }
                        let index = tmpBudgets.firstIndex {$0.isActive == true}
                        if index == nil && tmpBudgets.count != 0 {
                            tmpBudgets[0].isActive = true
                        }
                        self.budgetStore.budgets = tmpBudgets
                    }
            } message: { budget in
                Text("予算を削除すると、予算に紐づく出費記録も削除されます。")
            }
            .sheet(item: self.$editTarget) { editTarget in
                EditBudgetModalView(budget: editTarget) { budget in
                    if let index = self.budgetStore.budgets.firstIndex(where: {el in el.id == editTarget.id}) {
                        self.budgetStore.budgets[index] = budget
                    }
                }
                
            }
        }
    }
}

struct BudgetListModalView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetListModalView(showBudgetList: .constant(true))
            .environmentObject(BudgetStore())
    }
}
