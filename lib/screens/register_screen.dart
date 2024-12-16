import 'package:employee_attendance/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    double  screenWidth = MediaQuery.of(context).size.width;
    double screenHeight =  MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('To Login'),
        backgroundColor: Colors.blueGrey,
      ),
      resizeToAvoidBottomInset: false,
      body: Column(children: [
        Container(
          height: screenHeight /3,
          width: screenWidth,
          decoration: const BoxDecoration(
            color: Colors.blueGrey,
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(70),
            )
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Image.asset(
                  'assets/Healthcare.png',
                  height: 110,
                  width: 110,
                ),
              const SizedBox(height: 10,),
              const Text("Hogar Estancias de Paz 2", style: TextStyle(
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: "cursive"
              ),
              ),
              const SizedBox(height: 20),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10.0,0,0,0),
                    child :  Text(
                      "Entre un email y password para registrarse a la aplicación, después regrese a la pagina de Login.",
                      style: TextStyle(
                      color: Colors.white),
                    ),
                  ),
                )
            ],
          ),
        ),
        
        const SizedBox(height: 50,),
        Padding(padding: const EdgeInsets.all(20),
        child: Column(children: [
          TextField(
            decoration: const InputDecoration(
              label: Text ("Enter Employee Email"),
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(borderSide: BorderSide()),
            ),
            controller: _emailController,
          ),
          const SizedBox(
            height: 20,
          ),
          
            TextField(
            decoration: const InputDecoration(
              label: Text ("Enter Employee Password"),
              prefixIcon: Icon(Icons.lock),
              border: OutlineInputBorder(borderSide: BorderSide()),
            ),
            controller: _passwordController,
            obscureText: true,
          ),
          const SizedBox(
            height: 20,
          ),
          Consumer<AuthService>(
            builder: (context, authServiceProvider, child) {
            return
            SizedBox(
              height: 60,
              width: double.infinity,
              child: authServiceProvider.isLoading ? const Center(
                child : CircularProgressIndicator(),
              )
              :ElevatedButton(onPressed: () {
                authServiceProvider.registerEmployee(
                  _emailController.text.trim(), 
                  _passwordController.text.trim(),
                   context);
              }, 
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)
                )
              ) ,
              child: const Text(
                "Register",
                style: TextStyle
                (fontSize: 18,
                color: Colors.white
                ),),
              )
             
            
            );

            },
          )

        ]),
        )




      ],)
    );
  }
}