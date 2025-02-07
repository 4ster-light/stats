# stats

An small tool I made to know how much I code in each language I use

## Usage

### Install

>[!IMPORTANT]
> First, you need to install the dependencies

```bash
swift package resolve
```

Package.swift:

```swift
// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "stats",
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "4.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "stats",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Rainbow", package: "Rainbow"),
            ]),
        .testTarget(
            name: "statsTests",
            dependencies: ["stats"]),
    ]
)
```

### Running

The directory must be given as only argument or else it'll default to the current directory.
If you just want to run it directly:

```bash
swift run stats <directory>
```
If you want a production build:

```bash
swift build -c release
.build/release/stats <directory>
```

In order to run the tests:

```bash
swift test
```

## Output

```bash
Language Statistics
┏━━━━━━━━━━━━┳━━━━━━━┳━━━━━━━┳━━━━━━━━┳━━━━━━━━┓
┃ Language   ┃ Files ┃ Lines ┃ File % ┃ Line % ┃
┡━━━━━━━━━━━━╇━━━━━━━╇━━━━━━━╇━━━━━━━━╇━━━━━━━━┩
│ Haskell    │ 5     │ 165   │ 10.9%  │ 9.1%   │
│ JavaScript │ 3     │ 107   │ 6.5%   │ 5.9%   │
│ Lua        │ 4     │ 203   │ 8.7%   │ 11.2%  │
│ Python     │ 3     │ 113   │ 6.5%   │ 6.2%   │
│ Rust       │ 15    │ 625   │ 32.6%  │ 34.5%  │
│ Swift      │ 6     │ 266   │ 13.0%  │ 14.7%  │
│ TypeScript │ 10    │ 330   │ 21.7%  │ 18.2%  │
└────────────┴───────┴───────┴────────┴────────┘
```

## License

GNU GPL v3
