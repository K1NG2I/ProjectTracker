import SwiftUI

struct TypeIcon: View {
    let type: EntryType
    var size: CGFloat = 24

    var body: some View {
        Image(systemName: type.icon)
            .font(.system(size: size * 0.5))
            .foregroundColor(.white)
            .frame(width: size, height: size)
            .background(type.color)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}
