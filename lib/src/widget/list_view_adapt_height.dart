
import 'package:flutter/widgets.dart';

/// ListView 列表自适配布局，适用于列表项高度不固定且需要自适应高度的场景，可以任意列数
class ListViewAdaptHeight<T> extends StatelessWidget {
  /// ListViewAdaptHeight(list: list, itemBuilder: (
  /// BuildContext context, int index, T item) {
  /// return buildSingleItem(item);
  /// },
  /// )
  final Widget Function(BuildContext context, int index, T item) itemBuilder;
  final List<T> list; // 明确指定了T类型
  final int columnCount; // 列数，默认为2

  const ListViewAdaptHeight({
    super.key,
    required this.list,
    required this.itemBuilder,
    this.columnCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) {
      // 当列表为空时，显示一个占位符或者提示信息
      return const Center(
        child: Text(''),
      );
    }

    final List<Widget> columnWidgets = _splitItemsByColumn(context, list, columnCount);

    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: columnWidgets,
      ),
    );
  }

  /// 将列表项按照指定的列数分割并扁平化为一维列表
  List<Widget> _splitItemsByColumn(BuildContext context, List<T> items, int columns) {
    final columnsList = List.generate(columns, (_) => <Widget>[]);

    for (int i = 0; i < items.length; i++) {
      int shortestColumnIndex = _getShortestColumnIndex(columnsList);
      columnsList[shortestColumnIndex].add(itemBuilder(context, i, items[i]));
    }

    return columnsList.map((columnItems) {
      return Expanded(
        flex: 1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: columnItems,
        ),
      );
    }).toList();
  }

  int _getShortestColumnIndex(List<List<Widget>> columnsList) {
    int shortestColumnIndex = 0;
    int shortestColumnLength = columnsList[0].length;

    for (int i = 1; i < columnsList.length; i++) {
      final currentLength = columnsList[i].length;
      if (currentLength < shortestColumnLength) {
        shortestColumnIndex = i;
        shortestColumnLength = currentLength;
      }
    }

    return shortestColumnIndex;
  }

}
