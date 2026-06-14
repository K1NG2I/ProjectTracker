import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showNewEntry = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $selectedTab) {
                CalendarCoordinatorView()
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                    }
                    .tag(0)

                EntryListView()
                    .tabItem {
                        Label("List", systemImage: "list.bullet")
                    }
                    .tag(1)
            }

            Button {
                showNewEntry = true
            } label: {
                Image(systemName: "plus")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.accentColor, in: .circle)
                    .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 90)
        }
        .sheet(isPresented: $showNewEntry) {
            EntryFormView()
        }
    }
}
