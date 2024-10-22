
import 'package:common_plugin/common_plugin.dart';
import 'package:flutter/material.dart';


///使用示例
///    StateValue<ModelDynamicsList> dynamicItem = StateValue<ModelDynamicsList>(ModelDynamicsList());  //添加为观察变量,创建实例
///
///    dynamicItem.value = ModelDynamicsList();  //更新变量值，注意多层级数据结构需要手动dynamicItem.notifyNow通知更新
/// 或者   dynamicItem.update(ModelDynamicsList());
///
///        StateWidget(
///             stateValue: dynamicItem,  //要监听的变量
///             builder: (value){   //变量值改变时刷新该builder界面
///               return Text('dynamicItem:${value.length}');
///             },
///        )

/// 观察变量，创建实例
class StateValue<T> extends ChangeNotifier {
  T _value;

  static final QueueTask _queueTask = QueueTask(); //请求队列调度

  StateValue(this._value);

  T get value => _value;

  set value(T newValue) {
    update(newValue);
  }

  void update(T newValue) {
    try {
      if (_value != newValue) { // 校验变量值不相同才更新
        _value = newValue;
        notifyNow();
      }
    } catch (error) {
      Logger.error(error,mark: 'StateValue update');
    }
  }

  /// 异步更新值
  Future<void> updateAsync(T newValue) async {
    final oldValue = _value;
    _value = newValue;
    if (oldValue != _value) {
      await Future<void>.microtask(() => notifyListeners());
    }
  }

  /// 立即通知更新
  void notifyNow() {
    _queueTask.add(() async {
      notifyListeners();
    });
  }

  /// 等待数据处理，延迟300ms更新
  void notifyLater() {
    _queueTask.add(() async {
      await Future.delayed(const Duration(milliseconds: 300), () {
        notifyListeners();
      });
    });
  }
}

/// 观察组件
class StateWidget<T> extends StatefulWidget {
  final StateValue<T> stateValue;
  final Widget Function(T) builder;

  const StateWidget({
    super.key,
    required this.stateValue,
    required this.builder,
  });

  @override
  State<StateWidget<T>> createState() => _StateWidgetState<T>();
}

class _StateWidgetState<T> extends State<StateWidget<T>> with AutomaticKeepAliveClientMixin {
  late final VoidCallback _listener;

  @override
  bool get wantKeepAlive => true; // 保持状态

  @override
  void initState() {
    super.initState();
    _listener = () {

      if (mounted) {
        setState(() {});
      }
    };
    widget.stateValue.addListener(_listener);
  }

  @override
  void dispose() {
    widget.stateValue.removeListener(_listener);
    super.dispose();
  }

  // @override
  // void didUpdateWidget(ObservedWidget<T> oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (oldWidget.observedValue != widget.observedValue) {
  //     oldWidget.observedValue.removeListener(_listener);
  //     widget.observedValue.addListener(_listener);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.builder(widget.stateValue.value);
  }

}



