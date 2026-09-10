import SwiftUI

// MARK: - FrequencyPickerView

@MainActor
struct FrequencyPickerView: View {
    // MARK: - Properties

    @Binding private var selectedFrequency: Frequency

    private let onInteraction: () -> Void

    private var selectedOption: FrequencySelectorOption {
        FrequencySelectorOption(frequency: selectedFrequency)
    }

    // MARK: - Init

    init(
        selectedFrequency: Binding<Frequency>,
        onInteraction: @escaping () -> Void
    ) {
        _selectedFrequency = selectedFrequency
        self.onInteraction = onInteraction
    }

    // MARK: - Body

    var body: some View {
        frequencyMenu

        if let countRange = selectedOption.countRange {
            Stepper(
                value: countBinding,
                in: countRange,
                onEditingChanged: onStepperEditingChanged
            ) {
                Text(selectedFrequency.displayName)
            }
        }
    }

    // MARK: - Subviews

    private var frequencyMenu: some View {
        Menu {
            ForEach(FrequencySelectorOption.allCases) { option in
                Button {
                    onInteraction()
                    selectedFrequency = option.defaultFrequency
                } label: {
                    Text(option.menuTitle)
                }
            }
        } label: {
            LabeledContent("onb_custom_task.label.frequency") {
                Text(selectedFrequency.displayName)
            }
        }
        .simultaneousGesture(
            TapGesture().onEnded(onInteraction)
        )
    }

    // MARK: - Bindings

    private var countBinding: Binding<Int> {
        Binding(
            get: {
                selectedOption.count(for: selectedFrequency) ?? selectedOption.defaultFrequencyCount
            },
            set: { count in
                selectedFrequency = selectedOption.frequency(for: count)
            }
        )
    }

    // MARK: - Actions

    private func onStepperEditingChanged(isEditing: Bool) {
        if isEditing {
            onInteraction()
        }
    }
}

// MARK: - FrequencySelectorOption + Default Count

private extension FrequencySelectorOption {
    var defaultFrequencyCount: Int {
        count(for: defaultFrequency) ?? 0
    }
}
