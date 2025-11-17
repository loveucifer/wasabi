import 'package:flutter/foundation.dart';
import 'package:wasabi/models/widget_model.dart';
import 'package:wasabi/services/database_service.dart';

class WidgetProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;

  List<WidgetModel> _widgets = [];
  bool _isLoading = false;
  String? _error;

  List<WidgetModel> get widgets => _widgets;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasWidgets => _widgets.isNotEmpty;

  Future<void> loadWidgets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _widgets = await _db.getAllWidgets();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addWidget(WidgetModel widget) async {
    try {
      await _db.createWidget(widget);
      _widgets.insert(0, widget);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateWidget(WidgetModel widget) async {
    try {
      await _db.updateWidget(widget);
      final index = _widgets.indexWhere((w) => w.id == widget.id);
      if (index != -1) {
        _widgets[index] = widget;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteWidget(String id) async {
    try {
      await _db.deleteWidget(id);
      _widgets.removeWhere((w) => w.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> incrementUseCount(String id) async {
    try {
      await _db.incrementUseCount(id);
      final index = _widgets.indexWhere((w) => w.id == id);
      if (index != -1) {
        _widgets[index].useCount++;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  WidgetModel? getWidgetById(String id) {
    try {
      return _widgets.firstWhere((w) => w.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearAllWidgets() async {
    try {
      await _db.clearAllWidgets();
      _widgets = [];
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
