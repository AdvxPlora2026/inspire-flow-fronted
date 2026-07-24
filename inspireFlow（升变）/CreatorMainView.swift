import SwiftUI

struct CreatorMainView: View {
    @State private var selectedTab: CreatorTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack { CreatorHomeView() }
                .tabItem { Label("首页", systemImage: "house.fill") }
                .tag(CreatorTab.home)

            NavigationStack { CreatorProjectsView() }
                .tabItem { Label("项目", systemImage: "square.stack.3d.up.fill") }
                .tag(CreatorTab.projects)

            NavigationStack { PawnWorkspaceView() }
                .tabItem { Label("PAWN", systemImage: "sparkles") }
                .tag(CreatorTab.pawn)

            NavigationStack { AccountView() }
                .tabItem { Label("我的", systemImage: "person.crop.circle") }
                .tag(CreatorTab.account)
        }
        .tint(.white)
        .preferredColorScheme(.dark)
    }

    private enum CreatorTab: Hashable {
        case home, projects, pawn, account
    }
}