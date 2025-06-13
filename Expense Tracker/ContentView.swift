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
        .onAppear {
            testFileCache()
        }
    }
    private func testFileCache() {
            let fileCache = TransactionsFileCache()
            
            let file1 = "/Users/user/Desktop/Expense Tracker/Expense Tracker/TransactionsFileCache/TransactionsFile1.json"
            let file2 = "/Users/user/Desktop/Expense Tracker/Expense Tracker/TransactionsFileCache/TransactionsFile2.json"
            
            fileCache.save(to: file1)
            fileCache.load(from: file2)
            
            print(fileCache.transactions)
        }
}

#Preview {
    ContentView()
}
