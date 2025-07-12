import SwiftUI

struct CustomTimePicker: View {
    @Binding var selectedTime: Date
    @State var textWidth: CGFloat = 0
    
    var body: some View {
        ZStack {
            Text(selectedTime.formatted(date: .omitted, time: .shortened))
                .padding(.horizontal, 11)
                .padding(.vertical, 6)
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .onChange(of: geometry.size.width, initial: true) { _, newValue in
                                textWidth = newValue
                            }
                    }
                )
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.mintGreen)
                )
                .foregroundColor(.black)
            
            // кладем datePicker под визуальное отображение с помощью модификатора blendMode, но выше в стэке, так он остается кликабельным и при этом не виден на экране
            DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .blendMode(.destinationOver)
                .allowsHitTesting(true)
                .frame(width: textWidth)
        }
    }
}


#Preview {
    struct PreviewWrapper: View {
        @State var time = Date()
        var body: some View {
            CustomTimePicker(selectedTime: $time)
        }
    }
    return PreviewWrapper()
}
