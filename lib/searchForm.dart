import 'package:flutter/material.dart';

import 'colors.dart';

class SearchCityForm extends StatefulWidget {
  final Function fetchWeather;

  const SearchCityForm({super.key, required this.fetchWeather});

  @override
  _SearchCityFormState createState() => _SearchCityFormState();
}

class _SearchCityFormState extends State<SearchCityForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cityController = TextEditingController();
  final FocusNode _cityFocusNode = FocusNode();

  @override
  void dispose() {
    _cityController.dispose();
    _cityFocusNode.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      String cityName = _cityController.text;
      widget.fetchWeather(cityName);
      _cityController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _cityController,
            focusNode: _cityFocusNode,
            decoration: const InputDecoration(
              labelText: 'City',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a city';
              }
              return null;
            },
            onFieldSubmitted: (value) {
              _submitForm();
            },
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                String cityName = _cityController.text;
                widget.fetchWeather(cityName);
                _cityController.clear();

                _cityFocusNode.unfocus();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColors.meteblue,
            ),
            child: const Text(
              'Search',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}