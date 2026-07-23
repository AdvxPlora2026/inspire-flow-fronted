import SwiftUI

struct AccountView: View {
    @EnvironmentObject private var session: AppSession
    @State private var isConfirmingSignOut = false
    @State private var isEditingCreatorProfile = false

    var body: some View {
        AppBackground {
            List {
                Section {
                    HStack(spacing: 14) {
                        Text(String(session.displayName.prefix(1)).uppercased())
                            .font(.title2.bold())
                            .foregroundStyle(.black)
                            .frame(width: 54, height: 54)
                            .background(Color.white, in: Circle())

                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.displayName).font(.headline)
                            Text(session.role.title).foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 5)
                }

                Section("工作空间") {
                    if session.role == .creator {
                        Button {
                            isEditingCreatorProfile = true
                        } label: {
                            Label("创作者资料与可见性", systemImage: "person.text.rectangle")
                        }
                    }

                    Button {
                        session.switchRole()
                    } label: {
                        Label("切换为\(session.role == .creator ? "品牌方" : "创作者")", systemImage: "arrow.triangle.2.circlepath")
                    }

                    Label("本地内容已加密", systemImage: "lock.fill")
                    Label("设备与权限", systemImage: "dot.radiowaves.left.and.right")
                }

                Section {
                    Button(role: .destructive) { isConfirmingSignOut = true } label: {
                        Label("退出登录", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("我的")
        .confirmationDialog("确定退出登录？", isPresented: $isConfirmingSignOut) {
            Button("退出登录", role: .destructive) { session.signOut() }
        }
        .sheet(isPresented: $isEditingCreatorProfile) {
            CreatorProfileSetupView(mode: .editing)
        }
    }
}