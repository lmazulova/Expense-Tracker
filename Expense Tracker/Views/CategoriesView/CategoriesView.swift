import SwiftUI

struct CategoriesView: View {
    @State var viewModel = CategoriesViewModel()
    
    var body: some View {
        List {
            Section("Статьи") {
                ForEach(Array(viewModel.filteredCategories.enumerated()), id: \.element.id) { index, category in
                    let showDivider = index < viewModel.filteredCategories.count - 1
                    CategoryRowView(category: category, showDivider: showDivider)
                        .listRowSeparator(.hidden)
                        .listRowInsets(
                            EdgeInsets(
                                top: 0,
                                leading: 16,
                                bottom: 0,
                                trailing: 0
                            )
                        )
                        //Без этого модификатора, верхняя ячейка получается значительно ниже, чем остальные, какое-то стандартное поведение List
                        .padding(.top, index == 0 ? 10 : 0)
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
