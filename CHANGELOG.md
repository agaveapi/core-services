# Change Log
All notable changes to this project will be documented in this file.


## 2.1.1 - 2015-06-02
### Added
- ALL: Added support for pagination through the limit and offset url query parameters.
- FILES: Added support for forced downloads on the files download service. This will add the `Content-Disposition` header to the response whenever `force=true` is in the URL query.
- FILES: Added support for unspecified range request sizes. You can now specify `256-` as a valid range. The files services will return everything after byte 256 in that file. This is helpful whenever you need to continue a download after it previously failed.
- SYSTEMS: Added new `system.storage.auth.trustedCALocation` and `system.login.auth.trustedCALocation` fields to system definitions to allow for trustroots to be provided as tar, zip, tgz, or bzip2 archives at a public URL. 
- JOBS: Added support for forced downloads on the job output download service. This will add the `Content-Disposition` header to the response whenever `force=true` is in the URL query.
- JOBS: Added support for unspecified range request sizes. You can now specify `256-` as a valid range. The job output service will return everything after byte 256 in that file. This is helpful whenever you need to continue a download after it previously failed.
- JOBS: search has been updated so you can query by any job attribute using a URL query string such as status=running. Dates such as `created`, `starttime`, and `submittime` are rounded to the day and matched accordingly. `name`, `inputs`, and `parameters` are all partial matches. All other fields are exact matches.

### Changed
- APPS: Fixed a bug where app.input.semantics.maxCardinality was not preserved when copying or publishing an app.
- APPS: Fixed a bug where app.output.value.order was not preserved when copying or publishing an app.
- JOBS: Fixed a bug where jobs could remain in a persistent active state when they failed due to parsing or unexpected errors from the file system. Now they will be set to FAILED after the max job expiration time is reached.
- JOBS: Fixed a bug where non-primary tenant jobs were not being updated when the callback came. This had to do with the JobDAO.getJobBYUUID() method not removing the tenancy filter.
- JOBS: 
- SYSTEMS: Added better exception handling to prevent users from attempts to redefine an execution system to a storage system or vice versa.
- SYSTEMS: Fixed a bug in the SFTP client where port would not default properly if not given.
- SYSTEMS: Improved exception handling when validation X.509 credentials.
- JOBS: Bug causing a race condition in job submission and, indirecdtly, failed jobs under low traffic situations was fixed.

### Removed
- No change.

## 2.1.0 - 2014-11-23
### Added
- No change.

### Changed
- APPS: Fixed a bug where app.input.semantics.maxCardinality was not preserved when copying or publishing an app.
- APPS: Fixed a bug where app.output.value.order was not preserved when copying or publishing an app.
- JOBS: Fixed a bug where jobs could remain in a persistent active state when they failed due to parsing or unexpected errors from the file system. Now they will be set to FAILED after the max job expiration time is reached.
 
### Removed
- No change.


## 2.1.0 - 2014-11-05
### Added
- No change.

### Changed
- SYSTEMS: Rewrote the ssh tunneling code to produce more reliable tunnels through dynamic port selection and a vt100 pseudo terminal to the remote system.
- APPS: Rolling back change of app.parameter.value.enumValues attribute to app.parameter.value.enum_values for legacy compatibility.

### Removed
- No change.


## 2.1.0 - 2014-11-04
### Added
- Added Maven goals to build Docker containers out of each API.

### Changed
- Updated the fig.xml file to launch the API as a series of linked containers rather than a single fat container.
- Updated build instructions in the README.md file.

### Removed
- No change.

## 2.1.0 - 2014-11-04
### Added
- APPS: Support for array default values for app inputs, outputs, and parameters
- APPS: app.*.semantics.minCardinality and app.*.semantics.maxCardinality support for app inputs, outputs, and parameters.
- APPS: Inputs and parameters maintain default ordering and ordering values in the response from the API.
- APPS: Added app.*.value.repeatArguments support for app inputs, outputs, and parameters. This tells the job service whether to add the arguments once or in front of each job prior to injecting into the template.
- APPS: Added app.*.value.encoding support for app inputs, outputs, and parameters. This tells the job service whether to quote the value(s) prior to injecting into the template.
- JOBS: Support for array values when defining individual inputs and parameters
- SYSTEMS: Added global remote connection timeout limit of 90 seconds for command invocation on systems.
- PROFILES: Added UUID to user profiles.
- NOTIFICATIONS: Added support for notification events tied to user profiles. Currently CREATED, REVOKED, UPDATED are supported.

### Changed
- APPS: Input, output, and parameter default values are returned as JSON arrays rather than primary type values when the app.*.semantics.maxCardinality is greater than 1. All parameters, inputs, and outputs are set to 1 by default for backward compatibility.
- APPS: Increased label length on app inputs, outputs, and parameter labels from 64 to 128 characters.
- APPS: Fixed bug in SoftwareOutput.setValidator() preventing it from properly validating the value.   
- JOBS: Fixed bug in job submission stemming from failed scheduler id parsing when connection to remote system times out.
- JOBS: Fixed bug in monitoring processes that would terminate a job if it finished before the first check ran.
- JOBS: Improved exception handling so the scheduler response bubbles back to the job error message when submission fails.
- JOBS: Fixed a bug in job submission when retrieving the job id and the operation had not yet completed. Switched to blocking call that consumes output as it goes. This speeds up things on average quite a bit because there is no long a forced 8 second delay for every call.
- JOBS: Updated internal representation of job values to be json based and honor the original primary value types. This fixed a bug where the json response from jobs always turned job values into strings rather than honoring the primary type.
- JOBS: Fixed event message to reflect how the job was submitted, i.e. HPC, CLI, or other.
- JOBS: Fixed bug where boolean parameters were not parsed in the job request if the request was made as pure json.d
- SYSTEMS: Fixed a bug in MyProxy credential handling that prevented certificate retrieval if SSLv3 was disabled.
- MONITORS: Fixed exception handling when a check resulted in a RuntimeException so the logs and monitor message will still present the correct message.
- PROFILES: Fixed bug in profiles notifications that prevented the notification's template variables from resolving correctly.

### Removed
- No change.

## 2.0.0 - 2014-10-24
### Added
- Dockerfile to build the APIs as a single Docker image
- fig.yml file to orchestrate the deployment of the Agave APIs and dependent services in a single step.

### Changed
- FILES: Fixed bug in notifications for file imports. notifications attribute was not accepted.
- FILES: Fixed bug in web hook processing for file imports where certain web hook URLs could cause infinite loops.

### Removed
- No change.

## 2.0.0 - 2014-09-26
### Added
- NOTIFICATIONS: Adding support for setting wildcard UUID on notifications. Only tenant admins and above can add these.
- NOTIFICATIONS: Added support for new user creation events and general profile notifications.

### Changed
- FILES: Fixed hypermedia "self" reference on individual file listings.
- FILES: Fixed bug discovering and uploading data in virtual home directory on sftp systems.

### Removed
- No change.

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

