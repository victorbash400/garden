# Garden

## Inspiration and problem

A creative project rarely stays inside one application. Footage is opened in a video editor, images in a photo tool, documents in another app, and the finished work is sent to someone else. The files move with it: from a cloud folder to a local disk, into a project directory, then back to the cloud.

That movement has a cost. Large media fills local storage, duplicate copies accumulate, and teams have to keep track of which version belongs where. Paying for more storage does not resolve the work involved in downloading, organizing, editing and uploading the same files again. Object storage from providers such as AWS and Google Cloud gives developers a place to put the bytes, but using those bytes as a working drive requires another layer.

Garden grew from a practical question: **can the cloud folder itself be the place where the work happens?**

## Users

Garden is for people whose files need to move between applications and collaborators: video editors, photographers, designers, developers and small teams. An editor needs source media and project files in a stable location. A photographer needs to open an image, save an edit and share the result. A team needs shared access without passing another archive around every time something changes.

The longer-term aim is access from the devices a person owns, with a choice of cloud storage providers. The first implementation is a macOS application connected to a hosted backend and private AWS S3 storage. Other device platforms and user-connected providers are future work.

## Solution

Garden turns cloud files into personal and shared drives. Users create a drive, invite collaborators, organize folders and open files through Garden or Finder. Their usual applications can read from and save to the mounted drive using ordinary filesystem paths.

![Garden showing personal drives and invitations](screenshots/drives.png)

The difference becomes visible while working, rather than while storing a file:

| Step | Upload/download workflow | Garden's mounted workflow |
| --- | --- | --- |
| Open a project | Download files into a local working folder | Open files through the Garden drive path |
| Read large media | Prepare a local copy before editing | Fetch requested byte ranges and reuse a bounded cache |
| Save the result | Save locally, then upload the result | Save to the drive; Garden journals and publishes the write |
| Work with a team | Distribute files and coordinate access separately | Share drive membership, permissions and file-linked conversations |

Garden still stores cloud data and uses local cache space. Its contribution is the filesystem and collaboration layer around that storage. Applications may request an entire file, and cold reads still depend on network and cloud latency. The aim is to avoid unnecessary copies and transfers, not to promise that remote storage behaves like a local SSD.

### Editing directly in DaVinci Resolve

The media workflow has been exercised with an MP4 opened from a mounted Garden drive in DaVinci Resolve. The test included linked video and audio cuts, reordering a 40-second timeline, exporting the rendered video and a `.drp` project archive directly to Garden, then reopening the saved project after the drive was safely remounted. The project reopened without a media relink prompt.

The exported video and project archive were checked against independent cloud downloads. The corrected render fully decoded, and its video and audio were compared with a local render of the same timeline. These checks establish a tested editing and saving flow; they do not establish universal codec compatibility or uninterrupted real-time playback.

> **Image to add: Resolve reading Garden media.** Show the decoded source viewer and the clip's actual `/Volumes/Garden-…` path in the Media Pool or file details. Caption: “Source media opened from the mounted Garden drive.”

> **Image to add: Resolve timeline and direct export.** Show the linked video/audio cuts and an export destination inside the Garden drive. Caption: “Edited in Resolve and rendered directly to Garden.”

![Garden column view containing Resolve project archives and rendered media](screenshots/media-files.png)

Shared drives have Owner, Manager, Editor and Viewer roles. Garden's Inbox keeps drive conversations, private conversations, invitations and file references together. Sharing a drive gives a team a common working location; it does not imply simultaneous editing of a single Resolve timeline.

## Technology and architecture

**Flutter provides the application; Serverpod provides the shared system behind it.** The Flutter app handles account setup, drive browsing, uploads, storage controls and collaboration. A Swift helper mounts drives through macFUSE on macOS and translates filesystem operations into authenticated Serverpod requests.

```text
Flutter + generated Dart client       Finder + Swift/macFUSE
                │                              │
                └──────── Serverpod API ────────┘
                                 │
                      ┌──────────┴──────────┐
                      ▼                     ▼
              Serverpod PostgreSQL      Private S3
          metadata, messages, access    file content
```

Serverpod owns the metadata and messaging layer. Its generated database models persist drives, folders, file metadata, versions, memberships, conversations and unread state in PostgreSQL. S3 holds file content, not messages or permissions. Serverpod is responsible for:

- **Identity:** [email verification and authentication](backend/lib/server.dart), with registration emails sent through [Serverpod Cloud](backend/lib/src/auth/garden_email_config.dart).
- **Data and access:** [typed models](backend/lib/src/files/file_node.spy.yaml), metadata persisted through Serverpod's PostgreSQL database layer, [drive membership and roles](backend/lib/src/gardens/drive_permissions.dart), and server-enforced authorization.
- **File lifecycle:** [content endpoints](backend/lib/src/files/content_endpoint.dart), versions, multipart uploads and [private S3 integration](backend/lib/src/files/file_storage.dart).
- **Live collaboration:** [drive journals](backend/lib/src/files/drive_journal.dart) and [Inbox streams](backend/lib/src/inbox/inbox_endpoint.dart), with saved cursors for reconnecting.

The [generated Dart client](client/lib/src/protocol/client.dart) connects Flutter to those endpoints. The native helper uses the same backend through its [API client](frontend/macos/FinderShared/GardenAPI.swift). [Range caching](frontend/macos/FinderShared/GardenRangeCache.swift) bounds local read storage, while a [persistent write journal](frontend/macos/RemoteDrive/Engine/RemoteWriteJournal.swift) preserves accepted edits before cloud publication. Database transactions coordinate file metadata, committed versions and change events.

The backend runs on Serverpod Cloud. The current production file provider is AWS S3; the application keeps metadata and object storage responsibilities separate. This provides a foundation for adding other providers without making each one a separate user workflow.

## Impact

Garden makes cloud storage useful inside the tools people already use. The intended benefit is less manual file movement, fewer duplicate working copies and a shared location that remains meaningful across applications. A bounded cache gives users control over local disk use, while drive permissions and file-linked conversations keep access and discussion close to the work.

The current preview demonstrates the complete path from email signup to a shared drive, native file access, cloud saves and safe logout. It is available as a [macOS download](https://github.com/victorbash400/garden/releases/tag/v0.1.0-preview.2), with an onboarding checklist and [installation instructions](release/INSTALL.txt). The next steps are broader media testing, more storage providers and access from additional device platforms. Storage-cost savings depend on provider pricing, transfers and usage; no universal cost reduction is claimed.
