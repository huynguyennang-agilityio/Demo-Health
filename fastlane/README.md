fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios dev

```sh
[bundle exec] fastlane ios dev
```

Development build → Firebase App Distribution

### ios staging

```sh
[bundle exec] fastlane ios staging
```

Staging build → Firebase App Distribution

### ios prod

```sh
[bundle exec] fastlane ios prod
```

Production build → TestFlight

### ios local

```sh
[bundle exec] fastlane ios local
```

Auto-detect local environment via Info.plist and build an IPA without distributing it

### ios bump_versions

```sh
[bundle exec] fastlane ios bump_versions
```



----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
