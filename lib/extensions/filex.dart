import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// File extensions
extension FileX on File {
  // File operations
  Future<String> get readAsString => this.readAsString();
  Future<List<String>> get readAsLines => this.readAsLines();
  Future<Uint8List> get readAsBytes => this.readAsBytes();

  // File information
  String get fileName => uri.pathSegments.last;
  String get fileNameWithoutExtension {
    final name = fileName;
    final lastDot = name.lastIndexOf('.');
    return lastDot != -1 ? name.substring(0, lastDot) : name;
  }

  String get extension {
    final name = fileName;
    final lastDot = name.lastIndexOf('.');
    return lastDot != -1 ? name.substring(lastDot + 1) : '';
  }

  // Check if file is certain type
  bool get isImage => [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
    'bmp',
    'tiff',
  ].contains(extension.toLowerCase());

  bool get isVideo => [
    'mp4',
    'avi',
    'mov',
    'wmv',
    'flv',
    'mkv',
    'webm',
  ].contains(extension.toLowerCase());

  bool get isAudio => [
    'mp3',
    'wav',
    'ogg',
    'aac',
    'flac',
    'm4a',
  ].contains(extension.toLowerCase());

  bool get isDocument => [
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'ppt',
    'pptx',
    'txt',
  ].contains(extension.toLowerCase());

  // File size utilities
  Future<String> get formattedSize async {
    final bytes = await length();
    return _formatBytes(bytes);
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
    final i = (math.log(bytes) / math.log(1024)).floor();

    return '${(bytes / math.pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }

  // Create backup copy of the file
  Future<File> createBackup({String? customSuffix}) async {
    final suffix = customSuffix ?? '.bak';
    final backupPath = '$path$suffix';
    return copy(backupPath);
  }

  // Safe write operations
  Future<File> writeStringSafely(String contents) async {
    try {
      // Create backup
      await createBackup();
      // Write new content
      return writeAsString(contents);
    } catch (e) {
      // If write fails, try to restore backup
      final backupFile = File('$path.bak');
      if (await backupFile.exists()) {
        await backupFile.copy(path);
      }
      rethrow;
    }
  }

  // Read file in chunks
  Stream<List<int>> readInChunks([int chunkSize = 1024]) {
    return openRead().transform(
      StreamTransformer<List<int>, List<int>>.fromHandlers(
        handleData: (data, sink) {
          int start = 0;
          while (start < data.length) {
            final end = math.min(start + chunkSize, data.length);
            sink.add(data.sublist(start, end));
            start = end;
          }
        },
      ),
    );
  }
}
