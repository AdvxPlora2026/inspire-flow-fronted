import SwiftUI

struct AccountView: View {
    @EnvironmentObject private var session: AppSession
    @EnvironmentObject private var appStore: AppStore
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @State private var isConfirmingSignOut = false
    @State private var isEditingCreatorProfile = false
    @State private var isShowingGuide = false
    @State private var isConfirmingReset = false

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

                Section("帮助") {
                    Button {
                        isShowingGuide = true
                    } label: {
                        Label("重新查看产品引导", systemImage: "questionmark.circle")
                    }

                    Button(role: .destructive) {
                        isConfirmingReset = true
                    } label: {
                        Label("重置演示数据", systemImage: "arrow.counterclockwise")
                    }
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
        .confirmationDialog("重置演示数据？", isPresented: $isConfirmingReset, titleVisibility: .visible) {
            Button("重置", role: .destructive) { appStore.resetDemoData() }
        } message: {
            Text("将恢复默认的演示灵感和项目，不会退出登录或清除账号信息。")
        }
        .sheet(isPresented: $isEditingCreatorProfile) {
            CreatorProfileSetupView(mode: .editing)
        }
        .fullScreenCover(isPresented: $isShowingGuide) {
            StartView(hasCompletedOnboarding: .constant(true))
                .overlay(alignment: .topTrailing) {
                    Button {
                        isShowingGuide = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.7))
                            .padding(20)
                    }
                    .accessibilityLabel("关闭引导")
                }
        }
    }
}