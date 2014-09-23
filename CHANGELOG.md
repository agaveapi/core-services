# Change Log
All notable changes to this project will be documented in this file.

## 2.0.0 - 2014-09-17
### Added
- No change.

### Changed
- FILES: * Updating how file permissions are returned from irods on public systems. Now if the system is public, rather than returning all users, it will simply list the "public" user as having read access unless, of course, they do not have read access. Basically s/$username/public/g. 
- FILES: Fixed bug in path resolution when passing in agave:// and tenant file url, such as when transferring data, importing, or specifying job inputs. Standard tenant urls now validate properly and throw exceptions properly when a bad system is provided.
- FILES: Fixed bug in url parsing allowing for proper handling of system root paths
- FILES: Fixed bug in file permissions preventing recursive permissions from being applied on non-irods systems.
- FILES: Updated file upload processing to reduce disk footprint, shorten response time, and increase the relay transfer to the remote system.
- FILES: Updating response from systems roles service to list the user profile under the correct hypermedia attribute

### Removed
- No change.


## 2.0.0 - 2014-09-06
### Added
- Project CHANGELOG.md file.

### Changed
- NOTIFICATIONS: Fixed bug in notifications sent from monitors service to list the proper webhook response.
- FILES: Updating response to requests to transfer data from non-agave systems. This response was different from the one given when uploading a file. Matching up for consistency.
- DOCS: Fixing bad url value in the job search method

### Removed
- No change.
