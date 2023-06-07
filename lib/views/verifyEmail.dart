import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Your Email'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          const Text('Verify your Email', style: TextStyle(fontSize: 30),),
          TextButton(onPressed: ()async{
                final user= FirebaseAuth.instance.currentUser;
                await user!.sendEmailVerification();
          },
              child:const Text('send Email', style: TextStyle(fontSize: 30),))
        ],
      ),
    );
  }
}
