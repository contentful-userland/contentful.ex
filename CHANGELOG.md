# CHANGELOG

## Master

## 0.3.1

* [#37](https://github.com/contentful-labs/contentful.ex/issues/37) Fixed an error preventing corrent entity resolution for assets (thanks @OldhamMade)
* [#44](https://github.com/contentful-labs/contentful.ex/issues/44) Adds missing common properties to content types, assets entries (thanks @OldhamMade)
* [#36](https://github.com/contentful-labs/contentful.ex/issues/36) Added dependabot for keeping dependencies up to date
* [#9](https://github.com/contentful-labs/contentful.ex/issues/9) Added the ability to specify an endpoint other than the Delivery API
* Improved some README sections about how to qeruy certain entities

## 0.3.0

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
