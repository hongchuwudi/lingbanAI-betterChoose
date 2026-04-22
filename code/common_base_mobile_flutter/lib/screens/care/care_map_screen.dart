import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_baidu_mapapi_map/flutter_baidu_mapapi_map.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:flutter_baidu_mapapi_search/flutter_baidu_mapapi_search.dart';
import 'package:flutter_bmflocation/flutter_bmflocation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../widgets/notification/notification_helper.dart';
import '../../config/api_keys.dart';

class CareMapScreen extends StatefulWidget {
  const CareMapScreen({super.key});

  @override
  State<CareMapScreen> createState() => _CareMapScreenState();
}

class _CareMapScreenState extends State<CareMapScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  BMFMapController? _mapController;
  final LocationFlutterPlugin _locationPlugin = LocationFlutterPlugin();

  double? _currentLat;
  double? _currentLng;
  String _currentAddress = '';
  bool _isLocating = false;

  double? _homeLat;
  double? _homeLng;
  String _homeAddress = '';
  bool _hasHomeLocation = false;

  List<HospitalInfo> _hospitals = [];
  bool _isSearchingHospitals = false;

  final List<BMFMarker> _markers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _requestLocationPermission();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _locationPlugin.stopLocation();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      status = await Permission.location.request();
    }
    if (status.isGranted) {
      _initLocation();
    } else {
      NotificationHelper.showWarning(message: '需要定位权限才能使用地图功能');
    }
  }

  void _initLocation() {
    _locationPlugin.setAgreePrivacy(true);

    if (Platform.isIOS) {
      _locationPlugin.authAK(ApiKeys.baiduMapIosKey);
    }

    final androidOption = BaiduLocationAndroidOption(
      coordType: BMFLocationCoordType.bd09ll,
      isNeedAddress: true,
      openGps: true,
      locationMode: BMFLocationMode.hightAccuracy,
      scanspan: 0,
    );
    final iosOption = BaiduLocationIOSOption(
      coordType: BMFLocationCoordType.bd09ll,
      locationTimeout: 10,
      reGeocodeTimeout: 10,
    );
    _locationPlugin.prepareLoc(androidOption.getMap(), iosOption.getMap());

    _startLocation();
  }

  void _startLocation() {
    setState(() => _isLocating = true);

    _locationPlugin.seriesLocationCallback(
      callback: (BaiduLocation result) {
        if (result != null && mounted) {
          double? lat = result.latitude;
          double? lng = result.longitude;
          String addr = result.address ?? result.locationDetail ?? '';

          if (lat != null && lng != null && lat != 0.0 && lng != 0.0) {
            setState(() {
              _currentLat = lat;
              _currentLng = lng;
              _currentAddress = addr;
              _isLocating = false;
            });
            _moveToPosition(lat, lng);
            _locationPlugin.stopLocation();
          }
        }
      },
    );

    _locationPlugin.startLocation();

    Future.delayed(const Duration(seconds: 15), () {
      if (_isLocating && mounted) {
        setState(() => _isLocating = false);
        NotificationHelper.showWarning(message: '定位超时，请检查定位权限和网络');
      }
    });
  }

  void _moveToPosition(double lat, double lng) {
    if (_mapController == null) return;
    final coordinate = BMFCoordinate(lat, lng);
    _mapController!.setCenterCoordinate(coordinate, true);
    _mapController!.setZoomTo(16);
  }

  void _onMapCreated(BMFMapController controller) {
    _mapController = controller;

    _mapController!.setMapDidLoadCallback(callback: () {
      debugPrint('[BaiduMap] 地图加载完成');
    });

    if (_currentLat != null && _currentLng != null) {
      _moveToPosition(_currentLat!, _currentLng!);
      _addCurrentLocationMarker();
    }
  }

  Future<void> _addCurrentLocationMarker() async {
    if (_mapController == null || _currentLat == null) return;
    final marker = BMFMarker(
      position: BMFCoordinate(_currentLat!, _currentLng!),
      title: '当前位置',
      identifier: 'current_location',
    );
    await _mapController!.addMarker(marker);
    _markers.add(marker);
  }

  Future<void> _clearMarkers() async {
    if (_mapController == null) return;
    for (var marker in _markers) {
      await _mapController!.removeMarker(marker);
    }
    _markers.clear();
  }

  Future<void> _addHomeMarker() async {
    if (_mapController == null || _homeLat == null) return;
    await _clearMarkers();
    await _addCurrentLocationMarker();

    final homeMarker = BMFMarker(
      position: BMFCoordinate(_homeLat!, _homeLng!),
      title: '家园',
      subtitle: _homeAddress,
      identifier: 'home_location',
    );
    await _mapController!.addMarker(homeMarker);
    _markers.add(homeMarker);
  }

  Future<void> _addHospitalMarkers() async {
    if (_mapController == null) return;
    await _clearMarkers();
    await _addCurrentLocationMarker();
    if (_hasHomeLocation) await _addHomeMarker();

    for (var hospital in _hospitals) {
      final marker = BMFMarker(
        position: BMFCoordinate(hospital.lat, hospital.lng),
        title: hospital.name,
        subtitle: hospital.address,
        identifier: 'hospital_${hospital.name}',
      );
      await _mapController!.addMarker(marker);
      _markers.add(marker);
    }
  }

  Future<void> _setHomeLocation() async {
    if (_currentLat == null) {
      NotificationHelper.showWarning(message: '请先获取当前位置');
      return;
    }

    setState(() {
      _homeLat = _currentLat;
      _homeLng = _currentLng;
      _homeAddress = _currentAddress.isNotEmpty ? _currentAddress : '已标记家园位置';
      _hasHomeLocation = true;
    });

    await _addHomeMarker();
    NotificationHelper.showSuccess(message: '家园位置已设置');
  }

  Future<void> _searchNearbyHospitals() async {
    if (_currentLat == null) {
      NotificationHelper.showWarning(message: '请先获取当前位置');
      return;
    }

    setState(() => _isSearchingHospitals = true);

    final poiNearbySearch = BMFPoiNearbySearch();
    final poiSearchParam = BMFPoiNearbySearchOption(
      keywords: ['医院', '诊所', '卫生院'],
      location: BMFCoordinate(_currentLat!, _currentLng!),
      radius: 5000,
      pageIndex: 0,
      pageSize: 20,
    );

    poiNearbySearch.onGetPoiNearbySearchResult(
      callback: (result, errorCode) {
        if (errorCode == BMFSearchErrorCode.NO_ERROR &&
            result.poiInfoList != null &&
            mounted) {
          setState(() {
            _hospitals = result.poiInfoList!.map((poi) {
              return HospitalInfo(
                name: poi.name ?? '未知医院',
                address: poi.address ?? '未知地址',
                lat: poi.pt?.latitude ?? 0.0,
                lng: poi.pt?.longitude ?? 0.0,
                distance: (poi.distance ?? 0.0).toDouble(),
                phone: poi.phone ?? '',
              );
            }).toList();
            _isSearchingHospitals = false;
          });
          _addHospitalMarkers();
        } else {
          if (mounted) {
            setState(() => _isSearchingHospitals = false);
            debugPrint('[BaiduSearch] POI搜索失败，errorCode: $errorCode');
            NotificationHelper.showWarning(
              message: '搜索失败(errorCode:$errorCode)',
            );
          }
        }
      },
    );

    await poiNearbySearch.poiNearbySearch(poiSearchParam);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '家园定位',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF252542) : Colors.white,
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: colorScheme.primary,
              unselectedLabelColor: isDark ? Colors.white54 : Colors.black45,
              indicatorColor: colorScheme.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: '家园定位'),
                Tab(text: '周边医院'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(flex: 3, child: _buildMapView()),
          Expanded(
            flex: 2,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHomeLocationTab(isDark, colorScheme),
                _buildHospitalTab(isDark, colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeLocationTab(bool isDark, ColorScheme colorScheme) {
    return _buildHomeLocationPanel(isDark, colorScheme);
  }

  Widget _buildHospitalTab(bool isDark, ColorScheme colorScheme) {
    return _buildHospitalPanel(isDark, colorScheme);
  }

  Widget _buildMapView() {
    return Stack(
      children: [
        BMFMapWidget(
          onBMFMapCreated: _onMapCreated,
          mapOptions: BMFMapOptions(
            center: BMFCoordinate(39.915, 116.404),
            zoomLevel: 15,
            showMapScaleBar: true,
          ),
        ),
        if (_isLocating)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildHomeLocationPanel(bool isDark, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252542) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  LucideIcons.mapPin,
                  color: colorScheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '当前位置',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _currentAddress.isNotEmpty
                          ? _currentAddress
                          : '正在获取位置...',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (_isLocating)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                ),
            ],
          ),
          if (_hasHomeLocation) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.home,
                    color: Colors.green.shade600,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '家园位置',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _homeAddress,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_homeLat != null) {
                        _moveToPosition(_homeLat!, _homeLng!);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '导航',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: LucideIcons.locate,
                  label: '重新定位',
                  color: colorScheme.primary,
                  isDark: isDark,
                  colorScheme: colorScheme,
                  onTap: _startLocation,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: LucideIcons.home,
                  label: _hasHomeLocation ? '更新家园' : '设为家园',
                  color: Colors.green,
                  isDark: isDark,
                  colorScheme: colorScheme,
                  onTap: _setHomeLocation,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalPanel(bool isDark, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252542) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      LucideIcons.building2,
                      color: Colors.red.shade400,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    '周边医院',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _isSearchingHospitals ? null : _searchNearbyHospitals,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red.shade400, Colors.red.shade300],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _isSearchingHospitals
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.search,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '搜索',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _hospitals.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.mapPin,
                          size: 36,
                          color: isDark ? Colors.white24 : Colors.black12,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '点击搜索查找周边医院',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white38 : Colors.black26,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: _hospitals.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final hospital = _hospitals[index];
                      return _buildHospitalCard(hospital, isDark, colorScheme);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalCard(
    HospitalInfo hospital,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      onTap: () {
        _moveToPosition(hospital.lat, hospital.lng);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                LucideIcons.building2,
                color: Colors.red.shade400,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hospital.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hospital.address,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (hospital.distance > 0)
                  Text(
                    hospital.distance < 1000
                        ? '${hospital.distance.toStringAsFixed(0)}m'
                        : '${(hospital.distance / 1000).toStringAsFixed(1)}km',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                const SizedBox(height: 4),
                Icon(
                  LucideIcons.navigation,
                  color: colorScheme.primary,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required ColorScheme colorScheme,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.8)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HospitalInfo {
  final String name;
  final String address;
  final double lat;
  final double lng;
  final double distance;
  final String phone;

  HospitalInfo({
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.distance,
    required this.phone,
  });
}
