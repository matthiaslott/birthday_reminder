import 'dart:ui';

import 'package:birthday_reminder/models/date_scroller_model.dart';
import 'package:birthday_reminder/util/configuration.dart';
import 'package:birthday_reminder/util/date_utilities.dart';
import 'package:birthday_reminder/widget/date_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DateScroller extends StatefulWidget {
  const DateScroller({Key? key}) : super(key: key);

  @override
  State<DateScroller> createState() => DateScrollerState();
}

class DateScrollerState extends State<DateScroller> {

  static const LAZY_SCROLL_OFFSET = 500;
  static const PREFETCH_AMOUNT = 28;
  static const PADDING = 3.0;
  final _backwardKey = UniqueKey();
  final _forwardKey = UniqueKey();
  final _scrollController = ScrollController(keepScrollOffset: true);
  final _sliverGridDelegate = const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 7,
    childAspectRatio: 0.85,
  );
  int forwardSize = 100, backwardSize = 100;
  DateTime newDay = CURRENT_DATE, oldDay = CURRENT_DATE;

  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.offset <= _scrollController.position.minScrollExtent + LAZY_SCROLL_OFFSET) {
        // add new elements at the beginning
        setState(() {
          backwardSize += PREFETCH_AMOUNT;
        });
      }
      else if (_scrollController.offset >= _scrollController.position.maxScrollExtent - LAZY_SCROLL_OFFSET) {
        // add new elements at the end
        setState(() {
          forwardSize += PREFETCH_AMOUNT;
        });
      }

      updateModel(false);
    });
    super.initState();
  }

  updateModel(bool reset) {
    if (reset) {
      _scrollController.animateTo(0, duration: DURATION, curve: Curves.easeInOut);
    }

    // calculate the height of an element (needs to be dynamic in case of change in aspect ratio
    double elemHeight = (((window.physicalSize / window.devicePixelRatio).width / _sliverGridDelegate.crossAxisCount))/_sliverGridDelegate.childAspectRatio;
    // calculate the index of the currently topmost right element
    int index = ((_scrollController.offset) / elemHeight).floor();
    index *= 7;
    index -= CURRENT_DATE.day + CURRENT_DATE.weekday - 1;
    index += 6;
    // correct more to the center
    index += 21;
    // notify if month has changed
    oldDay = newDay;
    newDay = getDayFromIndex(index);
    if (newDay.year != oldDay.year || newDay.month != oldDay.month) {
      Provider.of<DateScrollerModel>(context, listen: false).setCurrentDate(newDay, newDay.year > oldDay.year || newDay.month > oldDay.month);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      center: _forwardKey,
      controller: _scrollController,
      slivers: [
        SliverGrid(
          key: _backwardKey,
          gridDelegate: _sliverGridDelegate,
          delegate: SliverChildBuilderDelegate(

            childCount: backwardSize,
            (context, index) {
              // Goal: align index 0 on the current day such that the current month is visible on startup
              index -= 2*((index % 7)-3); // make index go from right to left
              index *= -1; // make index decreasing
              index -= CURRENT_DATE.day + CURRENT_DATE.weekday; // move start of index
              DateTime dateTime = getDayFromIndex(index);
              return Padding(
                padding: const EdgeInsets.all(PADDING),
                child: DateTile(dateTime: dateTime),
              );
            },
          ),
        ),
        SliverGrid(
          key: _forwardKey,
          gridDelegate: _sliverGridDelegate,
          delegate: SliverChildBuilderDelegate(
            childCount: forwardSize,
            (context, index) {
              // Goal: align index 0 on the current day such that the current month is visible on startup
              index -= CURRENT_DATE.day + CURRENT_DATE.weekday - 1;
              DateTime dateTime = getDayFromIndex(index);
              return Padding(
                padding: const EdgeInsets.all(PADDING),
                child: DateTile(dateTime: dateTime),
              );
            },
          ),
        ),
      ],
    );
  }
}