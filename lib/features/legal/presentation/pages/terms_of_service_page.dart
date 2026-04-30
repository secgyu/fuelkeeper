import 'package:flutter/material.dart';
import 'package:fuelkeeper/features/legal/presentation/widgets/legal_document_view.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentView(
      title: '이용약관',
      effectiveDate: '2026년 4월 30일',
      disclaimer:
          '본 약관은 일반 템플릿을 기반으로 작성되었으며, '
          '실제 출시 전 운영자/사업자 정보를 반영하고 변호사 검토를 받을 것을 권장합니다.',
      children: [
        LegalSection(
          heading: '제1조 (목적)',
          children: [
            LegalParagraph(
              '본 약관은 사용자가 FuelKeeper(이하 "앱")가 제공하는 '
              '주유소 가격 비교 및 주유 기록 관리 서비스를 이용함에 있어 '
              '운영자와 사용자의 권리·의무·책임 사항을 규정함을 목적으로 합니다.',
            ),
          ],
        ),
        LegalSection(
          heading: '제2조 (서비스의 내용)',
          children: [
            LegalParagraph('앱이 제공하는 주요 서비스는 다음과 같습니다.'),
            LegalBulletList(
              items: [
                '사용자 위치 기반 주변 주유소 검색 및 가격 비교',
                '주유소 상세 정보 및 즐겨찾기 관리',
                '주유 기록 입력·조회·통계 제공',
                '지도 기반 주유소 위치 안내',
              ],
            ),
          ],
        ),
        LegalSection(
          heading: '제3조 (서비스 이용)',
          children: [
            LegalBulletList(
              items: [
                '앱은 별도의 회원 가입 없이 누구나 무료로 이용할 수 있습니다.',
                '서비스 이용 중 발생하는 데이터 통신 요금은 사용자 본인이 부담합니다.',
                '운영자는 서비스의 안정적 제공을 위해 사전 공지 없이 점검·업데이트를 진행할 수 있습니다.',
              ],
            ),
          ],
        ),
        LegalSection(
          heading: '제4조 (가격 정보의 정확성)',
          children: [
            LegalParagraph(
              '앱이 제공하는 주유 가격 정보는 한국석유공사 Opinet에서 제공하는 '
              '공공 데이터를 기반으로 하며, 다음 사항에 유의해야 합니다.',
            ),
            LegalBulletList(
              items: [
                '가격은 실시간이 아닐 수 있으며, 실제 주유소 현장 가격과 차이가 발생할 수 있습니다.',
                '주유소의 운영 상태(휴업·폐업·임시 가격 변동)는 즉시 반영되지 않을 수 있습니다.',
                '최종 가격은 반드시 주유소 현장에서 직접 확인하시기 바랍니다.',
                '운영자는 가격 정보의 오류로 인한 손해에 대해 책임지지 않습니다.',
              ],
            ),
          ],
        ),
        LegalSection(
          heading: '제5조 (사용자의 의무)',
          children: [
            LegalBulletList(
              items: [
                '사용자는 본 약관 및 관련 법령을 준수해야 합니다.',
                '서비스를 상업적 목적의 데이터 수집·재배포·역설계 등에 이용해서는 안 됩니다.',
                '서비스에 비정상적인 부하를 유발하는 자동화 도구·크롤링을 사용해서는 안 됩니다.',
                '앱이 제공하는 가격·위치 정보를 가공·재가공해 별도 서비스를 제공하려면 사전 협의가 필요합니다.',
              ],
            ),
          ],
        ),
        LegalSection(
          heading: '제6조 (지식재산권)',
          children: [
            LegalBulletList(
              items: [
                '앱의 디자인, UI/UX, 코드 등 일체의 저작물은 운영자에게 귀속됩니다.',
                '주유 가격·주유소 정보의 원천 권리는 한국석유공사 Opinet에 있습니다.',
                '지도 데이터의 저작권은 NAVER Cloud Platform 및 관련 제공자에게 귀속됩니다.',
                '주소·행정구역 변환 데이터의 저작권은 Kakao Corp.에 귀속됩니다.',
              ],
            ),
          ],
        ),
        LegalSection(
          heading: '제7조 (면책)',
          children: [
            LegalBulletList(
              items: [
                '운영자는 천재지변, 통신 장애, 외부 API의 일시적 장애 등 운영자의 통제 밖 사유로 인한 서비스 중단에 책임지지 않습니다.',
                '사용자가 입력한 주유 기록의 정확성과 보관 책임은 사용자 본인에게 있습니다.',
                '단말기 분실·고장·앱 삭제 등으로 인한 데이터 손실에 대해 운영자는 책임지지 않습니다. 중요한 데이터는 별도로 백업해 주시기 바랍니다.',
                '사용자의 부주의(예: 주유소 현장 가격 미확인)로 인한 금전적 손해에 대해 운영자는 책임지지 않습니다.',
              ],
            ),
          ],
        ),
        LegalSection(
          heading: '제8조 (서비스의 변경 및 종료)',
          children: [
            LegalParagraph(
              '운영자는 사업상·기술상의 사유로 서비스의 일부 또는 전부를 '
              '변경하거나 종료할 수 있습니다. 종료 시에는 앱 내 공지 또는 '
              '스토어 안내를 통해 사전 고지합니다.',
            ),
          ],
        ),
        LegalSection(
          heading: '제9조 (분쟁 해결)',
          children: [
            LegalParagraph(
              '본 약관과 관련해 발생한 분쟁은 대한민국 법령에 따라 처리됩니다. '
              '관할 법원은 운영자의 주된 사업장 소재지를 관할하는 법원으로 합니다.',
            ),
          ],
        ),
        LegalSection(
          heading: '부칙',
          children: [LegalParagraph('본 약관은 시행일부터 적용됩니다.')],
        ),
      ],
    );
  }
}
