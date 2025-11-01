// import 'package:flutter/material.dart';
// import 'package:loan_management_app/CustomersPage.dart';
// import 'package:loan_management_app/DashboardPage.dart';
// import 'package:loan_management_app/DocumentStoragePage.dart';
// import 'package:loan_management_app/EMICalculatorPage.dart';
// import 'package:loan_management_app/LoanManagementPage.dart';

// class NavigationBarPage extends StatefulWidget {
//   const NavigationBarPage({super.key});

//   @override
//   State<NavigationBarPage> createState() => _NavigationBarPageState();
// }

// class _NavigationBarPageState extends State<NavigationBarPage> {
//   int _selectedIndex = 0;

//   final List<Widget> _pages = const [
//     DashboardPage(),
//     CustomersPage(),
//     LoanManagementPage(),
//     DocumentStoragePage(),
//     EmiCalculatorPage(),
//   ];

//   void _onItemTapped(int index) {
//     if (index == _selectedIndex) return; // Prevent reloading same page
//     setState(() => _selectedIndex = index);

//     // For limited pages, use route navigation
//     if (index == 3 || index == 4) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => _pages[index]),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: IndexedStack(
//         index: _selectedIndex,
//         children: _pages,
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         selectedItemColor: Colors.amber[800],
//         unselectedItemColor: Colors.grey[600],
//         type: BottomNavigationBarType.fixed,
//         showUnselectedLabels: true,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home_outlined),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.group_outlined),
//             label: 'Customers',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.account_balance_wallet_outlined),
//             label: 'Loans',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.description_outlined),
//             label: 'Documents',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.calculate_outlined),
//             label: 'Calculator',
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:loan_management_app/DashboardPage.dart';
import 'package:loan_management_app/CustomersPage.dart';
import 'package:loan_management_app/DocumentStoragePage.dart';
import 'package:loan_management_app/EMICalculatorPage.dart';
import 'package:loan_management_app/LoanManagementPage.dart';

class NavigationBarPage extends StatefulWidget {
  final int initialIndex;
  const NavigationBarPage({super.key, this.initialIndex = 0});

  @override
  State<NavigationBarPage> createState() => _NavigationBarPageState();
}

class _NavigationBarPageState extends State<NavigationBarPage> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return; // prevent reloading same page

    setState(() => _selectedIndex = index);

    Widget nextPage;
    switch (index) {
      case 0:
        nextPage = const DashboardPage();
        break;
      case 1:
        nextPage = const CustomersPage();
        break;
      case 2:
        nextPage = const LoanManagementPage();
        break;
      case 3:
        nextPage = const DocumentStoragePage();
        break;
      case 4:
        nextPage = const EmiCalculatorPage();
        break;
      default:
        nextPage = const DashboardPage();
    }

    // Navigate to the selected page, replacing the previous one
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: nextPage,
          bottomNavigationBar: NavigationBarPage(initialIndex: index),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFecb613);

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primaryColor, 
      backgroundColor: const Color.fromARGB(255, 57, 48, 23),
      unselectedItemColor: Colors.grey.shade600,
      showUnselectedLabels: true,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded), label: "Dashboard"),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: "Customers"),
        BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet), label: "Loans"),
        BottomNavigationBarItem(
            icon: Icon(Icons.description), label: "Documents"),
        BottomNavigationBarItem(
            icon: Icon(Icons.calculate), label: "Calculator"),
      ],
    );
  }
}
