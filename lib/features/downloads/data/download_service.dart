import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../domain/download_item.dart';
import '../domain/file_name_utils.dart';

/// Callback for download progress updates.
typedef DownloadProgressCallback = void Function(
    String downloadId, int received, int total);

/// Callback when a download completes or fails.
typedef DownloadCompleteCallback = void Function(
    String downloadId, DownloadStatus status, String? savePath);

/// Manages actual file downloads using Dio.
class DownloadService {
  DownloadService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;
  final _cancelTokens = <String, CancelToken>{};

  /// Starts downloading a file from [url].
  ///
  /// Returns the [DownloadItem] with an assigned id and derived filename.
  /// Calls [onProgress] with received/total bytes and [onComplete] when done.
  Future<DownloadItem> startDownload(
    String url, {
    DownloadProgressCallback? onProgress,
    DownloadCompleteCallback? onComplete,
  }) async {
    final id = const Uuid().v4();
    final cancelToken = CancelToken();
    _cancelTokens[id] = cancelToken;

    // Derive filename from URL first; may be updated from headers.
    var fileName = FileNameUtils.deriveFromUrl(url);

    final downloadsDir = await _getDownloadsDirectory();
    var savePath = '${downloadsDir.path}/$fileName';

    final item = DownloadItem(
      id: id,
      url: url,
      fileName: fileName,
      savePath: savePath,
      startedAt: DateTime.now(),
      status: DownloadStatus.downloading,
    );

    // Fire-and-forget the actual download; caller tracks via callbacks.
    _performDownload(
      item: item,
      cancelToken: cancelToken,
      onProgress: onProgress,
      onComplete: onComplete,
    );

    return item;
  }

  Future<void> _performDownload({
    required DownloadItem item,
    required CancelToken cancelToken,
    DownloadProgressCallback? onProgress,
    DownloadCompleteCallback? onComplete,
  }) async {
    try {
      // HEAD request to try getting filename from Content-Disposition.
      String? resolvedFileName;
      try {
        final head = await _dio.head<void>(
          item.url,
          cancelToken: cancelToken,
          options: Options(followRedirects: true),
        );
        final cd = head.headers.value('content-disposition');
        resolvedFileName = FileNameUtils.deriveFromContentDisposition(cd);
      } catch (_) {
        // HEAD may fail; proceed with URL-derived name.
      }

      final downloadsDir = await _getDownloadsDirectory();
      final fileName = resolvedFileName ?? item.fileName;
      final savePath = '${downloadsDir.path}/$fileName';

      await _dio.download(
        item.url,
        savePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          onProgress?.call(item.id, received, total);
        },
      );

      _cancelTokens.remove(item.id);
      onComplete?.call(item.id, DownloadStatus.completed, savePath);
    } on DioException catch (e) {
      _cancelTokens.remove(item.id);
      if (e.type == DioExceptionType.cancel) {
        onComplete?.call(item.id, DownloadStatus.cancelled, null);
      } else {
        onComplete?.call(item.id, DownloadStatus.failed, null);
      }
    } catch (_) {
      _cancelTokens.remove(item.id);
      onComplete?.call(item.id, DownloadStatus.failed, null);
    }
  }

  /// Cancels an in-progress download.
  void cancelDownload(String downloadId) {
    _cancelTokens[downloadId]?.cancel('User cancelled');
    _cancelTokens.remove(downloadId);
  }

  Future<Directory> _getDownloadsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final downloadsDir = Directory('${appDir.path}/WebBuddy_Downloads');
    if (!downloadsDir.existsSync()) {
      downloadsDir.createSync(recursive: true);
    }
    return downloadsDir;
  }
}
