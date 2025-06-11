import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        //===== Чтение/запись в файл =====
        // Можно раскомментить и посмотреть как работает сохранение и чтение из файла JSON
        
//        .onAppear {
//            let fileCache = TransactionsFileCache()
//            fileCache.save(to: "/Users/user/Desktop/Expense Tracker/Expense Tracker/TransactionsFileCache/TransactionsFile1.json")
//            fileCache.load(from: "/Users/user/Desktop/Expense Tracker/Expense Tracker/TransactionsFileCache/TransactionsFile2.json")
//            print(fileCache.transactions)
//        }
    }
}

#Preview {
    ContentView()
}
