import SwiftUI
import Foundation

struct ScheduleView: View {
    @State private var selectedDate = Date()
    @State private var showingAddAppointment = false
    @State private var appointments: [Appointment] = []

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Appointments")
                    .font(.title)
                    .padding(.top)

                // Upcoming appointments list
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(getUpcomingAppointments()) { appointment in
                        HStack {
                            Text(appointment.date, format: .dateTime.month().day().year())
                            Text("-")
                            Text(appointment.location)
                        }
                        .padding(.horizontal)
                        .foregroundColor(.secondary)
                    }
                }

                // Calendar
                CalendarView(selectedDate: $selectedDate)
                    .padding()
                    .background(Color("Background"))
                    .cornerRadius(15)

                // Selected date appointments
                if let appointment = getAppointment(for: selectedDate) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Appointments")
                            .font(.headline)
                            .padding(.horizontal)

                        HStack {
                            Text(appointment.date, format: .dateTime.hour().minute())
                            if let notes = appointment.notes {
                                Text(notes)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color("Background"))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                }

                Spacer()

                // Add button
                Button(action: { showingAddAppointment = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(Color("Primary"))
                }
                .padding(.bottom)
            }
            .sheet(isPresented: $showingAddAppointment) {
                AddAppointmentSheet(selectedDate: selectedDate) { date, location, notes in
                    appointments.append(Appointment(date: date, location: location, notes: notes))
                }
            }
        }
    }

    private func getUpcomingAppointments() -> [Appointment] {
        appointments
            .filter { $0.date >= Date() }
            .sorted { $0.date < $1.date }
            .prefix(3)
            .map { $0 }
    }

    private func getAppointment(for date: Date) -> Appointment? {
        appointments.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
}

struct CalendarView: View {
    @Binding var selectedDate: Date
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekDays = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        VStack(spacing: 15) {
            // Month navigation
            HStack {
                Button(action: { moveMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(selectedDate, format: .dateTime.month().year())
                    .font(.headline)
                Spacer()
                Button(action: { moveMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                }
            }

            // Week days
            LazyVGrid(columns: columns) {
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Days
            LazyVGrid(columns: columns) {
                ForEach(getDaysInMonth(), id: \.self) { date in
                    Text("\(calendar.component(.day, from: date))")
                        .frame(height: 35)
                        .foregroundColor(calendar.isDate(date, equalTo: selectedDate, toGranularity: .month) ? .primary : .secondary)
                        .background(calendar.isDate(date, inSameDayAs: selectedDate) ? Color("Primary").opacity(0.2) : Color.clear)
                        .clipShape(Circle())
                        .onTapGesture {
                            selectedDate = date
                        }
                }
            }
        }
    }

    private func moveMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: selectedDate) {
            selectedDate = newDate
        }
    }

    private func getDaysInMonth() -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1) else {
            return []
        }

        let dateInterval = DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end)
        var dates: [Date] = []
        calendar.enumerateDates(
            startingAfter: dateInterval.start,
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime
        ) { date, _, stop in
            guard let date = date else { return }
            if date > dateInterval.end {
                stop = true
                return
            }
            dates.append(date)
        }
        return dates
    }
}

struct AddAppointmentSheet: View {
    @Environment(\.dismiss) var dismiss
    let selectedDate: Date
    let onSave: (Date, String, String?) -> Void

    @State private var date: Date
    @State private var location = ""
    @State private var notes = ""

    init(selectedDate: Date, onSave: @escaping (Date, String, String?) -> Void) {
        self.selectedDate = selectedDate
        self.onSave = onSave
        _date = State(initialValue: selectedDate)
    }

    var body: some View {
        NavigationView {
            Form {
                DatePicker("Date", selection: $date)
                TextField("Location", text: $location)
                TextField("Optional Notes", text: $notes)
            }
            .navigationTitle("Add Appointment")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(date, location, notes.isEmpty ? nil : notes)
                        dismiss()
                    }
                    .disabled(location.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct Appointment: Identifiable {
    let id = UUID()
    let date: Date
    let location: String
    let notes: String?
}

