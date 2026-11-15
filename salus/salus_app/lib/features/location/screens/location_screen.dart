import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/salus_app_bar.dart';

enum UnitType { all, ubs, upa, hospital } // representa os tipos de unidades de saúde (UBS, UPA, Hospital) e "all" para todos os tipos

class HealthUnit { // representa uma unidade de saúde com seus dados básicos
  final String name;
  final String address;
  final double distance;
  final UnitType type;
  final bool isSus;
  final bool isOpen24h;
  final double lat;
  final double lon;

  HealthUnit({
    required this.name,
    required this.address,
    required this.distance,
    required this.type,
    required this.isSus,
    required this.isOpen24h,
    required this.lat,
    required this.lon,
  });

  // construtor a partir do JSON retornado pela API
  factory HealthUnit.fromJson(Map<String, dynamic> json) {
    final typeStr = json['tipo'] as String;
    UnitType type;
    switch (typeStr) {
      case 'ubs':
        type = UnitType.ubs;
        break;
      case 'upa':
      case 'pronto_atendimento':
        type = UnitType.upa;
        break;
      case 'hospital':
        type = UnitType.hospital;
        break;
      default:
        type = UnitType.all;
    }

    // para SUS e 24h
    final isSus = json['tipo'] == 'ubs' || json['nome'].toString().toUpperCase().contains('UBS');
    final isOpen24h = json['tipo'] == 'pronto_atendimento' ||
        json['nome'].toString().toUpperCase().contains('UPA') ||
        json['nome'].toString().toUpperCase().contains('PRONTO SOCORRO');

    return HealthUnit( // cria o objeto HealthUnit com os dados do JSON
      name: json['nome'] as String, // nome da unidade
      address: json['endereco'] ?? 'Endereço não informado',
      distance: (json['distancia_km'] as num).toDouble(),
      type: type,
      isSus: isSus,
      isOpen24h: isOpen24h,
      lat: (json['latitude'] as num).toDouble(), // converte a latitude e longitude para double
      lon: (json['longitude'] as num).toDouble(),
    );
  }
}

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

// tela principal de localização com mapa, filtros e lista de unidades 
class _LocationScreenState extends State<LocationScreen> {
  UnitType _selectedFilter = UnitType.all;
  List<HealthUnit> _units = [];
  List<HealthUnit> _filteredUnits = [];
  bool _isLoading = false;
  String? _errorMessage;

  // dados da localização do usuário
  Position? _currentPosition;
  bool _hasLocation = false;

  // dados da rota (para exibir no mapa)
  List<LatLng> _routePoints = [];
  bool _isRouteLoading = false;

  final ApiService _api = ApiService(); // instância do serviço de API para buscar dados de localização e unidades

  @override
  void initState() {
    super.initState();
    _loadLocationAndUnits();
  }

  // carrega a localização e depois as unidades próximas
  Future<void> _loadLocationAndUnits() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoading = false;
        _errorMessage = "O GPS está desativado. Ative a localização no seu dispositivo.";
      });
      return;
    }

    final posResult = await _api.getCurrentLocation(); // pega a posição atual do usuário usando
    if (!mounted) return;

    if (!posResult.isSuccess) {
      setState(() {
        _isLoading = false;
        _errorMessage = posResult.error;
      });
      return;
    }

    final pos = posResult.data!;
    setState(() {
      _currentPosition = pos; // armazena a posição atual do usuário
      _hasLocation = true;
    });

    // agora busca as unidades próximas
    await _fetchUnits(pos.latitude, pos.longitude); // manda para a função que busca as unidades de saúde próximas usando a API com a lat e lon!
  }

  // busca unidades próximas da API
  Future<void> _fetchUnits(double lat, double lon) async {
    final result = await _api.getNearbyUnits(lat, lon); // pega as unidades de saúde próximas da localização atual do usuário usando a API
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.isSuccess) {
      try{
        final List<dynamic> data = result.data!; // converte o JSON retornado pela API em uma lista de objetos HealthUnit
        final units = data.map((item) => HealthUnit.fromJson(item as Map<String, dynamic>)).toList();
        setState(() {
          _units = units;
          _filteredUnits = _applyFilter(units, _selectedFilter); // aplica o filtro selecionado para mostrar apenas as unidades do tipo escolhido
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Erro ao processar os dados das unidades.';
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _errorMessage = result.error;
      });
    }
  }

  // aplica o filtro selecionado
  List<HealthUnit> _applyFilter(List<HealthUnit> units, UnitType filter) {
    if (filter == UnitType.all) return units;
    return units.where((u) => u.type == filter).toList();
  }

  // atualiza o filtro
  void _updateFilter(UnitType filter) {
    setState(() {
      _selectedFilter = filter;
      _filteredUnits = _applyFilter(_units, filter);
    });
  }

  // busca a rota até uma unidade e exibe no mapa
  Future<void> _fetchRoute(HealthUnit destination) async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Localização não disponível')),
      );
      return;
    }

    setState(() {
      _isRouteLoading = true;
    });

    final result = await _api.getRoute( // chama a API para calcular a rota entre a localização atual do usuário e a unidade de saúde escolhida
      origemLat: _currentPosition!.latitude,
      origemLon: _currentPosition!.longitude,
      destinoLat: destination.lat,
      destinoLon: destination.lon,
    );

    if (!mounted) return;

    setState(() {
      _isRouteLoading = false;
    });

    if (result.isSuccess && result.data != null) {
      final data = result.data!; // pega os dados da rota retornados pela API (coordenadas, distância e duração)
      final coords = data['coordenadas'] as List<dynamic>;
      final points = coords
          .map((c) => LatLng(
                (c['latitude'] as num).toDouble(),
                (c['longitude'] as num).toDouble(),
              ))
          .toList();

      setState(() {
        _routePoints = points;
      });

      // exibe informações da rota
      final dist = data['distancia_km'] as num;
      final dur = data['duracao_min'] as int;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🚗 $dist km · ${dur}min'),
          duration: const Duration(seconds: 3),
          backgroundColor: AppColors.mint,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Erro ao calcular rota'),
          backgroundColor: AppColors.urgencyMedium,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) { // monta a tela principal com o mapa, filtros e lista de unidades
    return Scaffold(
      appBar: SalusAppBar(
        title: AppStrings.locationTitle,
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_rounded, color: AppColors.white),
            onPressed: _hasLocation ? _loadLocationAndUnits : null,
            tooltip: 'Atualizar localização',
          ),
        ],
      ),
      body: Column(
        children: [
          // mapa
          _buildMap(),
          // filtros
          _buildFilterChips(),
          // lista ou loading/erro
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_errorMessage != null)
            Expanded( // exibe uma mensagem de erro com botão para tentar novamente
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: AppColors.urgencyMedium),
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadLocationAndUnits,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mint,
                        ),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Expanded(child: _buildUnitList()),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }

  // monta o mapa principal com a localização do usuário e as unidades, depois desenha a rota, os pontos e o estado de carregamento do mapa
  Widget _buildMap() {
    return Container(
      height: 200,
      width: double.infinity,
      color: const Color(0xFFE8F5E9),
      child: _hasLocation
          ? FlutterMap(
              options: MapOptions( // configurações do mapa, incluindo a posição inicial e o zoom
                initialCenter: LatLng(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                ),
                initialZoom: 14,
              ),
              children: [
                TileLayer( // camada de tiles do mapa usando OpenStreetMap
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.salus',
                ),
                // marcador do usuário
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      width: 24,
                      height: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.blue.withValues(alpha: 0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // marcadores das unidades
                MarkerLayer(
                  markers: _filteredUnits.map((unit) {
                    return Marker(
                      point: LatLng(unit.lat, unit.lon),
                      width: 28,
                      height: 28,
                      child: Icon(
                        Icons.location_on_rounded,
                        color: unit.type == UnitType.upa
                            ? Colors.red
                            : unit.type == UnitType.hospital
                                ? Colors.blue
                                : AppColors.mint,
                        size: 28,
                      ),
                    );
                  }).toList(),
                ),
                // rota (se tiver)
                if (_routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        color: AppColors.blue,
                        strokeWidth: 4,
                      ),
                    ],
                  ),
                // indicador de carregamento da rota
                if (_isRouteLoading)
                  const Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            )
          : _buildMapPlaceholder(),
    );
  }

  // mostra um estado vazio quando ainda não há localização disponível (orienta a pessoa a ativar o GPS para continuar)
  Widget _buildMapPlaceholder() {
    return Stack(
      children: [
        Container(
          height: 200,
          color: const Color(0xFFE8F5E9),
          child: const Center(
            child: Text(
              'Ative o GPS para ver o mapa',
              style: TextStyle(color: AppColors.textHint),
            ),
          ),
        ),
        // badge informativo
        Positioned(
          bottom: 12,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Text(
                '📍 Toque em "Atualizar" para obter sua localização',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // cria os filtros por tipo de unidade de saúde (perimite alterar entre todos)
  Widget _buildFilterChips() {
    final filters = [
      (UnitType.all, AppStrings.locationFilterAll),
      (UnitType.ubs, AppStrings.locationFilterUbs),
      (UnitType.upa, AppStrings.locationFilterUpa),
      (UnitType.hospital, AppStrings.locationFilterHospital),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final isSelected = _selectedFilter == f.$1;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(f.$2),
                selected: isSelected,
                onSelected: (_) => _updateFilter(f.$1),
                backgroundColor: AppColors.mintSurface,
                selectedColor: AppColors.mint,
                checkmarkColor: AppColors.white,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.white : AppColors.mint,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                side: BorderSide(
                  color: isSelected ? AppColors.mint : AppColors.mint,
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // monta a lista de unidades após aplicar o filtro atual
  Widget _buildUnitList() {
    if (_filteredUnits.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma unidade encontrada nessa categoria.',
          style: TextStyle(color: AppColors.textHint),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: _filteredUnits.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _buildUnitCard(_filteredUnits[index]),
    );
  }

  // monta cada card de unidade com nome, endereço e badges e um botão para fazer a rota até ela
  Widget _buildUnitCard(HealthUnit unit) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildUnitIcon(unit.type),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unit.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  unit.isOpen24h ? 'Aberto 24h · ${unit.address}' : unit.address,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (unit.isSus)
                      _buildBadge(
                        'SUS',
                        const Color(0xFFE3F2FD),
                        const Color(0xFF1565C0),
                      ),
                    _buildBadge(
                      '${unit.distance.toStringAsFixed(1)} km',
                      const Color(0xFFF3E5F5),
                      const Color(0xFF7B1FA2),
                    ),
                    if (unit.isOpen24h)
                      _buildBadge(
                        '24h',
                        const Color(0xFFE8F5E9),
                        AppColors.mintDark,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _isRouteLoading ? null : () => _fetchRoute(unit),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mint,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: _isRouteLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : const Text(
                    AppStrings.locationRoute,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // escolhe o ícone e a cor do card conforme o tipo da unidade
  Widget _buildUnitIcon(UnitType type) {
    IconData icon;
    Color bg;
    switch (type) {
      case UnitType.upa:
        icon = Icons.local_hospital_rounded;
        bg = AppColors.mintLight;
        break;
      case UnitType.ubs:
        icon = Icons.medical_services_outlined;
        bg = const Color(0xFFE3F2FD);
        break;
      case UnitType.hospital:
        icon = Icons.domain_rounded;
        bg = const Color(0xFFFFF3E0);
        break;
      default:
        icon = Icons.location_on_rounded;
        bg = AppColors.surface;
    }
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppColors.mint, size: 22),
    );
  }

  // cria os badges visuais para mostrar SUS, distância e horário
  Widget _buildBadge(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}