import CoreData
import Foundation

extension ChemoSession {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChemoSession> {
        return NSFetchRequest<ChemoSession>(entityName: "ChemoSession")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var location: String?
    @NSManaged public var notes: String?
}
