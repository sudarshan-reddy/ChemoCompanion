// ChecklistItem+CoreDataProperties.swift
import CoreData
import Foundation

extension ChecklistItem {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChecklistItem> {
        let request = NSFetchRequest<ChecklistItem>(entityName: "ChecklistItem")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ChecklistItem.title, ascending: true)]
        return request
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var notes: String?
    @NSManaged public var chemoSession: ChemoSession?
}
