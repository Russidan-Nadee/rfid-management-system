// Path: frontend/lib/features/search/presentation/widgets/search_result_detail_dialog.dart
import 'package:flutter/material.dart';
import '../../domain/entities/search_result_entity.dart'; // ตรวจสอบ path ให้ถูกต้อง

class SearchResultDetailDialog extends StatelessWidget {
  final SearchResultEntity result;

  const SearchResultDetailDialog({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      // --- ตกแต่ง: กำหนดสีพื้นหลัง Dialog ---
      backgroundColor:
          theme.colorScheme.surface, // ใช้สีพื้นผิวของ Theme (สีขาว)
      // --- ตกแต่ง: กำหนดรูปทรง Dialog ให้มีขอบโค้งมน ---
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // ทำให้ Dialog มีขอบโค้งมน
      ),
      title: Text(
        result.title,
        style: theme.textTheme.headlineSmall?.copyWith(
          color:
              theme.colorScheme.primary, // ใช้สี primary สำหรับ title เพื่อเน้น
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          // เปลี่ยนเป็น Column เพื่อจัดเรียง Text และ Icon
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // ทำให้ Column ใช้พื้นที่น้อยที่สุด
          children: [
            // --- ตกแต่ง: เพิ่มไอคอนและปรับสไตล์ข้อความสำหรับแต่ละรายการ ---
            _buildDetailRow(
              context,
              Icons.category,
              'Type:',
              result.entityType,
            ),
            _buildDetailRow(context, Icons.fingerprint, 'ID:', result.id),
            if (result.description != null)
              _buildDetailRow(
                context,
                Icons.description,
                'Description:',
                result.description!,
              ),
            if (result.status != null)
              _buildDetailRow(
                context,
                Icons.info_outline,
                'Status:',
                result.statusLabel,
              ),
            if (result.plantCode != null)
              _buildDetailRow(
                context,
                Icons.apartment,
                'Plant:',
                result.plantCode!,
              ),
            if (result.locationCode != null)
              _buildDetailRow(
                context,
                Icons.location_on,
                'Location:',
                result.locationCode!,
              ),
          ],
        ),
      ),
      actions: [
        // --- ตกแต่ง: เพิ่มเส้นแบ่งก่อนปุ่ม ---
        Divider(color: theme.colorScheme.onSurface.withOpacity(0.1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: TextStyle(
                color:
                    theme.colorScheme.primary, // ใช้สี primary สำหรับปุ่ม Close
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper method สำหรับสร้างแต่ละแถวของรายละเอียด
  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary.withOpacity(
              0.7,
            ), // สีไอคอนเป็นสี primary จางๆ
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              // ใช้ RichText เพื่อ Bold Label
              text: TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface, // สีข้อความปกติ
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ), // ทำให้ Label เป็นตัวหนา
                  ),
                  TextSpan(text: ' $value'), // ค่าของข้อมูล
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
