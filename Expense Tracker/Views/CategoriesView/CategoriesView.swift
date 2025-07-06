import SwiftUI

struct CategoriesView: View {
    @State var viewModel = CategoriesViewModel()
    
    var body: some View {
        List {
            Section("Статьи") {
                ForEach(Array(viewModel.filteredCategories.enumerated()), id: \.element.id) { index, category in
                    CategoryRowView(category: category, isFirst: index == 0)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
                }
            }
        }
        .searchable(
            text: $viewModel.searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search"
        )
        .task {
            await viewModel.loadCategories()
        }
    }
}


#Preview {
    CategoriesView()
}
