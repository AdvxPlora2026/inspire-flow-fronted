import SwiftUI

struct ClientCreateBriefView: View {
    @EnvironmentObject private var appStore: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var requirement = ""
    @State private var budget = ""
    @State private var deadline = Date.now.addingTimeInterval(604_800)

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
                Label("发布后将创建版本记录，验收与结算状态对双方可见。", systemImage: "checkmark.seal.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("发布委托")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("发布", action: createBrief)
                    .fontWeight(.semibold)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || requirement.isEmpty)
            }
        }
        .preferredColorScheme(.dark)
    }

    private func createBrief() {
        let budgetText = budget.isEmpty ? "预算待沟通" : "预算 ¥\(budget)"
        let dateText = deadline.formatted(date: .abbreviated, time: .omitted)
        appStore.createProject(
            name: title,
            initialIdea: "\(requirement) · \(budgetText) · \(dateText) 交付",
            kind: .commercial
        )
        dismiss()
    }
}