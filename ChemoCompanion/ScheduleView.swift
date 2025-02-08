import SwiftUI
import CoreData

struct ScheduleView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: ChemoSession.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ChemoSession.date, ascending: true)]
    ) private var appointments: FetchedResults<ChemoSession>
    
    @State private var selectedMonth = Date()
    @State private var showingAddAppointment = false
    
    private let calendar = Calendar.current
    
    // Filter for next two upcoming appointments only
    private var nextTwoAppointments: [ChemoSession] {
        let today = calendar.startOfDay(for: Date())
        let upcoming = appointments.filter { appointment in
            guard let appointmentDate = appointment.date else { return false }
            return calendar.startOfDay(for: appointmentDate) >= today
        }
        return Array(upcoming.prefix(2))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Chemo Schedule")
                    .font(.largeTitle)
                    .fontWeight(.medium)
                Spacer()
                Image(systemName: "calendar.badge.clock")
                    .font(.title)
                    .foregroundColor(.neuSecondary)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
            
            // Calendar section
            VStack(spacing: 16) {
                // Month navigation
                HStack {
                    Text(monthYearString(from: selectedMonth))
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        Button(action: { changeMonth(by: -1) }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.neuSecondary)
                        }
                        Button(action: { changeMonth(by: 1) }) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.neuSecondary)
                        }
                    }
                }
                
                // Calendar grid
                VStack(spacing: 12) {
                    // Weekday headers
                    HStack {
                        ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                            Text(day.prefix(1))
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    
                    // Days grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                        ForEach(daysInMonth(), id: \.self) { date in
                            if let date = date {
                                Text("\(calendar.component(.day, from: date))")
                                    .font(.body)
                                    .frame(maxWidth: .infinity, minHeight: 35)
                                    .foregroundColor(getDateColor(for: date))
                                    .background(
                                        Circle()
                                            .fill(hasAppointment(on: date) ? Color.neuPrimary.opacity(0.2) : Color.clear)
                                            .frame(width: 35, height: 35)
                                    )
                            } else {
                                Text("")
                                    .frame(maxWidth: .infinity, minHeight: 35)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Upcoming appointments section
            VStack(alignment: .leading, spacing: 16) {
                Text("Upcoming Appointments")
                    .font(.title3)
                    .fontWeight(.medium)
                    .padding(.horizontal)
                
                if !nextTwoAppointments.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(nextTwoAppointments, id: \.id) { appointment in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color.neuSecondary)
                                    .frame(width: 6, height: 6)
                                
                                Text(appointment.date?.formatted(date: .abbreviated, time: .omitted) ?? "")
                                    .fontWeight(.medium)
                                
                                Text("-")
                                    .foregroundColor(.secondary)
                                
                                Text(appointment.location ?? "")
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Button(action: {
                                    deleteAppointment(appointment)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red.opacity(0.8))
                                        .font(.footnote)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                } else {
                    Text("No upcoming appointments")
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
            }
            .padding(.bottom, 20)
            
            // Add button
            Button(action: { showingAddAppointment = true }) {
                Circle()
                    .fill(Color.neuPrimary)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.white)
                    )
                    .shadow(color: Color.neuShadowDark.opacity(0.2), radius: 8, x: 0, y: 4)
            }
            .padding(.bottom, 20)
        }
        .padding(.top)
        .background(Color.neuBackground.ignoresSafeArea())
        .sheet(isPresented: $showingAddAppointment) {
            AddAppointmentView()
        }
    }
    
    private func deleteAppointment(_ appointment: ChemoSession) {
        viewContext.delete(appointment)
        
        do {
            try viewContext.save()
        } catch {
            print("Error deleting appointment: \(error)")
        }
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func changeMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: selectedMonth) {
            selectedMonth = newDate
        }
    }
    
    private func daysInMonth() -> [Date?] {
        let interval = calendar.dateInterval(of: .month, for: selectedMonth)!
        let firstWeekday = calendar.component(.weekday, from: interval.start)
        let daysInMonth = calendar.dateComponents([.day], from: interval.start, to: interval.end).day!
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: interval.start) {
                days.append(date)
            }
        }
        
        while days.count % 7 != 0 {
            days.append(nil)
        }
        
        return days
    }
    
    private func getDateColor(for date: Date) -> Color {
        if calendar.isDateInToday(date) {
            return .neuPrimary
        }
        if hasAppointment(on: date) {
            return .neuSecondary
        }
        return .neuText
    }
    
    private func hasAppointment(on date: Date) -> Bool {
        nextTwoAppointments.contains { appointment in
            guard let appointmentDate = appointment.date else { return false }
            return calendar.isDate(appointmentDate, inSameDayAs: date)
        }
    }
}

// AddAppointmentView remains unchanged
struct AddAppointmentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    @State private var date = Date()
    @State private var location = ""
    
    var body: some View {
        NavigationView {
            Form {
                DatePicker("Date", selection: $date)
                TextField("Location", text: $location)
            }
            .navigationTitle("Add Appointment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        saveAppointment()
                        dismiss()
                    }
                    .disabled(location.isEmpty)
                }
            }
        }
    }
    
    private func saveAppointment() {
        let newAppointment = ChemoSession(context: viewContext)
        newAppointment.id = UUID()
        newAppointment.date = date
        newAppointment.location = location
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving appointment: \(error)")
        }
    }
}
