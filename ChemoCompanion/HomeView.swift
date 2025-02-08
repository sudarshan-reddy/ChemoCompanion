import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: ChemoSession.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ChemoSession.date, ascending: true)]
    ) private var sessions: FetchedResults<ChemoSession>
    
    var body: some View {
        VStack(spacing: 24) {
            Text("ChemoCompanion")
                .font(.largeTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            // Next Appointment Card
            if let nextSession = sessions.first(where: { $0.date ?? Date() > Date() }) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Next Appointment")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    Text(nextSession.date ?? Date(), format: .dateTime.day().month().year())
                        .font(.title3)
                    
                    Text(nextSession.location ?? "")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.neuForeground)
                .cornerRadius(15)
                .neuCard()
                .padding(.horizontal)
            }
            
            // Quick Actions Grid
            HStack(spacing: 20) {
                NavigationLink(destination: ScheduleView()) {
                    QuickActionButton(
                        icon: "calendar",
                        title: "Schedule",
                        color: .neuSecondary
                    )
                }
                
                NavigationLink(destination: ChecklistView()) {
                    QuickActionButton(
                        icon: "checklist",
                        title: "Checklist",
                        color: .neuSecondary
                    )
                }
                
                NavigationLink(destination: SymptomTrackerView()) {
                    QuickActionButton(
                        icon: "waveform.path.ecg",
                        title: "Symptoms",
                        color: .neuSecondary
                    )
                }
            }
            .padding(.horizontal)
            
            // Today's Symptoms Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Today's Symptoms")
                    .font(.title2)
                    .fontWeight(.medium)
                
                NavigationLink(destination: SymptomTrackerView()) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Log Symptoms")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.neuForeground)
                    .cornerRadius(10)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.neuForeground)
            .cornerRadius(15)
            .neuCard()
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top)
        .background(Color.neuBackground.ignoresSafeArea())
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.neuText)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .padding()
        .background(Color.neuForeground)
        .cornerRadius(15)
        .neuCard()
    }
}
