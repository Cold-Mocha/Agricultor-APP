import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/modules/auth/presentation/controllers/session_controller.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_status_banner.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

final class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

final class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider);
    final loading = session.status == SessionStatus.restoring;
    final locked = session.status == SessionStatus.locked;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AgroSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          LucideIcons.sprout,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AgroSpacing.md),
                    Text(
                      'AGROCAMPO',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            letterSpacing: 2,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: AgroSpacing.xs),
                    Text(
                      'Tu cuaderno de campo',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (session.message case final message?) ...[
                      const SizedBox(height: AgroSpacing.md),
                      AgroStatusBanner(
                        message: message,
                        status: AgroStatus.error,
                      ),
                    ],
                    const SizedBox(height: AgroSpacing.lg),
                    if (locked) ...[
                      FilledButton.icon(
                        onPressed: loading
                            ? null
                            : () => ref
                                  .read(sessionControllerProvider.notifier)
                                  .unlockWithBiometrics(),
                        icon: const Icon(LucideIcons.fingerprint),
                        label: const Text('Desbloquear con biometría'),
                      ),
                      const SizedBox(height: AgroSpacing.sm),
                      const Text(
                        'También puedes ingresar nuevamente con tu usuario y PIN.',
                      ),
                      const SizedBox(height: AgroSpacing.lg),
                    ],
                    const _FieldLabel('Usuario'),
                    TextFormField(
                      controller: _email,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                      decoration: const InputDecoration(
                        prefixIcon: Icon(LucideIcons.user),
                      ),
                      validator: (value) =>
                          value != null && value.trim().isNotEmpty
                          ? null
                          : 'Ingresa tu usuario.',
                    ),
                    const SizedBox(height: AgroSpacing.md),
                    const _FieldLabel('PIN'),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      // The PIN is exactly six digits.
                      maxLength: 6,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      autofillHints: const [AutofillHints.password],
                      decoration: const InputDecoration(
                        hintText: '6 dígitos',
                        counterText: '',
                        prefixIcon: Icon(LucideIcons.lock),
                      ),
                      validator: (value) =>
                          value != null && RegExp(r'^\d{6}$').hasMatch(value)
                          ? null
                          : 'El PIN tiene 6 dígitos.',
                    ),
                    const SizedBox(height: AgroSpacing.lg),
                    FilledButton(
                      onPressed: loading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                ref
                                    .read(sessionControllerProvider.notifier)
                                    .signIn(
                                      email: accountEmail(_email.text),
                                      password: _password.text,
                                    );
                              }
                            },
                      child: Text(loading ? 'Ingresando…' : 'Ingresar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Supabase signs in by email; the single account is addressed by a short
/// user name such as "Mario", which maps to `mario@agrocampo.app`.
String accountEmail(String user) {
  final value = user.trim().toLowerCase();
  return value.contains('@') ? value : '$value@agrocampo.app';
}

final class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(
      left: AgroSpacing.xxs,
      bottom: AgroSpacing.xs,
    ),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );
}
