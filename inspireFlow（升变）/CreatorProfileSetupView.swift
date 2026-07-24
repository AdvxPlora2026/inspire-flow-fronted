import SwiftUI

struct CreatorProfileSetupView: View {
    enum Mode {
        case registration
        case editing
    }

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: AppSession

    let mode: Mode

    @State private var profile: CreatorProfile
    @State private var hasAttemptedSave = false
    @State private var isSaving = false
    @State private var saveError: String?

    init(mode: Mode, profile: CreatorProfile = .empty(displayName: "")) {
        self.mode = mode
        _profile = State(initialValue: profile)
    }

    var body: some View {
        NavigationStack {
            AppBackground {
                Form {
                    identitySection
                    socialSection
                    contactSection
                    collaborationSection
                    privacySection
                }
                .scrollContentBackground(.hidden)
                .navigationTitle(mode == .registration ? "完善创作者资料" : "创作者资料")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbarContent }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { profile = session.creatorProfile }
        .alert("无法保存资料", isPresented: Binding(
            get: { saveError != nil },
            set: { if !$0 { saveError = nil } }
        )) {
            Button("好", role: .cancel) {}
        } message: {
            Text(saveError ?? "请稍后重试。")
        }
    }

    private var identitySection: some View {
        Section("创作者身份") {
            TextField("显示名称", text: $profile.displayName.value)
                .textContentType(.name)

            TextField("个人简介", text: $profile.biography.value, axis: .vertical)
                .lineLimit(3...6)

            TextField("创作类别，用逗号分隔", text: $profile.creativeCategories.value)

            if hasAttemptedSave && trimmedDisplayName.isEmpty {
                Label("请填写显示名称", systemImage: "exclamationmark.circle")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var socialSection: some View {
        Section("社交平台") {
            ForEach($profile.socialAccounts) { $account in
                VStack(alignment: .leading, spacing: 10) {
                    TextField("平台", text: $account.platform)
                    TextField("账号名称", text: $account.accountName)
                        .textInputAutocapitalization(.never)
                    visibilityPicker("账号可见范围", selection: $account.visibility)
                }
                .padding(.vertical, 4)
            }

            Button {
                profile.socialAccounts.append(.init(platform: "", accountName: ""))
            } label: {
                Label("添加社交账号", systemImage: "plus")
            }
        }
    }

    private var contactSection: some View {
        Section {
            ForEach($profile.contactMethods) { $contact in
                VStack(alignment: .leading, spacing: 10) {
                    TextField("联系方式类型", text: $contact.type)
                    TextField("联系方式", text: $contact.value)
                        .textInputAutocapitalization(.never)
                    visibilityPicker("披露范围", selection: $contact.visibility)
                }
                .padding(.vertical, 4)
            }

            Button {
                profile.contactMethods.append(.init(type: "", value: ""))
            } label: {
                Label("添加联系方式", systemImage: "plus")
            }
        } header: {
            Text("联系方式")
        } footer: {
            Text("联系方式默认仅自己可见。授权只决定品牌能否查看你的联系方式，不会向你披露品牌联系方式。")
        }
    }

    private var collaborationSection: some View {
        Section("合作状态") {
            Picker("当前状态", selection: $profile.collaborationAvailability.value) {
                Text("暂不接受合作").tag("暂不接受合作")
                Text("可讨论合作").tag("可讨论合作")
                Text("积极寻找合作").tag("积极寻找合作")
            }
            visibilityPicker("状态可见范围", selection: $profile.collaborationAvailability.visibility)
        }
    }

    private var privacySection: some View {
        Section {
            visibilityPicker("显示名称", selection: $profile.displayName.visibility)
            visibilityPicker("个人简介", selection: $profile.biography.visibility)
            visibilityPicker("创作类别", selection: $profile.creativeCategories.visibility)
        } header: {
            Text("资料可见性")
        } footer: {
            Text("保存资料不会发布公开工作坊。选择可见范围只是记录你的偏好，发布前仍会提供预览和确认。")
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        if mode == .registration {
            ToolbarItem(placement: .cancellationAction) {
                Button("稍后完善") { session.skipCreatorProfileSetup() }
            }
        } else {
            ToolbarItem(placement: .cancellationAction) {
                Button("取消") { dismiss() }
            }
        }

        ToolbarItem(placement: .confirmationAction) {
            Button(isSaving ? "保存中…" : "保存", action: save)
                .fontWeight(.semibold)
                .disabled(isSaving)
        }
    }

    private func visibilityPicker(
        _ title: String,
        selection: Binding<ProfileFieldVisibility>
    ) -> some View {
        Picker(title, selection: selection) {
            ForEach(ProfileFieldVisibility.allCases) { visibility in
                Text(visibility.title).tag(visibility)
            }
        }
    }

    private var trimmedDisplayName: String {
        profile.displayName.value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func save() {
        hasAttemptedSave = true
        guard !trimmedDisplayName.isEmpty, !isSaving else { return }
        profile.displayName.value = trimmedDisplayName
        profile.hasCompletedSetup = true
        isSaving = true
        Task {
            let success = await session.saveCreatorProfileRemotely(profile)
            isSaving = false
            if success {
                Haptics.success()
                if mode == .editing { dismiss() }
            } else {
                saveError = session.authErrorMessage ?? "请稍后重试。"
                Haptics.error()
            }
        }
    }
}