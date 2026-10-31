import 'package:file_picker/file_picker.dart';
import 'package:modoo_core/modoo_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../providers/app_providers.dart';
import 'import_service.dart';

part 'import_controller.g.dart';

/// Where the import flow currently stands.
enum ImportPhase { idle, picking, running, done, failed }

/// Immutable snapshot of the import flow, safe to watch from widgets.
final class ImportState {
  const ImportState({
    this.phase = ImportPhase.idle,
    this.progress = 0,
    this.errorCode,
    this.outcome,
  });

  final ImportPhase phase;

  /// 0..1 while [ImportPhase.running].
  final double progress;

  /// Stable code from [AppException], so the UI can pick a localized message.
  final String? errorCode;

  /// Set when [ImportPhase.done].
  final ImportOutcome? outcome;

  bool get isBusy => phase == ImportPhase.picking || phase == ImportPhase.running;

  ImportState copyWith({
    ImportPhase? phase,
    double? progress,
    String? errorCode,
    ImportOutcome? outcome,
  }) => ImportState(
    phase: phase ?? this.phase,
    progress: progress ?? this.progress,
    errorCode: errorCode ?? this.errorCode,
    outcome: outcome ?? this.outcome,
  );
}

/// Drives one import: pick a file, copy it into the library, insert rows.
@Riverpod(keepAlive: true)
class ImportController extends _$ImportController {
  @override
  ImportState build() => const ImportState();

  /// Opens the system picker and imports the chosen file.
  ///
  /// Returns the new book, or null when the user cancels or the import fails
  /// (the failure is exposed through [state]).
  Future<ImportOutcome?> pickAndImport() async {
    if (state.isBusy) {
      return null;
    }
    state = const ImportState(phase: ImportPhase.picking);

    final String? path;
    try {
      final FilePickerResult? picked = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ImportService.supportedExtensions
            .map((String value) => value.substring(1))
            .toList(growable: false),
        withData: false,
      );
      path = picked?.files.singleOrNull?.path;
    } on Object catch (error) {
      state = ImportState(
        phase: ImportPhase.failed,
        errorCode: error is AppException ? error.code : 'unknown',
      );
      return null;
    }

    if (path == null) {
      state = const ImportState();
      return null;
    }

    state = const ImportState(phase: ImportPhase.running);
    try {
      final service = ImportService(
        registry: ref.read(pluginRegistryProvider),
        books: ref.read(bookRepositoryProvider),
        chapters: ref.read(chapterRepositoryProvider),
        libraryDirectory: ref.read(libraryDirectoryProvider),
      );
      final ImportOutcome outcome = await service.importFile(
        sourcePath: path,
        onProgress: (double fraction) {
          if (!ref.mounted) {
            return;
          }
          state = state.copyWith(progress: fraction);
        },
      );
      if (!ref.mounted) {
        return outcome;
      }
      state = ImportState(phase: ImportPhase.done, progress: 1, outcome: outcome);
      return outcome;
    } on AppException catch (error) {
      if (ref.mounted) {
        state = ImportState(phase: ImportPhase.failed, errorCode: error.code);
      }
      return null;
    } on Object {
      if (ref.mounted) {
        state = const ImportState(phase: ImportPhase.failed, errorCode: 'unknown');
      }
      return null;
    }
  }

  void reset() => state = const ImportState();
}
