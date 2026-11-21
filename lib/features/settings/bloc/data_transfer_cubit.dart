import 'package:endelea/core/utils/clock.dart';
import 'package:endelea/core/utils/files_bridge.dart';
import 'package:endelea/data/repositories/backup_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class DataTransferState extends Equatable {
  const DataTransferState();

  @override
  List<Object?> get props => [];
}

final class DataTransferIdle extends DataTransferState {
  const DataTransferIdle();
}

final class DataTransferBusy extends DataTransferState {
  const DataTransferBusy();
}

final class DataExported extends DataTransferState {
  const DataExported();
}

final class DataImported extends DataTransferState {
  const DataImported(this.rows);

  /// Rows added or updated.
  final int rows;

  @override
  List<Object?> get props => [rows];
}

final class DataTransferFailed extends DataTransferState {
  const DataTransferFailed({required this.invalidFile});

  /// The picked file is not an Endelea export.
  final bool invalidFile;

  @override
  List<Object?> get props => [invalidFile];
}

/// JSON export and import (PLAN.md §9.8).
class DataTransferCubit extends Cubit<DataTransferState> {
  DataTransferCubit({
    required this.backup,
    required this.files,
    required this.clock,
  }) : super(const DataTransferIdle());

  final BackupRepository backup;
  final FilesBridge files;
  final Clock clock;

  Future<void> export({String? shareTitle}) async {
    if (state is DataTransferBusy) return;
    emit(const DataTransferBusy());
    try {
      final now = clock.now();
      await files.shareText(
        fileName: BackupRepository.fileName(now),
        content: await backup.exportJson(now),
        title: shareTitle,
      );
      emit(const DataExported());
    } on Object {
      emit(const DataTransferFailed(invalidFile: false));
    }
  }

  Future<void> import() async {
    if (state is DataTransferBusy) return;
    emit(const DataTransferBusy());
    try {
      final json = await files.openText();
      if (json == null) {
        emit(const DataTransferIdle());
        return;
      }
      final result = await backup.importJson(json);
      emit(DataImported(result.applied));
    } on InvalidExportException {
      emit(const DataTransferFailed(invalidFile: true));
    } on Object {
      emit(const DataTransferFailed(invalidFile: false));
    }
  }
}
