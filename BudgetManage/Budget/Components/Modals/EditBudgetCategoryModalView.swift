//
//  CreateBudgetCategoryModalView.swift
//  BudgetManage
//
//  Created by shuuhei hanashiro on 2022/09/05.
//

import SwiftUI

struct EditBudgetCategoryModalView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var budgetStore: BudgetStore
    @EnvironmentObject private var categoryTemplateStore: CategoryTemplateStore
    
    @State private var showAddConfirmAlert: Bool = false
    @State private var addTarget: CategoryTemplate? = nil
    @ObservedObject var categoryBudgetAmount = NumbersOnly()

    @State private var showRemoveConfirmAlert: Bool = false
    @State private var removeTarget: CategoryTemplate? = nil
    
    @State private var showCreateCategoryTemplateModalView: Bool = false

    @State private var tmpBudget: Budget = Budget(startDate: Date(), endDate: Date(), budgetAmount: 0)
    
    private var budgetCategories: [BudgetCategory.CategoryDisplayData] {
        return getBudgetCategorieDisplayDataList(categories: self.tmpBudget.categories, categoryTemplates: self.categoryTemplateStore.categories)
    }
    
    private var appendableCategoryTemplates: [CategoryTemplate] {
        self.categoryTemplateStore.categories.filter { categoryTemplate in
            self.tmpBudget.categories.first { $0.categoryTemplateId == categoryTemplate.id } == nil
        }
    }
    
    private func addBudgetCategory() -> Void {
        if addTarget == nil {
            return
        }
        
        let budgetAmount: Int = Int(self.categoryBudgetAmount.value) ?? 0
        self.tmpBudget.categories.append(Category(categoryTemplateId: self.addTarget!.id, budgetAmount: budgetAmount))
    }
    
    private func resetAddAlert() {
        self.showAddConfirmAlert = false
        self.addTarget = nil
        self.categoryBudgetAmount.value = ""
    }
    
    private func removeBudgetCategory() -> Void {
        if let categoryTemplate = self.removeTarget, let category = self.tmpBudget.categories.first(where: { $0.categoryTemplateId == categoryTemplate.id }) {
            self.tmpBudget.categories = self.tmpBudget.categories.filter { $0.categoryTemplateId != categoryTemplate.id }
            self.tmpBudget.expenses = self.tmpBudget.expenses.map { expense in
                var tmp = expense
                if expense.categoryId == category.id {
                    tmp.categoryId = nil
                }
                return tmp
            }
        }
    }
    
    private func commit() {
        self.budgetStore.selectedBudget = self.tmpBudget
        self.dismiss()
    }
    
    @State private var presentingConfirmationDialog: Bool = false
    private var isModified: Bool {
        get {
            self.budgetStore.selectedBudget != self.tmpBudget
        }
    }

    var body: some View {
        List {
            Text("\(self.tmpBudget.title)????????????????????????????????????, ??????")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .listRowBackground(Color.black.opacity(0))
                .listRowInsets(EdgeInsets())
            Section(header: Text("????????????")) {
                if self.tmpBudget.categories.isEmpty {
                    Text("???????????????????????????????????????????????????")
                        .listRowBackground(Color.black.opacity(0))
                        .font(.callout)
                }
                ForEach(Array(self.budgetCategories.enumerated()), id: \.element) { index, category in
                    Button(role: .none) {
                        let categoryTemplate = self.categoryTemplateStore.categories.first { $0.id == category.categoryTemplateId }
                        self.removeTarget = categoryTemplate
                        self.showRemoveConfirmAlert = true
                    } label: {
                        HStack {
                            HStack {
                                CategoryTemplateLabel(title: category.title, mainColor: category.mainColor, accentColor: category.accentColor)
                                Text("??\(category.budgetAmount)")
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "minus.circle.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.red)
                            
                        }
                    }
                }
            }
            Section(header: Text("??????????????????")) {
                if self.categoryTemplateStore.categories.isEmpty {
                    Text("??????????????????????????????????????????")
                        .listRowBackground(Color.black.opacity(0))
                        .font(.callout)
                }
                if self.appendableCategoryTemplates.isEmpty {
                    Text("?????????????????????????????????????????????")
                        .listRowBackground(Color.black.opacity(0))
                        .font(.callout)
                }
                ForEach(self.appendableCategoryTemplates) { categoryTemplate in
                    Button(role: .none) {
                        self.showAddConfirmAlert = true
                        self.addTarget = categoryTemplate
                    } label: {
                        HStack {
                            CategoryTemplateLabel(title: categoryTemplate.title, mainColor: categoryTemplate.theme.mainColor, accentColor: categoryTemplate.theme.accentColor)
                            Spacer()
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            
            HStack {
                Spacer()
                Button {
                    self.showCreateCategoryTemplateModalView = true
                } label: {
                    Text("??????????????????????????????")
                }
                .buttonStyle(.borderless)
                Spacer()
            }
            .listRowBackground(Color.black.opacity(0))
            .listRowSeparator(.hidden)
            
            AddBudgetCategoryAlert(
                textfieldText: self.$categoryBudgetAmount.value,
                showingAlert: self.$showAddConfirmAlert,
                budgetTitle: self.tmpBudget.title,
                categoryTitle: self.addTarget?.title ?? "",
                cancelButtonAction: {
                    self.resetAddAlert()
                },
                addButtonAction: {
                    self.addBudgetCategory()
                    self.resetAddAlert()
                }
            )
            .listRowBackground(Color.black.opacity(0))
        }
        .navigationTitle("???????????????????????????")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let budget = self.budgetStore.selectedBudget {
                self.tmpBudget = budget
            }
            if #available(iOS 15, *) {
                UITableView.appearance().contentInset.top = -25
            }
        }
        .onDisappear {
            if #available(iOS 15, *) {
                UITableView.appearance().contentInset.top = .zero
            }
        }
        .alert("?????????????????????", isPresented: self.$showRemoveConfirmAlert) {
            Button("??????", role: .destructive) {
                self.removeBudgetCategory()
                self.showRemoveConfirmAlert = false
                self.removeTarget = nil
            }
        } message: {
            if self.removeTarget == nil {
                Text("?????????")
            }
            Text("\(self.tmpBudget.title)??????\(self.removeTarget?.title ?? "")????????????????????????????????????????????????????????????????????????????????????????????????????????????")
        }
        .sheet(isPresented: self.$showCreateCategoryTemplateModalView) {
            CreateCategoryTemplateModalView(showModalView: self.$showCreateCategoryTemplateModalView) { categoryTemplate in
                self.categoryTemplateStore.categories.append(categoryTemplate)
            }
        }
        .confirmationDialog(isModified: self.isModified, onCommit: self.commit)
    }
}

struct CreateBudgetCategoryModalView_Previews: PreviewProvider {
    static var previews: some View {
        EditBudgetCategoryModalView()
            .environmentObject(BudgetStore())
            .environmentObject(CategoryTemplateStore())
    }
}
