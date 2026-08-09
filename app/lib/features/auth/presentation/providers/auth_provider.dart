// ignore_for_file: deprecated_member_use_from_same_package
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_config.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  SupabaseClient get _client => Supabase.instance.client;

  // serverClientId makes Google include an idToken (required for Supabase).
  late final _googleSignIn = GoogleSignIn(
    clientId: (Platform.isIOS || Platform.isMacOS)
        ? AppConfig.googleClientIdIos
        : null,
    serverClientId: AppConfig.googleClientIdWeb,
  );

  @override
  Stream<User?> build() {
    if (!AppConfig.isConfigured) return const Stream.empty();
    return _client.auth.onAuthStateChange
        .map((event) => event.session?.user);
  }

  void _assertConfigured() {
    if (!AppConfig.isConfigured) {
      throw Exception(
        'Supabase is not configured. '
        'Run the app with: flutter run --dart-define-from-file=env.json\n'
        'Or select a launch configuration in VS Code (F5).',
      );
    }
  }

  // ── Apple ─────────────────────────────────────────────────────────────────

  Future<void> signInWithApple() async {
    _assertConfigured();
    final rawNonce = _generateNonce();
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: _sha256(rawNonce),
    );
    final idToken = credential.identityToken;
    if (idToken == null) {
      throw Exception(
        'Apple did not return an identity token. '
        'Sign in with Apple requires a real device (not a simulator) '
        'and the capability must be enabled in your Apple Developer account.',
      );
    }

    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: rawNonce,
    );
  }

  // ── Google ────────────────────────────────────────────────────────────────

  Future<void> signInWithGoogle() async {
    _assertConfigured();
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return; // user cancelled

    final googleAuth = await googleUser.authentication;

    final idToken = googleAuth.idToken;
    if (idToken == null) {
      throw Exception(
        'Google did not return an ID token. '
        'Verify that GOOGLE_CLIENT_ID_WEB in env.json matches the '
        '"Web application" OAuth client in Google Cloud Console, '
        'and that the iOS OAuth client has the correct bundle ID.',
      );
    }

    // Google Sign-In on iOS doesn't use nonce flow - just pass the token directly
    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: googleAuth.accessToken,
    );
  }

  // ── Sign out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _client.auth.signOut();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _generateNonce([int length = 32]) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._';
    final rng = Random.secure();
    return List.generate(length, (_) => chars[rng.nextInt(chars.length)])
        .join();
  }

  String _sha256(String input) =>
      sha256.convert(utf8.encode(input)).toString();
}

/// Convenience provider — null means signed out or still loading.
@riverpod
User? currentUser(CurrentUserRef ref) =>
    ref.watch(authNotifierProvider).valueOrNull;
