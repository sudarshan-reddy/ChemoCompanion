import CoreData
import SwiftUI

struct ChecklistView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingAddItem = false
    @State private var selectedSession: ChemoSession?

    @FetchRequest(
        entity: ChemoSession.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ChemoSession.date, ascending: true)]
    ) private var sessions: FetchedResults<ChemoSession>

    @FetchRequest(
        entity: ChecklistItem.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ChecklistItem.title, ascending: true)]
    ) private var allItems: FetchedResults<ChecklistItem>

    var body: some View {
        VStack(spacing: 20) {
            // Session Picker
            Picker("Select Session", selection: $selectedSession) {
                Text("All Items").tag(nil as ChemoSession?)
                ForEach(sessions, id: \.id) { session in
                    if let date = session.date {
                        Text(date.formatted(date: .abbreviated, time: .omitted))
                            .tag(session as ChemoSession?)
                    }
                }
            }
            .pickerStyle(.menu)
            .padding()
            .background(Color.neuForeground)
            .cornerRadius(10)
            .padding(.horizontal)

            // Checklist Items
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filterItems(), id: \.id) { item in
                        ChecklistItemRow(item: item)
                            .padding(.horizontal)
                    }
                }
            }

            Spacer()

            // Add Button
            Button(action: { showingAddItem = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Item")
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(NeuButtonStyle())
            .padding()
        }
        .background(Color.neuBackground.ignoresSafeArea())
        .navigationTitle("Checklist")
        .sheet(isPresented: $showingAddItem) {
            AddChecklistItemView(selectedSession: selectedSession)
        }
    }

    private func filterItems() -> [ChecklistItem] {
        if let session = selectedSession {
            return allItems.filter { $0.chemoSession?.id == session.id }
        } else {
            return Array(allItems)
        }
    }
}

struct ChecklistItemRow: View {
    @ObservedObject var item: ChecklistItem
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        HStack {
            Toggle(
                isOn: Binding(
                    get: { item.isCompleted },
                    set: { newValue in
                        item.isCompleted = newValue
                        try? viewContext.save()
                    }
                )
            ) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title ?? "")
                        .strikethrough(item.isCompleted)
                    if let notes = item.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    if let session = item.chemoSession, let date = session.date {
                        Text(date.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption2)
                            .foregroundColor(.neuSecondary)
                    }
                }
            }

            Spacer()

            Button(action: deleteItem) {
                Image(systemName: "trash")
                    .foregroundColor(.red.opacity(0.8))
            }
        }
        .padding()
        .background(Color.neuForeground)
        .cornerRadius(10)
        .neuCard()
    }

    private func deleteItem() {
        viewContext.delete(item)
        try? viewContext.save()
    }
}

struct AddChecklistItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    let selectedSession: ChemoSession?
    @State private var title = ""
    @State private var notes = ""
    @State private var selectedSessionForItem: ChemoSession?

    @FetchRequest(
        entity: ChemoSession.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ChemoSession.date, ascending: true)]
    ) private var sessions: FetchedResults<ChemoSession>

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Title", text: $title)
                    TextField("Notes", text: $notes)
                }

                Section(header: Text("Associated Session")) {
                    Picker("Session", selection: $selectedSessionForItem) {
                        Text("None").tag(nil as ChemoSession?)
                        ForEach(sessions, id: \.id) { session in
                            if let date = session.date {
                                Text(date.formatted(date: .abbreviated, time: .omitted))
                                    .tag(session as ChemoSession?)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Checklist Item")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") { saveItem() }
                    .disabled(title.isEmpty)
            )
            .onAppear {
                selectedSessionForItem = selectedSession
            }
        }
    }

    private func saveItem() {
        let item = ChecklistItem(context: viewContext)
        item.id = UUID()
        item.title = title
        item.notes = notes
        item.isCompleted = false
        item.chemoSession = selectedSessionForItem

        try? viewContext.save()
        dismiss()
    }
}
