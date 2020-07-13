# CHANGELOG

## 0.0.1-alpha - Core Project - [08-07-2020]

### Added
* Create a CLI to get values from bash.
* Create client request to post JSON escaped yaml content to Gitlab API for linting.
* Evaluate response and display summary.
* Pre-commit hook for linting Gitlab yml file staged for changes.

## 0.0.1 - Refactored Project Structure - [12-07-2020]

### Added
* Entrypoint:
  * Gitlab::Lint::Client.entry
* Class:
  * Gitlab::Lint::Client::Api
  * Gitlab::Lint::Client::Args
  * Gitlab::Lint::Client::SummaryReport.
  * GitLab::CI::Lint::YamlFile.
* Added unit and integration tests
