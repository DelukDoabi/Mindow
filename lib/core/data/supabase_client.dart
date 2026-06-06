import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_client.g.dart';

/// Exposes the initialized Supabase client to the rest of the app.
///
/// Reading this before `Supabase.initialize` has run (e.g. when no backend is
/// configured for the current flavor) will throw — call sites in feature code
/// are only reached after a configured session exists.
@Riverpod(keepAlive: true)
SupabaseClient supabaseClient(Ref ref) => Supabase.instance.client;
