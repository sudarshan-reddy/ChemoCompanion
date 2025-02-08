import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            TabView {
                HomeView()
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                
                ScheduleView()
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Schedule")
                    }
                
                ChecklistView()
                    .tabItem {
                        Image(systemName: "checklist")
                        Text("Checklist")
                    }
                
                SymptomTrackerView()
                    .tabItem {
                        Image(systemName: "waveform.path.ecg")
                        Text("Symptoms")
                    }
                
                SettingsView()
                    .tabItem {
                        Image(systemName: "gearshape")
                        Text("Settings")
                    }
            }
            .tint(Color.neuSecondary)
        }
        .navigationViewStyle(.stack)
    }
}

struct SettingsView: View {
    var body: some View {
        Text("Settings")
            .background(Color.neuBackground)
    }
}
