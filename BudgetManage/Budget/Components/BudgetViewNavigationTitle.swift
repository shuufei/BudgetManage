//
//  NavigationViewTitle.swift
//  BudgetManage
//
//  Created by shuuhei hanashiro on 2022/08/21.
//

import SwiftUI

struct BudgetViewNavigationTitle: View {
    var title: String
    @Binding var openedBudgetListModal: Bool
    
    private let iconSize: CGFloat = 15
    private var titleWidth: CGFloat {
        let bounds = UIScreen.main.bounds
        let width = bounds.width
        let maxWidth = width * (2/3)
//        TODO: calculatedを使うと、ボタンが横幅に収まらないため一時的にmaxWidthを採用
//        let calculated =  (CGFloat(title.isEmpty ? 1 : title.count) * 30) + (self.iconSize * 2)
//        return calculated > maxWidth ? maxWidth : calculated
        return maxWidth
    }
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Spacer().frame(width: self.iconSize)
            Text(title)
            Button(role: .none) {
                self.openedBudgetListModal = true
            } label: {
                Image(systemName: "chevron.down")
                    .resizable()
                    .frame(width: self.iconSize, height: 8)
            }
        }
        .frame(width: self.titleWidth, height: 20, alignment: .center)
    }
}

struct NavigationViewTitle_Previews: PreviewProvider {
    static var previews: some View {
        BudgetViewNavigationTitle(title: "予算", openedBudgetListModal: .constant(false))
    }
}
