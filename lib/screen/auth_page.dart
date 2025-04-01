import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:carwaan/screen/dashboard/admin_dashboard.dart';
import 'package:carwaan/screen/dashboard/driver_dashboard.dart';
import 'package:carwaan/screen/dashboard/passenger_dashboard.dart';
import 'package:carwaan/screen/user_selection_page.dart';

class AuthPage extends StatefulWidget {
  final String userRole;

  const AuthPage({super.key, required this.userRole});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  String? gender;
  final TextEditingController carModelController = TextEditingController();
  final TextEditingController carNumberController = TextEditingController();

  Country? selectedCountry;

  @override
  void initState() {
    super.initState();
    selectedCountry = CountryParser.parseCountryCode('PK');
  }

  void toggleForm() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  void _navigateToDashboard() {
    if (_formKey.currentState!.validate()) {
      Widget dashboard;
      switch (widget.userRole) {
        case 'admin':
          dashboard = AdminDashboard();
          break;
        case 'driver':
          dashboard = DriverDashboard();
          break;
        case 'passenger':
          dashboard = PassengerDashboard();
          break;
        default:
          dashboard = UserSelectionPage();
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => dashboard),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                Image.asset(
                  'images/Carwaan Logo.png',
                  width: MediaQuery.of(context).size.width * 0.6,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 30),
                Text(
                  isLogin ? 'Sign In' : 'Sign Up',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                if (!isLogin) ...[
                  _buildTextField(nameController, 'Name'),
                  SizedBox(height: 10),
                  _buildPhoneNumberField(),
                  SizedBox(height: 10),
                  _buildDropdownField(),
                  SizedBox(height: 10),
                  if (widget.userRole == 'driver') ...[
                    _buildTextField(carModelController, 'Car Model'),
                    SizedBox(height: 10),
                    _buildTextField(carNumberController, 'Car Number'),
                    SizedBox(height: 10),
                  ],
                ],
                _buildTextField(emailController, 'Email'),
                SizedBox(height: 10),
                _buildTextField(passwordController, 'Password', isPassword: true),
                if (!isLogin) ...[
                  SizedBox(height: 10),
                  _buildTextField(confirmPasswordController, 'Confirm Password', isPassword: true),
                ],
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onPressed: _navigateToDashboard,
                  child: Text(isLogin ? 'Sign In' : 'Sign Up', style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: toggleForm,
                  child: Text(
                    isLogin ? "Don't have an account? Sign Up" : "Already have an account? Sign In",
                    style: TextStyle(color: Colors.lightBlue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: TextInputType.text,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.lightBlue),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Enter your $label';
        if (label == 'Email' && !value.contains('@')) return 'Enter a valid email';
        if (label == 'Password' && value.length < 6) return 'Password must be at least 6 characters';
        if (label == 'Confirm Password' && value != passwordController.text) return 'Passwords do not match';
        return null;
      },
    );
  }

  Widget _buildPhoneNumberField() {
    return TextFormField(
      controller: phoneController,
      keyboardType: TextInputType.phone,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Phone Number',
        labelStyle: TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.lightBlue),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        prefixIcon: InkWell(
          onTap: () {
            showCountryPicker(
              context: context,
              showPhoneCode: true,
              onSelect: (Country country) {
                setState(() {
                  selectedCountry = country;
                });
              },
              countryListTheme: CountryListThemeData(
                backgroundColor: Colors.black,
                textStyle: TextStyle(color: Colors.white),
                inputDecoration: InputDecoration(
                  hintText: "Search",
                  hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "+${selectedCountry?.phoneCode ?? '92'}",
                  style: TextStyle(color: Colors.white),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Enter your phone number';
        if (value.length < 10) return 'Enter a valid phone number';
        return null;
      },
    );
  }

  Widget _buildDropdownField() {
    if (widget.userRole == 'admin') {
      return SizedBox.shrink();
    } else {
      return DropdownButtonFormField<String>(
        dropdownColor: Colors.black, // Background color of the dropdown
        value: gender,
        onChanged: (newValue) => setState(() => gender = newValue),
        items: ['Male', 'Female'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(color: Colors.white), // Set text color to white
            ),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: 'Gender',
          labelStyle: TextStyle(color: Colors.white), // White label text
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.lightBlue),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12), // Proper padding
        ),
        icon: Icon(Icons.arrow_drop_down, color: Colors.white), // White dropdown icon
      );
    }
  }
}
