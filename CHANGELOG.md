# Change Log
All notable changes to this project will be documented in this file.

## 2.0.0 - 2014-09-05
### Added
- Project CHANGELOG.md file.

### Changed
- NOTIFICATIONS: Fixed bug in notifications sent from monitors service to list the proper webhook response.
- FILES: Updating response to requests to transfer data from non-agave systems. This response was different from the one given when uploading a file. Matching up for consistency.
- FILES: Fixed bug in url parsing allowing for proper handling of system root paths
- FILES: Fixed bug in file permissions preventing recursive permissions from being applied on non-irods systems.
- FILES: Updated file upload processing to reduce disk footprint, shorten response time, and increase the relay transfer to the remote system.
- FILES: Updating response from systems roles service to list the user profile under the correct hypermedia attribute
- DOCS: Fixing bad url value in the job search method

### Removed
- No change.

