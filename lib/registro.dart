import 'dart:convert';
import 'dart:math' as math;
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

const Color _fondoOscuro = Color(0xFF071426);
const Color _azulProfundo = Color(0xFF12345A);
const Color _azulBrillante = Color(0xFF47C9F5);
const Color _azulHielo = Color(0xFF9AF3FF);
const Color _textoOscuro = Color(0xFF153653);
const Color _textoSecundario = Color(0xFF526E88);

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

class _RegistroPageState extends State<RegistroPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _confirmarContrasenaController = TextEditingController();
  final _autenticacionLocal = LocalAuthentication();

  late final AnimationController _liquidController;
  late final AnimationController _entradaController;

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
  void initState() {
    super.initState();

    _liquidController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _entradaController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();
  }

  @override
  void dispose() {
    _liquidController.dispose();
    _entradaController.dispose();
    _correoController.dispose();
    _contrasenaController.dispose();
    _confirmarContrasenaController.dispose();
    super.dispose();
  }

  String _clavePreferenciaBiometrica(String correo) =>
      _biometriaPreferencePrefix +
      base64UrlEncode(
        utf8.encode(correo.trim().toLowerCase()),
      ).replaceAll('=', '');

  String _claveCredencialBiometrica(String correo) =>
      _biometriaCredentialPrefix +
      base64UrlEncode(
        utf8.encode(correo.trim().toLowerCase()),
      ).replaceAll('=', '');

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
            debugPrint('Error al guardar biometría: $error');
          }
        }

        try {
          await FirebaseAuth.instance.signOut();
        } catch (error) {
          debugPrint('Error al cerrar sesión: $error');
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

        await _mostrarConfirmacionRegistro(
          biometriaGuardada: biometriaGuardada,
        );
        return;
      }

      final credencial =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: correo,
        password: contrasena,
      );

      final preferences = await SharedPreferences.getInstance();

      if (preferences.getBool(_clavePreferenciaBiometrica(correo)) ==
          true) {
        try {
          await _guardarCredencialesBiometricas(
            correo: correo,
            contrasena: contrasena,
          );
        } catch (error) {
          debugPrint('Error al actualizar biometría: $error');
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
      debugPrint('Error de inicio de sesión: $error');
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
    final credencial =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: correo.trim(),
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
        'correo': correo.trim(),
        'tipo': tipoUsuario,
        'fechaRegistro': FieldValue.serverTimestamp(),
        'correoVerificado': false,
      });

      await usuario.sendEmailVerification();

      debugPrint('Correo de verificación enviado a ${usuario.email}');
    } catch (error) {
      debugPrint('Error al guardar los datos o enviar el correo: $error');

      if (error is FirebaseException) {
        try {
          await FirebaseFirestore.instance
              .collection(_coleccionUsuarios)
              .doc(usuario.uid)
              .delete();
          await usuario.delete();
        } catch (errorAlRevertir) {
          debugPrint(
            'No se pudo revertir el registro: $errorAlRevertir',
          );
        }
      }

      rethrow;
    }

    return usuario;
  }

  Future<void> _guardarCredencialesBiometricas({
    required String correo,
    required String contrasena,
  }) async {
    final clave = _claveCredencialBiometrica(correo);

    await _almacenSeguro.write(
      key: clave,
      value: jsonEncode({
        'correo': correo,
        'contrasena': contrasena,
      }),
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
    await _almacenSeguro.delete(
      key: _claveCredencialBiometrica(correo),
    );
  }

  String _mensajeErrorFirebase(FirebaseAuthException error) =>
      switch (error.code) {
        'email-already-in-use' =>
          'Ya existe una cuenta con ese correo. Inicia sesión.',
        'weak-password' =>
          'La contraseña es muy débil. Usa al menos 8 caracteres.',
        'invalid-email' => 'El correo no tiene un formato válido.',
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' =>
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
          'Firestore no está disponible. Revisa tu conexión.',
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

      final activada =
          preferences.getBool(_clavePreferenciaBiometrica(correo)) == true;

      if (!activada) {
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
          'Inicia sesión con tu contraseña para configurar la biometría.',
        );
        return;
      }

      final datos = Map<String, dynamic>.from(
        jsonDecode(guardado) as Map,
      );

      final correoGuardado = datos['correo'] as String?;
      final contrasenaGuardada = datos['contrasena'] as String?;

      if (correoGuardado == null ||
          contrasenaGuardada == null ||
          correoGuardado.toLowerCase() != correo) {
        await _borrarCredencialesBiometricas(correo);
        _mostrarMensaje(
          'Inicia sesión con tu contraseña para configurar la biometría.',
        );
        return;
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: correoGuardado,
        password: contrasenaGuardada,
      );
    } on LocalAuthException catch (error) {
      if (!mounted) return;
      _mostrarMensaje(_mensajeErrorBiometrico(error));
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
      debugPrint('Error biométrico: $error');
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
        _mostrarMensaje('Datos biométricos activados para esta cuenta.');
      } else {
        _mostrarMensaje(
          'No se activaron. Puedes continuar con tu contraseña.',
        );
      }
    } on LocalAuthException catch (error) {
      if (mounted) {
        _mostrarMensaje(_mensajeErrorBiometrico(error));
      }
    } catch (error) {
      debugPrint('Error activando biometría: $error');
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

    final tieneHardware = await _autenticacionLocal.canCheckBiometrics;

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
        'Registra una huella o el reconocimiento facial en los ajustes del teléfono.',
      );
      return false;
    }

    return true;
  }

  String _mensajeErrorBiometrico(LocalAuthException error) =>
      switch (error.code) {
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
        _ => 'No se pudo completar la verificación biométrica.',
      };

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

    _entradaController.forward(from: 0);
  }

  Future<void> _mostrarConfirmacionRegistro({
    required bool biometriaGuardada,
  }) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(
                sigmaX: 24,
                sigmaY: 24,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(25, 28, 25, 22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xF5F7FCFF),
                      Color(0xE4D8EAF9),
                      Color(0xF0ECF5FF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.90),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _fondoOscuro.withValues(alpha: 0.30),
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
                        color: const Color(0xFF168568)
                            .withValues(alpha: 0.12),
                        border: Border.all(
                          color: const Color(0xFF168568)
                              .withValues(alpha: 0.24),
                        ),
                      ),
                      child: const Icon(
                        Icons.mark_email_read_rounded,
                        color: Color(0xFF168568),
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      '¡Registro exitoso!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _textoOscuro,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      biometriaGuardada
                          ? 'Tu cuenta de TEC Móvil se creó correctamente.\n\n'
                              'Te enviamos un correo para verificar tu dirección. '
                              'Revisá tu bandeja de entrada y la carpeta de spam.\n\n'
                              'Presioná CONFIRMAR para continuar al inicio de sesión.'
                          : 'Tu cuenta se creó correctamente, pero no se pudo '
                              'guardar el acceso biométrico.\n\n'
                              'Te enviamos un correo para verificar tu dirección. '
                              'Revisá tu bandeja de entrada y la carpeta de spam.\n\n'
                              'Presioná CONFIRMAR para continuar al inicio de sesión.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _textoSecundario,
                        fontSize: 13,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _botonVidrio(
                      texto: 'CONFIRMAR',
                      icono: Icons.check_circle_outline_rounded,
                      onTap: () {
                        Navigator.of(dialogContext).pop();
                      },
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

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;

    setState(() => _procesando = false);

    final texto = mensaje.toLowerCase();

    final esExito = texto.contains('correctamente') ||
        texto.contains('activados para esta cuenta');

    final esError = texto.contains('no se pudo') ||
        texto.contains('no son correctos') ||
        texto.contains('no se confirmó') ||
        texto.contains('no se activaron') ||
        texto.contains('no dispone') ||
        texto.contains('no tiene lector') ||
        texto.contains('bloqueada') ||
        texto.contains('registra una huella') ||
        texto.contains('configura primero');

    final color = esExito
        ? const Color(0xFF168568)
        : esError
            ? const Color(0xFFB84B61)
            : const Color(0xFF287BB1);

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
              filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                padding: const EdgeInsets.fromLTRB(25, 28, 25, 22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xF5F7FCFF),
                      Color(0xE4D8EAF9),
                      Color(0xF0ECF5FF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.90),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _fondoOscuro.withValues(alpha: 0.30),
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
                        color: color.withValues(alpha: 0.12),
                        border: Border.all(
                          color: color.withValues(alpha: 0.24),
                        ),
                      ),
                      child: Icon(
                        esExito
                            ? Icons.check_circle_rounded
                            : esError
                                ? Icons.info_rounded
                                : Icons.fingerprint_rounded,
                        color: color,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      esExito
                          ? '¡Todo listo!'
                          : esError
                              ? 'Revisa esta información'
                              : 'Aviso de TEC Móvil',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _textoOscuro,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      mensaje,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _textoSecundario,
                        fontSize: 13,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 23),
                    _botonVidrio(
                      texto: 'ENTENDIDO',
                      icono: Icons.check_rounded,
                      onTap: () => Navigator.of(dialogContext).pop(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondoOscuro,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF06101F),
                  Color(0xFF102C4D),
                  Color(0xFF173D64),
                  Color(0xFF08192E),
                ],
                stops: [0, 0.36, 0.70, 1],
              ),
            ),
          ),
          Positioned(
            top: -200,
            left: -220,
            child: _brillo(
              470,
              const [
                Color(0xB34DDCFF),
                Color(0x4450A9FF),
                Color(0x0050A9FF),
              ],
              velocidad: 1,
            ),
          ),
          Positioned(
            top: 180,
            right: -270,
            child: _brillo(
              520,
              const [
                Color(0x887D83FF),
                Color(0x3364BFFF),
                Color(0x0064BFFF),
              ],
              velocidad: -0.75,
            ),
          ),
          Positioned(
            bottom: -280,
            left: -130,
            child: _brillo(
              540,
              const [
                Color(0x8871EFFF),
                Color(0x3348A5FF),
                Color(0x0048A5FF),
              ],
              velocidad: 0.65,
            ),
          ),
          AnimatedBuilder(
            animation: _liquidController,
            builder: (context, child) {
              final t = _liquidController.value * math.pi * 2;

              return Stack(
                children: [
                  Positioned(
                    top: MediaQuery.sizeOf(context).height * 0.22 +
                        math.sin(t) * 12,
                    right: 42,
                    child: _destello(5, 0.45 + 0.45 * math.sin(t)),
                  ),
                  Positioned(
                    bottom: MediaQuery.sizeOf(context).height * 0.23 +
                        math.cos(t) * 16,
                    left: 34,
                    child: _destello(4, 0.45 + 0.45 * math.cos(t)),
                  ),
                ],
              );
            },
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 410),
                  child: _tarjetaLogin(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _destello(double size, double intensidad) {
    return Opacity(
      opacity: intensidad.clamp(0.1, 1.0),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _azulHielo,
          boxShadow: [
            BoxShadow(
              color: _azulBrillante.withValues(alpha: 0.75),
              blurRadius: 15,
              spreadRadius: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _brillo(
    double size,
    List<Color> colors, {
    double velocidad = 1,
  }) {
    return AnimatedBuilder(
      animation: _liquidController,
      child: ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: 48, sigmaY: 48),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: colors,
              stops: const [0, 0.55, 1],
            ),
          ),
        ),
      ),
      builder: (context, child) {
        final fase =
            _liquidController.value * math.pi * 2 * velocidad;

        return Transform.translate(
          offset: Offset(
            math.sin(fase) * 30,
            math.cos(fase * 0.72) * 26,
          ),
          child: Transform.scale(
            scale: 1 + math.sin(fase) * 0.055,
            child: child,
          ),
        );
      },
    );
  }

  Widget _tarjetaLogin() {
    return AnimatedBuilder(
      animation: _entradaController,
      builder: (context, child) {
        final progreso = Curves.easeOutCubic.transform(
          _entradaController.value,
        );

        return Opacity(
          opacity: progreso,
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - progreso)),
            child: Transform.scale(
              scale: 0.975 + progreso * 0.025,
              child: child,
            ),
          ),
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 48),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF000814)
                        .withValues(alpha: 0.34),
                    blurRadius: 48,
                    offset: const Offset(0, 24),
                  ),
                  BoxShadow(
                    color: _azulBrillante.withValues(alpha: 0.18),
                    blurRadius: 35,
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(
                    sigmaX: 28,
                    sigmaY: 28,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xEFFFFFFF),
                          Color(0xDCEAF7FF),
                          Color(0xC9C6E1F8),
                          Color(0xE8E9F5FF),
                        ],
                        stops: [0, 0.32, 0.68, 1],
                      ),
                      borderRadius: BorderRadius.circular(35),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.88),
                        width: 1.5,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: IgnorePointer(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(34),
                              child: AnimatedBuilder(
                                animation: _liquidController,
                                builder: (context, child) {
                                  final t = _liquidController.value;

                                  return LayoutBuilder(
                                    builder: (context, constraints) {
                                      final ancho =
                                          constraints.maxWidth;

                                      return Stack(
                                        children: [
                                          Positioned(
                                            left: (t * (ancho + 300)) -
                                                300,
                                            top: -100,
                                            bottom: -100,
                                            width: 135,
                                            child: Transform.rotate(
                                              angle: -0.22,
                                              child: DecoratedBox(
                                                decoration:
                                                    BoxDecoration(
                                                  gradient:
                                                      LinearGradient(
                                                    begin:
                                                        Alignment.topCenter,
                                                    end: Alignment
                                                        .bottomCenter,
                                                    colors: [
                                                      Colors.white
                                                          .withValues(
                                                        alpha: 0,
                                                      ),
                                                      Colors.white
                                                          .withValues(
                                                        alpha: 0.22,
                                                      ),
                                                      const Color(
                                                              0xFF9CEBFF)
                                                          .withValues(
                                                        alpha: 0.10,
                                                      ),
                                                      Colors.white
                                                          .withValues(
                                                        alpha: 0,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 0,
                                            left: 22,
                                            right: 22,
                                            child: Container(
                                              height: 1,
                                              decoration:
                                                  BoxDecoration(
                                                gradient:
                                                    LinearGradient(
                                                  colors: [
                                                    Colors.transparent,
                                                    Colors.white
                                                        .withValues(
                                                      alpha: 0.90,
                                                    ),
                                                    Colors.transparent,
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            25,
                            73,
                            25,
                            24,
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
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: _textoOscuro,
                                    fontSize: 27,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.9,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _mostrarRegistro
                                      ? 'Tu próximo paso comienza aquí.'
                                      : 'Tu formación, un mismo camino.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: _textoSecundario,
                                    fontSize: 12.5,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 27),
                                _campo(
                                  controller: _correoController,
                                  hint: 'Correo electrónico',
                                  icono:
                                      Icons.alternate_email_rounded,
                                  keyboardType:
                                      TextInputType.emailAddress,
                                  autofillHints: const [
                                    AutofillHints.email,
                                  ],
                                  validator: (value) {
                                    final correo =
                                        value?.trim() ?? '';

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
                                const SizedBox(height: 14),
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
                                    if (value == null ||
                                        value.isEmpty) {
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
                                  const SizedBox(height: 14),
                                  _campo(
                                    controller:
                                        _confirmarContrasenaController,
                                    hint: 'Confirmar contraseña',
                                    icono: Icons.verified_user_outlined,
                                    obscure: !_mostrarContrasena,
                                    textInputAction:
                                        TextInputAction.done,
                                    onSubmitted: (_) =>
                                        _iniciarSesion(),
                                    suffix:
                                        _botonMostrarContrasena(),
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty) {
                                        return 'Confirma tu contraseña.';
                                      }

                                      if (value !=
                                          _contrasenaController.text) {
                                        return 'Las contraseñas no coinciden.';
                                      }

                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 17),
                                  _selectorTipoUsuario(),
                                  const SizedBox(height: 13),
                                  _selectorBiometria(),
                                ],
                                const SizedBox(height: 23),
                                _botonInicio(),
                                if (!_mostrarRegistro) ...[
                                  const SizedBox(height: 13),
                                  _botonBiometrico(),
                                ],
                                const SizedBox(height: 22),
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Divider(
                                        color: Color(0x55476B8B),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      child: Text(
                                        _mostrarRegistro
                                            ? '¿YA TIENES CUENTA?'
                                            : '¿ERES NUEVO?',
                                        style: const TextStyle(
                                          color: _textoSecundario,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.8,
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
                                const SizedBox(height: 5),
                                TextButton(
                                  onPressed: _procesando ||
                                          _procesandoBiometria
                                      ? null
                                      : _alternarFormulario,
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        const Color(0xFF245C91),
                                    padding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 11,
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
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.shield_outlined,
                                      size: 14,
                                      color: _textoSecundario
                                          .withValues(alpha: 0.85),
                                    ),
                                    const SizedBox(width: 6),
                                    const Flexible(
                                      child: Text(
                                        'Acceso protegido desde tu dispositivo',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: _textoSecundario,
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
                      ],
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
      ),
    );
  }

  Widget _avatar() {
    return AnimatedBuilder(
      animation: _liquidController,
      builder: (context, child) {
        final fase = _liquidController.value * math.pi * 2;

        return Transform.translate(
          offset: Offset(0, math.sin(fase) * 3.5),
          child: child,
        );
      },
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFB4F6FF),
              Color(0xFF55BDF4),
              Color(0xFF3866D8),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.96),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _azulBrillante.withValues(alpha: 0.48),
              blurRadius: 30,
              spreadRadius: -2,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.28),
              blurRadius: 12,
              offset: const Offset(-3, -4),
            ),
          ],
        ),
        child: const Icon(
          Icons.person_outline_rounded,
          color: Colors.white,
          size: 52,
        ),
      ),
    );
  }

  InputBorder _bordeCampo({
    Color color = const Color(0x88FFFFFF),
    double width = 1,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: color, width: width),
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
      cursorColor: const Color(0xFF2588C8),
      style: const TextStyle(
        color: _textoOscuro,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icono, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.43),
        hintStyle: const TextStyle(
          color: Color(0xFF6C8298),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        errorStyle: const TextStyle(
          color: Color(0xFF96394E),
          fontSize: 10,
          height: 1.25,
        ),
        errorMaxLines: 2,
        prefixIconColor: const Color(0xFF315C7D),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
        border: _bordeCampo(),
        enabledBorder: _bordeCampo(),
        focusedBorder: _bordeCampo(
          color: const Color(0xFF3A9FE0),
          width: 1.7,
        ),
        errorBorder: _bordeCampo(
          color: const Color(0xFFB34B62),
          width: 1.2,
        ),
        focusedErrorBorder: _bordeCampo(
          color: const Color(0xFFB34B62),
          width: 1.2,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _selectorTipoUsuario() {
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
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        DropdownButtonFormField<String>(
          initialValue: _tipoUsuario,
          isExpanded: true,
          icon: const Icon(Icons.expand_more_rounded),
          dropdownColor: const Color(0xFFEAF4FB),
          style: const TextStyle(
            color: _textoOscuro,
            fontSize: 13,
          ),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.badge_outlined, size: 20),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.43),
            prefixIconColor: const Color(0xFF315C7D),
            border: _bordeCampo(),
            enabledBorder: _bordeCampo(),
            focusedBorder: _bordeCampo(
              color: const Color(0xFF3A9FE0),
              width: 1.7,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.35),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.78),
        ),
      ),
      child: CheckboxListTile(
        value: _biometriaActivada,
        onChanged: !_biometriaMovilDisponible ||
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
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(
                Icons.fingerprint_rounded,
                color: Color(0xFF315C7D),
                size: 28,
              ),
        title: const Text(
          'Activar datos biométricos',
          style: TextStyle(
            color: _textoOscuro,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: const Text(
          'Usa la huella o el reconocimiento facial de tu teléfono.',
          style: TextStyle(
            color: _textoSecundario,
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
        onPressed: !_biometriaMovilDisponible ||
                _procesando ||
                _procesandoBiometria
            ? null
            : _iniciarSesionBiometrico,
        icon: _procesandoBiometria
            ? const SizedBox(
                width: 19,
                height: 19,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.fingerprint_rounded, size: 23),
        label: Text(
          _procesandoBiometria
              ? 'Verificando identidad...'
              : 'Iniciar con datos biométricos',
          textAlign: TextAlign.center,
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF24547F),
          backgroundColor: Colors.white.withValues(alpha: 0.30),
          disabledForegroundColor: const Color(0xFF70869A),
          side: BorderSide(
            color: const Color(0xFF315C85).withValues(alpha: 0.40),
          ),
          minimumSize: const Size.fromHeight(50),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
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
    return _botonVidrio(
      texto: _mostrarRegistro ? 'CREAR CUENTA' : 'INICIAR SESIÓN',
      icono: _mostrarRegistro
          ? Icons.person_add_alt_1_rounded
          : Icons.login_rounded,
      cargando: _procesando,
      onTap: _procesando || _procesandoBiometria
          ? null
          : _iniciarSesion,
    );
  }

  Widget _botonVidrio({
    required String texto,
    required IconData icono,
    required VoidCallback? onTap,
    bool cargando = false,
  }) {
    return AnimatedBuilder(
      animation: _liquidController,
      builder: (context, child) {
        final fase = _liquidController.value * math.pi * 2;

        return Transform.translate(
          offset: Offset(0, math.sin(fase) * 0.7),
          child: child,
        );
      },
      child: Container(
        width: double.infinity,
        height: 51,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(27),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF8AF0FF),
              Color(0xFF45BDF3),
              Color(0xFF426DE4),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.74),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _azulBrillante.withValues(alpha: 0.30),
              blurRadius: 23,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(27),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(27),
            splashColor: Colors.white.withValues(alpha: 0.28),
            highlightColor: Colors.white.withValues(alpha: 0.10),
            child: Center(
              child: cargando
                  ? const SizedBox(
                      width: 21,
                      height: 21,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icono,
                          color: Colors.white,
                          size: 19,
                        ),
                        const SizedBox(width: 9),
                        Text(
                          texto,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}