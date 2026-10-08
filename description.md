Garden

Remote storage

Large file collections tie access to the capacity of individual computers. Expanding local storage means buying more hardware, while synchronizing a cloud collection repeats its disk requirements on each device. For creators, researchers and teams, the storage available remotely can be much larger than the storage available where the work happens. Downloading files before working on them leaves that constraint in place.

Garden is a remote filesystem built with Flutter and Serverpod. It mounts cloud storage as a drive on macOS, making remote files accessible to existing applications through normal filesystem operations. Serverpod coordinates authentication, drive metadata, permissions, file versions and collaboration. The backend runs on Serverpod Cloud, PostgreSQL holds application data, and private AWS S3 holds file content.

The drive can be accessed from multiple Macs and shared with a team without keeping a complete copy on each computer. DaVinci Resolve can edit media from the mounted drive and render back to it. Documents, images and audio use the same filesystem, so access is not tied to a separate integration for each application.

Filesystem and application state

A desktop application expects directories, file offsets and writes. Object storage exposes objects and transfers. Garden connects those interfaces through a Swift helper using macFUSE's FSKit backend. The helper translates filesystem operations into authenticated Serverpod requests, while Flutter provides drive browsing, account setup, sharing, conversations and storage controls.

Both clients use the same backend metadata and permissions. A rename in Finder and a rename in Garden change the same file record. File content is stored separately from its name, parent folder, membership rules and version history, allowing Serverpod to coordinate the drive without storing large media objects in PostgreSQL.

Serverpod generates the Dart client and database access from the backend's models and endpoints. Flutter controllers manage application state and stream subscriptions through that client. The authentication session manager supplies the account session used by backend requests and native integration.

https://github.com/victorbash400/garden/blob/main/frontend/lib/services/serverpod_gateway.dart

Reading remote files

Applications do not necessarily read a file from beginning to end. They seek to headers, indexes and specific regions, then revisit data during playback or editing. Downloading the entire object for each of those operations would turn filesystem access into a sequence of large transfers.

Garden translates reads into byte-range requests. Its cache reuses fetched ranges, combines concurrent requests for the same data and adjusts read windows to the access pattern. Cached data is associated with a file version so it is not reused as content from a newer version. A configurable disk limit bounds the read cache rather than requiring the whole drive to fit locally.

This makes the requested portion of a remote file available without first synchronizing the collection. Repeated reads can use the cache; uncached reads still depend on the network and cloud response time.

Saving edits

Filesystem writes and cloud uploads finish on different timescales. Garden persists writes in a local SQLite journal before publishing them, retaining pending edits across interruptions. The publisher starts from a base file version, uploads changed regions and copies eligible unchanged multipart regions within S3. Resuming an upload checks the parts already present instead of restarting every transfer.

Serverpod validates the completed upload before committing a new file version. Incomplete uploads remain separate from the visible committed version. If another writer has changed the base version, Garden preserves the competing edit as a conflict copy. Each filesystem mutation also carries an operation ID, allowing Serverpod to return a recorded result when a request is retried after its response was lost.

https://github.com/victorbash400/garden/blob/main/backend/lib/src/files/content_endpoint.dart

Shared drives and live updates

Drive invitations assign Owner, Manager, Editor or Viewer permissions. Serverpod checks the sender's authority when an invitation is created and again when it is accepted, along with the recipient's identity and the invitation's expiry and status. Membership is created transactionally. File operations enforce current access on the server for both Flutter and the mounted drive.

The Inbox combines drive conversations, private conversations, invitations, unread state and file references. Serverpod stores these alongside the drive metadata, connecting collaboration to the files and memberships it concerns.

A live notification alone is insufficient when a client disconnects. Garden commits file changes and their revision records in the same database transaction, then publishes the event through Serverpod messaging. Clients resume streams from saved cursors and replay persisted changes. Subscribing before replay buffers changes that arrive during catch-up, closing the gap between historical and live state. The Inbox uses the same snapshot-and-cursor approach for account events.

https://github.com/victorbash400/garden/blob/main/backend/lib/src/files/drive_journal.dart

Garden separates remote capacity from the size of a computer's disk while retaining the filesystem interface applications already use. Flutter brings file access and collaboration into one application; Serverpod maintains the shared identity, permissions and versioned state across devices.
