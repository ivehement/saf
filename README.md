![saf](https://github.com/ivehement/saf/blob/master/example/screenshots/saf_banner.png?raw=true)
<p align="center">
 <a href="https://pub.dartlang.org/packages/saf">
    <img alt="Saf" src="https://img.shields.io/pub/v/saf.svg">
  </a>
  <a href="https://github.com/ivehement/saf/issues"><img src="https://img.shields.io/github/issues/ivehement/saf">
  </a>
  <img src="https://img.shields.io/github/license/ivehement/saf">
  <!-- <a href="https://github.com/ivehement/saf/actions/workflows/main.yml">
    <img alt="CI pipeline status" src="https://github.com/ivehement/saf/actions/workflows/main.yml/badge.svg">
  </a> -->
</p>

# Saf
Flutter plugin that leverages Storage Access Framework (SAF) API to get access and perform the operations on files and folders.

## Currently supported features
* Uses OS default native file explorer
* Access the **hidden** folder and files
* Accessing directories
* **Caching** the files inside the app External files directory
* **Syncing** the files of some directory with cached one
* Different default type filtering (media, image, video, audio or any)
* Support Android

If you have any feature that you want to see in this package, please feel free to issue a suggestion. 🎉

## Usage

To use this plugin, add `saf` as a [dependency in your pubspec.yaml file](https://flutter.dev/docs/development/platform-integration/platform-channels).

### Initiate Saf with instance
```dart
Saf saf = Saf(directoryPath: "~/some/path")
```

#### Directory Permission request
```dart
bool? isGranted = await saf.getDirectoryPermission(isDynamic: false);

if (isGranted != null) {
  // Perform some file operations
} else {
  // User canceled the native explorer
}
```
#### Get paths of all the files of granted directory
```dart

List<String>? paths = await saf.getFilesPath(FileType.media);

```
#### Cache the granted directory
```dart

List<String>? cachedFilesPath = await saf.cache();

```
#### Get the cached files' path
```dart

List<String>? cachedFilesPath = await saf.getCachedFilesPath();

```
#### Cache a single file of the granted directory
```dart

String? path = await saf.singleCache(filePath: "~/some/path/file.type");

```
#### Clear cache of the granted directory
```dart

bool? isClear = await saf.clearCache();

```
#### Sync the cached directory with the granted directory
```dart

bool? isSynced = await saf.syncWithCacheDirectory();

```
#### Release the persisted permission for current granted directory
```dart

bool? isReleased = await saf.releasePersistedPermission();

```
#### Get the list of all the granted directory paths with persisted permissions
```dart

// Static method
List<String>? paths = await Saf.getPersistedPermissionDirectories();

```
#### Release the persisted permissions for all granted the directories
```dart

// Static method
bool? isReleased = await Saf.releasePersistedPermissions();

```

## Documentation
See the **[Saf Wiki](https://github.com/ivehement/saf/wiki)** for every detail on about how to install, setup and use it.

### Saf Wiki

1. [Installation](https://github.com/ivehement/saf/wiki/Installation)
2. [Setup](https://github.com/ivehement/saf/wiki/Setup)
   * [Android](https://github.com/ivehement/saf/wiki/Setup#android)
3. [API](https://github.com/ivehement/saf/wiki/api)
   * [Methods](https://github.com/ivehement/saf/wiki/API#methods)
   * [Parameters](https://github.com/ivehement/saf/wiki/API#parameters)
   * [Filters](https://github.com/ivehement/saf/wiki/API#filters)
4. [FAQ](https://github.com/ivehement/saf/wiki/FAQ)
5. [Troubleshooting](https://github.com/ivehement/saf/wiki/Troubleshooting)

For full usage details refer to the **[Wiki](https://github.com/ivehement/saf/wiki)** above.

## Example App
#### Android
![Demo](https://github.com/ivehement/saf/blob/master/example/screenshots/saf_example.gif)

## Compatibility Chart

| API                                   | Android            | iOS                | Windows            | linux              | macOS              |
| ------------------------------------- | ------------------ | ------------------ | ------------------ | ------------------ | ------------------ |
| getDirectoryPermission()              | :white_check_mark: | :x:                | :x:                | :x:                | :x:                |
| getFilesPath()                        | :white_check_mark: | :x:                | :x:                | :x:                | :x:                |
| getCachedFilesPath()                  | :white_check_mark: | :x:                | :x:                | :x:                | :x:                |
| cache()                               | :white_check_mark: | :x:                | :x:                | :x:                | :x:                |
| singleCache()                         | :white_check_mark: | :x:                | :x:                | :x:                | :x:                |
| clearCache()                          | :white_check_mark: | :x:                | :x:                | :x:                | :x:                |
| syncWithCacheDir()                    | :white_check_mark: | :x:                | :x:                | :x:                | :x:                |
| getPersistedPermissionDirectories()   | :white_check_mark: | :x:                | :x:                | :x:                | :x:                |
| releasePersistedPermissions()         | :white_check_mark: | :x:                | :x:                | :x:                | :x:                |

See the [API section of the Saf Wiki](https://github.com/ivehement/saf/wiki/api) or the [official API reference on pub.dev](https://pub.dev/documentation/saf/latest/saf/Saf-class.html) for further details.

## Getting Started

For help getting started with Flutter, view our online
[documentation](https://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/platform-plugins/#edit-code).
