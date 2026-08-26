import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../shared/widgets/app_shell.dart';
import '../data/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class HorariosPage extends StatefulWidget {
  const HorariosPage({super.key});

  @override
  State<HorariosPage> createState() => _HorariosPageState();
}

class _HorariosPageState extends State<HorariosPage> {
  final ApiService _apiService = ApiService();
  final GlobalKey _resultsKey = GlobalKey();

  bool loading = true;
  bool cargandoDestinos = false;
  String? error;

  String? origenSeleccionado;
  String? destinoSeleccionado;
  String diaSeleccionado = 'laborable';
  bool busquedaRealizada = false;

  List<Map<String, dynamic>> stops = [];
  List<Map<String, dynamic>> destinosDisponibles = [];
  List<Map<String, dynamic>> resultadosHorarios = [];

  @override
  void initState() {
    super.initState();
    _loadParadas();
  }

  Future<void> _loadParadas() async {
    try {
      final loadedStops = await _apiService.getParadas(dia: diaSeleccionado);

      if (!mounted) return;

      setState(() {
        stops = loadedStops;
        loading = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        stops = [];
        error = e.toString();
        loading = false;
      });
    }
  }

  Future<void> _cargarDestinosValidos(String origen) async {
    setState(() {
      cargandoDestinos = true;
      destinosDisponibles = [];
      destinoSeleccionado = null;
      busquedaRealizada = false;
      resultadosHorarios = [];
      error = null;
    });

    try {
      final destinos = await _apiService.getDestinosValidos(
        origen: origen,
        dia: diaSeleccionado,
      );

      if (!mounted) return;

      setState(() {
        destinosDisponibles = destinos;
        cargandoDestinos = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
        destinosDisponibles = [];
        destinoSeleccionado = null;
        busquedaRealizada = false;
        resultadosHorarios = [];
        cargandoDestinos = false;
      });
    }
  }

  void _scrollToResults() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final resultsContext = _resultsKey.currentContext;

      if (resultsContext != null) {
        Scrollable.ensureVisible(
          resultsContext,
          duration: const Duration(milliseconds: 550),
          curve: Curves.easeInOut,
          alignment: 0.08,
        );
      }
    });
  }

  Future<void> _buscarHorarios() async {
    if (origenSeleccionado == null || destinoSeleccionado == null) return;

    try {
      final resultado = await _apiService.getHorarios(
        origen: origenSeleccionado!,
        destino: destinoSeleccionado!,
        dia: diaSeleccionado,
      );

      if (!mounted) return;

      setState(() {
        resultadosHorarios = List<Map<String, dynamic>>.from(
          resultado['horarios'] ?? [],
        );
        busquedaRealizada = true;
        error = null;
      });

      _scrollToResults();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
        resultadosHorarios = [];
        busquedaRealizada = true;
      });
    }
  }

  void intercambiarOrigenDestino() {
    if (origenSeleccionado == null || destinoSeleccionado == null) return;

    final destinoPuedeSerOrigen = stops.any(
      (stop) => stop['id'] == destinoSeleccionado,
    );

    if (!destinoPuedeSerOrigen) return;

    final nuevoOrigen = destinoSeleccionado!;
    final nuevoDestino = origenSeleccionado!;

    setState(() {
      origenSeleccionado = nuevoOrigen;
      destinoSeleccionado = null;
      destinosDisponibles = [];
      resultadosHorarios = [];
      busquedaRealizada = false;
      error = null;
    });

    _cargarDestinosValidos(nuevoOrigen).then((_) {
      if (!mounted) return;

      final destinoExiste = destinosDisponibles.any(
        (stop) => stop['id'] == nuevoDestino,
      );

      if (destinoExiste) {
        setState(() {
          destinoSeleccionado = nuevoDestino;
        });
      }
    });
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    required bool selected,
  }) {
    final borderColor = selected ? AppColors.accentHover : AppColors.border;

    return InputDecoration(
      labelText: label,

      labelStyle: TextStyle(
        color: selected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      ),

      prefixIcon: Icon(
        icon,
        color: selected ? AppColors.primary : AppColors.textMuted,
        size: 21,
      ),

      filled: true,

      fillColor: selected
          ? const Color.fromRGBO(216, 233, 106, 0.08)
          : AppColors.surfaceSoft,

      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor, width: selected ? 1.4 : 1),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.7),
      ),

      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: Container(
        width: double.infinity,
        color: AppColors.pageBackground,
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 38, 24, 56),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 28),

                    if (loading)
                      _buildLoadingCard()
                    else if (error != null && stops.isEmpty)
                      _buildInitialError()
                    else ...[
                      _buildSearchCard(),
                      if (kIsWeb) ...[
                        const SizedBox(height: 24),
                        _buildRegularLinesCard(),
                      ],

                      if (error != null && stops.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        _buildErrorCard(),
                      ],

                      if (busquedaRealizada) ...[
                        const SizedBox(height: 24),
                        _buildResultsCard(),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
      decoration: AppDecorations.softPanel(),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderIcon(),
          SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consulta de horarios',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDeep,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Selecciona día, origen y destino para consultar las salidas disponibles.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: AppDecorations.card(radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Planifica tu viaje',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Indica desde dónde sales y hasta dónde quieres viajar.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          DropdownButtonFormField<String>(
            isExpanded: true,
            decoration: _inputDecoration(
              label: 'Día del servicio',
              icon: Icons.calendar_today_outlined,
              selected: true,
            ),
            value: diaSeleccionado,
            items: const [
              DropdownMenuItem(value: 'laborable', child: Text('Laborable')),
              DropdownMenuItem(value: 'sabado', child: Text('Sábado')),
              DropdownMenuItem(
                value: 'domingo_festivos',
                child: Text('Domingos y festivos'),
              ),
            ],
            onChanged: (value) async {
              if (value == null || value == diaSeleccionado) return;

              setState(() {
                diaSeleccionado = value;

                origenSeleccionado = null;
                destinoSeleccionado = null;

                stops = [];
                destinosDisponibles = [];
                resultadosHorarios = [];

                busquedaRealizada = false;
                error = null;
              });

              await _loadParadas();
            },
          ),

          const SizedBox(height: 24),

          DropdownButtonFormField<String>(
            isExpanded: true,
            decoration: _inputDecoration(
              label: 'Origen',
              icon: Icons.trip_origin_rounded,
              selected: origenSeleccionado != null,
            ),
            value: origenSeleccionado,
            items: stops.map((stop) {
              return DropdownMenuItem<String>(
                value: stop['id'] as String,
                child: Text(
                  stop['nombre'] as String,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (value) async {
              if (value == null) return;

              setState(() {
                origenSeleccionado = value;
                destinosDisponibles = [];
                destinoSeleccionado = null;
                resultadosHorarios = [];
                busquedaRealizada = false;
                error = null;
              });

              await _cargarDestinosValidos(value);
            },
          ),

          const SizedBox(height: 12),

          Center(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(9, 37, 79, 0.05),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                onPressed:
                    (!cargandoDestinos &&
                        origenSeleccionado != null &&
                        destinoSeleccionado != null &&
                        stops.any((stop) => stop['id'] == destinoSeleccionado))
                    ? intercambiarOrigenDestino
                    : null,
                icon: const Icon(Icons.swap_vert_rounded),
                color: AppColors.primary,
                disabledColor: AppColors.textMuted,
                hoverColor: AppColors.accentSoft,
                highlightColor: AppColors.accentSoft,
                splashColor: AppColors.accent,
                iconSize: 27,
                tooltip: 'Intercambiar origen y destino',
              ),
            ),
          ),

          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            isExpanded: true,
            decoration: _inputDecoration(
              label: 'Destino',
              icon: Icons.location_on_outlined,
              selected: destinoSeleccionado != null,
            ),
            value:
                destinosDisponibles.any(
                  (stop) => stop['id'] == destinoSeleccionado,
                )
                ? destinoSeleccionado
                : null,
            items: destinosDisponibles.map((stop) {
              return DropdownMenuItem<String>(
                value: stop['id'] as String,
                child: Text(
                  stop['nombre'] as String,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (origenSeleccionado == null || cargandoDestinos)
                ? null
                : (value) {
                    setState(() {
                      destinoSeleccionado = value;
                      resultadosHorarios = [];
                      busquedaRealizada = false;
                      error = null;
                    });
                  },
            hint: cargandoDestinos
                ? const Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Cargando destinos...',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  )
                : const Text('Selecciona un destino'),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed:
                  (!cargandoDestinos &&
                      origenSeleccionado != null &&
                      destinoSeleccionado != null)
                  ? _buscarHorarios
                  : null,
              icon: const Icon(Icons.search_rounded, size: 22),
              label: const Text(
                'Buscar horarios',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color?>((
                  states,
                ) {
                  if (states.contains(WidgetState.disabled)) {
                    return AppColors.border;
                  }

                  if (states.contains(WidgetState.hovered)) {
                    return AppColors.primaryDark;
                  }

                  if (states.contains(WidgetState.pressed)) {
                    return AppColors.primaryDeep;
                  }

                  return AppColors.primary;
                }),
                foregroundColor: WidgetStateProperty.resolveWith<Color?>((
                  states,
                ) {
                  if (states.contains(WidgetState.disabled)) {
                    return AppColors.textMuted;
                  }

                  return AppColors.white;
                }),
                overlayColor: WidgetStateProperty.all(
                  const Color.fromRGBO(216, 233, 106, 0.10),
                ),
                elevation: WidgetStateProperty.resolveWith<double>((states) {
                  if (states.contains(WidgetState.hovered)) {
                    return 3;
                  }

                  return 0;
                }),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegularLinesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: AppDecorations.card(radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.route_outlined, color: AppColors.primary, size: 25),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Líneas regulares',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          const Text(
            'Consulta información sobre recorridos, paradas y servicios de nuestras líneas regulares.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 24),

          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 720;

              final vcm618 = _buildRegularLineItem(
                code: 'VCM-618',
                title: 'Torrijos ↔ Toledo',
                description:
                    'Información de la línea, recorrido y principales paradas.',
                path: '/horarios/vcm-618-torrijos-toledo',
              );

              final vcm042 = _buildRegularLineItem(
                code: 'VCM-042',
                title: 'Almorox ↔ Torrijos',
                description:
                    'Recorridos entre Almorox, Escalona, Torrijos y otras localidades.',
                path: '/horarios/vcm-042-almorox-torrijos',
              );

              if (compact) {
                return Column(
                  children: [vcm618, const SizedBox(height: 16), vcm042],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: vcm618),
                  const SizedBox(width: 18),
                  Expanded(child: vcm042),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRegularLineItem({
    required String code,
    required String title,
    required String description,
    required String path,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              code,
              style: const TextStyle(
                color: AppColors.primaryDeep,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ),

          const SizedBox(height: 14),

          Text(
            title,
            style: const TextStyle(
              color: AppColors.primaryDeep,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.45,
            ),
          ),

          const SizedBox(height: 18),

          TextButton.icon(
            onPressed: () => _openRegularLine(path),
            icon: const Icon(Icons.arrow_forward_rounded, size: 19),
            label: const Text('Ver información de la línea'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: EdgeInsets.zero,
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openRegularLine(String path) async {
    final uri = Uri.parse('${Uri.base.origin}$path');

    final opened = await launchUrl(uri, webOnlyWindowName: '_self');

    if (!opened) {
      throw Exception('No se pudo abrir $uri');
    }
  }

  Widget _buildResultsCard() {
    return Container(
      key: _resultsKey,
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: AppDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.directions_bus_outlined,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Horarios disponibles',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (resultadosHorarios.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${resultadosHorarios.length} '
                    '${resultadosHorarios.length == 1 ? 'servicio' : 'servicios'}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          if (resultadosHorarios.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.event_busy_outlined,
                    size: 34,
                    color: AppColors.textMuted,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'No hay horarios disponibles',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            ...resultadosHorarios.map(
              (viaje) => _ScheduleItem(
                salida: '${viaje['salida']}',
                llegada: '${viaje['llegada']}',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 70),
      decoration: AppDecorations.card(),
      child: const Column(
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 18),
          Text(
            'Cargando paradas...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: AppDecorations.card(radius: 18),
      child: Text(
        'No se han podido cargar las paradas.\n$error',
        style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFF9A3412)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No se ha podido completar la consulta: $error',
              style: const TextStyle(color: Color(0xFF7C2D12), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Icon(
        Icons.schedule_rounded,
        color: AppColors.white,
        size: 27,
      ),
    );
  }
}

class _ScheduleItem extends StatefulWidget {
  final String salida;
  final String llegada;

  const _ScheduleItem({required this.salida, required this.llegada});

  @override
  State<_ScheduleItem> createState() => _ScheduleItemState();
}

class _ScheduleItemState extends State<_ScheduleItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: _isHovered ? AppColors.white : AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isHovered ? AppColors.borderStrong : AppColors.border,
          ),
          boxShadow: _isHovered
              ? const [
                  BoxShadow(
                    color: AppColors.shadowSoft,
                    blurRadius: 14,
                    offset: Offset(0, 5),
                  ),
                ]
              : const [],
        ),
        child: Row(
          children: [
            Expanded(
              child: _TimeBlock(
                label: 'Salida',
                time: widget.salida,
                alignment: CrossAxisAlignment.start,
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: _isHovered ? AppColors.accent : AppColors.accentSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.primaryDeep,
                size: 19,
              ),
            ),
            Expanded(
              child: _TimeBlock(
                label: 'Llegada',
                time: widget.llegada,
                alignment: CrossAxisAlignment.end,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeBlock extends StatelessWidget {
  final String label;
  final String time;
  final CrossAxisAlignment alignment;

  const _TimeBlock({
    required this.label,
    required this.time,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          time,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDeep,
          ),
        ),
      ],
    );
  }
}
