import SwiftUI

struct ClientCreateBriefView: View {
    @EnvironmentObject private var appStore: AppStore
    @EnvironmentObject private var session: AppSession
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var requirement = ""
    @State private var budget = ""
    @State private var deadline = Date.now.addingTimeInterval(604_800)
    @State private var isPublishing = false
    @State private var publishError: String?

    var body: some View {
        Form {
            Section("基本信息") {
                TextField("委托名称", text: $title)
                TextField("预算（元）", text: $budget)
                    .keyboardType(.decimalPad)
                DatePicker("交付日期", selection: $deadline, displayedComponents: .date)
            }

            Section("创作需求") {
                TextEditor(text: $requirement)
                    .frame(minHeight: 140)
            }

            Section {
                VStack(alignment: .leading, spacing: 10) {
                    Label("Injective 商业保障", systemImage: "link")
                        .font(.subheadline.weight(.semibold))

                    Text("发布需求会先创建云端项目。选定创作者与分账比例后，商业任务可进入预算托管、作品摘要存证、授权和结算流程。")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Label("当前发布不会立即发起链上交易", systemImage: "info.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("发布委托")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("发布", action: createBrief)
                    .fontWeight(.semibold)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || requirement.isEmpty || isPublishing)
            }
        }
        .preferredColorScheme(.dark)
        .alert("无法发布委托", isPresented: Binding(
            get: { publishError != nil },
            set: { if !$0 { publishError = nil } }
        )) {
            Button("好", role: .cancel) {}
        } message: {
            Text(publishError ?? "请稍后重试。")
        }
    }

    private func createBrief() {
        guard !isPublishing else { return }
        let budgetText = budget.isEmpty ? "预算待沟通" : "预算 ¥\(budget)"
        let dateText = deadline.formatted(date: .abbreviated, time: .omitted)
        isPublishing = true
        Task {
            do {
                _ = try await appStore.createProject(
                    name: title,
                    initialIdea: "\(requirement) · \(budgetText) · \(dateText) 交付",
                    kind: .commercial,
                    contentType: "商业委托",
                    audience: "内容创作者",
                    accessToken: session.accessToken
                )
                isPublishing = false
                Haptics.success()
                dismiss()
            } catch {
                isPublishing = false
                publishError = error.localizedDescription
                Haptics.error()
            }
        }
    }
}