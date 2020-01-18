// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:analog_clock/inner_shadow.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;

import 'container_hand.dart';

/// Total distance traveled by a second or a minute hand, each second or minute,
/// respectively.
final radiansPerTick = radians(360 / 60);

/// Total distance traveled by an hour hand, each hour, in radians.
final radiansPerHour = radians(360 / 12);

/// A basic analog clock.
///
/// You can do better than this!
class AnalogClock extends StatefulWidget {
  const AnalogClock(this.model);

  final ClockModel model;

  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  var _now = DateTime.now();
  var _temperature = '';
  var _temperatureRange = '';
  var _condition = '';
  var _location = '';
  Timer _timer;

  var icons = {
    'sunny': 'assets/animated_icons/sunny.flr',
    'rainy': 'assets/animated_icons/rainy.flr',
    'foggy': 'assets/animated_icons/foggy.flr',
    'cloudy': 'assets/animated_icons/cloudy.flr',
    'snowy': 'assets/animated_icons/snowy.flr',
    'windy': 'assets/animated_icons/windy.flr',
    'thunderstorm': 'assets/animated_icons/thunderstorm.flr',
  };

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    // Set the initial values.
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(AnalogClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString;
      _temperatureRange = '(${widget.model.low} - ${widget.model.highString})';
      _condition = widget.model.weatherString;
      _location = widget.model.location;
    });
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      // Update once per second. Make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // There are many ways to apply themes to your clock. Some are:
    //  - Inherit the parent Theme (see ClockCustomizer in the
    //    flutter_clock_helper package).
    //  - Override the Theme.of(context).colorScheme.
    //  - Create your own [ThemeData], demonstrated in [AnalogClock].
    //  - Create a map of [Color]s to custom keys, demonstrated in
    //    [DigitalClock].
    final customTheme = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).copyWith(
            // Use the old theme but apply the following three changes
            textTheme: Theme.of(context).textTheme.apply(
                  fontFamily: 'OpenSans',
                ),
            // Hour hand.
            primaryColor: Color(0xFF2740cc),
            // Minute hand.
            highlightColor: Color(0xFF4868cf),
            // Second hand.
            // accentColor: Color(0xFFe8fafe),
            accentColor: Colors.white70.withOpacity(.20),
            backgroundColor: Color(0xFFd2f3fc),

            //white shadow color
            splashColor: Colors.white.withOpacity(0.8),

            //black shadow color
            dividerColor: Colors.black.withOpacity(0.1))
        : Theme.of(context).copyWith(
            primaryColor: Colors.white,
            highlightColor: Color(0xFF6ea2fa),
            accentColor: Colors.black87.withOpacity(.08),
            backgroundColor: Color(0xFF2D3748),
            splashColor: Colors.white.withOpacity(0.2),
            dividerColor: Colors.black.withOpacity(0.8));

    final time = DateFormat.Hms().format(DateTime.now());

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Analog clock with time $time',
        value: time,
      ),
      child: Container(
        color: customTheme.backgroundColor,
        child: InnerShadow(
          color: Colors.black.withOpacity(0.01),
          offset: Offset(20.0, 50.0),
          blur: 50.0,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                  width: 20.0,
                  color: customTheme.accentColor,
                  style: BorderStyle.solid),
              shape: BoxShape.circle,
              color: customTheme.backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: customTheme.splashColor,
                  blurRadius: 25.0,
                  spreadRadius: Theme.of(context).brightness == Brightness.light
                      ? -25.0
                      : -40.0,
                  offset: Offset(-25, -25),
                ),
                BoxShadow(
                  color: customTheme.dividerColor,
                  blurRadius: 25.0,
                  spreadRadius: -25.0,
                  offset: Offset(25, 25),
                )
              ],
            ),
            child: Stack(
              children: [
                ContainerHand(
                  color: Colors.transparent,
                  size: 1,
                  angleRadians: _now.second * radiansPerTick,
                  child: Transform.translate(
                    offset: Offset(0.0, -90.0),
                    child: Container(
                      width: 5,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        color: customTheme.highlightColor,
                      ),
                    ),
                  ),
                ),
                ContainerHand(
                  color: Colors.transparent,
                  size: 0.7,
                  angleRadians: _now.minute * radiansPerTick,
                  child: Transform.translate(
                    offset: Offset(0.0, -120.0),
                    child: Container(
                      width: 10,
                      height: 180,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 10.0,
                              offset: Offset(-25, 10.0))
                        ],
                        borderRadius: BorderRadius.circular(30.0),
                        color: customTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
                ContainerHand(
                  color: Colors.transparent,
                  size: 0.6,
                  angleRadians: _now.hour * radiansPerHour +
                      (_now.minute / 60) * radiansPerHour,
                  child: Transform.translate(
                    offset: Offset(00.0, -120.0),
                    child: Container(
                      width: 22,
                      height: 150,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 10.0,
                              offset: Offset(-25, 10.0))
                        ],
                        borderRadius: BorderRadius.circular(30.0),
                        color: customTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: Container(
                        height: 120.0,
                        width: 120.0,
                        child: Stack(
                          children: <Widget>[
                            Positioned(
                              child: FlareActor(
                                icons[_condition],
                                sizeFromArtboard: true,
                                fit: BoxFit.contain,
                                animation: 'go',
                              ),
                            ),
                            Positioned(
                              top: 45.0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: <Widget>[
                                      Text(
                                        _temperature.substring(
                                            0, _temperature.length - 2),
                                        style: TextStyle(
                                            color: customTheme.primaryColor,
                                            fontSize: 45.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        _temperature.substring(
                                            _temperature.length - 2,
                                            _temperature.length),
                                        style: TextStyle(
                                            color: customTheme.primaryColor,
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    _temperatureRange,
                                    style: TextStyle(
                                        color: customTheme.primaryColor,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w300),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      )),
                ),
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 30.0),
                    child: Text(
                      _location,
                      style: TextStyle(
                        color: customTheme.primaryColor,
                        fontSize: 18.0,
                        fontFamily: 'OpenSans',
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
