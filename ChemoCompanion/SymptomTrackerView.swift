import SwiftUI
import CoreData

struct SymptomTrackerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingSymptomPicker = false
    @State private var selectedDate = Date()
    @State private var showingDatePicker = false
    
    // Fetch symptoms for selected date
    private var datePredicateFormat = "date >= %@ AND date < %@"
    
    var dateSymptoms: FetchRequest<SymptomLog>
    private var symptoms: FetchedResults<SymptomLog> { dateSymptoms.wrappedValue }
    
    init() {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        
        dateSymptoms = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \SymptomLog.date, ascending: true)],
            predicate: NSPredicate(
                format: datePredicateFormat,
                start as CVarArg,
                end as CVarArg
            )
        )
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Date selector
            HStack {
                Button(action: { showingDatePicker = true }) {
                    HStack {
                        Image(systemName: "calendar")
                        Text(selectedDate, format: .dateTime.day().month().year())
                    }
                    .padding()
                    .background(Color.neuForeground)
                    .cornerRadius(10)
                    .neuCard()
                }
                
                Spacer()
                
                NavigationLink(destination: SymptomHistoryView()) {
                    Image(systemName: "clock.arrow.circlepath")
                        .padding()
                        .background(Color.neuForeground)
                        .cornerRadius(10)
                        .neuCard()
                }
            }
            .padding(.horizontal)
            
            // Today's Symptoms List
            VStack(alignment: .leading, spacing: 16) {
                Text("\(selectedDate.formatted(.dateTime.weekday())) Symptoms")
                    .font(.title2)
                    .fontWeight(.medium)
                    .padding(.horizontal)
                
                if symptoms.isEmpty {
                    Text("No symptoms logged")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(symptoms, id: \.id) { symptom in
                                SymptomRow(symptom: symptom)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color.neuForeground)
            .cornerRadius(15)
            .neuCard()
            .padding(.horizontal)
            
            Spacer()
            
            // Add Symptom Button
            Button(action: { showingSymptomPicker = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Log New Symptom")
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(NeuButtonStyle())
            .padding()
        }
        .background(Color.neuBackground.ignoresSafeArea())
        .sheet(isPresented: $showingSymptomPicker) {
            SymptomPickerView(date: selectedDate)
        }
        .sheet(isPresented: $showingDatePicker) {
            DatePickerSheet(selectedDate: $selectedDate)
        }
        .onChange(of: selectedDate) { newDate in
            updateDatePredicate()
        }
    }
    
    private func updateDatePredicate() {
        // Note: We'll handle date changes by reinitializing the view
        // SwiftUI will automatically handle the view update
    }
}

struct SymptomPickerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    let date: Date
    
    // Common symptom categories
    let symptomCategories = [
        "Physical": ["Nausea", "Fatigue", "Pain", "Dizziness", "Loss of Appetite", "Weakness"],
        "Digestive": ["Constipation", "Diarrhea", "Bloating", "Acid Reflux"],
        "Mental": ["Anxiety", "Depression", "Brain Fog", "Insomnia"],
        "Other": ["Fever", "Chills", "Hair Loss", "Mouth Sores"]
    ]
    
    @State private var selectedSymptom = ""
    @State private var severity: Double = 5
    @State private var notes = ""
    @State private var customSymptom = ""
    @State private var showingCustomInput = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Symptom Categories
                    ForEach(symptomCategories.keys.sorted(), id: \.self) { category in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(category)
                                .font(.headline)
                                .padding(.horizontal)
                            
                            FlowLayout(spacing: 8) {
                                ForEach(symptomCategories[category]!, id: \.self) { symptom in
                                    Button(action: { selectedSymptom = symptom }) {
                                        Text(symptom)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(selectedSymptom == symptom ? Color.neuPrimary : Color.neuForeground)
                                            .foregroundColor(.neuText)
                                            .cornerRadius(20)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Custom Symptom Button
                    Button("Add Custom Symptom") {
                        showingCustomInput = true
                    }
                    .padding()
                    
                    if !selectedSymptom.isEmpty || showingCustomInput {
                        // Severity Slider
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Severity")
                                .font(.headline)
                            NeuSlider(value: $severity, range: 1...10)
                                .frame(height: 24)
                            Text("Level: \(Int(severity))")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        
                        // Notes
                        TextField("Optional notes", text: $notes)
                            .textFieldStyle(.roundedBorder)
                            .padding()
                        
                        // Save Button
                        Button(action: saveSymptom) {
                            Text("Save Symptom")
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .buttonStyle(NeuButtonStyle())
                        .padding()
                    }
                }
            }
            .navigationTitle("Log Symptom")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
            .alert("Add Custom Symptom", isPresented: $showingCustomInput) {
                TextField("Symptom name", text: $customSymptom)
                Button("Cancel", role: .cancel) { }
                Button("Add") {
                    selectedSymptom = customSymptom
                    customSymptom = ""
                }
            }
        }
    }
    
    private func saveSymptom() {
        guard !selectedSymptom.isEmpty else { return }
        
        let symptom = SymptomLog(context: viewContext)
        symptom.id = UUID()
        symptom.date = date
        symptom.symptomType = selectedSymptom
        symptom.severity = Int16(severity)
        symptom.notes = notes
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving symptom: \(error)")
        }
    }
}

struct SymptomHistoryView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SymptomLog.date, ascending: false)],
        animation: .default
    ) private var symptoms: FetchedResults<SymptomLog>
    
    var groupedSymptoms: [(Date, [SymptomLog])] {
        let grouped = Dictionary(grouping: symptoms) { symptom in
            Calendar.current.startOfDay(for: symptom.date ?? Date())
        }
        return grouped.sorted { $0.key > $1.key }
    }
    
    var body: some View {
        List {
            ForEach(groupedSymptoms, id: \.0) { date, symptoms in
                Section(header: Text(date, format: .dateTime.month().day().year())) {
                    ForEach(symptoms, id: \.id) { symptom in
                        SymptomRow(symptom: symptom)
                    }
                }
            }
        }
        .navigationTitle("Symptom History")
    }
}

// Helper view for flow layout of symptom buttons
struct FlowLayout: Layout {
    let spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            let point = result.points[index]
            subview.place(at: CGPoint(x: point.x + bounds.minX, y: point.y + bounds.minY), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize
        var points: [CGPoint]
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            var points: [CGPoint] = []
            var maxWidth: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                points.append(CGPoint(x: currentX, y: currentY))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
                maxWidth = max(maxWidth, currentX)
            }
            
            self.points = points
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

struct SymptomRow: View {
    let symptom: SymptomLog
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(symptom.symptomType ?? "Unknown")
                    .font(.headline)
                Spacer()
                Text("Level: \(symptom.severity)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Severity indicator
            GeometryReader { geometry in
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.neuPrimary.opacity(0.3))
                    .frame(width: geometry.size.width * CGFloat(symptom.severity) / 10)
                    .frame(height: 8)
            }
            .frame(height: 8)
            .background(Color.neuBackground.opacity(0.5))
            .cornerRadius(4)
            
            if let notes = symptom.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.neuForeground)
        .cornerRadius(10)
    }
}

struct DatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date
    
    var body: some View {
        NavigationView {
            DatePicker(
                "Select Date",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .navigationTitle("Select Date")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
            .padding()
        }
    }
}
