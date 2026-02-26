// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'topic_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TopicModel {
  String get prompt;

  /// Create a copy of TopicModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TopicModelCopyWith<TopicModel> get copyWith =>
      _$TopicModelCopyWithImpl<TopicModel>(this as TopicModel, _$identity);

  /// Serializes this TopicModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TopicModel &&
            (identical(other.prompt, prompt) || other.prompt == prompt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, prompt);

  @override
  String toString() {
    return 'TopicModel(prompt: $prompt)';
  }
}

/// @nodoc
abstract mixin class $TopicModelCopyWith<$Res> {
  factory $TopicModelCopyWith(
          TopicModel value, $Res Function(TopicModel) _then) =
      _$TopicModelCopyWithImpl;
  @useResult
  $Res call({String prompt});
}

/// @nodoc
class _$TopicModelCopyWithImpl<$Res> implements $TopicModelCopyWith<$Res> {
  _$TopicModelCopyWithImpl(this._self, this._then);

  final TopicModel _self;
  final $Res Function(TopicModel) _then;

  /// Create a copy of TopicModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? prompt = null,
  }) {
    return _then(_self.copyWith(
      prompt: null == prompt
          ? _self.prompt
          : prompt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [TopicModel].
extension TopicModelPatterns on TopicModel {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_TopicModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TopicModel() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_TopicModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TopicModel():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_TopicModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TopicModel() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String prompt)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TopicModel() when $default != null:
        return $default(_that.prompt);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String prompt) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TopicModel():
        return $default(_that.prompt);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String prompt)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TopicModel() when $default != null:
        return $default(_that.prompt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _TopicModel implements TopicModel {
  _TopicModel({required this.prompt});
  factory _TopicModel.fromJson(Map<String, dynamic> json) =>
      _$TopicModelFromJson(json);

  @override
  final String prompt;

  /// Create a copy of TopicModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TopicModelCopyWith<_TopicModel> get copyWith =>
      __$TopicModelCopyWithImpl<_TopicModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TopicModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TopicModel &&
            (identical(other.prompt, prompt) || other.prompt == prompt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, prompt);

  @override
  String toString() {
    return 'TopicModel(prompt: $prompt)';
  }
}

/// @nodoc
abstract mixin class _$TopicModelCopyWith<$Res>
    implements $TopicModelCopyWith<$Res> {
  factory _$TopicModelCopyWith(
          _TopicModel value, $Res Function(_TopicModel) _then) =
      __$TopicModelCopyWithImpl;
  @override
  @useResult
  $Res call({String prompt});
}

/// @nodoc
class __$TopicModelCopyWithImpl<$Res> implements _$TopicModelCopyWith<$Res> {
  __$TopicModelCopyWithImpl(this._self, this._then);

  final _TopicModel _self;
  final $Res Function(_TopicModel) _then;

  /// Create a copy of TopicModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? prompt = null,
  }) {
    return _then(_TopicModel(
      prompt: null == prompt
          ? _self.prompt
          : prompt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
