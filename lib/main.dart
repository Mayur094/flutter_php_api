import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
        title: 'Api Development in PHP',
        debugShowCheckedModeBanner: false,
        home: ApiDevelopment(),
    );
  }
}

class ApiDevelopment extends StatefulWidget{
  @override
  State<ApiDevelopment> createState() => ApiDevelopmentState();
}

class ApiDevelopmentState extends State<ApiDevelopment>{
  final formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final baseurl = 'http://10.0.2.2/apis/api.php';

  bool isSubmitting = false;

  //Function for making a POST request
  Future<Map<String,dynamic>> createUser(String name,String email) async{
    final uri = Uri.parse(baseurl);
    final body = jsonEncode({'name': name, 'email': email});

    // log before request
    debugPrint('>>> createUser: POST $uri');
    debugPrint('>>> body: $body');

    try {
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(Duration(seconds: 15));

      //php returns 200 for POST request
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        return jsonDecode(resp.body);
      } else {
        throw Exception('Failed to create user');
      }
    } on Exception catch (e, st){
      // always log the exception and stacktrace
      debugPrint('!!! createUser Exception: $e');
      debugPrint(st as String?);
      rethrow; // rethrow so caller can show the error
    }
  }

  //Function to get users list
  Future<List<Map<String,dynamic>>> getUsers() async{
    final uri = Uri.parse(baseurl);
    final res = await http.get(uri).timeout(Duration(seconds: 15));
    if(res.statusCode == 200){
      final data = jsonDecode(res.body);
      final List list = data['data'] ?? [];
      return List<Map<String, dynamic>>.from(list);
    }else{
      throw Exception('Failed to fetch users');
    }
  }


  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(
          leading: SizedBox(child: Icon(Icons.menu,color: Colors.white,size: 30,),),
          centerTitle: true,
          title: Text('Api In PHP',style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white
          ),),
          backgroundColor: Colors.purple[500],
          elevation: 5,
        ),
        body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blue,Colors.purple],
              begin: Alignment.topRight,end: Alignment.bottomLeft),
            ),
            child: Center(
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Material(
                   borderRadius: BorderRadius.circular(12),
                   elevation: 18.0,
                   color: Colors.transparent,
                   shadowColor: Colors.black,
                   child: Container(
                     width: 300,
                     decoration: BoxDecoration(
                       color: Colors.white,
                       borderRadius: BorderRadius.circular(12),
                     ),
                     child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 16),
                       child: Form(
                         key: formKey,
                         child: Column(
                           mainAxisAlignment: MainAxisAlignment.start,
                           children: [
                             Padding(
                               padding: const EdgeInsets.symmetric(horizontal: 12,),
                               child: TextFormField(
                                 controller: _nameController,
                                 decoration: InputDecoration(
                                   labelText: "Name",
                                   errorBorder: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(12),
                                     borderSide:BorderSide(width: 2,color: Colors.red),
                                   ),
                                   focusedErrorBorder: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(12),
                                     borderSide:BorderSide(width: 2,color: Colors.red),
                                   ),
                                   border: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(12),
                                     borderSide:BorderSide(width: 2),
                                   ),
                                   hintText: 'Enter Your Name',
                                 ),
                                 validator: (value){
                                   if(value!.isEmpty){
                                     return 'Please Enter Your Name';
                                   }
                                   return null;
                                 },
                               ),
                             ),
                             SizedBox(height: 20),
                             Padding(
                               padding: const EdgeInsets.symmetric(horizontal: 12),
                               child: TextFormField(
                                controller: _emailController,
                                 decoration: InputDecoration(
                                   labelText: "Email",
                                   border: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(12),
                                     borderSide:BorderSide(width: 2),
                                   ),
                                 ),
                                 validator: (value) {
                                   if (value == null || value.isEmpty) {
                                     return "Please enter your email";
                                   }
                                   final gmailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@gmail\.com$");
                                   if (!gmailRegex.hasMatch(value)) {
                                     return "Enter a valid email";
                                   }
                                   return null;
                                 },
                               ),
                             ),
                           ],
                         ),
                       )
                     ),
                   ),
                 ),
                 SizedBox(height: 40,),
                 ElevatedButton(
                   onPressed: isSubmitting ? null : () async{
                     if(formKey.currentState!.validate()){
                       setState(() {
                         isSubmitting = true;
                       });
                       debugPrint("Name: ${_nameController.text}");
                       debugPrint("Name: ${_nameController.text}");

                       final name = _nameController.text.trim();
                       final email = _emailController.text.trim();
                       try {
                         final response = await createUser(name, email);
                         final status = response['status'] ?? '';
                         final message = response['message'] ?? response['error'] ?? 'Done';
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text('Server: $message')),
                         );
                         //clear fields on success
                         if(status == 'success'){
                           _nameController.clear();
                           _emailController.clear();
                         }
                       } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                         );
                       } finally {
                         setState(() {
                           isSubmitting = false;
                         });
                       }
                     }
                   },
                   style: ElevatedButton.styleFrom(
                     elevation: 8.0,
                     backgroundColor: Colors.lightBlue,
                     padding: EdgeInsets.symmetric(horizontal: 40,vertical: 14)
                   ),
                   child: isSubmitting ?
                     SizedBox(height: 20, width: 20, child: CircularProgressIndicator(),)
                     : Text(
                       "Submit",
                       style: TextStyle(
                         fontWeight: FontWeight.bold,
                         fontSize: 20,
                         color: Colors.white,
                       ),
                     ),
                 ),
                 SizedBox(height: 20,),
                 ElevatedButton(
                   onPressed: () async{
                     //quick demo fetch and show users (GET)
                     try{
                       final list = await getUsers();
                       if(list.isEmpty) {
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text('no users')),
                         );
                         return;
                       }
                       //show in dialogBox
                       showDialog(
                         context: context, builder: (_){
                         return AlertDialog(
                           title: Text('Users List'),
                           content: SizedBox(
                             width: double.maxFinite,
                             child: ListView.builder(
                               shrinkWrap: true,
                               itemCount: list.length,
                               itemBuilder: (context,index){
                                 final user = list[index];
                                 return ListTile(
                                   title: Text(user['name'] ?? ''),
                                   subtitle: Text(user['email'] ?? ''),
                                 );
                               }
                             )
                           ),
                           actions: [
                             TextButton(onPressed: () => Navigator.pop(context),
                                 child: Text('Close')),
                           ],
                         );
                       });
                     } on TimeoutException catch (e) {
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(content: Text('Timeout: $e')),
                       );
                     } catch (e) {
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(content: Text('Error: $e')),
                       );
                     }
                   },
                   style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                   child: Text('Fetch Users'),
                 )
               ],
             ),
          ),
        ),
    );
  }
}