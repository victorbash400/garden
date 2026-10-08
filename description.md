Garden

Inspiration and problem

Creators, researchers and teams work with file collections that can exceed the storage available on their computers. Downloading those files before using them consumes disk space and delays access. Keeping full copies on several computers repeats that storage requirement, while external drives add hardware to purchase, carry and manage. Cloud storage provides capacity, but using it through separate downloads and uploads still requires a local working copy and another transfer whenever an edit is finished.

Garden is a remote filesystem built with Flutter and Serverpod. It mounts cloud storage as a drive on your Mac, so you can open, edit and save files through your existing applications. Serverpod manages the accounts, drive metadata, memberships, file versions, messages and live updates that let several users and computers work against the same stored data.

The application retrieves byte ranges as they are requested, caches fetched data within a configurable disk limit and publishes saved changes to cloud storage. Accessing a large drive does not require synchronizing its entire contents to every computer.

Users and use cases

An individual can keep files in a personal drive and access that drive from another Mac by signing in. Applications use the mounted path to open documents, images, audio, media and other files. Garden handles the remote reads and writes underneath those filesystem operations.

A team can share a drive without giving every member the same authority. Editors can change files, Viewers can read them, Managers can administer eligible memberships, and the Owner controls the drive. Members use their own accounts to access the shared files and discuss them through conversations with file and folder references.

DaVinci Resolve provides a tested example of this access. An MP4 was imported from a mounted Garden drive, cut and reordered in a 40-second timeline with linked video and audio, then rendered directly to the drive. The project archive was also saved to Garden and reopened after remounting without a media relink prompt. The rendered file and project archive matched independent cloud downloads, and the corrected video and audio output passed decoding and comparison with a local render.

Mounting and sharing drives

Users create drives, organize folders and import files through the Flutter application. The same drives appear in Finder through a Swift helper using macFUSE's FSKit backend. Desktop applications can read, seek, rename and write files through ordinary filesystem paths. Garden's browser and the mounted drive use the same Serverpod file operations and permission checks.

Sharing begins with an email invitation and a selected role. Serverpod checks whether the sender can grant that role, then stores the invitation and an account notification together. The invitation expires after seven days. Acceptance checks the signed-in recipient's email, the invitation's current state and the sender's current authority before creating membership in a database transaction. Duplicate acceptance does not create another membership, and email delivery failures remain visible for retry.

Membership changes produce permission events and account notices. File requests check current access on the server, including requests from the native helper. The Inbox stores conversations, invitations, unread state and file references, so discussion and access changes remain associated with the shared drive.

Serverpod and Flutter architecture

The Flutter application handles account setup, drive browsing, sharing controls, the Inbox, storage settings and native integration. It uses Serverpod's generated Dart client and authentication session manager. Controllers own the application state and stream subscriptions; widgets display that state and invoke the corresponding actions.

The backend runs on Serverpod Cloud. Serverpod's model definitions generate database access, serialization and client methods for drives, folders, file nodes, versions, memberships, invitations and conversations. PostgreSQL persists this application data through Serverpod's database layer. Private AWS S3 stores file bytes. Metadata and messages remain in Serverpod, rather than being encoded into storage objects or kept only on the client.

File mutations and their revision records are committed in the same database transaction. After commit, Serverpod messaging notifies connected clients. File streams replay persisted revisions before delivering new events, allowing a client to reconnect from its saved cursor. The stream subscribes before catch-up begins so changes made during replay are buffered. The Inbox uses a recipient-scoped snapshot and cursor stream. Updates are driven by these events instead of periodic polling.

The native helper connects to the same authenticated Serverpod endpoints as Flutter. Each filesystem mutation carries an operation ID. Serverpod stores the request and result as a receipt, so retrying an operation after a lost response returns its existing result instead of applying the mutation again. Reusing an operation ID with different arguments fails explicitly.

Streaming reads and publishing edits

The native range cache fetches the parts of a file requested by an application, shares in-flight requests and reuses cached ranges for repeated reads. Read windows adapt to the access pattern. Previously fetched data can be served locally; uncached reads still depend on network and cloud latency. An application that scans every byte can cause a full-file transfer.

Writes are persisted in a local SQLite journal before cloud publication. The helper starts an edit against a base file version, uploads changed multipart regions and can copy eligible unchanged regions within S3. Uploaded parts are checked when resuming a transfer. Serverpod validates the completed content before committing the new file version and publishing its revision.

If another writer has changed the base version, Garden creates a conflict copy instead of silently replacing that writer's file. The write journal, resumable upload and transactional commit preserve the edit across interruptions while keeping incomplete uploads separate from committed versions.

Impact and current implementation

Garden reduces the local copies and manual transfers required to work with remote files. Users can access a drive from another computer without preparing a full synchronized copy, and teams can grant access to shared data through individual accounts. Applications continue to use filesystem operations while Serverpod coordinates identity, metadata, permissions, versions and collaboration.

The macOS preview has been tested from ordinary email signup and verification through drive creation, native mounting, file saves and logout. MP4, WAV, PNG and Markdown saves through the mounted drive matched independent cloud reads. Logout removed the mount and returned the application to sign-in. The Resolve tests additionally exercised editing, rendering and reopening a saved project; uninterrupted playback across all codecs and project sizes has not been established.

The current implementation uses Serverpod Cloud and AWS S3, with macFUSE required for Finder mounting. Additional device platforms and user-connected storage providers are planned. The next work is broader application and media testing, continued optimization of cold reads and larger imports, and extending access beyond macOS.
