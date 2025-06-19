import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

late Logger appLogger;

Future<void> initLogger() async {
  // Get the app's documents directory, guaranteed writable
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/app_logs.txt');

  final fileOutput = FileLogOutput(file);

  appLogger = Logger(printer: PrettyPrinter(), output: fileOutput);

  appLogger.i("Logger initialized. Logs will be written to: ${file.path}");
}

class FileLogOutput extends LogOutput {
  final File file;
  final int maxFileSizeInBytes;

  FileLogOutput(
    this.file, {
    this.maxFileSizeInBytes = 1024 * 1024,
  }); // Default 1 MB

  @override
  void output(OutputEvent event) {
    try {
      // Check current file size
      if (file.existsSync()) {
        final fileSize = file.lengthSync();
        if (fileSize >= maxFileSizeInBytes) {
          // Delete the file (or you could rename to archive)
          file.deleteSync();
        }
      }

      // Append logs
      for (final line in event.lines) {
        file.writeAsStringSync('$line\n', mode: FileMode.append, flush: true);
      }
    } catch (e) {
      // Handle any IO exceptions
      print('Error writing logs: $e');
    }
  }
}
