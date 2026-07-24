import SwiftUI

struct ClientMessagesView: View {
    var body: some View {
        AppBackground {
            List {
                Label {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("PAWN Creator")
                        Text("初版大纲已提交，请查看本次更新。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.title2)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("消息")
    }
}