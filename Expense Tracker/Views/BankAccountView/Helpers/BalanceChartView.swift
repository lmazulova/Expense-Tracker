import SwiftUI
import Charts

struct BalanceChartView: View {
    let balances: [DailyBalance]
    
    @State private var selectedItem: DailyBalance?
    @State private var popupPosition: CGPoint?

    var body: some View {
        Chart {
            ForEach(balances.sorted(by: { $0.date < $1.date })) { item in
                BarMark(
                    x: .value("Date", item.date, unit: .day),
                    yStart: .value("Start", 0),
                    yEnd: .value("Balance", abs(item.balance))
                )
                .foregroundStyle(item.balance < 0 ? .chartRed : .chartGreen)
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 7)) { value in
                AxisValueLabel(format: .dateTime.day().month(.twoDigits), centered: true)
            }
        }
        .chartYAxis {
            AxisMarks() { _ in }
        }
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        LongPressGesture(minimumDuration: 0.1)
                            .sequenced(before: DragGesture(minimumDistance: 0))
                            .onChanged { value in
                                switch value {
                                case .second(true, let drag?):
                                    let location = drag.location
                                    if let date: Date = proxy.value(atX: location.x) {
                                        let day = Calendar.current.startOfDay(for: date)
                                        if let item = balances.first(where: { Calendar.current.isDate($0.date, inSameDayAs: day) }) {
                                            selectedItem = item
                                            popupPosition = CGPoint(x: location.x, y: proxy.position(forY: abs(item.balance)) ?? 0)
                                        }
                                    }
                                default: break
                                }
                            }
                            .onEnded { _ in
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    selectedItem = nil
                                    popupPosition = nil
                                }
                            }
                    )
            }
        }
        .overlay(alignment: .topLeading) {
            if let item = selectedItem, let position = popupPosition {
                Text("\(item.balance, format: .number.precision(.fractionLength(2)))")
                    .font(.caption)
                    .padding(6)
                    .background(Color(.systemGray6))
                    .foregroundColor(.black)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 0.5)
                    )
                    .position(x: position.x, y: position.y - 30)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.2), value: selectedItem)
            }
        }
        .frame(height: 230)
    }
}
