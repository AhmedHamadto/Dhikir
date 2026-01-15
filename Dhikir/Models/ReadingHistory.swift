import Foundation
import SwiftData

@Model
final class ReadingHistory {
    @Attribute(.unique) var id: UUID
    var dhikirId: UUID
    var dateRead: Date
    var category: String
    var completedRepetitions: Int

    init(
        id: UUID = UUID(),
        dhikirId: UUID,
        dateRead: Date = Date(),
        category: String,
        completedRepetitions: Int = 0
    ) {
        self.id = id
        self.dhikirId = dhikirId
        self.dateRead = dateRead
        self.category = category
        self.completedRepetitions = completedRepetitions
    }
}
