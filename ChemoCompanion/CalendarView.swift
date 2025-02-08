import SwiftUI

struct CalendarView: View {
    @Binding var selectedDate: Date

    var body: some View {
        DatePicker(
            "Select Date",
            selection: $selectedDate,
            displayedComponents: [.date]
        )
        .datePickerStyle(.graphical)
        .labelsHidden()
    }
}
