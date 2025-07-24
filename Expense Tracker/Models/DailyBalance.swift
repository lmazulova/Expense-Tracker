import Foundation

struct DailyBalance: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    //Заменяем Decimal на Double т.к. Double конформит Plottable
    let balance: Double
}
