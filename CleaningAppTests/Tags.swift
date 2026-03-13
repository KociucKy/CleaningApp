import Testing

// MARK: - Tags

extension Tag {

    // MARK: - Feature Tags

    @Tag static var home: Self
    @Tag static var rooms: Self
    @Tag static var settings: Self

    // MARK: - Behavior Tags

    @Tag static var adding: Self
    @Tag static var deleting: Self
    @Tag static var editing: Self
    @Tag static var navigation: Self

    // MARK: - Priority Tags

    @Tag static var critical: Self
    @Tag static var slow: Self
}