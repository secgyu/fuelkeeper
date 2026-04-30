import 'package:flutter/material.dart';
import 'package:fuelkeeper/features/legal/presentation/widgets/legal_document_view.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentView(
      title: '개인정보 처리방침',
      effectiveDate: '2026년 4월 30일',
      disclaimer:
          '본 문서는 일반 템플릿을 기반으로 작성되었으며, '
          '실제 서비스 출시 전 운영자 정보(사업자명, 연락처, 개인정보 보호책임자)를 '
          '채우고 변호사 검토를 받을 것을 권장합니다.',
      children: [
        LegalSection(
          heading: '1. 총칙',
          children: [
            LegalParagraph(
              'FuelKeeper(이하 "앱")는 사용자의 개인정보를 소중히 다루며, '
              '관련 법령에 따라 안전하게 처리합니다. 본 방침은 앱이 어떤 정보를 '
              '수집하고, 어떻게 이용·보관·파기하는지 설명합니다.',
            ),
          ],
        ),
        LegalSection(
          heading: '2. 수집하는 개인정보 항목',
          children: [
            LegalParagraph('앱은 서비스 제공에 필요한 최소한의 정보만 수집합니다.'),
            LegalKeyValueTable(
              rows: [
                (
                  label: '위치 정보',
                  value:
                      '단말기 GPS/네트워크 기반 현재 위치(위도·경도). '
                      '주변 주유소 검색 및 거리 계산 목적으로 사용합니다.',
                ),
                (
                  label: '주유 기록',
                  value:
                      '사용자가 직접 입력한 날짜·금액·주유량·주행거리 등. '
                      '단말기 내부에만 저장되며 서버로 전송되지 않습니다.',
                ),
                (
                  label: '즐겨찾기',
                  value:
                      '사용자가 등록한 주유소 ID 목록. '
                      '단말기 내부에만 저장됩니다.',
                ),
                (
                  label: '앱 설정',
                  value:
                      '선호 연료 종류, 정렬 옵션 등. '
                      '단말기 내부에만 저장됩니다.',
                ),
              ],
            ),
            SizedBox(height: 12),
            LegalParagraph(
              '앱은 이름·이메일·전화번호 등 개인 식별 정보, 결제 정보, '
              '단말기 고유 식별자(IMEI, MAC 주소 등)를 수집하지 않습니다.',
            ),
          ],
        ),
        LegalSection(
          heading: '3. 위치정보의 처리',
          children: [
            LegalParagraph(
              '앱은 「위치정보의 보호 및 이용 등에 관한 법률」에 따라 '
              '다음과 같이 위치정보를 처리합니다.',
            ),
            LegalBulletList(
              items: [
                '수집 목적: 사용자 주변 주유소 검색, 거리 계산, 지도 표시.',
                '수집 시점: 사용자가 앱을 실행하고 위치 권한을 허용한 시점.',
                '보관 기간: 위치 정보는 단말기 내부에서만 일시적으로 사용되며 별도로 저장하지 않습니다.',
                '제3자 제공: 카카오 Local API에 좌표를 전달해 행정 동·구 정보를 받아옵니다. 이때 좌표는 주소 변환 용도로만 사용되고 카카오 측에 영구 저장되지 않는 것을 확인하였습니다.',
                '권한 거부: 위치 권한을 거부해도 앱의 다른 기능(주유 기록, 통계)은 정상 사용할 수 있으나 주변 주유소 검색은 제한될 수 있습니다.',
              ],
            ),
          ],
        ),
        LegalSection(
          heading: '4. 개인정보의 보유 및 이용 기간',
          children: [
            LegalBulletList(
              items: [
                '주유 기록·즐겨찾기·앱 설정은 사용자가 앱을 삭제하거나 설정에서 직접 삭제할 때까지 단말기 내부에 보관됩니다.',
                '위치 정보는 별도 저장 없이 요청 시점에만 사용됩니다.',
                '사용자는 언제든지 앱 설정의 "데이터 관리"에서 즐겨찾기·주유 기록을 삭제할 수 있습니다.',
              ],
            ),
          ],
        ),
        LegalSection(
          heading: '5. 제3자 제공 및 처리 위탁',
          children: [
            LegalParagraph(
              '앱은 다음의 외부 서비스를 이용하며, 각 서비스에는 서비스 제공에 '
              '필요한 최소 정보만 전달됩니다.',
            ),
            LegalKeyValueTable(
              rows: [
                (
                  label: '한국석유공사 Opinet',
                  value: '주유소 정보 및 가격 조회. 좌표(KATEC 변환)만 전달.',
                ),
                (
                  label: 'NAVER Maps SDK',
                  value: '지도 화면 표시. 사용자 화면 영역의 지도 타일만 요청.',
                ),
                (label: 'Kakao Local API', value: '좌표 → 행정구역 변환. 위·경도만 전달.'),
              ],
            ),
            SizedBox(height: 12),
            LegalParagraph(
              '앱은 사용자의 개인정보를 위 서비스 외의 제3자에게 제공하거나 '
              '판매하지 않습니다.',
            ),
          ],
        ),
        LegalSection(
          heading: '6. 단말기 권한 안내',
          children: [
            LegalKeyValueTable(
              rows: [
                (label: '위치(필수)', value: '주변 주유소 검색 및 지도 표시.'),
                (label: '모션·나침반(선택)', value: '지도에서 사용자 방향 표시(아이폰만 명시적 권한 필요).'),
                (label: '전화(선택)', value: '주유소 상세에서 전화 걸기 버튼 사용 시.'),
              ],
            ),
          ],
        ),
        LegalSection(
          heading: '7. 사용자의 권리',
          children: [
            LegalBulletList(
              items: [
                '사용자는 단말기 OS 설정에서 언제든지 위치 권한을 변경하거나 철회할 수 있습니다.',
                '주유 기록·즐겨찾기 데이터는 앱 내 "설정 > 데이터 관리"에서 직접 삭제할 수 있습니다.',
                '앱을 삭제하면 단말기 내부의 모든 사용자 데이터가 함께 삭제됩니다.',
              ],
            ),
          ],
        ),
        LegalSection(
          heading: '8. 개인정보 보호책임자',
          children: [
            LegalParagraph(
              '개인정보 처리에 관한 문의는 아래 연락처로 보내주시기 바랍니다. '
              '(출시 전 본인 정보로 교체 필요)',
            ),
            LegalKeyValueTable(
              rows: [
                (label: '책임자', value: '[운영자 이름]'),
                (label: '이메일', value: '[support@example.com]'),
              ],
            ),
          ],
        ),
        LegalSection(
          heading: '9. 정책의 변경',
          children: [
            LegalParagraph(
              '본 방침은 법령·서비스 변경에 따라 수정될 수 있으며, '
              '변경 시 앱 내 공지를 통해 안내합니다. '
              '중요 변경의 경우 시행 7일 전부터 안내합니다.',
            ),
          ],
        ),
      ],
    );
  }
}
