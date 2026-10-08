Garden

Inspiration

Large file collections tie access to the capacity of individual computers. Expanding local storage means buying more hardware, while synchronizing a cloud collection repeats its disk requirements on each device. For creators, researchers and teams, the storage available remotely can be much larger than the storage available where the work happens. Downloading files before working on them leaves that constraint in place.

Garden is a remote filesystem built with Flutter and Serverpod. It mounts cloud storage as a drive on macOS, making remote files accessible to existing applications without synchronizing a complete copy to each computer. The same drive can be accessed from multiple Macs and shared with a team.

DaVinci Resolve can edit media from a Garden drive and render directly back to it. The mounted filesystem supports cuts, reordered video and audio, and saved project archives that reopen with their media paths intact. Documents, images and audio use the same drive, without a separate integration for each application.

Serverpod and Flutter

Serverpod provides the shared backend for both Flutter and the native filesystem. Its endpoints authenticate requests, enforce drive permissions and coordinate file operations and version commits. Model definitions generate database access and the Dart client used by Flutter, keeping the application and backend on the same typed contract.

Serverpod messaging delivers file changes and conversation events through live streams. Persisted revision records let those streams resume after a disconnect. Serverpod Cloud hosts the backend, with PostgreSQL storing accounts, drive metadata, memberships, file versions and messages. Private AWS S3 stores file content, keeping large objects separate from the application data that Serverpod manages.

Flutter provides account setup, drive browsing, sharing, the Inbox, storage controls and native integration. Its controllers manage state and stream subscriptions through the generated client and authentication session manager.

https://github.com/victorbash400/garden/blob/main/frontend/lib/services/serverpod_gateway.dart

A desktop application expects directories, file offsets and writes. Object storage exposes objects and transfers. Garden connects those interfaces through a Swift helper using macFUSE's FSKit backend. The helper translates filesystem operations into authenticated Serverpod endpoint requests.

Both clients use the same backend metadata and permissions. A rename in Finder and a rename in Garden change the same file record. File content is stored separately from its name, parent folder, membership rules and version history, allowing Serverpod to coordinate the drive without storing large media objects in PostgreSQL.

Storage implementation

Applications do not necessarily read a file from beginning to end. They seek to headers, indexes and specific regions, then revisit data during playback or editing. Downloading the entire object for each of those operations would turn filesystem access into a sequence of large transfers.

Garden translates reads into byte-range requests. Its cache reuses fetched ranges, combines concurrent requests for the same data and adjusts read windows to the access pattern. Cached data is associated with a file version so it is not reused as content from a newer version. A configurable disk limit bounds the read cache rather than requiring the whole drive to fit locally.

Two empty-cache runs against a 72.5 MB H.264 MP4 displayed the first frame in 10.83 and 12.24 seconds through the mounted drive. Both decoded 1280 × 720 video and reached 20 seconds of media time. These measurements use a native AVPlayer first-frame check; they measure cold file access, not DaVinci Resolve startup. Repeated reads can use the cache; uncached reads still depend on the network and cloud response time.

Filesystem writes and cloud uploads finish on different timescales. Garden persists writes in a local SQLite journal before publishing them, retaining pending edits across interruptions. The publisher starts from a base file version, uploads changed regions and copies eligible unchanged multipart regions within S3. Resuming an upload checks the parts already present instead of restarting every transfer.

Serverpod validates the completed upload before committing a new file version. Incomplete uploads remain separate from the visible committed version. If another writer has changed the base version, Garden preserves the competing edit as a conflict copy. Each filesystem mutation also carries an operation ID, allowing Serverpod to return a recorded result when a request is retried after its response was lost.

https://github.com/victorbash400/garden/blob/main/backend/lib/src/files/content_endpoint.dart

Sharing and collaboration

Personal and shared drives are accessible from another Mac through the same account, without synchronizing the full collection. Members mount the same cloud-backed drive and use their own authenticated sessions. Email verification and the setup checklist guide account creation and Finder mounting.

Drive invitations assign Owner, Manager, Editor or Viewer permissions. Serverpod checks the sender's authority when an invitation is created and again when it is accepted, along with the recipient's identity and the invitation's expiry and status. Membership is created transactionally. File operations enforce current access on the server for both Flutter and the mounted drive.

The Inbox combines drive conversations, private conversations, invitations, unread state and file references. Serverpod stores these alongside the drive metadata, connecting collaboration to the files and memberships it concerns.

Serverpod messaging keeps the Flutter application and native helper informed of file and membership changes, while Inbox streams deliver messages, invitations and unread state. A saved change creates a persistent revision in the same transaction as the file update. Connected clients receive the event immediately after commit; returning clients resume from their saved cursor. The same mechanism brings conversation state up to date after a reconnect, without repeatedly polling the backend.

https://github.com/victorbash400/garden/blob/main/backend/lib/src/files/drive_journal.dart

Lessons learnt

Application read patterns mattered as much as network throughput. Small, repeated filesystem reads could trigger excessive cloud transfers even when the application used only part of a file. Tracing those requests led us to narrower read-ahead windows, shared in-flight fetches and aggregate cache storage. On the same captured 49,864-read MP4 trace, aggregate storage reduced replay time from 283.47 to 183.69 seconds with identical returned data and remote bytes, a 35.2% reduction in that comparison.

Reading quickly was only one part of making the drive usable. Editing introduced partial writes, retries and competing versions. Persisting writes before publication and committing versions through Serverpod made those transitions explicit, rather than treating a completed local save as a completed cloud upload.

End-to-end checks also exposed problems that isolated reads could not: mount lifecycle, project reopening and file integrity after export. We checked the rendered media against an independent cloud download and reopened the saved Resolve project after remounting. Building around those complete operations gave us a more useful measure of the filesystem than transfer speed alone.
