import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:agrocampo/features/auth/domain/session_state.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/shared/presentation/components/agro_status_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final loading = session.status == SessionStatus.checking;
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
                    Text(
                      'AGROCAMPO',
                      style: Theme.of(context).textTheme.labelLarge
                          ?.copyWith(letterSpacing: .7),
                    ),
                    const SizedBox(height: AgroSpacing.xs),
                    Text(
                      'Acceso',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: AgroSpacing.xs),
                    const Text(
                      'El primer acceso requiere conexión. Después podrás consultar tus datos locales sin internet.',
                    ),
                    if (session.message case final message?) ...[
                      const SizedBox(height: AgroSpacing.md),
                      AgroStatusBanner(
                        message: message,
                        status: AgroStatus.error,
                      ),
                    ],
                    const SizedBox(height: AgroSpacing.lg),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                      ),
                      validator: (value) => value != null && value.contains('@')
                          ? null
                          : 'Ingresa un correo válido.',
                    ),
                    const SizedBox(height: AgroSpacing.sm),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                      ),
                      validator: (value) => value != null && value.length >= 8
                          ? null
                          : 'Usa al menos 8 caracteres.',
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
                                      email: _email.text,
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
