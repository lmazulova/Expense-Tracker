import SwiftUI

struct CategoriesView: View {
    @State var viewModel: CategoriesViewModel
    
    init() {
        self._viewModel = State(wrappedValue: CategoriesViewModel(categoriesService: CategoriesService(networkClient: NetworkClient(), localStorage: CategoriesStorage())))
    }
    
    var body: some View {
        VStack {
            if viewModel.state == .loading {
                ProgressView()
            } else {
                List {
                    Section("Статьи") {
                        ForEach(Array(viewModel.filteredCategories.enumerated()), id: \.element.id) { index, category in
                            CategoryRowView(category: category, isFirst: index == 0)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
                        }
                    }
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
        .alert("Упс, что-то пошло не так.", isPresented: .constant({
            if case .error = viewModel.state { return true }
            return false
        }())) {
            Button("Ок", role: .cancel) {
                viewModel.state = .data
            }
        } message: {
            Text(viewModel.state.errorMessage ?? "Уже чиним!")
        }
    }
}


#Preview {
//    CategoriesView()
}
