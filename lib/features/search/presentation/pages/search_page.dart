import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/theme/app_color_tokens.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/core/location/kakao_local_repository.dart';
import 'package:fuelkeeper/core/location/location_providers.dart';
import 'package:fuelkeeper/features/search/application/search_providers.dart';

/// 키워드 검색으로 다른 동네/장소 주변 주유소를 보러 가는 페이지.
///
/// 결과 항목을 탭하면 [locationOverrideProvider]가 그 좌표로 설정되고
/// 페이지가 닫혀 홈/지도가 새 위치 기준으로 다시 로드된다.
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 320), () {
      if (!mounted) return;
      ref.read(searchQueryProvider.notifier).set(value);
    });
  }

  void _selectPlace(KakaoPlace place) {
    ref.read(locationOverrideProvider.notifier).set(
          LocationOverride(
            location: place.location,
            label: place.name,
          ),
        );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${place.name} 주변 주유소를 보여드릴게요'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final resultsAsync = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          textInputAction: TextInputAction.search,
          onChanged: _onChanged,
          onSubmitted: (v) => ref.read(searchQueryProvider.notifier).set(v),
          style: TextStyle(
            fontSize: 16,
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: '주유소·동·역 이름으로 검색',
            hintStyle: TextStyle(
              color: context.colors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
            border: InputBorder.none,
          ),
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                _controller.clear();
                ref.read(searchQueryProvider.notifier).set('');
                _focusNode.requestFocus();
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (query.trim().length < 2) {
              return const _SearchHint();
            }
            return resultsAsync.when(
              loading: () => const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.2),
                ),
              ),
              error: (_, _) => const _NoResults(message: '검색에 실패했어요'),
              data: (places) {
                if (places.isEmpty) {
                  return const _NoResults(message: '검색 결과가 없어요');
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm,
                  ),
                  itemCount: places.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    thickness: 1,
                    color: context.colors.borderHair,
                    indent: AppSpacing.lg,
                    endIndent: AppSpacing.lg,
                  ),
                  itemBuilder: (_, i) => _PlaceTile(
                    place: places[i],
                    onTap: () => _selectPlace(places[i]),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _PlaceTile extends StatelessWidget {
  const _PlaceTile({required this.place, required this.onTap});

  final KakaoPlace place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final distanceLabel = place.distanceMeters != null
        ? _formatDistance(place.distanceMeters!)
        : null;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                Icons.place_outlined,
                color: context.colors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    place.address.isEmpty ? place.category : place.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            if (distanceLabel != null) ...[
              const SizedBox(width: AppSpacing.sm),
              Text(
                distanceLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _formatDistance(int meters) {
    if (meters < 1000) return '${meters}m';
    return '${(meters / 1000).toStringAsFixed(1)}km';
  }
}

class _SearchHint extends StatelessWidget {
  const _SearchHint();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_rounded,
              size: 48,
              color: context.colors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '주유소·동·역 이름을 입력해보세요',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '예) 강남역, 대연동, GS칼텍스 양재점',
              style: TextStyle(
                fontSize: 12,
                color: context.colors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text(
          message,
          style: TextStyle(
            fontSize: 14,
            color: context.colors.textTertiary,
          ),
        ),
      ),
    );
  }
}
