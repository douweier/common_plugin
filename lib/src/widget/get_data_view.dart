import 'package:common_plugin/common_plugin.dart';
import 'package:common_plugin/src/widget/refre.dart';
import 'package:flutter/material.dart';

class GetDataController {
  _GetDataViewState? _state;

  void _bind(_GetDataViewState state) {
    _state = state;
  }

  /// 获取当前数据
  List get data => _state?._currentData ?? [];

  /// 获取当前页码
  int get currentPage => _state?._currentPage ?? 1;

  /// 清空数据并刷新
  void clearData() {
    _state?._clearData();
  }

  /// 重置请求数据
  void resetGetData() {
    _state?._resetGetData();
  }

  /// 添加数据
  void addData(List newData) {
    _state?._addData(newData);
  }

  /// 更新数据
  void updateData(int index, dynamic newData) {
    _state?._updateData(index, newData);
  }

  /// 删除数据
  void deleteData(int index) {
    _state?._deleteData(index);
  }
}

class GetDataView extends StatefulWidget {
  const GetDataView({
    super.key,
    this.controller,
    this.getData,
    this.data,
    this.buildItem,
    this.padding,
    this.margin,
    this.itemPadding,
    this.freshMorePage = true,
    this.initAnimation = true,
    this.noDataTip,
    this.isShowNoDataImage = true,
    this.isShowNoData = true,
    this.isShowMoreData = true,
    this.getCompleteTip,
    this.showCompleteTip = true,
    this.listColumnCount = 1,
  });

  /// 控制器，外界可以自由控制内部数据构造
  final GetDataController? controller;

  ///获取数据必须return返回，getData: (page) async {
  ///           return await Sql.queryAll(table.history, orderBy: 'addTime desc',page: page) ?? [];
  ///         },
  final Function(
    int page,
  )? getData;

  ///返回数据构造，buildItem: (data，index) {
  ///           return buildPageItem(data[index]);
  ///           },
  final Widget Function(dynamic data, int index)? buildItem;

  /// 列表显示的列数，默认1列
  final int listColumnCount;

  final List? data;

  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final EdgeInsets? itemPadding;

  ///开启上拉加载更多数据
  final bool freshMorePage;

  ///显示获取数据完成显示文字
  final bool showCompleteTip;

  ///没有任何数据时显示的文字
  final String? noDataTip;
  final bool isShowNoDataImage; //是否显示没有数据的图片
  final bool isShowNoData; //是否显示没有数据的所有提示

  final bool isShowMoreData; //是否显示加载更多的提示

  ///获取数据完成显示的文字
  final String? getCompleteTip;

  final bool initAnimation;

  @override
  State<StatefulWidget> createState() => _GetDataViewState();
}

class _GetDataViewState extends State<GetDataView> {
  List data = [];
  int page = 1;
  bool isLoading = false; //加载中
  bool hasMoreData = true; //是否还有更多数据
  bool isDataList = false; //自动判断获取的数据是否List

  /// 提供外部访问的只读数据
  List get _currentData => data;

  /// 提供外部访问的只读页码
  int get _currentPage => page;

  @override
  void initState() {
    super.initState();
    widget.controller?._bind(this);
  }

  /// 清空数据
  void _clearData() {
    if (mounted){
    setState(() {
      data.clear();
      page = 1;
      hasMoreData = true;
      isLoading = false;
    });
    }
  }

  /// 重置请求
  Future<void> _resetGetData() async {
    page = 1;
    hasMoreData = true;
    isLoading = true;
    data.clear();
    await _getData();
    if (mounted) {
      setState(() {});
    }
  }

  /// 添加数据
  void _addData(List newData) {
      data.addAll(newData);
      if (mounted) {
        setState(() {});
      }
  }

  /// 更新数据
  void _updateData(int index, dynamic newData) {
    if (index >= 0 && index < data.length) {
        data[index] = newData;
        if (mounted) {
          setState(() {});
        }
    }
  }

  /// 删除数据
  void _deleteData(int index) {
    if (index >= 0 && index < data.length) {
        data.removeAt(index);
        if (mounted) {
          setState(() {});
        }
    }
  }

  Future<bool> _getData({bool clear = false}) async {
    if (clear) {
      data.clear();
      if (mounted) {
        setState(() {});
      }
      return true;
    }

    //传入数据直接返回显示
    if (widget.data != null) {
      if (widget.data is List) {
        isDataList = true;
      }
      data = widget.data ?? [];
      return true;
    }

    //获取数据方法
    if (widget.getData != null) {
      var data2 = await widget.getData!(page);
      if (isEmptyOrNull(data2)) {
        hasMoreData = false;
      } else if (data2 is List) {
        isDataList = true;
        if (data2.length < 20) {
          hasMoreData = false;
        }
        data.addAll(data2);
      } else {
        data.add(data2);
      }
    }

    isLoading = false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Refre(
        child: (child, start, end, updata) {
          if (data.isEmpty) {
            return emptyDataWidget();
          }
          return SingleChildScrollView(
            child: Container(
              padding: widget.padding,
              margin: widget.margin,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  child,
                  isDataList
                      ? ListViewAdaptHeight(
                          list: data,
                          columnCount: widget.listColumnCount,
                          itemBuilder: (context, index, item) {
                            return Padding(
                              padding:
                                  widget.itemPadding ?? const EdgeInsets.all(0),
                              child: widget.buildItem!(data, index),
                            );
                          })
                      : widget.buildItem!(data, 0),
                  if (data.isNotEmpty &&
                      !hasMoreData &&
                      !isLoading &&
                      widget.showCompleteTip)
                    noMoreDataWidget(),
                ],
              ),
            ),
          );
        },

        ///下拉刷新
        onRefresh: () async {
          page = 1;
          hasMoreData = true;
          isLoading = true;
          data.clear();
         await _getData();
        },

        ///上拉加载
        pullUpRefresh: () async {
          if (hasMoreData && !isLoading && widget.freshMorePage) {
            isLoading = true;
            Future.delayed(const Duration(milliseconds: 500), () async {
              page++;
             await _getData();
            });
          }
        },
        initRefresh: widget.initAnimation);
  }

  Widget emptyDataWidget() {
    if (!widget.isShowNoData) {
      return Container();
    }
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.isShowNoDataImage)
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Image.asset(
                "assets/images/icon_empty.png",
                width: 60,
                fit: BoxFit.cover,
                package: "common_plugin",
              ),
            ),
          TextView(
            widget.noDataTip ?? '没有数据',
            color: ColorTheme.fontLight,
          ),
        ],
      ),
    );
  }

  Widget noMoreDataWidget() {
    if (!widget.isShowMoreData) {
      return Container();
    }
    return Container(
        margin: const EdgeInsets.only(top: 10, bottom: 20, left: 10, right: 10),
        child: Column(
          children: [
            const Divider(),
            TextView(
              widget.getCompleteTip ?? '暂无更多数据',
              color: ColorTheme.fontLight,
            ),
          ],
        ));
  }
}
