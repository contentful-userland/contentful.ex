# CHANGELOG

## Master

### Features

* Introduced a DSL that can be composed into queries 
* Solved the `include` removal by readding it (#20)
  * Also allows for resolving assets included in entries

### Chores

* Deleted most Context(s) module code
* Updated the docs with more working examples

## 0.2.0

Note: This release is incompatible with previous releases as this lacks the `include` functionality, specifically.

### Features

* Reworked the way data can be queried from the CDA endpoint
* Split up the modules into mapping to different Contentful APIs
* Introduced a way to stream the CDA API endpoints instead of relying on pagination
* Added 

### Chores

* Added badges and `ex_doc` integration (published via [hex.pm](https://hex.pm))
* Updated the docs with examples

## 0.1.1

### Fixed

* Fixed issue on empty includes
* Fixed compatibility with Elixir 1.4

## 0.1.0

### Added

* Added some spec coverage for all endpoints and include resolution
* Added Linter tool

### Changed

* Improved syntax conventions
* Refactored Include Resolution into it's own module

## 0.0.1 [INITIAL RELEASE]

### Added

* Added all CDA Endpoints
* Added Basic Include Resolution
