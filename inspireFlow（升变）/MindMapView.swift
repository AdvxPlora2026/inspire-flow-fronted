import SwiftUI
import Grape

struct MindMapView: View {
    @EnvironmentObject private var appStore: AppStore

    let projectID: UUID

    @State private var graphState = ForceDirectedGraphState(
        initialIsRunning: true,
        initialModelTransform: .identity.scale(by: 1.1)
    )

    private var project: CreatorProject? {
        appStore.projects.first { $0.id == projectID }
    }

    private var model: MindGraph {
        MindGraph.build(
            project: project,
            inspirations: appStore.inspirations.filter { $0.projectID == projectID },
            conversation: appStore.conversation(for: projectID)
        )
    }

    var body: some View {
        ShengbianBackground {
            let graph = model

            ForceDirectedGraph(states: graphState) {
                Series(graph.edges) { edge in
                    LinkMark(from: edge.from, to: edge.to)
                }
                .stroke(ShengbianColors.glassBorder, StrokeStyle(lineWidth: 1.4, lineCap: .round))

                Series(graph.nodes) { node in
                    NodeMark(id: node.id)
                        .symbol(.circle)
                        .symbolSize(radius: node.kind.radius)
                        .foregroundStyle(node.kind.color)
                        .stroke(ShengbianColors.glassHighlight)
                        .annotation(node.id, alignment: .bottom, offset: .zero) {
                            label(node)
                        }
                }
            } force: {
                .manyBody(strength: -70)
                .center()
                .link(originalLength: 68.0)
            }
            .graphOverlay { proxy in
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .withGraphDragGesture(proxy, of: String.self)
            }
            .padding(ShengbianMetrics.pageMargin)
        }
        .navigationTitle("脑图")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func label(_ node: MindNode) -> some View {
        Text(node.label)
            .font(ShengbianTypography.caption)
            .lineLimit(1)
            .foregroundStyle(ShengbianColors.primaryText)
            .padding(.vertical, 3)
            .padding(.horizontal, 9)
            .background(.thinMaterial, in: Capsule())
            .overlay(Capsule().strokeBorder(ShengbianColors.glassBorder))
            .fixedSize()
    }
}

// MARK: - Graph model

private struct MindNode: Identifiable {
    let id: String
    let label: String
    let kind: MindNodeKind
}

private struct MindEdge: Identifiable {
    let from: String
    let to: String
    var id: String { "\(from)->\(to)" }
}

private enum MindNodeKind {
    case project
    case inspiration
    case questions
    case pack
    case pawn

    var color: Color {
        switch self {
        case .project: ShengbianColors.primaryText
        case .inspiration: ShengbianColors.secondaryText
        case .questions: ShengbianColors.tertiaryText
        case .pack: ShengbianColors.success
        case .pawn: ShengbianColors.warning
        }
    }

    var radius: CGFloat {
        switch self {
        case .project: 18
        case .inspiration: 12
        case .pack: 10
        case .pawn: 12
        case .questions: 9
        }
    }
}

private struct MindGraph {
    var nodes: [MindNode]
    var edges: [MindEdge]

    static func build(
        project: CreatorProject?,
        inspirations: [InspirationCapture],
        conversation: PawnConversation?
    ) -> MindGraph {
        var nodes: [MindNode] = []
        var edges: [MindEdge] = []

        let rootID = "project"
        nodes.append(
            MindNode(id: rootID, label: project?.name ?? "项目", kind: .project)
        )

        for inspiration in inspirations {
            let inspID = "insp-\(inspiration.id.uuidString)"
            nodes.append(
                MindNode(id: inspID, label: shorten(inspiration.transcription, fallback: "灵感"), kind: .inspiration)
            )
            edges.append(MindEdge(from: rootID, to: inspID))

            if !inspiration.pawnQAs.isEmpty {
                let qaID = "qa-\(inspiration.id.uuidString)"
                nodes.append(
                    MindNode(id: qaID, label: "PAWN 三问 · \(inspiration.pawnQAs.count)", kind: .questions)
                )
                edges.append(MindEdge(from: inspID, to: qaID))
            }

            if let pack = inspiration.bilibiliPack {
                let packID = "pack-\(inspiration.id.uuidString)"
                nodes.append(
                    MindNode(id: packID, label: shorten(pack.title, fallback: "成品包"), kind: .pack)
                )
                edges.append(MindEdge(from: inspID, to: packID))
            }
        }

        if let conversation, !conversation.messages.isEmpty {
            let pawnID = "pawn"
            nodes.append(
                MindNode(id: pawnID, label: "PAWN 对话 · \(conversation.messages.count)", kind: .pawn)
            )
            edges.append(MindEdge(from: rootID, to: pawnID))
        }

        return MindGraph(nodes: nodes, edges: edges)
    }

    private static func shorten(_ text: String, fallback: String, limit: Int = 14) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return fallback }
        if trimmed.count <= limit { return trimmed }
        return String(trimmed.prefix(limit)) + "…"
    }
}
