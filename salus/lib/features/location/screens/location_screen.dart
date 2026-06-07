import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/salus_app_bar.dart';

enum UnitType { all, ubs, upa, hospital }

class HealthUnit {
  final String name;
  final String address;
  final String distance;
  final UnitType type;
  final bool isSus;
  final bool isOpen24h;

  const HealthUnit({
    required this.name,
    required this.address,
    required this.distance,
    required this.type,
    required this.isSus,
    required this.isOpen24h,
  });
}

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  UnitType _selectedFilter = UnitType.all;

  // Dados simulados
  final List<HealthUnit> _units = const [
    HealthUnit(
      name: 'UPA Barreiro',
      address: 'R. das Rosas, 120 - Barreiro',
      distance: '1,2 km',
      type: UnitType.upa,
      isSus: true,
      isOpen24h: true,
    ),
    HealthUnit(
      name: 'UBS Vila Clóris',
      address: 'Av. dos Andradas, 890 - Vila Clóris',
      distance: '1,8 km',
      type: UnitType.ubs,
      isSus: true,
      isOpen24h: false,
    ),
    HealthUnit(
      name: 'Hospital Vera Cruz',
      address: 'Av. Principal, 450 - Centro',
      distance: '2,5 km',
      type: UnitType.hospital,
      isSus: false,
      isOpen24h: true,
    ),
    HealthUnit(
      name: 'UPA Venda Nova',
      address: 'R. Padre Pedro Pinto, 1200',
      distance: '3,1 km',
      type: UnitType.upa,
      isSus: true,
      isOpen24h: true,
    ),
    HealthUnit(
      name: 'UBS Planalto',
      address: 'R. das Figueiras, 340 - Planalto',
      distance: '3,7 km',
      type: UnitType.ubs,
      isSus: true,
      isOpen24h: false,
    ),
  ];

  List<HealthUnit> get _filteredUnits => _selectedFilter == UnitType.all
      ? _units
      : _units.where((u) => u.type == _selectedFilter).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SalusAppBar(
        title: AppStrings.locationTitle,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_rounded, color: AppColors.white),
            onPressed: () {
              // TODO: obter localização atual via geolocator
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildMapPlaceholder(),
          _buildFilterChips(),
          Expanded(child: _buildUnitList()),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    // TODO: substituir pelo google_maps_flutter widget
    return Container(
      height: 200,
      width: double.infinity,
      color: const Color(0xFFE8F5E9),
      child: Stack(
        children: [
          // Grid de ruas simulado
          CustomPaint(
            size: const Size(double.infinity, 200),
            painter: _MapGridPainter(),
          ),
          // Pin do usuário
          Positioned(
            left: MediaQuery.of(context).size.width * 0.4,
            top: 100,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.blue.withValues(alpha: 0.3),
                      blurRadius: 8)
                ],
              ),
            ),
          ),
          // Pins das unidades
          _buildMapPin(left: 0.2, top: 0.25, color: AppColors.mint),
          _buildMapPin(left: 0.6, top: 0.55, color: AppColors.urgencyMedium),
          _buildMapPin(left: 0.75, top: 0.3, color: AppColors.mint),
          // Badge informativo
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8)
                  ],
                ),
                child: const Text(
                  '📍 Sua localização atual',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPin({
    required double left,
    required double top,
    required Color color,
  }) {
    return Positioned(
      left: MediaQuery.of(context).size.width * left,
      top: 200 * top,
      child: Icon(Icons.location_on_rounded, color: color, size: 28),
    );
  }

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
                onSelected: (_) => setState(() => _selectedFilter = f.$1),
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
                    width: 1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildUnitList() {
    final units = _filteredUnits;
    if (units.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma unidade encontrada nessa categoria.',
          style: TextStyle(color: AppColors.textHint),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: units.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _buildUnitCard(units[index]),
    );
  }

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
                  unit.isOpen24h
                      ? 'Aberto 24h · ${unit.address}'
                      : unit.address,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (unit.isSus)
                      _buildBadge(AppStrings.locationSus,
                          const Color(0xFFE3F2FD), const Color(0xFF1565C0)),
                    if (unit.isSus) const SizedBox(width: 6),
                    _buildBadge(unit.distance, const Color(0xFFF3E5F5),
                        const Color(0xFF7B1FA2)),
                    if (unit.isOpen24h) ...[
                      const SizedBox(width: 6),
                      _buildBadge(
                          '24h',
                          const Color(0xFFE8F5E9),
                          AppColors.mintDark),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              // TODO: abrir Maps API com rota
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mint,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              AppStrings.locationRoute,
              style: TextStyle(
                  color: AppColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

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
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: AppColors.mint, size: 22),
    );
  }

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
            fontSize: 11, fontWeight: FontWeight.w600, color: textColor),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 8;

    // Ruas horizontais
    canvas.drawLine(
        Offset(0, size.height * 0.4), Offset(size.width, size.height * 0.4), paint);
    canvas.drawLine(
        Offset(0, size.height * 0.75), Offset(size.width, size.height * 0.75), paint);

    // Ruas verticais
    canvas.drawLine(
        Offset(size.width * 0.35, 0), Offset(size.width * 0.35, size.height), paint);
    canvas.drawLine(
        Offset(size.width * 0.7, 0), Offset(size.width * 0.7, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
