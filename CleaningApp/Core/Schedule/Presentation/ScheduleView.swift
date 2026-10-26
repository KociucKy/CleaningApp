import SwiftUI
import FulhamKit

// MARK: - ScheduleView

@MainActor
struct ScheduleView: View {
    // MARK: - Properties

    @State private var presenter: SchedulePresenter
    @State private var selectedDay: ScheduleWeekday?

    // MARK: - Init

    init(presenter: SchedulePresenter) {
        _presenter = State(initialValue: presenter)
        _selectedDay = State(initialValue: .monday)
    }

    // MARK: - Body

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(ScheduleWeekday.allCases) { day in
                    ScheduleTasksListView(
                        summary: presenter.summary(for: day),
                        tasks: presenter.tasks(for: day),
                        onComplete: { task in
                            presenter.complete(task)
                        },
                        onSkip: { task in
                            presenter.skip(task)
                        },
                        onUndoSkip: { task in
                            presenter.undoSkip(task)
                        },
                        onUncomplete: { task in
                            presenter.uncomplete(task)
                        }
                    )
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $selectedDay, anchor: .center)
        .scrollEdgeEffectStyle(.soft, for: .top)
        .background(FKColor.Background.primary)
        .onAppear {
            let today = Date()
            presenter.ensureSchedule(today: today)
            selectedDay = presenter.currentWeekday
        }
        .navigationTitle("schedule.nav_title")
        .navigationSubtitle("schedule.nav_subtitle")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    presenter.refresh()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .accessibilityLabel("Refresh schedule")
            }

            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ForEach(ScheduleWeekday.allCases) { weekday in
                        Button {
                            withAnimation(.smooth) {
                                selectedDay = weekday
                            }
                        } label: {
                            let isSelected = selectedDay == weekday

                            HStack {
                                Image(systemName: isSelected ? "checkmark" : "")
                                Text(weekday.name)
                            }
                        }
                    }
                } label: {
                    Text(selectedDay?.name ?? "")
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let container = DevPreview.shared.container
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)

    return RouterView { router in
        ScheduleView(
            presenter: SchedulePresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: builder)
            )
        )
    }
}
