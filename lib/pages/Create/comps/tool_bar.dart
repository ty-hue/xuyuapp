import 'dart:async';
import 'dart:math' as math;

import 'package:bilbili_project/utils/ToastUtils.dart';
import 'package:bilbili_project/viewmodels/Create/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ToolBar extends StatefulWidget {
  final RecordStatus recordStatus;
  final FlashStatus flashStatus;
  final RecordDuration recordDuration;
  final ValueChanged<FlashStatus> onFlashStatusChanged;
  final ValueChanged<RecordDuration> onRecordDurationChanged;
  final bool speedMode;
  final ValueChanged<bool> onSpeedModeChanged;
  final VoidCallback onRotateChanged;
  final VoidCallback onSettingChanged;
  // 美颜
  final VoidCallback onBeautyChanged;
  // 滤镜
  final VoidCallback onFilterChanged;
  // 倒计时
  final VoidCallback onCountDownChanged;
  // 麦克风
  final MicrophoneStatus microphoneStatus;
  final ValueChanged<MicrophoneStatus> onMicrophoneStatusChanged;
  // 动图
  final GifStatus gifStatus;
  final ValueChanged<GifStatus> onGifStatusChanged;
  final int cameraSelectedIndex;
  final bool isStartCountDown;

  ToolBar({
    Key? key,
    required this.recordStatus,
    required this.flashStatus,
    required this.recordDuration,
    required this.onFlashStatusChanged,
    required this.onRecordDurationChanged,
    required this.speedMode,
    required this.onSpeedModeChanged,
    required this.onRotateChanged,
    required this.onSettingChanged,
    required this.onBeautyChanged,
    required this.onFilterChanged,
    required this.onCountDownChanged,
    required this.microphoneStatus,
    required this.onMicrophoneStatusChanged,
    required this.gifStatus,
    required this.onGifStatusChanged,
    required this.cameraSelectedIndex,
    required this.isStartCountDown,
  }) : super(key: key);

  @override
  _ToolBarState createState() => _ToolBarState();
}

class _ToolBarState extends State<ToolBar> {
  static const Duration _kFlipIconAnimDuration = Duration(milliseconds: 320);

  /// 每次点击递增，与 [_flipRotationTween] 同步换新的一段动画。
  int _flipAnimGeneration = 0;
  /// 当前累计圈数（终点），+0.5 = 顺时针半圈。
  double _flipTurnEnd = 0;
  /// 必须在 State 里保持**同一引用**，直到下次点击再替换；若在 [build] 里每次 `Tween(...)` 新建，
  /// 父组件相机重启 [setState] 时 [TweenAnimationBuilder] 会认为 tween 变化而重置动画 → 只剩抖动。
  late Tween<double> _flipRotationTween;
  /// 动画播放期间忽略连点；相机重启延后到动画结束，避免 [_restartCamera] 的 [setState] 打断补间。
  bool _flipIconAnimating = false;
  Timer? _flipRestartTimer;

  @override
  void initState() {
    super.initState();
    _flipRotationTween = Tween<double>(begin: 0, end: 0);
  }

  @override
  void dispose() {
    _flipRestartTimer?.cancel();
    super.dispose();
  }

  void _onFlipTap() {
    if (_flipIconAnimating) return;
    _flipIconAnimating = true;
    _flipRestartTimer?.cancel();

    final begin = _flipTurnEnd;
    _flipTurnEnd += 0.5;
    _flipRotationTween = Tween<double>(begin: begin, end: _flipTurnEnd);
    _flipAnimGeneration++;
    setState(() {});

    _flipRestartTimer = Timer(_kFlipIconAnimDuration, () {
      _flipRestartTimer = null;
      if (!mounted) return;
      _flipIconAnimating = false;
      widget.onRotateChanged();
    });
  }

  // 闪光灯图标
  IconData get flashIcon {
    switch (widget.flashStatus) {
      case FlashStatus.off:
        return Icons.flash_off_sharp;
      case FlashStatus.on:
        return Icons.flash_on_sharp;
      case FlashStatus.auto:
        return Icons.flash_auto_sharp;
    }
  }

  /// 最大拍摄时长：Font Awesome **hourglass** 命名三连（solid），沙漏阶段与可录时长档位对应。
  ///
  /// - 15s → [FontAwesomeIcons.hourglassStart]
  /// - 60s → [FontAwesomeIcons.solidHourglassHalf]
  /// - 180s → [FontAwesomeIcons.hourglassEnd]
  ///
  /// 文档：<https://fontawesome.com/icons/hourglass-start?style=solid>
  IconData get recordDurationIcon {
    switch (widget.recordDuration) {
      case RecordDuration.s15:
        return FontAwesomeIcons.hourglassStart;
      case RecordDuration.s60:
        return FontAwesomeIcons.solidHourglassHalf;
      case RecordDuration.s180:
        return FontAwesomeIcons.hourglassEnd;
    }
  }

  /// 快慢速：默认关闭为 [Icons.motion_photos_off_sharp]，开启为 [Icons.motion_photos_on_sharp]。
  IconData get speedModeIcon {
    return widget.speedMode
        ? Icons.motion_photos_on_sharp
        : Icons.motion_photos_off_sharp;
  }

  // 麦克风图标
  IconData get microphoneIcon {
    return widget.microphoneStatus == MicrophoneStatus.on
        ? Icons.mic_sharp
        : Icons.mic_off_sharp;
  }

  /// 动图：严格 `xxx` / `xxx_off` 成对（与快慢速的 `motion_photos_*` 区分），用 [Icons.videocam_sharp] / [Icons.videocam_off_sharp] 表示动态影像开关。
  IconData get gifIcon {
    return widget.gifStatus == GifStatus.on
        ? Icons.videocam_sharp
        : Icons.videocam_off_sharp;
  }

  // 是否展开工具栏
  bool isExpandToolsBar = false;

  double get toolBarHeight {
    if (isExpandToolsBar) {
      if (widget.cameraSelectedIndex == 1) {
        return 9 * 60.0.h;
      }
      return 8 * 60.0.h;
    } else {
      if (widget.cameraSelectedIndex == 1) {
        return 8 * 60.0.h;
      }
      return 7 * 60.0.h;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onVerticalDragUpdate: (details) {
            final dy = details.delta.dy;

            // 手指向上滑（dy < 0）→ 展开
            if (dy < 0 && !isExpandToolsBar) {
              setState(() => isExpandToolsBar = true);
            }
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: 64.0.w,
            height: toolBarHeight,
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                widget.isStartCountDown 
                    ? Container()
                    : GestureDetector(
                        onTap: _onFlipTap,
                        child: Container(
                          height: 50.h,
                          alignment: Alignment.center,
                          child: Column(
                            spacing: 2.0.h,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TweenAnimationBuilder<double>(
                                key: ValueKey<int>(_flipAnimGeneration),
                                duration: _kFlipIconAnimDuration,
                                curve: Curves.easeInOutCubic,
                                tween: _flipRotationTween,
                                builder: (context, double turns, child) {
                                  return Transform.rotate(
                                    angle: turns * 2 * math.pi,
                                    child: child,
                                  );
                                },
                                child: Icon(
                                  // 用户指定沿用最初循环箭头；与 Material 翻转图标区分
                                  // ignore: deprecated_member_use
                                  FontAwesomeIcons.refresh,
                                  color: Colors.white,
                                  size: 22.0.sp,
                                ),
                              ),
                              Text(
                                '翻转',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.0.sp,
                                  decoration: TextDecoration.none, // ⭐关键
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                widget.recordStatus == RecordStatus.normal
                    ? GestureDetector(
                        onTap: () {
                          switch (widget.flashStatus) {
                            case FlashStatus.off:
                              widget.onFlashStatusChanged(FlashStatus.on);
                              break;
                            case FlashStatus.on:
                              widget.onFlashStatusChanged(FlashStatus.auto);
                              break;
                            case FlashStatus.auto:
                              widget.onFlashStatusChanged(FlashStatus.off);
                              break;
                          }
                        },
                        child: Container(
                          height: 60.h,
                          alignment: Alignment.center,
                          child: Column(
                            spacing: 2.0.h,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                flashIcon,
                                color: Colors.white,
                                size: 22.0.sp,
                              ),
                              Text(
                                '闪光灯',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.0.sp,
                                  decoration: TextDecoration.none, // ⭐关键
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(),
                widget.recordStatus == RecordStatus.normal
                    ? GestureDetector(
                        onTap: () {
                          widget.onSettingChanged();
                        },
                        child: Container(
                          height: 60.h,
                          alignment: Alignment.center,
                          child: Column(
                            spacing: 2.0.h,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.settings_sharp,
                                color: Colors.white,
                                size: 22.0.sp,
                              ),
                              Text(
                                '设置',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.0.sp,
                                  decoration: TextDecoration.none, // ⭐关键
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(),
                widget.cameraSelectedIndex == 1 &&
                        widget.recordStatus == RecordStatus.normal
                    ? GestureDetector(
                        onTap: () {
                          widget.onMicrophoneStatusChanged(
                            widget.microphoneStatus == MicrophoneStatus.off
                                ? MicrophoneStatus.on
                                : MicrophoneStatus.off,
                          );
                        },
                        child: Container(
                          height: 60.h,
                          alignment: Alignment.center,
                          child: Column(
                            spacing: 2.0.h,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                microphoneIcon,
                                color:
                                    widget.microphoneStatus ==
                                        MicrophoneStatus.off
                                    ? Colors.red
                                    : Colors.white,
                                size: 22.0.sp,
                              ),
                              Text(
                                '麦克风',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.0.sp,
                                  decoration: TextDecoration.none, // ⭐关键
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(),
                widget.cameraSelectedIndex == 2
                    ? Container()
                    : AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        child: widget.recordStatus == RecordStatus.normal
                            ? widget.cameraSelectedIndex == 1
                                  ? GestureDetector(
                                      key: ValueKey(1), // 每个widget都需要唯一的key
                                      onTap: () {
                                        switch (widget.recordDuration) {
                                          case RecordDuration.s15:
                                            widget.onRecordDurationChanged(
                                              RecordDuration.s60,
                                            );
                                            ToastUtils.showToastReplace(
                                              context,
                                              msg: '最大拍摄时长60秒',
                                            );
                                            break;
                                          case RecordDuration.s60:
                                            widget.onRecordDurationChanged(
                                              RecordDuration.s180,
                                            );
                                            ToastUtils.showToastReplace(
                                              context,
                                              msg: '最大拍摄时长3分钟',
                                            );
                                            break;
                                          case RecordDuration.s180:
                                            widget.onRecordDurationChanged(
                                              RecordDuration.s15,
                                            );
                                            ToastUtils.showToastReplace(
                                              context,
                                              msg: '最大拍摄时长15秒',
                                            );
                                            break;
                                        }
                                      },
                                      child: Container(
                                        height: 60.h,
                                        alignment: Alignment.center,
                                        child: Column(
                                          spacing: 2.0.h,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              recordDurationIcon,
                                              color: Colors.white,
                                              size: 22.0.sp,
                                            ),
                                            Text(
                                              '时长',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13.0.sp,
                                                decoration:
                                                    TextDecoration.none, // ⭐关键
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : GestureDetector(
                                      key: ValueKey(2), // 每个widget都需要唯一的key
                                      onTap: () {
                                        widget.onGifStatusChanged(
                                          widget.gifStatus == GifStatus.off
                                              ? GifStatus.on
                                              : GifStatus.off,
                                        );
                                      },
                                      child: Container(
                                        height: 60.h,
                                        alignment: Alignment.center,
                                        child: Column(
                                          spacing: 2.0.h,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              gifIcon,
                                              color: Colors.white,
                                              size: 22.0.sp,
                                            ),
                                            Text(
                                              '动图',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13.0.sp,
                                                decoration:
                                                    TextDecoration.none, // ⭐关键
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                            : Container(),
                      ),

                widget.recordStatus == RecordStatus.normal
                    ? GestureDetector(
                        onTap: () {
                          widget.onCountDownChanged();
                        },
                        child: Container(
                          height: 60.h,
                          alignment: Alignment.center,
                          child: Column(
                            spacing: 2.0.h,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer_sharp,
                                color: Colors.white,
                                size: 22.0.sp,
                              ),
                              Text(
                                '倒计时',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.0.sp,
                                  decoration: TextDecoration.none, // ⭐关键
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(),
                widget.recordStatus == RecordStatus.normal
                    ? GestureDetector(
                        onTap: () {
                          widget.onBeautyChanged();
                        },
                        child: Container(
                          height: 60.h,
                          alignment: Alignment.center,
                          child: Column(
                            spacing: 2.0.h,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.face_retouching_natural_sharp,
                                color: Colors.white,
                                size: 22.0.sp,
                              ),
                              Text(
                                '美颜',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.0.sp,
                                  decoration: TextDecoration.none, // ⭐关键
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(),
                widget.recordStatus == RecordStatus.normal
                    ? GestureDetector(
                        onTap: () {
                          widget.onFilterChanged();
                        },
                        child: Container(
                          height: 60.h,
                          alignment: Alignment.center,
                          child: Column(
                            spacing: 2.0.h,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.movie_filter_sharp,
                                color: Colors.white,
                                size: 22.0.sp,
                              ),
                              Text(
                                '滤镜',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.0.sp,
                                  decoration: TextDecoration.none, // ⭐关键
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(),
                widget.recordStatus == RecordStatus.normal
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            widget.onSpeedModeChanged(!widget.speedMode);
                          });
                        },
                        child: Container(
                          height: 60.h,
                          alignment: Alignment.center,
                          child: Column(
                            spacing: 2.0.h,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                speedModeIcon,
                                color: Colors.white,
                                size: 22.0.sp,
                              ),
                              Text(
                                '快慢速',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.0.sp,
                                  decoration: TextDecoration.none, // ⭐关键
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
        widget.recordStatus == RecordStatus.normal
            ? GestureDetector(
                onTap: () {
                  print('更多');
                  setState(() {
                    isExpandToolsBar = !isExpandToolsBar;
                  });
                },
                child: Container(
                  height: 60.h,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        height: 30.0.h,
                        width: 30.0.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0.r),
                          color: Colors.white.withOpacity(0.2),
                        ),
                        // 向下的箭头 （不是三角形）
                        child: Icon(
                          isExpandToolsBar
                              ? FontAwesomeIcons.angleUp
                              : FontAwesomeIcons.angleDown,
                          color: Colors.white,
                          size: 18.0.sp,
                        ),
                      ),
                      Text(
                        isExpandToolsBar ? '收起' : '更多',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.0.sp,
                          decoration: TextDecoration.none, // ⭐关键
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Container(),
      ],
    );
  }
}
