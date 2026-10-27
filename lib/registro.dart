
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart' show buildAppTheme;
import 'home.dart' show TecHomeScreen;

const String registroCompletadoPreferenceKey = 'registro_completado';
const String cuentasUsuariosPreferenceKey = 'cuentas_usuarios';
const String _biometriaPreferencePrefix = 'firebase_biometria_';
const String _biometriaCredentialPrefix = 'firebase_credencial_';
const String _coleccionUsuarios = 'usuarios';
const FlutterSecureStorage _almacenSeguro = FlutterSecureStorage();

const List<String> _tiposUsuario = [
  'Estudiante',
  'Empleado',
  'Empresa',
  'Egresado',
];

class RegistroApp extends StatelessWidget {
  const RegistroApp({
    super.key,
    this.onRegistrationComplete,
  });

  final VoidCallback? onRegistrationComplete;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TEC Móvil',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(Brightness.light),
      home: RegistroPage(
        onRegistrationComplete: onRegistrationComplete,
      ),
    );
  }
}

class RegistroPage extends StatefulWidget {
  const RegistroPage({
    super.key,
    this.onRegistrationComplete,
  });

  final VoidCallback? onRegistrationComplete;

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _confirmarContrasenaController = TextEditingController();
  final _autenticacionLocal = LocalAuthentication();

  bool _mostrarContrasena = false;
  bool _mostrarRegistro = false;
  bool _procesando = false;
  bool _procesandoBiometria = false;
  bool _biometriaActivada = false;

  String _tipoUsuario = _tiposUsuario.first;

  bool get _biometriaMovilDisponible =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  void dispose() {
    _correoController.dispose();
    _contrasenaController.dispose();
    _confirmarContrasenaController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (_procesando ||
        _procesandoBiometria ||
        !_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _procesando = true);

    try {
      final correo = _correoController.text.trim().toLowerCase();
      final contrasena = _contrasenaController.text;

      if (_mostrarRegistro) {
        await _crearCuentaFirebase(
          correo: correo,
          contrasena: contrasena,
          tipoUsuario: _tipoUsuario,
        );

        var biometriaGuardada = !_biometriaActivada;
        if (_biometriaActivada) {
          try {
            await _guardarCredencialesBiometricas(
              correo: correo,
              contrasena: contrasena,
            );
            biometriaGuardada = true;
          } catch (error) {
            debugPrint('No se pudieron guardar credenciales biométricas: $error');
          }
        }

        try {
          await FirebaseAuth.instance.signOut();
        } catch (error) {
          debugPrint('No se pudo cerrar la sesión tras el registro: $error');
        }

        if (!mounted) return;

        _formKey.currentState?.reset();
        _correoController.text = correo;
        _contrasenaController.clear();
        _confirmarContrasenaController.clear();

        setState(() {
          _mostrarRegistro = false;
          _mostrarContrasena = false;
          _tipoUsuario = _tiposUsuario.first;
          _biometriaActivada = false;
          _procesando = false;
        });

        _mostrarMensaje(
          biometriaGuardada
              ? 'Cuenta creada correctamente. Ahora inicia sesión.'
              : 'Cuenta creada. Inicia sesión con tu contraseña; no se pudo guardar la opción biométrica.',
        );
        return;
      }

      final credencial = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: correo,
        password: contrasena,
      );

      final preferences = await SharedPreferences.getInstance();
      if (preferences.getBool(_clavePreferenciaBiometrica(correo)) == true) {
        try {
          await _guardarCredencialesBiometricas(
            correo: correo,
            contrasena: contrasena,
          );
        } catch (error) {
          debugPrint('No se pudieron actualizar credenciales biométricas: $error');
        }
      }

      if (credencial.user == null) {
        throw StateError('Firebase no devolvió el usuario autenticado.');
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      _mostrarMensaje(_mensajeErrorFirebase(error));
      return;
    } on FirebaseException catch (error) {
      if (!mounted) return;

      _mostrarMensaje(_mensajeErrorFirestore(error));
      return;
    } catch (error) {
      debugPrint('Error al iniciar sesión: $error');
      if (!mounted) return;

      _mostrarMensaje('No se pudo iniciar sesión. Inténtalo de nuevo.');
      return;
    }

    _completarInicioSesion();
  }

  Future<User> _crearCuentaFirebase({
    required String correo,
    required String contrasena,
    required String tipoUsuario,
  }) async {
    final credencial = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: correo,
      password: contrasena,
    );
    final usuario = credencial.user;

    if (usuario == null) {
      throw StateError('Firebase no devolvió el usuario registrado.');
    }

    try {
      await FirebaseFirestore.instance
          .collection(_coleccionUsuarios)
          .doc(usuario.uid)
          .set({
        'uid': usuario.uid,
        'correo': correo,
        'tipo': tipoUsuario,
        'fechaRegistro': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      try {
        await usuario.delete();
      } catch (error) {
        debugPrint('No se pudo revertir el registro incompleto: $error');
      }
      rethrow;
    }

    return usuario;
  }

  String _clavePreferenciaBiometrica(String correo) =>
      _biometriaPreferencePrefix +
      base64UrlEncode(utf8.encode(correo.trim().toLowerCase()))
          .replaceAll('=', '');

  String _claveCredencialBiometrica(String correo) =>
      _biometriaCredentialPrefix +
      base64UrlEncode(utf8.encode(correo.trim().toLowerCase()))
          .replaceAll('=', '');

  Future<void> _guardarCredencialesBiometricas({
    required String correo,
    required String contrasena,
  }) async {
    final clave = _claveCredencialBiometrica(correo);
    await _almacenSeguro.write(
      key: clave,
      value: jsonEncode({'correo': correo, 'contrasena': contrasena}),
    );

    final preferences = await SharedPreferences.getInstance();
    final guardada = await preferences.setBool(
      _clavePreferenciaBiometrica(correo),
      true,
    );
    if (!guardada) {
      await _almacenSeguro.delete(key: clave);
      throw StateError('No se pudo guardar la preferencia biométrica.');
    }
  }

  Future<void> _borrarCredencialesBiometricas(String correo) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_clavePreferenciaBiometrica(correo));
    await _almacenSeguro.delete(key: _claveCredencialBiometrica(correo));
  }

  String _mensajeErrorFirebase(FirebaseAuthException error) =>
      switch (error.code) {
        'email-already-in-use' =>
          'Ya existe una cuenta con ese correo. Inicia sesión.',
        'weak-password' =>
          'La contraseña es muy débil. Usa al menos 6 caracteres.',
        'invalid-email' => 'El correo no tiene un formato válido.',
        'invalid-credential' || 'wrong-password' || 'user-not-found' =>
          'El correo o la contraseña no son correctos.',
        'operation-not-allowed' =>
          'Activa el proveedor Correo/contraseña en Firebase Authentication.',
        'network-request-failed' =>
          'No hay conexión. Revisa tu internet e inténtalo de nuevo.',
        'too-many-requests' =>
          'Hubo muchos intentos. Espera un momento y vuelve a intentar.',
        _ => 'Firebase no pudo autenticar la cuenta (${error.code}).',
      };

  String _mensajeErrorFirestore(FirebaseException error) =>
      switch (error.code) {
        'permission-denied' =>
          'Firebase rechazó guardar el perfil. Revisa las reglas de Firestore.',
        'failed-precondition' || 'not-found' =>
          'Crea la base de datos de Cloud Firestore en Firebase Console.',
        'unavailable' =>
          'Firestore no está disponible. Revisa la conexión e inténtalo de nuevo.',
        _ => 'No se pudo guardar el perfil en Firestore (${error.code}).',
      };

  Future<void> _iniciarSesionBiometrico() async {
    if (_procesando || _procesandoBiometria) return;

    final correo = _correoController.text.trim().toLowerCase();

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(correo)) {
      _mostrarMensaje('Escribe primero el correo de tu cuenta.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _procesandoBiometria = true);

    try {
      final preferences = await SharedPreferences.getInstance();
      final biometriaActivada =
          preferences.getBool(_clavePreferenciaBiometrica(correo)) == true;
      if (!biometriaActivada) {
        _mostrarMensaje(
          'Activa los datos biométricos al crear tu cuenta en este dispositivo.',
        );
        return;
      }

      if (!await _verificarBiometriaDisponible()) return;

      final autenticado = await _autenticacionLocal.authenticate(
        localizedReason:
            'Confirma tu identidad para iniciar sesión en TEC Móvil.',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );

      if (!autenticado) {
        _mostrarMensaje(
          'No se confirmó tu identidad. Puedes usar tu contraseña.',
        );
        return;
      }

      final guardado = await _almacenSeguro.read(
        key: _claveCredencialBiometrica(correo),
      );
      if (guardado == null) {
        await _borrarCredencialesBiometricas(correo);
        _mostrarMensaje(
          'Vuelve a iniciar sesión con tu contraseña para configurar la biometría.',
        );
        return;
      }

      final datos = Map<String, dynamic>.from(jsonDecode(guardado) as Map);
      final correoGuardado = datos['correo'] as String?;
      final contrasenaGuardada = datos['contrasena'] as String?;
      if (correoGuardado == null ||
          contrasenaGuardada == null ||
          correoGuardado.toLowerCase() != correo) {
        await _borrarCredencialesBiometricas(correo);
        _mostrarMensaje(
          'Vuelve a iniciar sesión con tu contraseña para configurar la biometría.',
        );
        return;
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: correoGuardado,
        password: contrasenaGuardada,
      );
    } on LocalAuthException catch (error) {
      if (!mounted) return;

      _mostrarMensaje(_mensajeErrorBiometrico(error, activando: false));
      return;
    } on FirebaseAuthException catch (error) {
      if (error.code == 'invalid-credential' ||
          error.code == 'wrong-password' ||
          error.code == 'user-not-found') {
        await _borrarCredencialesBiometricas(correo);
      }
      if (!mounted) return;

      _mostrarMensaje(_mensajeErrorFirebase(error));
      return;
    } catch (error) {
      debugPrint('Error de inicio biométrico: $error');
      if (!mounted) return;

      _mostrarMensaje(
        'No se pudo iniciar con biometría. Inténtalo con tu contraseña.',
      );
      return;
    } finally {
      if (mounted) {
        setState(() => _procesandoBiometria = false);
      }
    }

    _completarInicioSesion();
  }

  void _completarInicioSesion() {
    if (!mounted) return;

    HapticFeedback.selectionClick();

    final callback = widget.onRegistrationComplete;

    if (callback != null) {
      setState(() => _procesando = false);
      callback();
      return;
    }

    Navigator.of(context).pushAndRemoveUntil<void>(
      MaterialPageRoute<void>(
        builder: (_) => const TecHomeScreen(),
      ),
      (route) => false,
    );
  }

  Future<void> _cambiarAccesoBiometrico(bool activar) async {
    if (!activar) {
      setState(() => _biometriaActivada = false);
      return;
    }

    if (_procesando || _procesandoBiometria) return;

    setState(() => _procesandoBiometria = true);

    try {
      if (!await _verificarBiometriaDisponible()) return;

      final autenticado = await _autenticacionLocal.authenticate(
        localizedReason:
            'Confirma tu identidad para activar los datos biométricos.',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );

      if (!mounted) return;

      if (autenticado) {
        setState(() => _biometriaActivada = true);

        _mostrarMensaje(
          'Datos biométricos activados para esta cuenta.',
        );
      } else {
        _mostrarMensaje(
          'No se activaron. Puedes continuar con tu contraseña.',
        );
      }
    } on LocalAuthException catch (error) {
      if (mounted) {
        _mostrarMensaje(
          _mensajeErrorBiometrico(error, activando: true),
        );
      }
    } catch (_) {
      if (mounted) {
        _mostrarMensaje(
          'No se pudo activar la biometría. Inténtalo de nuevo.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _procesandoBiometria = false);
      }
    }
  }

  Future<bool> _verificarBiometriaDisponible() async {
    if (!_biometriaMovilDisponible) {
      _mostrarMensaje(
        'Los datos biométricos están disponibles en Android o iPhone.',
      );
      return false;
    }

    final tieneHardware =
        await _autenticacionLocal.canCheckBiometrics;

    if (!tieneHardware) {
      _mostrarMensaje(
        'Este dispositivo no dispone de un lector biométrico compatible.',
      );
      return false;
    }

    final biometriaRegistrada =
        await _autenticacionLocal.getAvailableBiometrics();

    if (biometriaRegistrada.isEmpty) {
      _mostrarMensaje(
        'Registra una huella o el reconocimiento facial en los ajustes '
        'del teléfono antes de continuar.',
      );
      return false;
    }

    return true;
  }

  String _mensajeErrorBiometrico(
    LocalAuthException error, {
    required bool activando,
  }) {
    final accion = activando ? 'activar' : 'iniciar sesión';

    return switch (error.code) {
      LocalAuthExceptionCode.noBiometricHardware =>
        'Este dispositivo no tiene lector biométrico compatible.',
      LocalAuthExceptionCode.noBiometricsEnrolled =>
        'Registra una huella o el reconocimiento facial en los ajustes.',
      LocalAuthExceptionCode.noCredentialsSet =>
        'Configura primero el bloqueo de pantalla del dispositivo.',
      LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable =>
        'El lector biométrico no está disponible en este momento.',
      LocalAuthExceptionCode.temporaryLockout ||
      LocalAuthExceptionCode.biometricLockout =>
        'La biometría está bloqueada temporalmente. Inténtalo más tarde.',
      LocalAuthExceptionCode.userCanceled ||
      LocalAuthExceptionCode.systemCanceled =>
        'Cancelaste la verificación. Puedes usar tu contraseña.',
      LocalAuthExceptionCode.uiUnavailable =>
        'No se pudo mostrar la verificación. Vuelve a abrir la aplicación.',
      _ =>
        'No se pudo $accion con biometría. Puedes usar tu contraseña.',
    };
  }

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;

    setState(() => _procesando = false);

    final texto = mensaje.toLowerCase();
    final esExito = texto.contains('correctamente') ||
        texto.contains('activados para esta cuenta');
    final esError = texto.contains('no encontramos') ||
        texto.contains('no son correctos') ||
        texto.contains('no se pudo') ||
        texto.contains('no se confirmó') ||
        texto.contains('no se activaron') ||
        texto.contains('no dispone') ||
        texto.contains('no tiene lector') ||
        texto.contains('bloqueada') ||
        texto.contains('registra una huella') ||
        texto.contains('configura primero');

    final Color color = esExito
        ? const Color(0xFF168568)
        : esError
            ? const Color(0xFFB84B61)
            : const Color(0xFF287BB1);
    final IconData icono = esExito
        ? Icons.check_circle_rounded
        : esError
            ? Icons.info_rounded
            : Icons.fingerprint_rounded;
    final String titulo = esExito
        ? '¡Todo listo!'
        : esError
            ? 'Revisa esta información'
            : 'Aviso de TEC Móvil';

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 22, sigmaY: 22),
              child: Container(
                padding: const EdgeInsets.fromLTRB(25, 28, 25, 22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xF2F4FAFF),
                      Color(0xF0DCEAF7),
                      Color(0xF2EAF3FC),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.88),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF07142B)
                          .withValues(alpha: 0.28),
                      blurRadius: 35,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            color.withValues(alpha: 0.18),
                            color.withValues(alpha: 0.08),
                          ],
                        ),
                        border: Border.all(
                          color: color.withValues(alpha: 0.20),
                        ),
                      ),
                      child: Icon(icono, color: color, size: 38),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      titulo,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF173A5C),
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      mensaje,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF47627D),
                        fontSize: 13,
                        height: 1.55,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 23),
                    SizedBox(
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF3DA9E8),
                              Color(0xFF315FD1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3289E7)
                                  .withValues(alpha: 0.22),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: TextButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          child: const Text(
                            'ENTENDIDO',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _alternarFormulario() {
    if (_procesando || _procesandoBiometria) return;

    _formKey.currentState?.reset();
    _correoController.clear();
    _contrasenaController.clear();
    _confirmarContrasenaController.clear();

    setState(() {
      _mostrarRegistro = !_mostrarRegistro;
      _mostrarContrasena = false;
      _tipoUsuario = _tiposUsuario.first;
      _biometriaActivada = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF101A32),
                  Color(0xFF203D63),
                  Color(0xFF315E87),
                ],
                stops: [0, 0.55, 1],
              ),
            ),
          ),
          Positioned(
            top: -210,
            left: -230,
            child: _brillo(
              450,
              const [
                Color(0x6659D8FF),
                Color(0x0059D8FF),
              ],
            ),
          ),
          Positioned(
            bottom: -230,
            right: -220,
            child: _brillo(
              500,
              const [
                Color(0x554D8CFF),
                Color(0x004D8CFF),
              ],
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 28,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 390),
                  child: _tarjetaLogin(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _brillo(double size, List<Color> colors) {
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(
        sigmaX: 42,
        sigmaY: 42,
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }

  Widget _tarjetaLogin() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 46),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF07142B)
                      .withValues(alpha: 0.38),
                  blurRadius: 38,
                  offset: const Offset(0, 19),
                ),
                BoxShadow(
                  color: const Color(0xFF7AE4FF)
                      .withValues(alpha: 0.20),
                  blurRadius: 28,
                  spreadRadius: -7,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(34),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(
                  sigmaX: 25,
                  sigmaY: 25,
                ),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(
                    25,
                    72,
                    25,
                    24,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xD9EAF8FF),
                        Color(0xB8C5E0F2),
                        Color(0xD9D8EBFA),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(34),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.78),
                      width: 1.3,
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _mostrarRegistro
                              ? 'Crear cuenta'
                              : 'Inicia sesión',
                          style: const TextStyle(
                            color: Color(0xFF173A5C),
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          _mostrarRegistro
                              ? 'Únete a TEC Móvil y continúa tu formación.'
                              : 'Tu formación, un mismo camino.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF47627D),
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        _campo(
                          controller: _correoController,
                          hint: 'Correo electrónico',
                          icono: Icons.alternate_email_rounded,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [
                            AutofillHints.email,
                          ],
                          validator: (value) {
                            final correo = value?.trim() ?? '';

                            if (correo.isEmpty) {
                              return 'Escribe tu correo electrónico.';
                            }

                            if (!RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            ).hasMatch(correo)) {
                              return 'Revisa el formato del correo.';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 13),

                        _campo(
                          controller: _contrasenaController,
                          hint: 'Contraseña',
                          icono: Icons.lock_outline_rounded,
                          obscure: !_mostrarContrasena,
                          autofillHints: const [
                            AutofillHints.password,
                          ],
                          textInputAction: _mostrarRegistro
                              ? TextInputAction.next
                              : TextInputAction.done,
                          onSubmitted: _mostrarRegistro
                              ? null
                              : (_) => _iniciarSesion(),
                          suffix: _botonMostrarContrasena(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa tu contraseña.';
                            }

                            if (_mostrarRegistro &&
                                value.length < 8) {
                              return 'Usa al menos 8 caracteres.';
                            }

                            return null;
                          },
                        ),

                        if (_mostrarRegistro) ...[
                          const SizedBox(height: 13),
                          _campo(
                            controller:
                                _confirmarContrasenaController,
                            hint: 'Confirmar contraseña',
                            icono: Icons.verified_user_outlined,
                            obscure: !_mostrarContrasena,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _iniciarSesion(),
                            suffix: _botonMostrarContrasena(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Confirma tu contraseña.';
                              }

                              if (value !=
                                  _contrasenaController.text) {
                                return 'Las contraseñas no coinciden.';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _selectorTipoUsuario(),
                          const SizedBox(height: 12),
                          _selectorBiometria(),
                        ],

                        const SizedBox(height: 22),
                        _botonInicio(),

                        if (!_mostrarRegistro) ...[
                          const SizedBox(height: 12),
                          _botonBiometrico(),
                        ],

                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(
                                color: Color(0x55476B8B),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                _mostrarRegistro
                                    ? '¿YA TIENES CUENTA?'
                                    : '¿ERES NUEVO EN TEC MÓVIL?',
                                style: const TextStyle(
                                  color: Color(0xFF58718A),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(
                                color: Color(0x55476B8B),
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed:
                              _procesando || _procesandoBiometria
                              ? null
                              : _alternarFormulario,
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF245C91),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          child: Text(
                            _mostrarRegistro
                                ? 'Iniciar sesión'
                                : 'Crear una cuenta',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              size: 14,
                              color: Color(0xFF58718A),
                            ),
                            SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Acceso protegido desde tu dispositivo',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF58718A),
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          child: _avatar(),
        ),
      ],
    );
  }

  Widget _avatar() {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7CE7FF),
            Color(0xFF397FE3),
            Color(0xFF234DAB),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.92),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C69CF)
                .withValues(alpha: 0.38),
            blurRadius: 25,
            offset: const Offset(0, 11),
          ),
          BoxShadow(
            color: const Color(0xFF7BE9FF)
                .withValues(alpha: 0.30),
            blurRadius: 25,
          ),
        ],
      ),
      child: const Icon(
        Icons.person_outline_rounded,
        color: Colors.white,
        size: 51,
      ),
    );
  }

  Widget _selectorTipoUsuario() {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: Colors.white.withValues(alpha: 0.82),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Tipo de usuario',
            style: TextStyle(
              color: Color(0xFF344D69),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        DropdownButtonFormField<String>(
          initialValue: _tipoUsuario,
          isExpanded: true,
          icon: const Icon(Icons.expand_more_rounded),
          dropdownColor: const Color(0xFFEAF4FB),
          style: const TextStyle(
            color: Color(0xFF173A5C),
            fontSize: 13,
          ),
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.badge_outlined,
              size: 20,
            ),
            filled: true,
            fillColor: const Color(0xFFDCECF7)
                .withValues(alpha: 0.84),
            prefixIconColor: const Color(0xFF315C7D),
            border: border,
            enabledBorder: border,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF287BB1),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
          items: _tiposUsuario
              .map(
                (tipo) => DropdownMenuItem<String>(
                  value: tipo,
                  child: Text(tipo),
                ),
              )
              .toList(),
          onChanged: _procesando
              ? null
              : (tipo) {
                  if (tipo != null) {
                    setState(() => _tipoUsuario = tipo);
                  }
                },
        ),
      ],
    );
  }

  Widget _selectorBiometria() {
    return Material(
      color: const Color(0xFFDCECF7).withValues(alpha: 0.64),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.82),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: CheckboxListTile(
        value: _biometriaActivada,
        onChanged:
            !_biometriaMovilDisponible ||
                _procesando ||
                _procesandoBiometria
            ? null
            : (value) {
                if (value != null) {
                  _cambiarAccesoBiometrico(value);
                }
              },
        activeColor: const Color(0xFF287DCA),
        checkColor: Colors.white,
        controlAffinity: ListTileControlAffinity.trailing,
        secondary: _procesandoBiometria
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : const Icon(
                Icons.fingerprint_rounded,
                color: Color(0xFF315C7D),
                size: 28,
              ),
        title: const Text(
          'Activar datos biométricos',
          style: TextStyle(
            color: Color(0xFF173A5C),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: const Text(
          'Usa la huella o el reconocimiento facial de tu teléfono '
          'para iniciar sesión.',
          style: TextStyle(
            color: Color(0xFF47627D),
            fontSize: 10,
            height: 1.4,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 7,
        ),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _botonBiometrico() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed:
            !_biometriaMovilDisponible ||
                _procesando ||
                _procesandoBiometria
            ? null
            : _iniciarSesionBiometrico,
        icon: _procesandoBiometria
            ? const SizedBox(
                width: 19,
                height: 19,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : const Icon(
                Icons.fingerprint_rounded,
                size: 23,
              ),
        label: Text(
          _procesandoBiometria
              ? 'Verificando identidad...'
              : 'Iniciar con datos biométricos',
          textAlign: TextAlign.center,
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF24547F),
          backgroundColor: Colors.white.withValues(alpha: 0.35),
          disabledForegroundColor: const Color(0xFF70869A),
          side: BorderSide(
            color: const Color(0xFF315C85)
                .withValues(alpha: 0.38),
          ),
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _botonMostrarContrasena() {
    return IconButton(
      tooltip: _mostrarContrasena
          ? 'Ocultar contraseña'
          : 'Mostrar contraseña',
      onPressed: () {
        setState(() {
          _mostrarContrasena = !_mostrarContrasena;
        });
      },
      visualDensity: VisualDensity.compact,
      icon: Icon(
        _mostrarContrasena
            ? Icons.visibility_off_outlined
            : Icons.visibility_outlined,
        color: const Color(0xFF3D7097),
        size: 19,
      ),
    );
  }

  Widget _botonInicio() {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        onTap:
            _procesando || _procesandoBiometria
            ? null
            : _iniciarSesion,
        borderRadius: BorderRadius.circular(25),
        splashColor: Colors.white.withValues(alpha: 0.24),
        child: Container(
          width: double.infinity,
          height: 49,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF59D9F2),
                Color(0xFF3489E8),
                Color(0xFF365FD1),
              ],
              stops: [0, 0.53, 1],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3289E7)
                    .withValues(alpha: 0.30),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: _procesando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _mostrarRegistro
                          ? Icons.person_add_alt_1_rounded
                          : Icons.login_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                    const SizedBox(width: 9),
                    Text(
                      _mostrarRegistro
                          ? 'CREAR CUENTA'
                          : 'INICIAR SESIÓN',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String hint,
    required IconData icono,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    bool obscure = false,
    List<String>? autofillHints,
    Widget? suffix,
    ValueChanged<String>? onSubmitted,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: Colors.white.withValues(alpha: 0.82),
      ),
    );

    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: Color(0xFFB34B62),
        width: 1.2,
      ),
    );

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: TextCapitalization.none,
      autofillHints: autofillHints,
      autocorrect: false,
      obscureText: obscure,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      cursorColor: const Color(0xFF287BB1),
      style: const TextStyle(
        color: Color(0xFF173A5C),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icono, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFDCECF7)
            .withValues(alpha: 0.84),
        hintStyle: const TextStyle(
          color: Color(0xFF647C93),
          fontSize: 12,
        ),
        errorStyle: const TextStyle(
          color: Color(0xFF96394E),
          fontSize: 10,
          height: 1.25,
          fontWeight: FontWeight.w500,
        ),
        errorMaxLines: 2,
        prefixIconColor: const Color(0xFF315C7D),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF287BB1),
            width: 1.5,
          ),
        ),
        errorBorder: errorBorder,
        focusedErrorBorder: errorBorder,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
        ),
      ),
    );
  }
}
