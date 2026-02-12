# Changelog

All notable changes to this project are documented in this file.

## 2.0.0 - 2026-02-12

### Added
- SwiftPM test target with algorithm edge-case coverage.
- GitHub Actions CI workflow running `swift test`.

### Changed
- Core simplification internals now use non-optional `Double` tolerance handling.
- Douglas-Peucker implementation is now iterative (stack-based) instead of recursive.
- `Simplify` API container is now a `public enum` with static methods.
- Package metadata updated for modern SwiftPM platforms/toolchain.
- Example app now parses JSON with `Codable` and avoids force unwraps in core flow.
- Example polyline rendering now draws a single path per frame.

### Deprecated
- Legacy `simplify(_:tolerance: Float?, highQuality:)` overload.

### Removed
- CocoaPods support and pod artifacts.
