//
//  CategoryCard.swift
//  BudgetManage
//
//  Created by shuuhei hanashiro on 2022/08/24.
//

import SwiftUI

struct CategoryCard: View {
    @Environment(\.colorScheme) var colorScheme
    var budgetCategory: BudgetCategory
    
    @State private var totalHeight = CGFloat(0)
    private let horizontalPadding: CGFloat = 12
    private let verticalPadding: CGFloat = 12
    private let barHeight: CGFloat = 20

    private var data: BudgetCategory.CategoryDisplayData {
        self.budgetCategory.displayData()
    }
    
    private var balanceAmountRate: CGFloat {
        let rate = CGFloat(self.data.balanceAmount) / CGFloat(self.data.budgetAmount)
        return rate.isNaN || (!rate.isNaN && rate < 0) ? 0 : rate
    }
    
    private var totalExpenseAmountRate: CGFloat {
        CGFloat(1) - self.balanceAmountRate
    }
    
    private var isDeficit: Bool {
        self.data.balanceAmount < 0
    }
    
    private func getBalanceAmountBarWidth(_ geometryWidth: CGFloat) -> CGFloat {
        let sideSpacing = self.horizontalPadding * 2
        let width = geometryWidth - sideSpacing;
        print("rate: \(self.balanceAmountRate)")
        return width >= 0 ? width * self.balanceAmountRate : 0;
    }
    
    private func getTotalExpenseAmountBarWidth(_ geometryWidth: CGFloat) -> CGFloat {
        let sideSpacing = self.horizontalPadding * 2
        let width = geometryWidth - sideSpacing;
        return width >= 0 ? width * self.totalExpenseAmountRate : 0;
    }
    
    var body: some View {
        GeometryReader { geometry in
                VStack(spacing: 8) {
                    HStack {
                        Text(self.data.title)
                            .font(.headline)
                        Spacer()
                        HStack(spacing: 4) {
                            Text("残り")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            Text("¥\(self.data.balanceAmount)")
                                .font(.headline)
                                .foregroundColor(self.isDeficit ? .red : getDefaultForegroundColor(self.colorScheme))
                        }
                    }
                    VStack(spacing: 2) {
                        HStack(spacing: 0) {
                            self.data.color
                                .frame(width: self.getBalanceAmountBarWidth(geometry.size.width), height: self.barHeight)
                            Color(UIColor.systemGray5).frame(width: self.getTotalExpenseAmountBarWidth(geometry.size.width), height: self.barHeight)
                        }
                        .cornerRadius(3)
                        HStack {
                            Text("¥0")
                            Spacer()
                            Text("¥\(self.data.budgetAmount)")
                        }
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, self.horizontalPadding)
                .padding(.vertical, self.verticalPadding)
                .background(getDefaultBackgroundColor(self.colorScheme))
                .cornerRadius(8)
                .background(GeometryReader { gp -> Color in
                    DispatchQueue.main.async {
                        self.totalHeight = gp.size.height
                    }
                    return Color.clear
                })
        }
        .frame(height: self.totalHeight)
    }
}

struct CategoryCard_Previews: PreviewProvider {
    static var previews: some View {
        CategoryCard(
            budgetCategory: .uncategorized(
                UnCategorized(title: "未分類", budgetAmount: 40000),
                Expense.sampleData
            )
        )
    }
}
