import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        // Create the model programmatically
        let model = NSManagedObjectModel()
        
        // ChemoSession Entity
        let chemoSessionEntity = NSEntityDescription()
        chemoSessionEntity.name = "ChemoSession"
        chemoSessionEntity.managedObjectClassName = "ChemoCompanion.ChemoSession"
        
        // Create attributes for ChemoSession
        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.type = .uuid
        idAttribute.isOptional = false
        
        let dateAttribute = NSAttributeDescription()
        dateAttribute.name = "date"
        dateAttribute.type = .date
        dateAttribute.isOptional = false
        
        let locationAttribute = NSAttributeDescription()
        locationAttribute.name = "location"
        locationAttribute.type = .string
        locationAttribute.isOptional = false
        
        let notesAttribute = NSAttributeDescription()
        notesAttribute.name = "notes"
        notesAttribute.type = .string
        notesAttribute.isOptional = true
        
        // Add attributes to ChemoSession entity
        chemoSessionEntity.properties = [
            idAttribute,
            dateAttribute,
            locationAttribute,
            notesAttribute
        ]
        
        // SymptomLog Entity
        let symptomLogEntity = NSEntityDescription()
        symptomLogEntity.name = "SymptomLog"
        symptomLogEntity.managedObjectClassName = "ChemoCompanion.SymptomLog"
        
        // Create SymptomLog attributes
        let symptomIdAttribute = NSAttributeDescription()
        symptomIdAttribute.name = "id"
        symptomIdAttribute.type = .uuid
        symptomIdAttribute.isOptional = false
        
        let symptomDateAttribute = NSAttributeDescription()
        symptomDateAttribute.name = "date"
        symptomDateAttribute.type = .date
        symptomDateAttribute.isOptional = false
        
        let symptomTypeAttribute = NSAttributeDescription()
        symptomTypeAttribute.name = "symptomType"
        symptomTypeAttribute.type = .string
        symptomTypeAttribute.isOptional = false
        
        let severityAttribute = NSAttributeDescription()
        severityAttribute.name = "severity"
        severityAttribute.type = .integer16
        severityAttribute.isOptional = false
        
        let symptomNotesAttribute = NSAttributeDescription()
        symptomNotesAttribute.name = "notes"
        symptomNotesAttribute.type = .string
        symptomNotesAttribute.isOptional = true
        
        // Add attributes to SymptomLog entity
        symptomLogEntity.properties = [
            symptomIdAttribute,
            symptomDateAttribute,
            symptomTypeAttribute,
            severityAttribute,
            symptomNotesAttribute
        ]
        
        // Add both entities to model
        model.entities = [chemoSessionEntity, symptomLogEntity]
        
        // Create container
        container = NSPersistentContainer(name: "ChemoCompanion", managedObjectModel: model)
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // MARK: - Preview Helper
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        
        // Create example ChemoSessions
        for i in 0..<10 {
            let session = ChemoSession(context: controller.container.viewContext)
            session.id = UUID()
            session.date = Calendar.current.date(byAdding: .day, value: i, to: Date())!
            session.location = "Hospital \(i + 1)"
            session.notes = i % 2 == 0 ? "Follow-up required" : nil
        }
        
        // Create example SymptomLogs
        let symptoms = ["Nausea", "Fatigue", "Pain"]
        for i in 0..<5 {
            let symptom = SymptomLog(context: controller.container.viewContext)
            symptom.id = UUID()
            symptom.date = Date()
            symptom.symptomType = symptoms[i % symptoms.count]
            symptom.severity = Int16(Int.random(in: 1...10))
            symptom.notes = i % 2 == 0 ? "Getting better" : nil
        }
        
        try? controller.container.viewContext.save()
        return controller
    }()
}
