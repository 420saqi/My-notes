import 'package:flutter/material.dart';
import 'package:nots/constants/routes.dart%20';
import 'package:nots/services/auth/auth_service.dart';


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
          const Text('An email has sent to your account , Please verify',
            style: TextStyle(fontSize: 20),),
          const Text('Click below if you didn\'t receive email',
            style: TextStyle(fontSize: 20),),
          TextButton(onPressed: ()async{
                await AuthService.firebase().sendEmailVerification();
          },
              child:const Text('send Email' ,
              style: TextStyle(fontSize: 30),),),
          TextButton(onPressed: ()async{
            await AuthService.firebase().logout();
            Future.delayed(Duration.zero,(){
              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute,
                    (route) => false,
              );
            });
          },
            child: const Text('Reset',style: TextStyle(fontSize: 30),),),
        ],
      ),
    );
  }
}
