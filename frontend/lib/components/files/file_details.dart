import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';

import '../../utils/error_message.dart';

import '../../services/files/files_gateway.dart';
import 'file_comment_input.dart';
import 'file_comments_list.dart';
import 'file_versions_list.dart';
import 'file_information.dart';

class FileDetails extends StatefulWidget {
  const FileDetails({
    super.key,
    required this.gateway,
    required this.node,
    required this.revision,
    required this.userId,
    required this.onExport,
    this.canWrite = true,
  });
  final FilesGateway gateway;
  final FileNode node;
  final int revision;
  final String userId;
  final ValueChanged<FileVersion> onExport;
  final bool canWrite;
  @override
  State<FileDetails> createState() => _FileDetailsState();
}

class _FileDetailsState extends State<FileDetails> {
  List<FileVersion> versions = [];
  List<FileComment> comments = [];
  String? error;
  bool loading = true;
  int generation = 0;
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void didUpdateWidget(FileDetails old) {
    super.didUpdateWidget(old);
    if (old.node.id != widget.node.id || old.revision != widget.revision) {
      load();
    }
  }

  Future<void> load() async {
    final request = ++generation;
    final nodeId = widget.node.id!;
    try {
      late List<FileVersion> loadedVersions;
      late List<FileComment> loadedComments;
      await Future.wait<void>([
        widget.gateway.versions(nodeId).then<void>((value) {
          loadedVersions = value;
        }),
        widget.gateway.comments(nodeId).then<void>((value) {
          loadedComments = value;
        }),
      ]);
      if (!mounted || request != generation) return;
      setState(() {
        versions = loadedVersions;
        comments = loadedComments;
        loading = false;
        error = null;
      });
    } catch (failure) {
      if (mounted && request == generation) {
        setState(() {
          error = errorMessage(failure);
          loading = false;
        });
      }
    }
  }

  Future<bool> post(String text) async {
    try {
      await widget.gateway.comment(widget.node.id!, text);
      await load();
      return true;
    } catch (failure) {
      if (mounted) setState(() => error = errorMessage(failure));
      return false;
    }
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 280,
    child: DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: Color(0xFFE8E8EB))),
      ),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            FileInformation(node: widget.node),
            const TabBar(
              tabs: [
                Tab(text: 'Versions'),
                Tab(text: 'Comments'),
              ],
              labelStyle: TextStyle(fontSize: 12),
            ),
            if (loading) const LinearProgressIndicator(minHeight: 2),
            if (error != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: SelectableText(
                  error!,
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
              ),
            Expanded(
              child: TabBarView(
                children: [
                  FileVersionsList(
                    versions: versions,
                    userId: widget.userId,
                    onExport: widget.onExport,
                  ),
                  Column(
                    children: [
                      Expanded(
                        child: FileCommentsList(
                          comments: comments,
                          userId: widget.userId,
                        ),
                      ),
                      if (widget.canWrite) FileCommentInput(onSubmit: post),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
