import Foundation
import SwiftData

@Model
final class UserFavorite {
    @Attribute(.unique) var id: UUID
    var dhikirId: UUID
    var dateAdded: Date

    init(id: UUID = UUID(), dhikirId: UUID, dateAdded: Date = Date()) {
        self.id = id
        self.dhikirId = dhikirId
        self.dateAdded = dateAdded
    }
}
