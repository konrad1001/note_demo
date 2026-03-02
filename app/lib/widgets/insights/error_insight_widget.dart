part of 'insight_widget.dart';

class ErrorInsight extends StatelessWidget {
  const ErrorInsight({
    super.key,
    required this.message,
    required this.date,
    required this.code,
  });

  final String message;
  final int code;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: BoxBorder.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Row(
            children: [
              Expanded(
                flex: 9,
                child: RichText(
                  maxLines: 3,
                  text: TextSpan(
                    children: [
                      WidgetSpan(
                        child: Icon(Icons.error, size: 18, color: Colors.red),
                      ),
                      WidgetSpan(child: SizedBox(width: 18)),
                      TextSpan(
                        text: message,
                        style: TextStyle(fontSize: 13.0, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
              Spacer(),
              Expanded(
                flex: 1,
                child: Opacity(
                  opacity: 0.5,
                  child: Text(
                    code.toString(),
                    style: TextStyle(fontSize: 13.0),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                _formatDateTime(date),
                style: TextStyle(
                  fontSize: 11.0,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.color?.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
