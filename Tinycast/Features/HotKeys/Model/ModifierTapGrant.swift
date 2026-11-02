import Foundation

/// What a tap's own state says about its grant. See docs/features/hotkeys.md#double-tap-modifiers.
enum ModifierTapGrant {
    /// A tap macOS refuses to enable is as dead as one it refused to create, so both ask for it.
    /// `isTapEnabled` is nil when no tap stands, which is the refused-to-create case.
    static func isMissing(isBound: Bool, isSessionActive: Bool, isTapEnabled: Bool?) -> Bool {
        guard isBound, isSessionActive else { return false }
        return isTapEnabled != true
    }
}
