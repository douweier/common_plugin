import 'dart:async';
import 'dart:collection';
import 'dart:math';



//QueueTask 类实现了一个基于队列的任务调度器，
// 可以控制任务之间的执行间隔和最大并发数。
// 并提供了添加任务、优先执行、监听队列变化、闲置超时自动化销毁等功能。
// 通过定时器和队列的结合，实现了任务的有序执行和资源的有效管理。

///队列任务调度
class QueueTask {
  Queue<TaskWithId> _queue = Queue<TaskWithId>(); // 任务队列
  int interval = 100; // 任务间隔时间
  int defaultTaskTimeout = 30; // 任务执行超时时间（秒）
  final int _idleTimeout = 30; // 空闲超时时间（秒），自动销毁
  Timer? _timer; // 定时器
  final List<Function()> _queueListeners = []; // 监听队列变化
  static Function()? onError;
  DateTime? _lastQueueEmptyTime;  // 队列最后为空的时间

  QueueTask({
    this.interval = 100,
    this.defaultTaskTimeout = 30,
  })  : assert(interval > 0);

  // 添加任务
  Future<T> add<T>(
    Function() task, {
    String? taskId, // 任务ID
    int? taskTimeout, // 任务执行超时时间（秒）
    bool cancelOnTimeout = true, // 任务执行超时是否取消任务
    bool cancelOnError = true, // 任务执行出错是否取消任务
    bool isAddToFirst = false, // 是否添加到队列前面，优先执行
  }) async {
    _lastQueueEmptyTime = null;
    // 生成任务ID
    if (taskId == null) {
      taskId = generateRandomTaskId();
    }

    final completer = Completer<T>();

    final _taskFunction = TaskWithId(taskId, () async {
      try {
        final result = await task();
        completer.complete(result);
      } catch (e, stackTrace) {
        _logError("任务执行出错: $e\n$stackTrace");
        if (onError != null) {
          try {
            onError!();
          } catch (innerError) {
            _logError("OnError回调执行出错: $innerError");
          }
        }
        completer.completeError(e, stackTrace);
      } finally {
        _notifyQueueChanged();
      }
    });

    if (isAddToFirst) {
      _queue.addFirst(_taskFunction);
    } else {
      _queue.add(_taskFunction);
    }

    scheduleTaskExecution();
    _notifyQueueChanged();

    try {
      // 等待异步操作的结果，超时返回
      await completer.future.timeout(Duration(seconds: taskTimeout ?? defaultTaskTimeout));
    } on TimeoutException {
      if (cancelOnTimeout) {
        cancelTask(taskId);
      }
      _logError('任务执行超时');
    } catch (error) {
      if (cancelOnError) {
        cancelTask(taskId);
      }
      // _logError('获取结果时出错: $error');
    }
    return completer.future;
  }

  // 取消任务
  void cancelTask(String taskId) {
    // _queue.removeLast(); // 如果超时从队列中移除最后一个
    try {
      _queue.removeWhere((task) => task.taskId == taskId);
    } catch (e) {
      _logError('取消任务时出错: $e');
    }
  }

  // 生成任务ID
  static String generateRandomTaskId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  // 定时执行任务
  void scheduleTaskExecution() {
    if (_timer == null || !_timer!.isActive) {
         _executeQueue();
        _timer = Timer.periodic(Duration(milliseconds: interval), (timer) { _executeQueue();});
    }
  }

  // 执行任务
  void _executeQueue() async {
    if (_queue.isNotEmpty) {
      final callback = _queue.removeFirst();
      try {
        await callback.task();
      } catch (e, stackTrace) {
        _logError("任务执行出错: $e\n$stackTrace");
        if (onError != null) {
          try {
            onError!();
          } catch (innerError) {
            _logError("OnError回调执行出错: $innerError");
          }
        }
      } finally {
        _notifyQueueChanged();
      }
    }

    _notifyQueueChanged();

    if (_queue.isEmpty) {
      _disposeIfIdle(); // 队列为空时，重置空闲定时器
    } else {
      _lastQueueEmptyTime = null;
    }
  }


  // 如果队列空闲，则销毁定时器
  void _disposeIfIdle() {
    if (_lastQueueEmptyTime == null) {
      _lastQueueEmptyTime = DateTime.now();
    } else if (DateTime.now().difference(_lastQueueEmptyTime!).inSeconds >= _idleTimeout) {
      dispose();
    }
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    _queue.clear();
    _queueListeners.clear();
  }

  // 添加队列变化监听
  void addQueueListener(Function() listener) {
    _queueListeners.add(listener);
  }

  // 移除队列变化监听
  void removeQueueListener(Function() listener) {
    _queueListeners.remove(listener);
  }

  // 通知队列变化
  void _notifyQueueChanged() {
    if (_queue.isEmpty && _queueListeners.isNotEmpty) {
      for (final listener in _queueListeners) {
        try {
          listener();
        } catch (e, stackTrace) {
          print("Error executing queue listener: $e\n$stackTrace");
        }
      }
    }
  }

  // 错误日志记录器
  void _logError(String message) {
    print(message);
  }
}

class TaskWithId {
  final String? taskId;
  final Function() task;

  TaskWithId(this.taskId, this.task);
}

/// 使用示例
// QueueTask _queueTask = QueueTask(); // 初始化队列任务，不同调度的任务类型需要单独初始化
//
// // 添加几个任务
// _queueTask.add(() => print('Executing Task 1'));
// _queueTask.add(() => print('Executing Task 2'));
// _queueTask.add(() => print('Executing Task 3'));
//
// // 添加异步任务，返回数据
// final _requestBack = await _queueTask.add(() async {
//   return await urlToApi(url);
// }, taskTimeout: 30);
//
//
// // 添加队列变化监听器
// _queueTask.addQueueListener(() {
// print('Queue has changed!');
// });
//
// // 超时会自动销毁，也可手动清理资源
// _queueTask.dispose();
