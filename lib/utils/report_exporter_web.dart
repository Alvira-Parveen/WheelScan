import 'dart:html' as html;

void exportReportHtml(String title, String htmlContent) {
  final blob = html.Blob([htmlContent], 'text/html;charset=utf-8');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', '${title.replaceAll(' ', '_')}.html')
    ..click();
  html.Url.revokeObjectUrl(url);
}
