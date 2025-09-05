import 'package:flutter/material.dart';

@immutable
abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {
  final int pagesCalculated;
  HomeLoading(this.pagesCalculated);
}

class HomeLoaded extends HomeState {
  final String fullText;
  final List<int> pageMap; // Stores the start index of each page.

  HomeLoaded({required this.fullText, required this.pageMap});
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}
