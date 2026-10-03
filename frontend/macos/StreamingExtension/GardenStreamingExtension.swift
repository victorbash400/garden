import ExtensionFoundation
import FSKit

@main struct GardenStreamingExtension: UnaryFileSystemExtension {
  let fileSystem = GardenStreamingFileSystem()
}
