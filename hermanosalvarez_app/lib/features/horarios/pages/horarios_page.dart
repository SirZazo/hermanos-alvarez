import 'package:flutter/material.dart';
import '../../../shared/widgets/app_shell.dart';
import '../data/api_service.dart';

class HorariosPage extends StatefulWidget {
  const HorariosPage({super.key});

  @override
  State<HorariosPage> createState() => _HorariosPageState();
}

class _HorariosPageState extends State<HorariosPage> {
  final ApiService _apiService = ApiService();

  bool loading = true;
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
      final loadedStops = await _apiService.getParadas();

      setState(() {
        stops = loadedStops;
        loading = false;
        error = null;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

Future<void> _cargarDestinosValidos(String origen) async {
  try {
    final destinos = await _apiService.getDestinosValidos(
      origen: origen,
      dia: diaSeleccionado,
    );

    setState(() {
      destinosDisponibles = destinos;
      destinoSeleccionado = null;
      busquedaRealizada = false;
      resultadosHorarios = [];
      error = null;
    });
  } catch (e) {
    setState(() {
      error = e.toString();
      destinosDisponibles = [];
      destinoSeleccionado = null;
      busquedaRealizada = false;
      resultadosHorarios = [];
    });
  }
}

  Future<void> _buscarHorarios() async {
    if (origenSeleccionado == null || destinoSeleccionado == null) return;

    try {
      final resultado = await _apiService.getHorarios(
        origen: origenSeleccionado!,
        destino: destinoSeleccionado!,
        dia: diaSeleccionado,
      );

      setState(() {
        resultadosHorarios =
            List<Map<String, dynamic>>.from(resultado['horarios'] ?? []);
        busquedaRealizada = true;
        error = null;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        resultadosHorarios = [];
        busquedaRealizada = true;
      });
    }
  }

  void intercambiarOrigenDestino() {
    if (origenSeleccionado == null || destinoSeleccionado == null) return;

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

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    'Consulta de horarios',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF002F6C),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Selecciona origen, destino y día para ver las salidas disponibles de forma rápida y clara.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (loading)
                    const Center(child: CircularProgressIndicator())
                  else if (error != null && stops.isEmpty)
                    Text('Error cargando datos: $error')
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          hint: const Text('Origen'),
                          value: origenSeleccionado,
                          items: stops.map((stop) {
                            return DropdownMenuItem<String>(
                              value: stop['id'] as String,
                              child: Text(stop['nombre'] as String),
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
                            if (origenSeleccionado != null) {
                              await _cargarDestinosValidos(origenSeleccionado!);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: IconButton(
                            onPressed: (origenSeleccionado != null &&
                                    destinoSeleccionado != null)
                                ? intercambiarOrigenDestino
                                : null,
                            icon: const Icon(Icons.swap_vert_circle),
                            iconSize: 34,
                            tooltip: 'Intercambiar origen y destino',
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          hint: const Text('Destino'),
                          value: destinosDisponibles.any(
                                  (stop) => stop['id'] == destinoSeleccionado)
                              ? destinoSeleccionado
                              : null,
                          items: destinosDisponibles.map((stop) {
                            return DropdownMenuItem<String>(
                              value: stop['id'] as String,
                              child: Text(stop['nombre'] as String),
                            );
                          }).toList(),
                          onChanged: origenSeleccionado == null
                              ? null
                              : (value) {
                                  setState(() {
                                    destinoSeleccionado = value;
                                    resultadosHorarios = [];
                                    busquedaRealizada = false;
                                    error = null;
                                  });
                                },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: diaSeleccionado,
                          items: const [
                            DropdownMenuItem(
                              value: 'laborable',
                              child: Text('Laborable'),
                            ),
                            DropdownMenuItem(
                              value: 'sabado',
                              child: Text('Sábado'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                diaSeleccionado = value;
                                resultadosHorarios = [];
                                busquedaRealizada = false;
                                error = null;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (origenSeleccionado != null &&
                                    destinoSeleccionado != null)
                                ? _buscarHorarios
                                : null,
                            child: const Text('Buscar horarios'),
                          ),
                        ),
                        if (error != null && stops.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text('Error: $error'),
                          ),
                        if (busquedaRealizada)
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: resultadosHorarios.isEmpty
                                ? const Text('No hay horarios disponibles')
                                : Column(
                                    children: resultadosHorarios.map((viaje) {
                                      return Container(
                                        width: double.infinity,
                                        margin:
                                            const EdgeInsets.only(bottom: 10),
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: const Color(0xFFE0E0E0),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          '${viaje['salida']} → ${viaje['llegada']}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      );
                                    }).toList(),
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
    );
  }
}