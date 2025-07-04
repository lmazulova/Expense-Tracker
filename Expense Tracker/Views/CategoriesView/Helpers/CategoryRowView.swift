import SwiftUI

struct CategoryRowView: View {
    let category: Category
    let showDivider: Bool
    
    init(category: Category, showDivider: Bool) {
        self.category = category
        self.showDivider = showDivider
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(String(category.emoji))
                    .font(.system(size: 14.5))
                    .frame(width: ViewConstants.iconSize, height: ViewConstants.iconSize)
                    .background(Color.mintGreen)
                    .clipShape(.circle)
                
                Text(category.name)
                    .font(.system(size: 17))
                
                Spacer()
            }
            if showDivider {
                Divider()
                    .padding(.leading, ViewConstants.iconSize + 8)
            }
        }
    }
}

private enum ViewConstants {
    static let iconSize: Double = 22
}

#Preview {
    CategoryRowView(
        category: Category(
            id: 1,
            name: "Медицина",
            emoji: "💊",
            direction: .outcome
        ),
        showDivider: false
    )
}
