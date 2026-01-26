import 'package:bilbili_project/viewmodels/Report/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReportTypeView extends StatefulWidget {
  final int selectedReport;
  final List<ReportTypeItem> reportTypes;
  final Function(int) next;
  final void Function({required int selectedReport}) changeSelectedReport;
  ReportTypeView({
    Key? key,
    required this.selectedReport,
    required this.reportTypes,
    required this.next,
    required this.changeSelectedReport,
  }) : super(key: key);

  @override
  State<ReportTypeView> createState() => _ReportTypeState();
}

class _ReportTypeState extends State<ReportTypeView> {
  bool get isActive => widget.selectedReport != -1;
  Widget _buildReportItem({
    required String text,
    required int value,
    bool isNeedBottomLine = true,
  }) {
    return InkWell(
      onTap: () => widget.changeSelectedReport(selectedReport: value),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: isNeedBottomLine
                ? BorderSide(color: Colors.white.withOpacity(0.2), width: 0.5)
                : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            Text(
              text,
              style: TextStyle(color: Colors.white, fontSize: 15.sp),
            ),
            const Spacer(),
            Radio<int>(
              value: value,
              groupValue: widget.selectedReport,
              onChanged: (v) {
                widget.changeSelectedReport(selectedReport: v!);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(color: Color.fromRGBO(14, 16, 23, 1)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: Color.fromRGBO(22, 22, 22, 1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.reportTypes.length, (index) {
                if (index == widget.reportTypes.length - 1) {
                  return _buildReportItem(
                    text: widget.reportTypes[index].text,
                    value: int.parse(widget.reportTypes[index].code),
                    isNeedBottomLine: false,
                  );
                }
                return _buildReportItem(
                  text: widget.reportTypes[index].text,
                  value: int.parse(widget.reportTypes[index].code),
                );
              }),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: Color.fromRGBO(31, 94, 253, 0.2),
                backgroundColor: Color.fromRGBO(31, 94, 253, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),

              onPressed: isActive
                  ? () => widget.next(widget.selectedReport)
                  : null,
              child: Text(
                '下一步',
                style: TextStyle(
                  color: isActive
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                  fontSize: 16.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
