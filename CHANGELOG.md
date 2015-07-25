# Change Log
All notable changes to this project will be documented in this file.

## 2.1.3 - 2015-07-24
### Added
- ALL: Updating formatting on HTML email templates to provide cleaner field descriptions and enforce newlines.
- FILES: Added management UI for worker processes. This is identical to the one for the jobs API.

### Changed
- ALL: Fix a bug in notifiations preventing webhooks from sending due to messages not being able to be deserialized from the queue. [Issue 74](https://bitbucket.org/taccaci/agave/issues/74/job-notifications-are-not-sending)
- FILES: Refactored file staging processing to reflect the same producer/consumer approach taken by the jobs api. This removes contention and guarantees no-conflict in a single host environment.

### Removed
- nothing


## 2.1.3 - 2015-07-22
### Added
- ALL: HTML email notification support for all events. Email will be sent as both plain text and HTML.

### Changed
- JOBS: Fixed temporal job queries so searching by date range (ex `startTime.between=1 week ago,yesterday`, `endTime.between=2015-05-05 8:00,2015-05-05 12:00`) works as expected. 
- JOBS: Refactored queue processing into two schedulers, one for producer and the other consumer. Producers have a thread for each queue. Consumers have a generic pool of 25 threads to process new jobs and triggers created by the producers. Each quartz job has a key equal to the agave job uuid, thus quartz prevents duplication within a jvm. To prevent monopolization of the thread pool, the concurrent list of job ids is still kept in the producer and no new job will be created while the queue is at length Settings.MAX_XXXX_TASKS.
- JOBS: Fixed a bug where job status queries were not refreshing quickly enough. This is an artifact of optimistic record locking used to prevent concurrency issues across distributed JVM. Each request will give a stale update at most one time, then instantly refresh with a new query to the DB.

### Removed
- nothing


## 2.1.3 - 2015-07-16
### Added
- ALL: adding in Docker Compose file to bring up all core services, dependent services, and load balancer with routing built in. If using Swarm, this is sufficient for a scalable multihost setup.
- ALL: Added support for sending email using multiple clients. This lets us use SendGrid, MailGun, SMTP, PostFix, or optional log file printing of email notifications.
- JOBS: Improved performance and reliability of monitoring processes

### Changed
- JOBS: Fixed bug preventing job status updates from occuring during monitoring  processes when remote connectivity was needed.
- JOBS: Refactored job queues to use a custom job factory. They now follow producer/consumer pattern. This implementation uses a concurrent linked list to track the active jobs so no conflict can happen within a single jvm.
- FILES: Fixed bug in pagination of file histories.

### Removed
- Old fat container build
- Deprecated `fig.xml` file
- Deprecated tomcat and depenent service configs.


## 2.1.3 - 2015-07-13
### Added
- SYSTEMS: added system batch queues as a formal resource with independent crud api /systems/<id>/queues. With the expanded format, queue descriptions will include and additional `load` object which describes the current load on a queue in terms of Agave usage.
- SYSTEMS: added `system.load` object which describes the current load on a system in terms of Agave usage.
- JOBS, TRANSFORMS: Added reaper thread to clean up zombie jobs across the platform.
_ JOBS, FILES, TRANSFORMS: Added support for transferring job output directories by specifying their URI. Agave resolves them internally, verifies access rights, and resolves them to their current system and path. For users with access to a job, but not the system, the remote system is modified to use the job work directory as they system root, thus isolating their ability to access any other data.

### Changed
- ALL: AgaveUUID class was updated to avoid collisions when accessed within 100 nanoseconds. 
- JOBS: refactored worker processes so they are largely self-healing in the even the container is closed. Now any running processes will be rolled back to their previous state and resubmitted to the queue for pick up by another worker.
- SYSTEMS: Updated transfer classes to support graceful termination due to shutdown or thread interruption.
- SYSTEMS: Fixed bug in 3rd party transfers preventing total data moved from writing to the logs.
- POSTITS, LOGGING, TENANTS, USAGE: Fixed parameterization of the config files to inject the proper runtime values upon maven build.
- JOBS: lot of concurrency tests replicating production quartz behavior.
- JOBS, SYSTEMS: leveraging a new threadsafe approach to passing tasks through the API. 

### Removed
- nothing


## 2.1.2 - 2015-06-29
### Added
- ALL: Added iplant.dedicated.tenant.id configuration setting to enable the restriction of a worker to a particular tenant.
- ALL: Added iplant.drain.all.queues configuration setting to tell a worker to stop accepting new tasks.  
- ALL: Added quartz workers endpoint to legacy APIs to monitor worker tasks
- ALL: Added printing of JWT JSON as well as header when the `debugjwt` url parameter is defined.
- JOBS: Added reaper thread to roll back zombie archiving jobs that have not updated in several minutes. This will grow out to handle all zombie tasks.
- SYSTEMS: Added full support for FTP storage systems. Both authenticated and anonymous FTP is supported. Use FTP for the system.storage.protocol value and ANONYMOUS or PASSWORD for the system.storage.auth.type value.
- SYSTEMS: Added system.[storage,login].auth.caCerts field to x509 auth configurations to allow the importing of a trustroot archive from a public URL. This allows users to provide self-signed credentials for their private infrastructure and still access them from Agave. Each system's auth config trustroots are sandboxed and fetched as needed. Archive can be in zip, tar, bzip2, tgz, tar.gz, tar.bz2, or jar format.
- NOTIFICATIONS: Added support for authenticated SMTP servers and HTML email.


### Changed
- ALL: Updated myproxy to support  and fall back on TLS automatically.
- APPS: Fixed bug in app registration where apps would not save due to a uniqueness constraint failure.
- APPS: Fixed bug in app update endpoint where the app would not save due to the id not being resolved properly.
- APPS: Fixed bug in permission checks of app assets where checks would fail if an absolute path was not given on public systems.
- JOBS: Fixed bug in job status worker where concurrency collisions were not being caught. This prevented Condor jobs from updating.
- JOBS: Fixed bug in job staging worker where job would fail due to a StaleObjectException if more than one input was present. This was caused by the transfer task associated with the staging job event being updated as a separate entity during the execution of the `URLCopy.copy()` method. When the method returned, the original reference to the trnasfer task was still referenced in the job event. Because we had a `Cascade={ALL,DELETE}` annotation on the association, persistence failed due to the stale transfer task. This was corrected by changing the annotation field to `Cascade={DELETE}`. Since we manage transfer tasks independently, this is completely safe. 
- JOBS: Updated search query to accept comma-delimited lists of search values.
> /jobs/v2/?status.in=RUNNING,SUBMITTING,ARCHIVING   
> /jobs/v2/?endtime.after=2015-01-17&endtime.before=today

- JOBS: Updated search query to allow data ranges to be preceded by a comparator such that you can specify created=(2014-12-01,today) 
> /jobs/v2/?executionsystem.like=stampede&runtime.gt=86400  
> /jobs/v2/?submittime.on=yesterday&appid.like=bwa  

- FILES: Rewrote a portion of the jglobus library to support multiple truststore locations and concurrent, multiuser scenarios. 
- FILES: Fixed a bug where the root of public systems could not be viewed by admins.
- FILES: Fixed bug where staging and encoding tasks could not get an optimistic lock.
- JOBS: Rewrote job queues to handle concurrency and failures a bit better. Conflicts seem to be isolated at tests up to 10 simultaneous workers.
- SYSTEMS: Updated URLCopy, TransferTask, and RemoteTransferListener to catch content updates in real time.
- SYSTEMS: Updated URLCopy to use a relay transfer rather than a proxy transfer when file size is under 6GB. This allows for speedups from striping, etc in certain situations.
- SYSTEMS: Updated URLCopy to roll back and cancel transfer task groups when a transfer is cancelled from another thread.
- SYSTEMS: Fixed bug preventing MyProxy from retrieving certs from unknown, self-signed servers.
- SYSTEMS: Fixed S3 support, optimizing uploads and downloads using chunked transfers.
- SYSTEMS: Fixed bug in HTTP imports where some url parameters were not forwarded to the download client.
- TRANSFORMS: Fixed bug where decoding tasks could not get an optimistic lock.
- TRANSFORMS: Updated queue workers to track data movement.
- TRANSFORMS: Fixed bug where tenancy was not honored on callbacks.
- POSTITS: Fixed parameterization bug preventing CD
- USAGE: Fixed parameterization bug preventing CD

### Removed
- Disabling of apps if the assets disappear temporarily. 
- 

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

