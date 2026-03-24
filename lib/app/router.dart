import 'package:flutter/material.dart';
import '../features/auth/presentation/screens/auth_gate_screen.dart';
import '../features/auth/presentation/screens/client_email_screen.dart';
import '../features/auth/presentation/screens/client_otp_screen.dart';
import '../features/auth/presentation/screens/client_phone_gate_screen.dart';
import '../features/client/presentation/screens/client_home_screen.dart';
import '../features/client/presentation/screens/client_notifications_screen.dart';
import '../features/client/presentation/screens/client_order_create_screen.dart';
import '../features/client/presentation/screens/client_orders_screen.dart';
import '../features/client/presentation/screens/client_order_details_screen.dart';
import '../features/client/presentation/screens/client_account_screen.dart';
import '../features/client/presentation/screens/client_chat_screen.dart';
import '../features/admin/presentation/screens/admin_login_screen.dart';
import '../features/admin/presentation/screens/admin_home_screen.dart';
import '../features/admin/presentation/screens/admin_machines_screen.dart';
import '../features/admin/presentation/screens/admin_orders_screen.dart';
import '../features/admin/presentation/screens/admin_customer_orders_screen.dart';
import '../features/admin/presentation/screens/admin_order_details_screen.dart';
import '../features/admin/presentation/screens/admin_client_account_screen.dart';
import '../features/admin/presentation/screens/admin_clients_screen.dart';
import '../features/admin/presentation/screens/admin_client_profiles_screen.dart';
import '../features/admin/presentation/screens/admin_chats_screen.dart';
import '../features/admin/presentation/screens/admin_chat_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';

class AppRouter {
  static const authGate = '/';
  static const clientEmail = '/client/email';
  static const clientOtp = '/client/otp';
  static const clientPhoneGate = '/client/phone-gate';
  static const clientHome = '/client/home';
  static const clientNotifications = '/client/notifications';
  static const clientCreateOrder = '/client/orders/create';
  static const clientOrders = '/client/orders';
  static const clientOrderDetails = '/client/orders/details';
  static const clientAccount = '/client/account';
  static const clientChat = '/client/chat';
  static const adminLogin = '/admin/login';
  static const adminHome = '/admin/home';
  static const adminMachines = '/admin/machines';
  static const adminOrders = '/admin/orders';
  static const adminCustomerOrders = '/admin/orders/customer';
  static const adminOrderDetails = '/admin/orders/details';
  static const adminClientAccount = '/admin/clients/account';
  static const adminClients = '/admin/clients';
  static const adminClientProfiles = '/admin/clients/profiles';
  static const adminChats = '/admin/chats';
  static const adminChatDetails = '/admin/chats/details';
  static const notifications = '/notifications';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case authGate:
        return MaterialPageRoute(builder: (_) => const AuthGateScreen());
      case clientEmail:
        return MaterialPageRoute(builder: (_) => const ClientEmailScreen());
      case clientOtp:
        return MaterialPageRoute(
          builder: (_) => ClientOtpScreen(
            email: (settings.arguments as String?) ?? '',
          ),
        );
    case clientPhoneGate:
        return MaterialPageRoute(
          builder: (_) => ClientPhoneGateScreen(
            email: (settings.arguments as String?) ?? '',
          ),
        );
      case clientHome:
        return MaterialPageRoute(builder: (_) => const ClientHomeScreen());
      case clientNotifications:
        return MaterialPageRoute(
            builder: (_) => const ClientNotificationsScreen());
      case clientCreateOrder:
        return MaterialPageRoute(
            builder: (_) => const ClientOrderCreateScreen());
      case clientOrders:
        return MaterialPageRoute(builder: (_) => const ClientOrdersScreen());
      case clientOrderDetails:
        return MaterialPageRoute(
          builder: (_) => ClientOrderDetailsScreen(
            orderId: (settings.arguments as int?) ?? 0,
          ),
        );
      case clientAccount:
        return MaterialPageRoute(builder: (_) => const ClientAccountScreen());
      case clientChat:
        return MaterialPageRoute(builder: (_) => const ClientChatScreen());
      case adminLogin:
        return MaterialPageRoute(
          builder: (_) => AdminLoginScreen(
            initialEmail: settings.arguments as String?,
          ),
        );
      case adminHome:
        return MaterialPageRoute(builder: (_) => const AdminHomeScreen());
      case adminMachines:
        return MaterialPageRoute(builder: (_) => const AdminMachinesScreen());
      case adminOrders:
        return MaterialPageRoute(builder: (_) => const AdminOrdersScreen());
      case adminCustomerOrders:
        final args = settings.arguments is Map
            ? Map<String, dynamic>.from(settings.arguments as Map)
            : <String, dynamic>{};
        return MaterialPageRoute(
          builder: (_) => AdminCustomerOrdersScreen(
            clientId: int.tryParse('${args['client_id']}') ?? 0,
          ),
        );
      case adminOrderDetails:
        return MaterialPageRoute(
          builder: (_) => AdminOrderDetailsScreen(
            orderId: (settings.arguments as int?) ?? 0,
          ),
        );
      case adminClientAccount:
        return MaterialPageRoute(
          builder: (_) => AdminClientAccountScreen(
            clientId: (settings.arguments as int?) ?? 0,
          ),
        );
      case adminClients:
        return MaterialPageRoute(builder: (_) => const AdminClientsScreen());
        case adminClientProfiles:
          return MaterialPageRoute(
            builder: (_) => const AdminClientProfilesScreen(),
          );
      case adminChats:
        return MaterialPageRoute(builder: (_) => const AdminChatsScreen());
      case adminChatDetails:
        return MaterialPageRoute(
          builder: (_) => AdminChatScreen(
            conversationId: (settings.arguments as int?) ?? 0,
          ),
        );
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
