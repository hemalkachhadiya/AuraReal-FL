import 'package:aura_real/apis/notification_api.dart';
import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/home/notification/model/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider() {
    init();
  }

  Future<void> init() async {
    await getAllNotificationAPI(showLoader: true, resetData: true);
  }

  /// ================= Variables =================
  AppResponse2<NotificationModel>? paginationModel;
  List<NotificationModel> notifications = [];

  int currentPage = 0;
  int pageSize = 20;

  bool isApiCalling = false;
  bool loader = false;
  bool refreshLoader = false;
  bool hasMoreData = false;
  String? _error;
  bool _disposed = false;

  String? get error => _error;

  List<NotificationModel> get notificationList => paginationModel?.list ?? [];

  /// ================= API Call =================
  Future<void> getAllNotificationAPI({
    bool showLoader = false,
    bool resetData = false,
  }) async {
    if (paginationModel == null && !resetData) return;
    if (isApiCalling) return;

    isApiCalling = true;

    if (showLoader) {
      loader = true;
      _safeNotifyListeners();
    }

    if (resetData) {
      currentPage = 0;
      paginationModel = null;
      notifications.clear();
    }

    try {
      final model = await NotificationApis.getNotificationsAPI(
        page: currentPage + 1, // API expects 1-based indexing
        pageSize: pageSize,
      );

      if (model != null) {
        if (resetData || paginationModel == null) {
          paginationModel = model.copyWith();
        } else {
          final existingIds =
              paginationModel?.list?.map((e) => e.sId).toSet() ?? {};
          final newItems =
              (model.list ?? [])
                  .where((e) => !existingIds.contains(e.sId))
                  .toList();

          paginationModel = paginationModel?.copyWith(
            list: [...(paginationModel?.list ?? []), ...newItems],
          );
        }

        hasMoreData =
            (model.totalPages != null &&
                (currentPage + 1) < model.totalPages!) ||
            ((model.list?.length ?? 0) >= pageSize);

        currentPage++;

        print("paginationModel length ----- ${paginationModel?.list?.length}");
      } else {
        _error = "Failed to fetch notifications";
        hasMoreData = false;
      }
    } catch (e) {
      _error = e.toString();
      hasMoreData = false;
      if (showLoader) showCatchToast(_error, null);
    } finally {
      loader = false;
      isApiCalling = false;
      _safeNotifyListeners();
    }
  }

  /// Load Notifications (wrapper)
  Future<void> loadNotifications({bool resetData = false}) async {
    await getAllNotificationAPI(showLoader: true, resetData: resetData);
  }

  /// Refresh a specific page
  Future<void> refreshNotificationPage({
    required int page,
    bool showLoader = false,
    bool replacePage = false,
  }) async {
    if (isApiCalling) return;
    isApiCalling = true;

    if (showLoader) {
      refreshLoader = true;
      _safeNotifyListeners();
    }

    try {
      final model = await NotificationApis.getNotificationsAPI(
        page: page,
        pageSize: pageSize,
      );

      if (model != null) {
        if (replacePage || paginationModel == null) {
          final startIndex = (page - 1) * pageSize;
          final endIndex = startIndex + (model.list?.length ?? 0);

          if (paginationModel?.list != null &&
              startIndex < paginationModel!.list!.length) {
            paginationModel?.list?.replaceRange(
              startIndex,
              endIndex,
              model.list ?? [],
            );
          } else {
            paginationModel = model.copyWith();
          }
        } else {
          final existingIds =
              paginationModel?.list?.map((e) => e.sId).toSet() ?? {};
          final newItems =
              (model.list ?? [])
                  .where((e) => !existingIds.contains(e.sId))
                  .toList();

          paginationModel = paginationModel?.copyWith(
            list: [...(paginationModel?.list ?? []), ...newItems],
          );
        }
      } else {
        _error = "Failed to refresh notifications for page $page";
      }
    } catch (e) {
      _error = e.toString();
      if (showLoader) showCatchToast(_error, null);
    } finally {
      refreshLoader = false;
      isApiCalling = false;
      _safeNotifyListeners();
    }
  }

  /// Clear all notifications
  void clearNotifications() {
    notifications.clear();
    paginationModel = null;
    currentPage = 0;
    _error = null;
    _safeNotifyListeners();
  }

  /// Safe notifier
  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
