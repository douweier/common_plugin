import 'package:common_plugin/common_plugin.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

/// 日期时间处理
class DateUtil {
  /// 显示日期选择弹窗
  static showDatePicker({DateTime? initDate, Function(DateTime)? onCallback}) {
    DateTime? timeSelect;
    showDialogLayer(
        child: SfDateRangePicker(
          headerStyle: DateRangePickerHeaderStyle(
            backgroundColor: ColorTheme.background,
          ),
          todayHighlightColor: ColorTheme.main,
          backgroundColor: ColorTheme.body,
          onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
            timeSelect = args.value;
          },
          selectionMode: DateRangePickerSelectionMode.single,
          initialSelectedRange: PickerDateRange(
              DateTime.now().subtract(const Duration(days: 4)),
              DateTime.now().add(const Duration(days: 3))),
        ),
        backgroundColor: ColorTheme.white,
        maxWidth: 350,
        onOkCallBack: () {
          if (timeSelect != null) {
            onCallback!(timeSelect!);
          }
        });
  }

  /// 将时间戳规范为可阅读形式， 如 今天 09:25、昨天 09:25、2天前、3天前，
  /// 3天后显示：09-25，今年不显示年份，去年以前显示：2023年9月25日，
  /// 可控制是否显示具体时分，如 09月25日 15:00、2023年9月25日 15:00
  /// 支持秒级和毫秒级时间戳的转换
  static String timestampToDate(
    int timestamp, {
    bool showTodayDetails = false, // 是否显示今天具体时间，false为显示小时前
    bool showTime = true, // 是否显示具体时分
    bool isShowTimeAfter2Days = false, // 是否显示超过2天之前的时分
  }) {
    try {
      // 校验时间戳长度
      if (timestamp <= 0) {
        return "无效时间";
      }

      // 处理秒级和毫秒级时间戳
      if (timestamp.toString().length == 10) {
        timestamp = timestamp * 1000;
      }

      DateTime time;
      try {
        time = DateTime.fromMillisecondsSinceEpoch(timestamp);
      } catch (e) {
        return "无效时间";
      }

      DateTime now = DateTime.now();
      DateTime todayStart = DateTime(now.year, now.month, now.day);
      DateTime targetStart = DateTime(time.year, time.month, time.day);
      Duration difference = targetStart.difference(todayStart);
      int dayDifference = difference.inDays;

      if (now.year == time.year) {
        if (dayDifference == 0) {
          // 今天
          if (showTodayDetails) {
            return showTime ? DateFormat('HH:mm').format(time) : "今天";
          } else {
            Duration timeDifference = now.difference(time);
            if (timeDifference.inHours < 0) {
              return "${timeDifference.inHours.abs()}小时后";
            }
            if (timeDifference.inMinutes < 1) {
              return "刚刚";
            } else if (timeDifference.inMinutes < 60) {
              return "${timeDifference.inMinutes}分钟前";
            } else if (timeDifference.inHours < 24) {
              return "${timeDifference.inHours}小时前";
            }
            return DateFormat('HH:mm').format(time);
          }
        } else if (dayDifference == 1) {
          // 明天
          return "明天${showTime ? " ${DateFormat('HH:mm').format(time)}" : ""}";
        } else if (dayDifference == -1) {
          // 昨天
          return "昨天${showTime ? " ${DateFormat('HH:mm').format(time)}" : ""}";
        } else if (dayDifference > 1 && dayDifference <= 6) {
          // 未来的其他天数
          return "$dayDifference天后${showTime ? " ${DateFormat('HH:mm').format(time)}" : ""}";
        } else if (dayDifference < -1 && dayDifference >= -6) {
          // 过去的其他天数
          return "${-dayDifference}天前${showTime ? " ${DateFormat('HH:mm').format(time)}" : ""}";
        } else {
          // 超过一周的日期
          if (!isShowTimeAfter2Days) {
            showTime = false;
          }
          return "${_twoDigits(time.month)}月${_twoDigits(time.day)}日${showTime ? " ${DateFormat('HH:mm').format(time)}" : ""}";
        }
      }
      // 不同年
      else {
        if (!isShowTimeAfter2Days) {
          showTime = false;
        }
        return "${time.year.toString().padLeft(4, '0')}年${_twoDigits(time.month)}月${_twoDigits(time.day)}日${showTime ? " ${DateFormat('HH:mm').format(time)}" : ""}";
      }
    } catch (e) {
      Logger.warn("日期格式化异常：$e", mark: "timestampToDate");
      return "无效时间";
    }
  }

  /// 将日期时间规范化为阅读形式，如将2024-09-24 21:05:29先转为时间戳然后再通过timestampToDate规范化
  static String dateFormatToSee(
    String date, {
    bool showTodayDetails = false, // 是否显示今天具体时间，false为显示小时前
    bool showTime = true, // 是否显示具体时分
    bool isShowTimeAfter2Days = false, // 是否显示超过2天之前的时分
  }) {
    DateTime time;
    try {
      time = DateTime.parse(date);
    } catch (e) {
      Logger.warn("日期解析异常：$e", mark: "dateFormatToSee");
      return "无效日期";
    }
    return timestampToDate(time.millisecondsSinceEpoch,
        showTodayDetails: showTodayDetails,
        showTime: showTime,
        isShowTimeAfter2Days: isShowTimeAfter2Days);
  }

  /// 判断是否为同一天
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// 格式化为两位数字
  static String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }

  /// 获取星期几的中文表示，支持秒级和毫秒级时间戳的转换
  static String getWeekDay(int timestamp) {
    // 校验时间戳长度
    if (timestamp <= 0) {
      return "";
    }

    // 处理秒级和毫秒级时间戳
    if (timestamp.toString().length == 10) {
      timestamp = timestamp * 1000;
    }

    DateTime time;
    try {
      time = DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      return "";
    }

    switch (time.weekday) {
      case DateTime.monday:
        return "星期一";
      case DateTime.tuesday:
        return "星期二";
      case DateTime.wednesday:
        return "星期三";
      case DateTime.thursday:
        return "星期四";
      case DateTime.friday:
        return "星期五";
      case DateTime.saturday:
        return "星期六";
      case DateTime.sunday:
        return "星期日";
      default:
        return "";
    }
  }

  ///获取当天日期时间 2021-6-25 00:00:00
  static String getTodayDateStart() {
    var today = DateTime.now();
    var today2 = today.toString().substring(0, 10);
    return "$today2 00:00:00";
  }

  ///获取当天日期的8位秒单位的时间戳 16271424000
  static String getTodayDateStartTimestamp() {
    var today2 = getTodayDateStart();
    var today3 = DateTime.parse(today2);
    var today4 = today3.millisecondsSinceEpoch.toString().substring(0, 10);
    return today4;
  }

  ///获取当前时间的秒单位的时间戳,int格式 16271424000
  static int getNowTimestamp() {
    var today = DateTime.now().millisecondsSinceEpoch / 1000;
    return today.toInt();
  }

  ///转换消息详情的时间显示
  static String getMsgFormat(int timestamp) {
    try {
      if (timestamp.toString().length == 10) {
        timestamp = timestamp * 1000;
      }
      DateTime time = DateTime.fromMillisecondsSinceEpoch(timestamp);
      DateTime now = DateTime.now();

      if (now.year == time.year) {
        if (now.day == time.day) {
          return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
        } else {
          return "${time.month.toString().padLeft(2, '0')}月${time.day.toString().padLeft(2, '0')}日 ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
        }
      } else {
        return "${time.year.toString().padLeft(4, '0')}年${time.month.toString().padLeft(2, '0')}月${time.day.toString().padLeft(2, '0')}日 ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
      }
    } catch (e) {
      Logger.warn("时间格式化异常：$e", mark: "getMsgFormat");
      return "无效时间";
    }
  }

  ///时间戳转换详情的时间显示 2021-12-24 12:24
  static String timestampToAllDate(int timestamp) {
    try {
      if (timestamp.toString().length == 10) {
        timestamp = timestamp * 1000;
      }
      DateTime time = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return time.toLocal().toString().substring(0, 16);
    } catch (e) {
      Logger.warn("时间格式化异常：$e", mark: "timestampToAllDate");
      return "无效时间";
    }
  }

  /// 将DateTime转为年月日格式
  static String dateTimeToYMD(dynamic dateTime) {
    try {
      if (isEmptyOrNull(dateTime)) {
        return "";
      }
      if (dateTime is String) {
        dateTime = DateTime.parse(dateTime);
      } else if (dateTime is int) {
        dateTime = DateTime.fromMillisecondsSinceEpoch(dateTime);
      }
      return "${dateTime.year}-${dateTime.month}-${dateTime.day}";
    } catch (e) {
      Logger.error("时间格式化异常：$e", mark: "dateTimeToYMD");
      return "";
    }
  }
}
