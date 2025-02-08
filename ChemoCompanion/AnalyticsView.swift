import SwiftUI
import CoreData
import Charts

struct AnalyticsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: SymptomLog.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \SymptomLog.date, ascending: true)]
    ) private var symptoms: FetchedResults<SymptomLog>

    @State private var selectedTimeFrame: TimeFrame = .week
    @State private var selectedSymptom: String? = nil

    enum TimeFrame: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case threeMonths = "3 Months"
        case year = "Year"

        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            case .threeMonths: return 90
            case .year: return 365
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with time frame selector
                HStack {
                    Text("Analytics")
                        .font(.title)
                        .fontWeight(.bold)

                    Spacer()

                    Picker("Time Frame", selection: $selectedTimeFrame) {
                        ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                            Text(timeFrame.rawValue).tag(timeFrame)
                        }
                    }
                    .pickerStyle(.menu)
                }
                .padding(.horizontal)

                // Overall Symptom Intensity Card
                VStack(alignment: .leading, spacing: 12) {
                    Text("Overall Symptom Intensity")
                        .font(.headline)

                    if let chartData = generateOverallIntensityData() {
                        Chart {
                            ForEach(chartData, id: \.date) { data in
                                LineMark(
                                    x: .value("Date", data.date),
                                    y: .value("Severity", data.averageSeverity)
                                )
                                .foregroundStyle(Color.neuSecondary)

                                AreaMark(
                                    x: .value("Date", data.date),
                                    y: .value("Severity", data.averageSeverity)
                                )
                                .foregroundStyle(Gradient(colors: [Color.neuPrimary.opacity(0.3), Color.neuPrimary.opacity(0.1)]))
                            }
                        }
                        .frame(height: 200)
                        .chartYScale(domain: 0...10)
                    } else {
                        Text("No data available")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.neuForeground)
                .cornerRadius(15)
                .neuCard()
                .padding(.horizontal)

                // Symptom Frequency Card
                VStack(alignment: .leading, spacing: 12) {
                    Text("Symptom Frequency")
                        .font(.headline)

                    if let frequencyData = generateSymptomFrequencyData() {
                        Chart {
                            ForEach(frequencyData, id: \.symptom) { data in
                                BarMark(
                                    x: .value("Symptom", data.symptom),
                                    y: .value("Count", data.count)
                                )
                                .foregroundStyle(Color.neuPrimary)
                            }
                        }
                        .frame(height: 200)
                    } else {
                        Text("No data available")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.neuForeground)
                .cornerRadius(15)
                .neuCard()
                .padding(.horizontal)

                // Symptom Details
                VStack(alignment: .leading, spacing: 12) {
                    Text("Symptom Details")
                        .font(.headline)

                    Picker("Select Symptom", selection: $selectedSymptom) {
                        Text("All Symptoms").tag(nil as String?)
                        ForEach(Array(Set(symptoms.compactMap { $0.symptomType })), id: \.self) { symptom in
                            Text(symptom).tag(symptom as String?)
                        }
                    }
                    .pickerStyle(.menu)

                    if let detailData = generateSymptomDetailData() {
                        Chart {
                            ForEach(detailData, id: \.date) { data in
                                PointMark(
                                    x: .value("Date", data.date),
                                    y: .value("Severity", data.severity)
                                )
                                .foregroundStyle(Color.neuSecondary)
                            }
                        }
                        .frame(height: 200)
                        .chartYScale(domain: 0...10)
                    } else {
                        Text("No data available")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.neuForeground)
                .cornerRadius(15)
                .neuCard()
                .padding(.horizontal)

                // Key Stats
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    KeyStatCard(
                        title: "Most Common",
                        value: getMostCommonSymptom() ?? "N/A",
                        icon: "chart.bar.fill"
                    )

                    KeyStatCard(
                        title: "Average Severity",
                        value: String(format: "%.1f", getAverageSeverity()),
                        icon: "thermometer"
                    )
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color.neuBackground.ignoresSafeArea())
    }

    // MARK: - Data Generation Methods

    private func generateOverallIntensityData() -> [(date: Date, averageSeverity: Double)]? {
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -selectedTimeFrame.days, to: endDate) else { return nil }

        let filteredSymptoms = symptoms.filter { symptom in
            guard let symptomDate = symptom.date else { return false }
            return symptomDate >= startDate && symptomDate <= endDate
        }

        let groupedByDate = Dictionary(grouping: filteredSymptoms) { symptom in
            calendar.startOfDay(for: symptom.date ?? Date())
        }

        return groupedByDate.map { (date, symptoms) in
            let averageSeverity = Double(symptoms.reduce(0) { $0 + Int($1.severity) }) / Double(symptoms.count)
            return (date: date, averageSeverity: averageSeverity)
        }.sorted { $0.date < $1.date }
    }

    private func generateSymptomFrequencyData() -> [(symptom: String, count: Int)]? {
        let endDate = Date()
        guard let startDate = Calendar.current.date(byAdding: .day, value: -selectedTimeFrame.days, to: endDate) else { return nil }

        let filteredSymptoms = symptoms.filter { symptom in
            guard let symptomDate = symptom.date else { return false }
            return symptomDate >= startDate && symptomDate <= endDate
        }

        let groupedByType = Dictionary(grouping: filteredSymptoms) { $0.symptomType ?? "Unknown" }
        return groupedByType.map { (symptom: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }

    private func generateSymptomDetailData() -> [(date: Date, severity: Int)]? {
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -selectedTimeFrame.days, to: endDate) else { return nil }

        let filteredSymptoms = symptoms.filter { symptom in
            guard let symptomDate = symptom.date else { return false }
            return symptomDate >= startDate && symptomDate <= endDate &&
                (selectedSymptom == nil || symptom.symptomType == selectedSymptom)
        }

        return filteredSymptoms.map { (date: $0.date ?? Date(), severity: Int($0.severity)) }
            .sorted { $0.date < $1.date }
    }

    private func getMostCommonSymptom() -> String? {
        let groupedSymptoms = Dictionary(grouping: symptoms) { $0.symptomType ?? "Unknown" }
        return groupedSymptoms.max(by: { $0.value.count < $1.value.count })?.key
    }

    private func getAverageSeverity() -> Double {
        let totalSeverity = symptoms.reduce(0) { $0 + Int($1.severity) }
        return symptoms.isEmpty ? 0 : Double(totalSeverity) / Double(symptoms.count)
    }
}

struct KeyStatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.neuSecondary)

            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(value)
                .font(.title3)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.neuForeground)
        .cornerRadius(15)
        .neuCard()
    }
}
