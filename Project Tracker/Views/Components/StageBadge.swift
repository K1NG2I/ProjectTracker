import SwiftUI

struct StageBadge: View {
    let stage: Stage

    var body: some View {
        Text(stage.rawValue)
            .font(.caption2.weight(.medium))
            .foregroundColor(stage.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(stage.color.opacity(0.15))
            .clipShape(.capsule)
    }
}
