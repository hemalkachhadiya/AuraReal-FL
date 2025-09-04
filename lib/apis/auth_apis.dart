import 'package:aura_real/aura_real.dart';
import 'package:aura_real/services/api_services.dart';
import 'package:aura_real/utils/end_points.dart';

// class AuthApis {
//   ///Company Register API to register a new company account.
//   static Future<bool> registerAPI({
//     required String phoneNumber,
//     required String email,
//     required String fullName,
//     required String password,
//   }) async {
//     try {
//       final response = await ApiService.getApi(
//         url: EndPoints.register,
//         queryParams: {
//           "email": email,
//           "fullName": fullName,
//           "password": password,
//           "phoneNumber": phoneNumber,
//         },
//       );
//       if (response == null) {
//         showCatchToast('No response from server', null);
//         return false;
//       }
//       print("res: ${response.body}");
//       // final model = appResponseFromJson(response.body);
//       print("model.data");
//
//       // print(model?.data);
//       // if (model != null && model.code == 0) {
//       //   showSuccessToast('Form Submitted Successfully');
//       //   return true;
//       // } else {
//       //   return false;
//       // }
//     } catch (exception, stack) {
//       showCatchToast(exception, stack);
//     }
//     return false;
//   }
// }
