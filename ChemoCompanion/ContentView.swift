// ContentView.swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Text("Home")
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }

            ScheduleView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Schedule")
                }

            Text("Checklist")
                .tabItem {
                    Image(systemName: "checklist")
                    Text("Checklist")
                }

            Text("Symptoms")
                .tabItem {
                    Image(systemName: "heart.text.square")
                    Text("Symptoms")
                }

            Text("Settings")
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .tint(Color("Primary"))
        .background(Color("Background"))
    }
}

