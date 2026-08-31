import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/router.dart';
import '../../../../core/security/turnstile_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../../../home/presentation/widgets/footer.dart';
import '../../data/solicitudes_api_service.dart';

class ServiciosDiscrecionalesPage extends StatefulWidget {
  const ServiciosDiscrecionalesPage({super.key});

  @override
  State<ServiciosDiscrecionalesPage> createState() =>
      _ServiciosDiscrecionalesPageState();
}

class _ServiciosDiscrecionalesPageState
    extends State<ServiciosDiscrecionalesPage> {
  final _formKey = GlobalKey<FormState>();

  final _apiService = SolicitudesApiService();
  final _turnstileService = TurnstileService();

  final _nombreController = TextEditingController();
  final _empresaController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();

  final _origenController = TextEditingController();
  final _destinoController = TextEditingController();

  final _viajerosController = TextEditingController();
  final _observacionesController = TextEditingController();

  DateTime? _fechaIda;
  TimeOfDay? _horaIda;

  bool _necesitaVuelta = false;

  DateTime? _fechaVuelta;
  TimeOfDay? _horaVuelta;

  bool _aceptaPrivacidad = false;
  bool _enviando = false;
  bool _enviadoCorrectamente = false;

  String? _errorEnvio;

  @override
  void dispose() {
    _nombreController.dispose();
    _empresaController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _origenController.dispose();
    _destinoController.dispose();
    _viajerosController.dispose();
    _observacionesController.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // FORMATOS
  // ---------------------------------------------------------------------------

  String _fechaApi(DateTime fecha) {
    return '${fecha.year.toString().padLeft(4, '0')}-'
        '${fecha.month.toString().padLeft(2, '0')}-'
        '${fecha.day.toString().padLeft(2, '0')}';
  }

  String _fechaVisible(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }

  String _horaApi(TimeOfDay hora) {
    return '${hora.hour.toString().padLeft(2, '0')}:'
        '${hora.minute.toString().padLeft(2, '0')}';
  }

  String _horaVisible(TimeOfDay hora) {
    return '${hora.hour.toString().padLeft(2, '0')}:'
        '${hora.minute.toString().padLeft(2, '0')}';
  }

  // ---------------------------------------------------------------------------
  // DECORACIÓN DE CAMPOS
  // ---------------------------------------------------------------------------

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: AppColors.heritageGreenSoft,
        size: 21,
      ),
      labelStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(
        color: AppColors.textMuted.withValues(
          alpha: 0.85,
        ),
      ),
      filled: true,
      fillColor: AppColors.heritageBackgroundSoft.withValues(
        alpha: 0.92,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.heritageBorder,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.heritageGreenSoft.withValues(
            alpha: 0.30,
          ),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.heritageGreen,
          width: 1.7,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.5,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SELECTORES DE FECHA / HORA
  // ---------------------------------------------------------------------------

  Future<void> _seleccionarFechaIda() async {
    final ahora = DateTime.now();

    final seleccion = await showDatePicker(
      context: context,
      initialDate: _fechaIda ?? ahora,
      firstDate: DateTime(
        ahora.year,
        ahora.month,
        ahora.day,
      ),
      lastDate: DateTime(
        ahora.year + 3,
      ),
    );

    if (seleccion == null || !mounted) {
      return;
    }

    setState(() {
      _fechaIda = seleccion;

      if (_fechaVuelta != null &&
          _fechaVuelta!.isBefore(seleccion)) {
        _fechaVuelta = null;
        _horaVuelta = null;
      }
    });
  }

  Future<void> _seleccionarHoraIda() async {
    final seleccion = await showTimePicker(
      context: context,
      initialTime: _horaIda ?? TimeOfDay.now(),
    );

    if (seleccion == null || !mounted) {
      return;
    }

    setState(() {
      _horaIda = seleccion;
    });
  }

  Future<void> _seleccionarFechaVuelta() async {
    final ahora = DateTime.now();

    final primeraFecha =
        _fechaIda ??
        DateTime(
          ahora.year,
          ahora.month,
          ahora.day,
        );

    final seleccion = await showDatePicker(
      context: context,
      initialDate: _fechaVuelta ?? primeraFecha,
      firstDate: primeraFecha,
      lastDate: DateTime(
        ahora.year + 3,
      ),
    );

    if (seleccion == null || !mounted) {
      return;
    }

    setState(() {
      _fechaVuelta = seleccion;
    });
  }

  Future<void> _seleccionarHoraVuelta() async {
    final seleccion = await showTimePicker(
      context: context,
      initialTime: _horaVuelta ?? TimeOfDay.now(),
    );

    if (seleccion == null || !mounted) {
      return;
    }

    setState(() {
      _horaVuelta = seleccion;
    });
  }

  // ---------------------------------------------------------------------------
  // VALIDACIONES
  // ---------------------------------------------------------------------------

  String? _validarEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Introduce tu correo electrónico.';
    }

    final formato = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!formato.hasMatch(email)) {
      return 'Introduce un correo electrónico válido.';
    }

    return null;
  }

  String? _validarTelefono(String? value) {
    final telefono = value?.trim() ?? '';

    if (telefono.isEmpty) {
      return 'Introduce un teléfono de contacto.';
    }

    final digitos = telefono
        .split('')
        .where(
          (caracter) =>
              RegExp(r'\d').hasMatch(caracter),
        )
        .length;

    if (digitos < 7) {
      return 'Introduce un teléfono válido.';
    }

    return null;
  }

  String? _validarViajeros(String? value) {
    final viajeros = int.tryParse(
      value ?? '',
    );

    if (viajeros == null) {
      return 'Indica el número de viajeros.';
    }

    if (viajeros < 1 || viajeros > 200) {
      return 'El número debe estar entre 1 y 200.';
    }

    return null;
  }

  bool _validarFechas() {
    if (_fechaIda == null) {
      setState(() {
        _errorEnvio =
            'Selecciona la fecha de ida.';
      });

      return false;
    }

    if (_necesitaVuelta &&
        _fechaVuelta == null) {
      setState(() {
        _errorEnvio =
            'Selecciona la fecha de vuelta.';
      });

      return false;
    }

    if (_necesitaVuelta &&
        _fechaIda != null &&
        _fechaVuelta != null &&
        _fechaVuelta!.isBefore(_fechaIda!)) {
      setState(() {
        _errorEnvio =
            'La fecha de vuelta no puede ser anterior a la ida.';
      });

      return false;
    }

    return true;
  }

  // ---------------------------------------------------------------------------
  // ENVÍO
  // ---------------------------------------------------------------------------

  Future<void> _enviarFormulario() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _errorEnvio = null;
      _enviadoCorrectamente = false;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_validarFechas()) {
      return;
    }

    if (!_aceptaPrivacidad) {
      setState(() {
        _errorEnvio =
            'Debes confirmar que has leído la Política de Privacidad para enviar la solicitud.';
      });

      return;
    }

    final viajeros = int.parse(
      _viajerosController.text.trim(),
    );

    setState(() {
      _enviando = true;
    });

    try {
      final turnstileToken =
          await _turnstileService.obtenerToken(
            context,
          );

      await _apiService.enviarSolicitud(
        nombre: _nombreController.text,
        empresa: _empresaController.text,
        telefono: _telefonoController.text,
        email: _emailController.text,
        origen: _origenController.text,
        destino: _destinoController.text,
        fechaIda: _fechaApi(
          _fechaIda!,
        ),
        horaIda: _horaIda == null
            ? null
            : _horaApi(
                _horaIda!,
              ),
        necesitaVuelta: _necesitaVuelta,
        fechaVuelta:
            _necesitaVuelta &&
                _fechaVuelta != null
            ? _fechaApi(
                _fechaVuelta!,
              )
            : null,
        horaVuelta:
            _necesitaVuelta &&
                _horaVuelta != null
            ? _horaApi(
                _horaVuelta!,
              )
            : null,
        viajeros: viajeros,
        observaciones:
            _observacionesController.text,
        aceptaPrivacidad: _aceptaPrivacidad,
        turnstileToken: turnstileToken,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _enviadoCorrectamente = true;
        _errorEnvio = null;
      });
    } on TurnstileException catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorEnvio = e.message;
      });
    } on SolicitudApiException catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorEnvio = e.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorEnvio =
            'Se ha producido un error inesperado. Inténtalo de nuevo.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _enviando = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // PÁGINA
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return AppShell(
      background: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/home_background.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            filterQuality: FilterQuality.high,
          ),

          ColoredBox(
            color:
                AppColors.heritageBackground.withValues(
              alpha: 0.28,
            ),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1100,
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(
                      24,
                      38,
                      24,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),

                        const SizedBox(height: 28),

                        _buildFormCard(),
                      ],
                    ),
                  ),
                ),
              ),

              const FooterSection(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CABECERA
  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 28,
      ),
      decoration: BoxDecoration(
        color: AppColors.heritageSurface.withValues(
          alpha: 0.86,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.heritageGreenSoft.withValues(
            alpha: 0.28,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(
              16,
              58,
              34,
              0.10,
            ),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _HeaderIcon(),

          SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Pide tu presupuesto',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color:
                        AppColors.heritageGreenDark,
                    letterSpacing: -0.5,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  'Cuéntanos tu viaje y te prepararemos un presupuesto '
                  'personalizado, sin compromiso.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color:
                        AppColors.textSecondary,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  'Excursiones, eventos, viajes de empresa, grupos y '
                  'desplazamientos personalizados.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FORMULARIO
  // ---------------------------------------------------------------------------

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.heritageSurface.withValues(
          alpha: 0.94,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.heritageGreenSoft.withValues(
            alpha: 0.24,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(
              16,
              58,
              34,
              0.11,
            ),
            blurRadius: 28,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _SectionTitle(
              icon:
                  Icons.person_outline_rounded,
              title: 'Datos de contacto',
              subtitle:
                  'Indícanos cómo podemos ponernos en contacto contigo.',
            ),

            const SizedBox(height: 22),

            _ResponsiveFields(
              children: [
                TextFormField(
                  controller: _nombreController,
                  maxLength: 80,
                  decoration: _inputDecoration(
                    label:
                        'Nombre y apellidos *',
                    icon:
                        Icons.person_outline,
                  ).copyWith(
                    counterText: '',
                  ),
                  validator: (value) {
                    final texto =
                        value?.trim() ?? '';

                    if (texto.length < 2) {
                      return 'Introduce tu nombre.';
                    }

                    return null;
                  },
                ),

                TextFormField(
                  controller:
                      _empresaController,
                  maxLength: 120,
                  decoration: _inputDecoration(
                    label: 'Empresa',
                    icon:
                        Icons.business_outlined,
                    hint: 'Opcional',
                  ).copyWith(
                    counterText: '',
                  ),
                ),

                TextFormField(
                  controller:
                      _telefonoController,
                  maxLength: 25,
                  keyboardType:
                      TextInputType.phone,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(
                      25,
                    ),
                    FilteringTextInputFormatter.allow(
                      RegExp(
                        r'[0-9+\-(). ]',
                      ),
                    ),
                  ],
                  decoration: _inputDecoration(
                    label: 'Teléfono *',
                    icon:
                        Icons.phone_outlined,
                  ).copyWith(
                    counterText: '',
                  ),
                  validator:
                      _validarTelefono,
                ),

                TextFormField(
                  controller:
                      _emailController,
                  keyboardType:
                      TextInputType.emailAddress,
                  decoration:
                      _inputDecoration(
                    label:
                        'Correo electrónico *',
                    icon:
                        Icons.email_outlined,
                  ),
                  validator: _validarEmail,
                ),
              ],
            ),

            const SizedBox(height: 34),

            const Divider(
              color: AppColors.heritageBorder,
            ),

            const SizedBox(height: 28),

            _SectionTitle(
              icon:
                  Icons.directions_bus_outlined,
              title: 'Detalles del viaje',
              subtitle:
                  'Cuéntanos dónde quieres ir y cuándo necesitas el servicio.',
            ),

            const SizedBox(height: 22),

            _ResponsiveFields(
              children: [
                TextFormField(
                  controller:
                      _origenController,
                  maxLength: 120,
                  decoration: _inputDecoration(
                    label: 'Origen *',
                    icon:
                        Icons.trip_origin_rounded,
                    hint: 'Ej. Torrijos',
                  ).copyWith(
                    counterText: '',
                  ),
                  validator: (value) {
                    if ((value
                                    ?.trim()
                                    .length ??
                                0) <
                            2) {
                      return 'Indica el lugar de origen.';
                    }

                    return null;
                  },
                ),

                TextFormField(
                  controller:
                      _destinoController,
                  maxLength: 120,
                  decoration: _inputDecoration(
                    label: 'Destino *',
                    icon: Icons
                        .location_on_outlined,
                    hint: 'Ej. Madrid',
                  ).copyWith(
                    counterText: '',
                  ),
                  validator: (value) {
                    if ((value
                                    ?.trim()
                                    .length ??
                                0) <
                            2) {
                      return 'Indica el destino.';
                    }

                    return null;
                  },
                ),

                _SelectionField(
                  label: 'Fecha de ida *',
                  value: _fechaIda == null
                      ? 'Seleccionar fecha'
                      : _fechaVisible(
                          _fechaIda!,
                        ),
                  icon: Icons
                      .calendar_today_outlined,
                  onTap:
                      _seleccionarFechaIda,
                ),

                _SelectionField(
                  label: 'Hora de ida',
                  value: _horaIda == null
                      ? 'Opcional'
                      : _horaVisible(
                          _horaIda!,
                        ),
                  icon:
                      Icons.schedule_outlined,
                  onTap:
                      _seleccionarHoraIda,
                ),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors
                    .heritageBackgroundSoft
                    .withValues(
                  alpha: 0.80,
                ),
                borderRadius:
                    BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors
                      .heritageGreenSoft
                      .withValues(
                    alpha: 0.22,
                  ),
                ),
              ),
              child: SwitchListTile(
                contentPadding:
                    EdgeInsets.zero,
                activeTrackColor:
                    AppColors.heritageGreen,
                activeThumbColor:
                    AppColors.heritageAccent,
                title: const Text(
                  '¿Necesitas viaje de vuelta?',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w700,
                    color:
                        AppColors.textPrimary,
                  ),
                ),
                subtitle: const Text(
                  'Actívalo si el servicio incluye regreso.',
                  style: TextStyle(
                    color:
                        AppColors.textSecondary,
                  ),
                ),
                value: _necesitaVuelta,
                onChanged: (value) {
                  setState(() {
                    _necesitaVuelta = value;

                    if (!value) {
                      _fechaVuelta = null;
                      _horaVuelta = null;
                    }
                  });
                },
              ),
            ),

            if (_necesitaVuelta) ...[
              const SizedBox(height: 20),

              _ResponsiveFields(
                children: [
                  _SelectionField(
                    label:
                        'Fecha de vuelta *',
                    value:
                        _fechaVuelta == null
                        ? 'Seleccionar fecha'
                        : _fechaVisible(
                            _fechaVuelta!,
                          ),
                    icon: Icons
                        .event_available_outlined,
                    onTap:
                        _seleccionarFechaVuelta,
                  ),

                  _SelectionField(
                    label: 'Hora de vuelta',
                    value:
                        _horaVuelta == null
                        ? 'Opcional'
                        : _horaVisible(
                            _horaVuelta!,
                          ),
                    icon: Icons
                        .schedule_outlined,
                    onTap:
                        _seleccionarHoraVuelta,
                  ),
                ],
              ),
            ],

            const SizedBox(height: 20),

            ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 520,
              ),
              child: TextFormField(
                controller:
                    _viajerosController,
                keyboardType:
                    TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter
                      .digitsOnly,
                ],
                decoration:
                    _inputDecoration(
                  label:
                      'Número de viajeros *',
                  icon:
                      Icons.groups_outlined,
                  hint: 'Ej. 45',
                ),
                validator:
                    _validarViajeros,
              ),
            ),

            const SizedBox(height: 34),

            const Divider(
              color: AppColors.heritageBorder,
            ),

            const SizedBox(height: 28),

            _SectionTitle(
              icon: Icons.notes_outlined,
              title: 'Observaciones',
              subtitle:
                  'Añade cualquier información que pueda ayudarnos a preparar el servicio.',
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller:
                  _observacionesController,
              maxLength: 1500,
              maxLines: 6,
              minLines: 4,
              decoration: _inputDecoration(
                label:
                    'Información adicional',
                icon:
                    Icons.edit_note_outlined,
                hint:
                    'Equipaje, paradas intermedias, necesidades especiales...',
              ),
            ),

            const SizedBox(height: 26),

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors
                    .heritageBackgroundSoft
                    .withValues(
                  alpha: 0.82,
                ),
                borderRadius:
                    BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors
                      .heritageGreenSoft
                      .withValues(
                    alpha: 0.22,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value:
                        _aceptaPrivacidad,
                    activeColor:
                        AppColors.heritageGreen,
                    checkColor: Colors.white,
                    onChanged: (value) {
                      setState(() {
                        _aceptaPrivacidad =
                            value ?? false;
                      });
                    },
                  ),

                  const SizedBox(width: 6),

                  Expanded(
                    child: Wrap(
                      crossAxisAlignment:
                          WrapCrossAlignment.center,
                      children: [
                        const Text(
                          'He leído la ',
                          style: TextStyle(
                            color: AppColors
                                .textSecondary,
                            height: 1.5,
                          ),
                        ),

                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRouter
                                  .privacidad,
                            );
                          },
                          style:
                              TextButton.styleFrom(
                            padding:
                                EdgeInsets.zero,
                            minimumSize:
                                Size.zero,
                            tapTargetSize:
                                MaterialTapTargetSize
                                    .shrinkWrap,
                            foregroundColor:
                                AppColors
                                    .heritageGreen,
                          ),
                          child: const Text(
                            'Política de Privacidad',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ),

                        const Text(
                          '. *',
                          style: TextStyle(
                            color: AppColors
                                .textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (_errorEnvio != null) ...[
              const SizedBox(height: 20),

              _StatusMessage(
                icon: Icons
                    .error_outline_rounded,
                message: _errorEnvio!,
                success: false,
              ),
            ],

            if (_enviadoCorrectamente) ...[
              const SizedBox(height: 20),

              const _StatusMessage(
                icon: Icons
                    .check_circle_outline_rounded,
                message:
                    'Solicitud enviada correctamente. Nos pondremos en contacto contigo lo antes posible.',
                success: true,
              ),
            ],

            const SizedBox(height: 26),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _enviando
                    ? null
                    : _enviarFormulario,
                icon: _enviando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                      ),
                label: Text(
                  _enviando
                      ? 'Enviando solicitud...'
                      : 'Solicitar presupuesto',
                ),
                style:
                    ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor:
                      AppColors.heritageGreen,
                  foregroundColor:
                      Colors.white,
                  disabledBackgroundColor:
                      AppColors
                          .heritageGreenSoft,
                  disabledForegroundColor:
                      Colors.white,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            const Center(
              child: Text(
                'Tus datos se utilizarán únicamente para gestionar '
                'tu solicitud de presupuesto.',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// ICONO PRINCIPAL
// =============================================================================

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.heritageGreen,
        borderRadius:
            BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(
              16,
              58,
              34,
              0.15,
            ),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.directions_bus_filled_outlined,
        color: AppColors.heritageAccent,
        size: 28,
      ),
    );
  }
}

// =============================================================================
// TÍTULOS DE SECCIÓN
// =============================================================================

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color:
                AppColors.heritageAccent.withValues(
              alpha: 0.18,
            ),
            borderRadius:
                BorderRadius.circular(12),
            border: Border.all(
              color:
                  AppColors.heritageAccent.withValues(
                alpha: 0.42,
              ),
            ),
          ),
          child: Icon(
            icon,
            color:
                AppColors.heritageGreen,
            size: 22,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      AppColors.heritageGreenDark,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color:
                      AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// CAMPOS RESPONSIVE
// =============================================================================

class _ResponsiveFields
    extends StatelessWidget {
  final List<Widget> children;

  const _ResponsiveFields({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final twoColumns =
            constraints.maxWidth >= 720;

        if (!twoColumns) {
          return Column(
            children: [
              for (
                var i = 0;
                i < children.length;
                i++
              ) ...[
                children[i],

                if (i !=
                    children.length - 1)
                  const SizedBox(
                    height: 18,
                  ),
              ],
            ],
          );
        }

        return Wrap(
          spacing: 18,
          runSpacing: 18,
          children:
              children.map((child) {
            return SizedBox(
              width:
                  (constraints.maxWidth -
                          18) /
                      2,
              child: child,
            );
          }).toList(),
        );
      },
    );
  }
}

// =============================================================================
// CAMPO DE SELECCIÓN
// =============================================================================

class _SelectionField
    extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _SelectionField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final emptyValue =
        value == 'Opcional' ||
        value == 'Seleccionar fecha';

    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color:
                AppColors.textSecondary,
            fontWeight:
                FontWeight.w500,
          ),
          prefixIcon: Icon(
            icon,
            color:
                AppColors.heritageGreenSoft,
            size: 21,
          ),
          filled: true,
          fillColor: AppColors
              .heritageBackgroundSoft
              .withValues(
            alpha: 0.92,
          ),
          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide:
                const BorderSide(
              color:
                  AppColors.heritageBorder,
            ),
          ),
          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide: BorderSide(
              color: AppColors
                  .heritageGreenSoft
                  .withValues(
                alpha: 0.30,
              ),
            ),
          ),
        ),
        child: Text(
          value,
          style: TextStyle(
            color: emptyValue
                ? AppColors.textMuted
                : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// MENSAJES DE ESTADO
// =============================================================================

class _StatusMessage
    extends StatelessWidget {
  final IconData icon;
  final String message;
  final bool success;

  const _StatusMessage({
    required this.icon,
    required this.message,
    required this.success,
  });

  @override
  Widget build(BuildContext context) {
    final color = success
        ? const Color(0xFF287A42)
        : const Color(0xFFB42318);

    final background = success
        ? const Color(0xFFEAF7EE)
        : const Color(0xFFFFF0EF);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(
            alpha: 0.28,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontWeight:
                    FontWeight.w600,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}