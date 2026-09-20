import SwiftUI

// MARK: - KeyboardDismissModifier

struct KeyboardDismissModifier: ViewModifier {
    // MARK: - Properties

    @FocusState.Binding private var isFocused: Bool
    private let dismiss: () -> Void

    // MARK: - Init

    init(isFocused: FocusState<Bool>.Binding, dismiss: @escaping () -> Void) {
        self._isFocused = isFocused
        self.dismiss = dismiss
    }

    // MARK: - Body

    func body(content: Content) -> some View {
        content
            .scrollDismissesKeyboard(.interactively)
            .overlay(alignment: .bottomTrailing) {
                if isFocused {
                    Button(action: dismiss) {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .font(.body)
                            .imageScale(.medium)
                            .frame(width: 44, height: 44)
                            .background(.regularMaterial, in: Circle())
                            .overlay {
                                Circle()
                                    .strokeBorder(.white.opacity(0.16), lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 16)
                    .padding(.bottom, 12)
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                    .accessibilityLabel(Text("common.action.done"))
                }
            }
            .animation(.easeOut(duration: 0.2), value: isFocused)
            .onDisappear(perform: dismiss)
    }
}

// MARK: - View

extension View {
    func dismissesKeyboard(
        when isFocused: FocusState<Bool>.Binding,
        using dismiss: @escaping () -> Void
    ) -> some View {
        modifier(
            KeyboardDismissModifier(
                isFocused: isFocused,
                dismiss: dismiss
            )
        )
    }
}
