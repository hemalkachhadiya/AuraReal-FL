// import 'package:aura_real/aura_real.dart';
//
// class PostsListScreen extends StatelessWidget {
//   const PostsListScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<PostsProvider>(
//       builder: (context, postsProvider, child) {
//         if (postsProvider.isLoading) {
//           return Center(
//             child: CircularProgressIndicator(color: ColorRes.primaryColor),
//           );
//         }
//
//         if (postsProvider.error != null) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Error: ${postsProvider.error}',
//                   style: const TextStyle(fontSize: 16),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () => postsProvider.loadPosts(),
//                   child: const Text('Retry'),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         if (postsProvider.posts.isEmpty) {
//           return const Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.post_add, size: 64, color: Colors.grey),
//                 SizedBox(height: 16),
//                 Text(
//                   'No posts yet',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.grey,
//                   ),
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   'Be the first to share something!',
//                   style: TextStyle(fontSize: 14, color: Colors.grey),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         return RefreshIndicator(
//           color: ColorRes.primaryColor,
//           onRefresh: () => postsProvider.loadPosts(),
//           child: CustomListView(
//             padding: EdgeInsets.zero,
//             separatorBuilder:
//                 (p0, p1) => Container(padding: EdgeInsets.only(bottom: 10.ph)),
//             physics: const AlwaysScrollableScrollPhysics(),
//             itemCount: postsProvider.posts.length,
//             itemBuilder: (context, index) {
//               final post = postsProvider.posts[index];
//               return PostCard(post: post,onTap: (){},);
//             },
//           ),
//         );
//       },
//     );
//   }
// }
