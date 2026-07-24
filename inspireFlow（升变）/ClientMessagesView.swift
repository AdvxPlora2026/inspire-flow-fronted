import SwiftUI

struct ClientMessagesView: View {
    var body: some View {
        ShengbianBackground {
            ContentUnavailableView {
                Label("还没有消息", systemImage: "bubble.left.and.bubble.right")
            } description: {
                Text("与创作者的沟通、方案更新会出现在这里。")
            }
        }
        .navigationTitle("消息")
    }
}
