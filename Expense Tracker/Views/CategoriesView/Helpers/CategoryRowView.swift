import SwiftUI

struct CategoryRowView: View {
    let category: Category
    let isFirst: Bool
    
    init(category: Category, isFirst: Bool = false) {
        self.category = category
        self.isFirst = isFirst
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .padding(.leading, ViewConstants.iconSize + 8)
                .opacity(isFirst ? 0 : 1)
            
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
            .frame(idealHeight: ViewConstants.idealHeight, maxHeight: ViewConstants.maxHeight)
            
            Divider()
                .padding(.leading, ViewConstants.iconSize + 8)
                .opacity(0)
        }
    }
}

private enum ViewConstants {
    static let iconSize: Double = 22
    static let idealHeight: Double = 44
    static let maxHeight: Double = 64
}

#Preview {
    CategoryRowView(
        category: Category(
            id: 1,
            name: "Медицина",
            emoji: "💊",
            direction: .outcome
        )
    )
}
