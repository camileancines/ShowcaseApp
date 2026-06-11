# ShowcaseApp
Just a showcase for recruiters

> 🇧🇷 [Versão em português](README.pt-BR.md)

A SwiftUI showcase app that demonstrates senior-level integration of six Apple frameworks around the public **iTunes Search API**. Search the music catalog, play 30-second previews with a custom audio engine and an animated visualizer, save favorites that persist across launches, and get results localized to your region.

![iOS](https://img.shields.io/badge/iOS-26%2B-black)
![Swift](https://img.shields.io/badge/Swift-6.2-orange)
![Xcode](https://img.shields.io/badge/Xcode-26-blue)
![UI](https://img.shields.io/badge/UI-SwiftUI-green)

---

## What it does

| Screen | Description |
| --- | --- |
| **Search** | Reactive, debounced search over the iTunes catalog with artwork results. |
| **Player** | Plays the 30s audio preview with a custom AVFoundation engine and a Core Animation equalizer that reacts to playback. |
| **Favorites** | Persisted favorites with swipe-to-delete, in its own tab. |

The app uses **no API keys**: the iTunes Search API is keyless. This is a deliberate choice: anyone reviewing the project can clone and run it instantly, with zero setup friction.

---

## Frameworks, and what each one demonstrates

- **SwiftUI**: declarative UI, `NavigationStack` with value-based navigation, `@StateObject`/`@ObservedObject` ownership semantics, `AsyncImage` with phase handling, `ContentUnavailableView` for empty/error states, `.searchable`, `TabView`.
- **Swift Concurrency (6.2)**: `async`/`await` networking, **MainActor default isolation**, a `nonisolated` data layer, bridging callbacks to async with `CheckedContinuation`, and `MainActor.assumeIsolated` for runtime-guaranteed main-thread closures.
- **Combine**: a debounced search pipeline (`debounce` + `removeDuplicates`), and KVO publishers (`publisher(for:)`) to observe `AVPlayer` state.
- **AVFoundation**: a custom `AVPlayer` engine, `AVAudioSession` configuration, a periodic time observer for progress, and `timeControlStatus` observation.
- **Core Animation**: an equalizer built with `CAReplicatorLayer` + `CABasicAnimation`, hosted in SwiftUI through a `UIViewRepresentable`.
- **Core Data**: favorites persistence with `@FetchRequest`, `@Environment(\.managedObjectContext)`, and `NSPredicate` lookups.
- **Core Location + MapKit**: a regional storefront derived from the device's location via reverse geocoding, with graceful degradation.

---

## Architecture

- **MVVM.** View models are `@MainActor final class … ObservableObject` with `@Published` outputs.
- **Layered isolation.** The data/networking layer (`NetworkService`, `Codable` models) is `nonisolated`; the UI layer (view models, views) is `@MainActor`. This mirrors how real codebases adopt Swift 6.2's main-actor-by-default model.
- **Dependency-injection seams.** `NetworkService` is injected into the search view model with a default value, convenient to use, easy to mock in tests.

```
Search flow:  TextField → @Published searchText → Combine (debounce) → Task → async URLSession → Codable → @Published tracks → List
```

---

## Engineering decisions (the "why")

- **async/await vs Combine boundary.** Combine governs *continuous* events (search text over time, playback time); async/await governs *one-shot* operations (the network request). The bridge between them is a `Task` opened inside the Combine `sink`.
- **MainActor default isolation.** Under Swift 6.2, every type is implicitly `@MainActor` unless marked otherwise. The UI layer keeps that default; the data layer opts out with `nonisolated` so networking and decoding don't run on the main actor and can cross actor boundaries freely.
- **Audio, not video.** iTunes music previews are audio (`.m4a`), so there is no video layer to render, `AVPlayerLayer` would be a blank rectangle. AVFoundation depth comes instead from the player engine (asset/item/player, audio session, time observers). The visualizer is **decorative**; a true spectrum analyzer would tap the audio with `AVAudioEngine` and run an FFT.
- **iOS 26 deprecation.** `CLGeocoder` was deprecated in favor of MapKit's `MKReverseGeocodingRequest`, which returns the country *name* rather than an ISO code. The name is converted to an ISO code via `Locale`, with `Locale.current.region` as the fallback.
- **Graceful degradation.** The store region defaults instantly to the device locale (no permission needed) and is *refined* by GPS only if the user grants location. Deny the permission and the app still works, it's just less precise.
- **TabView lifecycle.** `onAppear`/`onDisappear` fire on tab switches, not only on push/pop. The player engine is therefore idempotent and distinguishes "pause" (tab hidden) from "destroy" (screen popped).
- **Core Data over SwiftData, on purpose.** Both are in my toolbox; using Core Data here broadens the demonstrated stack.

---

## Requirements

- iOS 26+ / Xcode 26 / Swift 6.2
- Build setting **Default Actor Isolation = MainActor** (the Xcode 26 default)
- `Info` key **`NSLocationWhenInUseUsageDescription`** (required for the regional-store feature)

---

## Getting started

1. Clone the repository.
2. Open the project in Xcode 26.
3. Run on a simulator or device. No keys, no `.env`, no setup.

To verify the audio session, run on a physical device with the silent switch on, the preview should still play.

---

## Author

**Camile Ancines** - iOS developer.
