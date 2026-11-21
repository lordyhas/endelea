import 'package:endelea/core/utils/clock.dart';
import 'package:endelea/data/repositories/sync_meta_repository.dart';
import 'package:endelea/sync/cloud_sync_provider.dart';
import 'package:endelea/sync/sync_engine.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Why a sync runs (PLAN.md §9.4).
enum SyncReason { appStart, sessionFinished, resumed, manual }

sealed class SyncEvent extends Equatable {
  const SyncEvent();

  @override
  List<Object?> get props => [];
}

/// App start: restore the account without user interaction, then sync.
final class SyncStarted extends SyncEvent {
  const SyncStarted();
}

final class SyncRequested extends SyncEvent {
  const SyncRequested(this.reason);

  final SyncReason reason;

  @override
  List<Object?> get props => [reason];
}

final class SyncSignInRequested extends SyncEvent {
  const SyncSignInRequested();
}

final class SyncSignOutRequested extends SyncEvent {
  const SyncSignOutRequested();
}

sealed class SyncState extends Equatable {
  const SyncState();

  @override
  List<Object?> get props => [];
}

/// Not connected to a cloud account.
final class SyncDisabled extends SyncState {
  const SyncDisabled({this.signInFailed = false});

  /// The last sign-in attempt failed (not cancelled).
  final bool signInFailed;

  @override
  List<Object?> get props => [signInFailed];
}

/// Connected: a sync is running, done, or failed.
sealed class SyncConnected extends SyncState {
  const SyncConnected({required this.account, this.lastSyncAt});

  final CloudAccount account;
  final DateTime? lastSyncAt;

  @override
  List<Object?> get props => [account, lastSyncAt];
}

final class SyncInProgress extends SyncConnected {
  const SyncInProgress({required super.account, super.lastSyncAt});
}

final class SyncUpToDate extends SyncConnected {
  const SyncUpToDate({required super.account, super.lastSyncAt});
}

/// Network or cloud error: silent, retried at the next trigger.
final class SyncFailed extends SyncConnected {
  const SyncFailed({required super.account, super.lastSyncAt});
}

/// Cloud sync state and triggers (PLAN.md §9.4).
class SyncBloc extends Bloc<SyncEvent, SyncState> {
  SyncBloc({
    required this.provider,
    required this.engine,
    required this.meta,
    required this.clock,
    required this.sessionActive,
  }) : super(const SyncDisabled()) {
    on<SyncEvent>(
      (event, emit) => switch (event) {
        SyncStarted() => _onStarted(emit),
        SyncRequested(:final reason) => _onRequested(reason, emit),
        SyncSignInRequested() => _onSignIn(emit),
        SyncSignOutRequested() => _onSignOut(emit),
      },
      // One at a time: a second trigger waits for the running sync.
      transformer: (events, mapper) => events.asyncExpand(mapper),
    );
  }

  final CloudSyncProvider provider;
  final SyncEngine engine;
  final SyncMetaRepository meta;
  final Clock clock;

  /// True while a workout is in progress: no automatic sync then.
  final bool Function() sessionActive;

  /// A resumed app syncs if the last sync is older than this.
  static const resumeInterval = Duration(minutes: 15);

  Future<void> _onStarted(Emitter<SyncState> emit) async {
    if (await meta.read(SyncMetaKeys.provider) != provider.id) return;
    try {
      final account = await provider.currentAccount();
      if (account == null) return;
      emit(
        SyncUpToDate(
          account: account,
          lastSyncAt: await meta.readDate(SyncMetaKeys.lastSyncAt),
        ),
      );
    } on Object {
      return;
    }
    await _sync(emit, SyncReason.appStart);
  }

  Future<void> _onRequested(SyncReason reason, Emitter<SyncState> emit) =>
      _sync(emit, reason);

  Future<void> _sync(Emitter<SyncState> emit, SyncReason reason) async {
    final current = state;
    if (current is! SyncConnected) return;
    if (reason != SyncReason.manual && sessionActive()) return;
    final last = current.lastSyncAt;
    if (reason == SyncReason.resumed &&
        last != null &&
        clock.now().difference(last) < resumeInterval) {
      return;
    }
    emit(SyncInProgress(account: current.account, lastSyncAt: last));
    try {
      await engine.sync(provider);
      emit(
        SyncUpToDate(
          account: current.account,
          lastSyncAt: await meta.readDate(SyncMetaKeys.lastSyncAt),
        ),
      );
    } on Object {
      emit(SyncFailed(account: current.account, lastSyncAt: last));
    }
  }

  Future<void> _onSignIn(Emitter<SyncState> emit) async {
    if (state is SyncConnected) return;
    final CloudAccount account;
    try {
      account = await provider.signIn();
    } on CloudSignInCancelled {
      emit(const SyncDisabled());
      return;
    } on Object {
      emit(const SyncDisabled(signInFailed: true));
      return;
    }
    await meta.write(SyncMetaKeys.provider, provider.id);
    await meta.write(SyncMetaKeys.accountEmail, account.email);
    emit(SyncUpToDate(account: account));
    await _sync(emit, SyncReason.manual);
  }

  Future<void> _onSignOut(Emitter<SyncState> emit) async {
    try {
      await provider.signOut();
    } on Object {
      // Signed out locally anyway.
    }
    await engine.reset();
    emit(const SyncDisabled());
  }
}
