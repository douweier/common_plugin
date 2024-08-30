
import 'package:common_plugin/common_plugin.dart';
import 'package:common_plugin/src/widget/refre.dart';
import 'package:flutter/material.dart';


class GetDataView extends StatefulWidget {
  GetDataView({
    Key? key,
    this.buildItem,
    this.padding =
        const EdgeInsets.only(top: 15, bottom: 15, left: 10, right: 10),
    this.itemPadding,
    this.freshMorePage = true,
    this.getData,
    this.data,
    this.initAnimation = true,
    this.noDataTip,
    this.getCompleteTip,
    this.showCompleteTip = true,
    this.isDataList,
  });

  ///返回数据构造，buildItem: (data) {
  ///           return buildPageItem(data);
  ///           },
  final Widget Function(dynamic data,int index)? buildItem;
  final EdgeInsets padding;
  final EdgeInsets? itemPadding;

  ///开启上拉加载更多数据
  final bool freshMorePage;

  ///显示获取数据完成显示文字
  final bool showCompleteTip;

  ///没有任何数据时显示的文字
  final String? noDataTip;
  ///获取数据完成显示的文字
  final String? getCompleteTip;

  final bool? isDataList;

  ///获取数据必须return返回，getData: (page) async {
  ///           return await Sql.queryAll(table.history, orderBy: 'addTime desc',page: page) ?? [];
  ///         },
  final Function(
    int page,
  )? getData;

  final List? data;
  final bool initAnimation;

  @override
  _GetDataViewState createState() => _GetDataViewState();

  static _GetDataViewState? of(BuildContext context) {
    return context.findAncestorStateOfType<_GetDataViewState>();
  }
}

class _GetDataViewState extends State<GetDataView> {
  List data = [];
  int page = 1;
  bool scroll = false;
  int x = 0;
  bool isLoading = false; //加载中
  bool hasMoreData = true; //是否还有更多数据
  bool isDataList = false; //自动判断获取的数据是否List

  @override
  void initState() {
    super.initState();
  }

  Future<bool> _getData({ bool clear = false}) async {
    if (clear) {
      data.clear();
      setState(() {});
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
      if (data2 == null || data2 == '') {
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

    if (widget.isDataList != null) {
      isDataList = widget.isDataList!;
    }
    isLoading = false;
    return true;
  }

  @override
  Widget build(BuildContext context) {

    return Refre(
        child: (child, start, end, updata) {
          return Container(
            padding: widget.padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                child,
                data.length > 0
                    ? Expanded(
                        child: ScrollConfiguration(
                        behavior: ScrollBehavior(),
                        child: isDataList
                            ? ListView.builder(
                                itemCount: data.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding:
                                        widget.itemPadding ?? EdgeInsets.all(0),
                                    child: (!hasMoreData &&
                                            index == data.length - 1 &&
                                            data.length > 0 &&
                                            !isLoading)
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              widget.buildItem!(data,index),
                                              if (!hasMoreData && !isLoading && widget.showCompleteTip)
                                                noDataWidget(),
                                            ],
                                          )
                                        : widget.buildItem!(data,index),
                                  );
                                },
                              )
                            : SingleChildScrollView(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    widget.buildItem!(data,0),
                                    if (!hasMoreData && !isLoading && widget.showCompleteTip)
                                      noDataWidget(),
                                  ],
                                ),
                            ),
                      ))
                    : Expanded(
                        child: Container(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/icon/icon_data_empty.png",
                              width: 80,
                              fit: BoxFit.cover,
                            ),
                            Text(widget.noDataTip ?? '哎呀，什么都没有'),
                          ],
                        ),
                      )),
              ],
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
            Future.delayed(Duration(milliseconds: 500), () async {
              page++;
              await _getData();
            });
          }
        },
        initRefresh: widget.initAnimation);
  }

  Widget noDataWidget() {
    return Container(
        margin: EdgeInsets.only(top: 10, bottom: 20, left: 10, right: 10),
        child: Column(
          children: [
            Divider(),
            TextView(
              widget.getCompleteTip ?? '暂无更多数据',
              color: ColorTheme.grey,
            ),
          ],
        ));
  }
}
