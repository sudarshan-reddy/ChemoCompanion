// SymptomLog+CoreDataProperties.swift
import CoreData
import Foundation

extension SymptomLog {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SymptomLog> {
        return NSFetchRequest<SymptomLog>(entityName: "SymptomLog")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var symptomType: String?
    @NSManaged public var severity: Int16
    @NSManaged public var notes: String?
}
