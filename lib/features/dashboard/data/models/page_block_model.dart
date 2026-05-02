/// A content block inside an app page.
/// Types: banner, card, button, text, image, section_header, spacer
class PageBlock {
  final String id;
  final String pageId;
  final String type;
  final String nameAr;
  final String nameEn;
  final String imageUrl;
  final String link;
  final String content; // text content for text/button blocks
  final String subtitle; // subtitle for banner/card
  final bool isActive;
  final int order;

  const PageBlock({
    required this.id,
    required this.pageId,
    this.type = 'card',
    this.nameAr = '',
    this.nameEn = '',
    this.imageUrl = '',
    this.link = '',
    this.content = '',
    this.subtitle = '',
    this.isActive = true,
    this.order = 0,
  });

  PageBlock copyWith({
    String? type,
    String? nameAr,
    String? nameEn,
    String? imageUrl,
    String? link,
    String? content,
    String? subtitle,
    bool? isActive,
    int? order,
  }) =>
      PageBlock(
        id: id,
        pageId: pageId,
        type: type ?? this.type,
        nameAr: nameAr ?? this.nameAr,
        nameEn: nameEn ?? this.nameEn,
        imageUrl: imageUrl ?? this.imageUrl,
        link: link ?? this.link,
        content: content ?? this.content,
        subtitle: subtitle ?? this.subtitle,
        isActive: isActive ?? this.isActive,
        order: order ?? this.order,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'pageId': pageId,
        'type': type,
        'nameAr': nameAr,
        'nameEn': nameEn,
        'imageUrl': imageUrl,
        'link': link,
        'content': content,
        'subtitle': subtitle,
        'isActive': isActive,
        'order': order,
      };

  factory PageBlock.fromMap(Map<String, dynamic> d) => PageBlock(
        id: d['id']?.toString() ?? '',
        pageId: d['pageId']?.toString() ?? '',
        type: d['type']?.toString() ?? 'card',
        nameAr: d['nameAr']?.toString() ?? '',
        nameEn: d['nameEn']?.toString() ?? '',
        imageUrl: d['imageUrl']?.toString() ?? '',
        link: d['link']?.toString() ?? '',
        content: d['content']?.toString() ?? '',
        subtitle: d['subtitle']?.toString() ?? '',
        isActive: d['isActive'] as bool? ?? true,
        order: d['order'] as int? ?? 0,
      );
}

const List<Map<String, String>> kBlockTypes = [
  {'id': 'banner',         'ar': 'بانر رئيسي',      'icon': 'view_carousel'},
  {'id': 'card',           'ar': 'بطاقة',            'icon': 'credit_card'},
  {'id': 'button',         'ar': 'زر',               'icon': 'smart_button'},
  {'id': 'text',           'ar': 'نص',               'icon': 'text_fields'},
  {'id': 'image',          'ar': 'صورة',             'icon': 'image'},
  {'id': 'section_header', 'ar': 'عنوان قسم',        'icon': 'title'},
  {'id': 'spacer',         'ar': 'مساحة فارغة',      'icon': 'space_bar'},
];

String blockTypeLabel(String type) =>
    kBlockTypes.firstWhere((t) => t['id'] == type, orElse: () => {'ar': type})['ar'] ?? type;
