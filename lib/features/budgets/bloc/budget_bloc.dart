import 'dart:async';

import 'package:expense_tracker/features/budgets/bloc/budget_event.dart';
import 'package:expense_tracker/features/budgets/bloc/budget_state.dart';
import 'package:expense_tracker/features/budgets/data/budget_repository.dart';
import 'package:expense_tracker/features/budgets/models/budget_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  BudgetBloc(this._repository) : super(const BudgetState(isLoading: true)) {
    on<WatchBudgetsRequested>(_onWatchBudgetsRequested);
    on<BudgetsChanged>(_onBudgetsChanged);
    on<BudgetsWatchFailed>(_onBudgetsWatchFailed);
    on<BudgetSaved>(_onBudgetSaved);
  }

  final BudgetRepository _repository;
  StreamSubscription<List<BudgetModel>>? _subscription;

  Future<void> _onWatchBudgetsRequested(
    WatchBudgetsRequested event,
    Emitter<BudgetState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        monthKey: event.monthKey,
        clearError: true,
        clearSuccess: true,
      ),
    );
    try {
      await _subscription?.cancel();
      _subscription = _repository.watchBudgetsByMonth(event.monthKey).listen(
        (List<BudgetModel> budgets) => add(BudgetsChanged(budgets)),
        onError: (_) => add(const BudgetsWatchFailed()),
      );
    } on StateError {
      emit(
        state.copyWith(
          isLoading: false,
          budgets: const <BudgetModel>[],
          errorMessage: 'Please login to sync budgets.',
          clearSuccess: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load budgets.',
          clearSuccess: true,
        ),
      );
    }
  }

  void _onBudgetsChanged(BudgetsChanged event, Emitter<BudgetState> emit) {
    emit(
      state.copyWith(
        budgets: event.budgets,
        isLoading: false,
        clearError: true,
        clearSuccess: true,
      ),
    );
  }

  void _onBudgetsWatchFailed(BudgetsWatchFailed event, Emitter<BudgetState> emit) {
    emit(
      state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load budgets.',
        clearSuccess: true,
      ),
    );
  }

  Future<void> _onBudgetSaved(BudgetSaved event, Emitter<BudgetState> emit) async {
    if (event.limitAmount <= 0) {
      emit(
        state.copyWith(
          errorMessage: 'Budget amount must be greater than zero.',
          clearSuccess: true,
        ),
      );
      return;
    }
    try {
      await _repository.upsertBudget(
        categoryName: event.categoryName,
        limitAmount: event.limitAmount,
        monthKey: event.monthKey,
      );
      emit(state.copyWith(successMessage: 'Budget saved.', clearError: true));
    } catch (_) {
      emit(
        state.copyWith(
          errorMessage: 'Failed to save budget.',
          clearSuccess: true,
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
