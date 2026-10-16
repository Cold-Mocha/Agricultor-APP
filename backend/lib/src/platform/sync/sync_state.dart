enum EntitySyncState { pending, syncing, synced, error, conflict }

enum OutboxState { pending, sending, retryWait, blocked, conflict, done }

enum MutationKind { create, update, archive, delete, resolve }
