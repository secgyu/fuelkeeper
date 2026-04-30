import 'package:flutter/material.dart';
import 'package:fuelkeeper/features/legal/presentation/widgets/legal_document_view.dart';

class DataSourcesPage extends StatelessWidget {
  const DataSourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentView(
      title: '데이터 출처 및 저작권',
      effectiveDate: '2026년 4월 30일',
      children: [
        LegalSection(
          heading: '주유 가격 정보',
          children: [
            LegalKeyValueTable(
              rows: [
                (label: '제공처', value: '한국석유공사 Opinet'),
                (
                  label: '내용',
                  value:
                      '전국 주유소의 위치, 브랜드, 연료별 판매 가격, '
                      '편의시설 정보(세차장, 정비, 편의점 등).',
                ),
                (
                  label: '갱신 주기',
                  value:
                      '운영자 신고에 따른 비실시간 데이터입니다. '
                      '실제 현장 가격과 차이가 있을 수 있습니다.',
                ),
              ],
            ),
          ],
        ),
        LegalSection(
          heading: '지도',
          children: [
            LegalKeyValueTable(
              rows: [
                (label: '제공처', value: 'NAVER Maps SDK for Flutter'),
                (label: '용도', value: '주유소 위치 시각화 및 사용자 현재 위치 표시.'),
                (
                  label: '저작권',
                  value:
                      '© NAVER Corp. 지도 데이터의 저작권은 '
                      '네이버 및 관련 제공자에게 귀속됩니다.',
                ),
              ],
            ),
          ],
        ),
        LegalSection(
          heading: '주소·행정구역 변환',
          children: [
            LegalKeyValueTable(
              rows: [
                (label: '제공처', value: 'Kakao Local API'),
                (
                  label: '용도',
                  value:
                      '사용자 현재 좌표를 한국 행정구역(시·도, 구, 동) '
                      '문자열로 변환합니다.',
                ),
                (label: '저작권', value: '© Kakao Corp.'),
              ],
            ),
          ],
        ),
        LegalSection(
          heading: '센서 정보',
          children: [
            LegalKeyValueTable(
              rows: [
                (label: '용도', value: '지도에서 사용자가 향하는 방향 표시.'),
                (
                  label: '데이터',
                  value: '단말기 자기장 센서(나침반) 값. 단말기 외부로 전송되거나 저장되지 않습니다.',
                ),
              ],
            ),
          ],
        ),
        LegalSection(
          heading: '오픈소스 라이선스',
          children: [
            LegalParagraph(
              '본 앱은 다양한 오픈소스 라이브러리(Flutter, Riverpod, Hive, '
              'Dio, flutter_compass 등)를 사용합니다. 각 라이브러리의 '
              '라이선스 전문은 설정 화면의 "오픈소스 라이선스"에서 확인할 수 있습니다.',
            ),
          ],
        ),
      ],
    );
  }
}
