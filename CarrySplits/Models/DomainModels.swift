import Foundation

// SwiftData-backed domain models will be introduced in the next implementation phase.
// This file reserves the model layer and documents the intended core entities.

enum CarrySplitsDomain {
    enum Entity: String, CaseIterable {
        case split
        case participant
        case expense
        case allocation
        case settlement
    }
}
