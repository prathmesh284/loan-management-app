// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class CustomersPage extends StatelessWidget {
//   const CustomersPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

//     final bgColor = isDark ? const Color(0xFF221d10) : const Color(0xFFf8f8f6);
//     final textColor = isDark ? Colors.white : Colors.black87;
//     final subTextColor = isDark ? Colors.white70 : Colors.black54;
//     final primaryColor = const Color(0xFFecb613);

//     final customers = [
//       {
//         'name': 'Rajesh Kumar',
//         'loanId': '12345',
//         'image':
//             'https://lh3.googleusercontent.com/aida-public/AB6AXuB-1km1GfCKHwGl1VfuoC8Rpo8Pn7F4mV-Ry8U7tKTqe7VSe05tf-Y8AQnh1csgoPE5qGy78eh9DjfhtpV-2gC0GX7QuqrwxKeK0ypZ8fT4US4fnZcV7rL_bWG6MM0WV2ERmwc38MGk2Ihorj7yqiKXMD569JoixA0UCs7r1bIdE-9otyemNAdXVs_R9AFK-Jv0ayzZdh5SuHM26RtOZlhS8D92jvYkoEqwDnKijRg2aWFT-usm_4B48GdjAl2Ns1fvHDTbsVemFf0H'
//       },
//       {
//         'name': 'Priya Sharma',
//         'loanId': '67890',
//         'image':
//             'https://lh3.googleusercontent.com/aida-public/AB6AXuA82K2zabiNb8qizVLpIYTzF-cXPi43YUBRW_u3NGkpcWRI4pko7VzC38lgXbBWQPyI_R5Z3fxG7uJg2VNI5PVVrpmWUgEFxHez2GrUF1wWtS6TRCLQ96EwYaJu_DJMhEyEC95C-RBxnfRlHS2i0jBH43RSIVKTelMrrffQMyzAARE7rd4q51jNgKziRDlYu94DjJbGxh3_Hr-L5UAPJbEgQj7te0j4rNnKl4RPZuKwzNNnJrXojL3xXkdJxIDVUQ29f90QYREMu9qN'
//       },
//       {
//         'name': 'Amit Verma',
//         'loanId': '11223',
//         'image':
//             'https://lh3.googleusercontent.com/aida-public/AB6AXuBxNOBSTG5_3kCNv9c9W05az-45k_-Wue9QShrOJdCXqphZqVn1wXdpjxM4omzVeDmEIzL4p3VsPcxtSCW0a_f8OobIPS6k4cTQC47eXjTuVB8TrYhvyHO9O9CYZaoWlz94G-I2X2L8PdqaCZMSZKhzsT7vJwfVIr45bC184_sw8jtRYLQablL6dxN8EhImrBoUQykiJWf4qTwN4hxxgjFHjNwUZKj8gq0N3iNTy2NGWejo8zDL1w5VZJ2oKD972fhZP0K3VTmVFYNE'
//       },
//       {
//         'name': 'Sneha Kapoor',
//         'loanId': '44556',
//         'image':
//             'https://lh3.googleusercontent.com/aida-public/AB6AXuDRh4iZokxzWPr5xxTqnY6I9QQHgKosQ0uF0yOxmOg0i-NCgJ5kYChZuCrZnDApp96WYVUQcbHd_dQycZd0YgmluCjdc0_fFOCu0iwx6-lP7xsUEIkPhKKuwjkB7meeqWX3nxfpMnUlBt7ix09MoZi1O-nG0On0E8-wpmhJ46G0q2ZYw0OAmMq_6VcK9lItA1mghKdzypdeT6nTMLJzKUkSs9upx8fW8jILoqnqjgbPBAFjsWy-3ewNDtt7X1tgTGOAWcIUjGB0GA5K'
//       },
//     ];

//     return Scaffold(
//       backgroundColor: bgColor,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const SizedBox(width: 40),
//                       Text(
//                         "Customers",
//                         style: GoogleFonts.manrope(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: textColor,
//                         ),
//                       ),
//                       Icon(Icons.add, color: textColor, size: 26),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   TextField(
//                     style: GoogleFonts.manrope(
//                       color: textColor,
//                       fontSize: 13,
//                     ),
//                     decoration: InputDecoration(
//                       prefixIcon: Icon(Icons.search,
//                           color: primaryColor, size: 22),
//                       hintText: "Search customers",
//                       hintStyle: TextStyle(
//                         color: subTextColor,
//                         fontSize: 13,
//                       ),
//                       filled: true,
//                       fillColor: isDark
//                           ? Colors.black.withOpacity(0.15)
//                           : const Color(0xFFF8F8F6),
//                       contentPadding:
//                           const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide:
//                             BorderSide(color: primaryColor.withOpacity(0.3)),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide:
//                             BorderSide(color: primaryColor.withOpacity(0.6)),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // List
//             Expanded(
//               child: ListView(
//                 padding: const EdgeInsets.all(16),
//                 children: [
//                   Text(
//                     "Recent Customers",
//                     style: GoogleFonts.manrope(
//                       fontSize: 15,
//                       fontWeight: FontWeight.bold,
//                       color: textColor,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   ...customers.map((c) {
//                     return InkWell(
//                       onTap: () {},
//                       borderRadius: BorderRadius.circular(12),
//                       child: Container(
//                         margin: const EdgeInsets.symmetric(vertical: 5),
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12),
//                           color: isDark
//                               ? primaryColor.withOpacity(0.1)
//                               : primaryColor.withOpacity(0.05),
//                         ),
//                         child: Row(
//                           children: [
//                             CircleAvatar(
//                               radius: 25,
//                               backgroundImage: NetworkImage(c['image']!),
//                             ),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     c['name']!,
//                                     style: GoogleFonts.manrope(
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.w600,
//                                       color: textColor,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 3),
//                                   Text(
//                                     "Loan ID: ${c['loanId']}",
//                                     style: GoogleFonts.manrope(
//                                       fontSize: 11,
//                                       color: subTextColor,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Icon(Icons.chevron_right,
//                                 color: subTextColor, size: 20),
//                           ],
//                         ),
//                       ),
//                     );
//                   }),
//                 ],
//               ),
//             ),

//             // Bottom Nav
//             Container(
//               decoration: BoxDecoration(
//                 color: bgColor,
//                 border: Border(
//                   top: BorderSide(color: primaryColor.withOpacity(0.3)),
//                 ),
//               ),
//               padding: const EdgeInsets.symmetric(vertical: 8),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   _buildNavItem(Icons.home, "Dashboard", false, primaryColor),
//                   _buildNavItem(Icons.group, "Customers", true, primaryColor),
//                   _buildNavItem(Icons.account_balance_wallet, "Loans", false, primaryColor),
//                   _buildNavItem(Icons.description, "Documents", false, primaryColor),
//                   _buildNavItem(Icons.calculate, "Calculator", false, primaryColor),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNavItem(IconData icon, String label, bool active, Color color) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(icon, color: active ? color : Colors.grey, size: 22),
//         const SizedBox(height: 2),
//         Text(
//           label,
//           style: GoogleFonts.manrope(
//             fontSize: 10,
//             color: active ? color : Colors.grey,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:loan_management_app/CustomerDetailPage.dart';

class CustomersPage extends StatelessWidget {
  const CustomersPage({super.key});

  final List<Map<String, String>> customers = const [
    {
      'name': 'Rajesh Kumar',
      'loanId': '12345',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB-1km1GfCKHwGl1VfuoC8Rpo8Pn7F4mV-Ry8U7tKTqe7VSe05tf-Y8AQnh1csgoPE5qGy78eh9DjfhtpV-2gC0GX7QuqrwxKeK0ypZ8fT4US4fnZcV7rL_bWG6MM0WV2ERmwc38MGk2Ihorj7yqiKXMD569JoixA0UCs7r1bIdE-9otyemNAdXVs_R9AFK-Jv0ayzZdh5SuHM26RtOZlhS8D92jvYkoEqwDnKijRg2aWFT-usm_4B48GdjAl2Ns1fvHDTbsVemFf0H'
    },
    {
      'name': 'Priya Sharma',
      'loanId': '67890',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA82K2zabiNb8qizVLpIYTzF-cXPi43YUBRW_u3NGkpcWRI4pko7VzC38lgXbBWQPyI_R5Z3fxG7uJg2VNI5PVVrpmWUgEFxHez2GrUF1wWtS6TRCLQ96EwYaJu_DJMhEyEC95C-RBxnfRlHS2i0jBH43RSIVKTelMrrffQMyzAARE7rd4q51jNgKziRDlYu94DjJbGxh3_Hr-L5UAPJbEgQj7te0j4rNnKl4RPZuKwzNNnJrXojL3xXkdJxIDVUQ29f90QYREMu9qN'
    },
    {
      'name': 'Amit Verma',
      'loanId': '11223',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBxNOBSTG5_3kCNv9c9W05az-45k_-Wue9QShrOJdCXqphZqVn1wXdpjxM4omzVeDmEIzL4p3VsPcxtSCW0a_f8OobIPS6k4cTQC47eXjTuVB8TrYhvyHO9O9CYZaoWlz94G-I2X2L8PdqaCZMSZKhzsT7vJwfVIr45bC184_sw8jtRYLQablL6dxN8EhImrBoUQykiJWf4qTwN4hxxgjFHjNwUZKj8gq0N3iNTy2NGWejo8zDL1w5VZJ2oKD972fhZP0K3VTmVFYNE'
    },
    {
      'name': 'Sneha Kapoor',
      'loanId': '44556',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDRh4iZokxzWPr5xxTqnY6I9QQHgKosQ0uF0yOxmOg0i-NCgJ5kYChZuCrZnDApp96WYVUQcbHd_dQycZd0YgmluCjdc0_fFOCu0iwx6-lP7xsUEIkPhKKuwjkB7meeqWX3nxfpMnUlBt7ix09MoZi1O-nG0On0E8-wpmhJ46G0q2ZYw0OAmMq_6VcK9lItA1mghKdzypdeT6nTMLJzKUkSs9upx8fW8jILoqnqjgbPBAFjsWy-3ewNDtt7X1tgTGOAWcIUjGB0GA5K'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F8F6),
        title: const Text(
          "Customers",
          style: TextStyle(
              color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.add, color: Colors.black87, size: 28),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: Color(0xFFecb613)),
              hintText: "Search customers",
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(0xFFecb613), width: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(0xFFecb613), width: 1.2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Recent Customers",
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: customers.length,
              itemBuilder: (context, index) {
                final c = customers[index];
                return InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => CustomerDetailsPage(name: c['name']!, imageUrl: c['image']!)),
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.amber.withOpacity(0.05),
                    ),
                    child: Row(children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundImage: NetworkImage(c['image']!),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c['name']!,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87)),
                              Text("Loan ID: ${c['loanId']}",
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                            ]),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey)
                    ]),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   selectedItemColor: const Color(0xFFecb613),
      //   unselectedItemColor: Colors.grey,
      //   showUnselectedLabels: true,
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: "Dashboard"),
      //     BottomNavigationBarItem(icon: Icon(Icons.group), label: "Customers"),
      //     BottomNavigationBarItem(
      //         icon: Icon(Icons.account_balance_wallet), label: "Loans"),
      //     BottomNavigationBarItem(
      //         icon: Icon(Icons.description), label: "Documents"),
      //     BottomNavigationBarItem(
      //         icon: Icon(Icons.calculate), label: "Calculator"),
      //   ],
      //   currentIndex: 1,
      // ),
    );
  }
}
