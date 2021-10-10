## [1.1.0]

- enable customize PullIndicator and CircleIndicator.

**breaking change**
- rename refresh indicator colors property.


## [1.0.0+1]

**breaking changes**
- rename ActionWidget to PullIndicator
  - then rename MultiPull property 'actionWidgets' to 'pullIndicators' too.
- abolish PullIndicator(ActionWidget)'s property: action and onRefresh.
  - then added new property onPull on MultiPull.
- label property of PullIndicator(ActionWidget) change type from String? to Widget?.
- there was some gap between user circle and pullIndicators. so fixed the misalignment.

## [0.3.2] -

- fix ActionWidget alignment when no label.
- breaking change: change ActionWidget label type from String to Widget.

## [0.3.1] -

- fix error: colortween is not subtype of type animated<color>

## [0.2.1] -

- update document

## [0.2.0] -

- fix bug: when build with ios device, warn ".xconfig file not exist". -> cd ios && pod install

- new 4 variables about "forcus circle"!!
  - circleOpacity: it just circle opacity
  - circleColor: it just circle color.
  - circleMoveDuration: circle moving animatioin duration
  - circleMoveCurve: circle moving animation curve


## [0.1.0] -

* initial release