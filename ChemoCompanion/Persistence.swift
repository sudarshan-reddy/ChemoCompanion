import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        // Create the model programmatically
        let model = NSManagedObjectModel()

        // ChemoSession Entity
        let chemoSession = NSEntityDescription()
        chemoSession.name = "ChemoSession"
        chemoSession.managedObjectClassName = "ChemoSession"

        let chemoAttributes: [(String, NSAttributeType, Bool)] = [
            ("id", .UUIDAttributeType, false),
            ("date", .dateAttributeType, false),
            ("location", .stringAttributeType, false),
            ("notes", .stringAttributeType, true)
        ]

        chemoSession.properties = chemoAttributes.map { name, type, optional in
            let attribute = NSAttributeDescription()
            attribute.name = name
            attribute.attributeType = type
            attribute.isOptional = optional
            return attribute
        }

        // SymptomLog Entity
        let symptomLog = NSEntityDescription()
        symptomLog.name = "SymptomLog"
        symptomLog.managedObjectClassName = "SymptomLog"

        let symptomAttributes: [(String, NSAttributeType, Bool)] = [
            ("id", .UUIDAttributeType, false),
            ("date", .dateAttributeType, false),
            ("symptomType", .stringAttributeType, false),
            ("severity", .integer16AttributeType, false),
            ("notes", .stringAttributeType, true)
        ]

        symptomLog.properties = symptomAttributes.map { name, type, optional in
            let attribute = NSAttributeDescription()
            attribute.name = name
            attribute.attributeType = type
            attribute.isOptional = optional
            return attribute
        }

        model.entities = [chemoSession, symptomLog]

        // Create container with the model
        container = NSPersistentContainer(name: "ChemoCompanion")

        // Use the programmatically created model
        let storeDescription = NSPersistentStoreDescription()
        if inMemory {
            storeDescription.url = URL(fileURLWithPath: "/dev/null")
        }

        container.persistentStoreDescriptions = [storeDescription]

        // Load the persistent store
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

