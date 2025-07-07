import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

// base_model.dart

abstract class IBaseModel<T> extends Equatable {
  final String id;
  const IBaseModel({this.id = ''});
 }

@immutable
abstract class BaseModel<T> extends IBaseModel<T> {
  const BaseModel({required super.id});
  Map<String, dynamic> toJson();
 }
