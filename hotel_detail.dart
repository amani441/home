import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:async/async.dart';
import 'package:logger/logger.dart';
import 'package:my_app/commons/global_variables.dart';
import 'package:my_app/home_page.dart';
import 'package:my_app/models/testModel.dart';
import 'package:my_app/sections/googlmap.dart';
// import 'package:my_app/sections/detailshotel.dart';
import 'package:my_app/styles/styles.dart';
import 'package:my_app/responsive.dart';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:my_app/widgets/hotel_description_widget.dart';


TextEditingController _destinationFieldController2 = TextEditingController();

String checkIn2 = "";
String checkOut2 = "";

bool checkInPicked2 = false;
bool checkOutPicked2 = false;

TextEditingController _checkInDateController2 = TextEditingController();
TextEditingController _checkOutDateController2 = TextEditingController();

DateTime _checkInDate2 = checkIn.isNotEmpty? DateFormat.yMMMMd('en_US').parse(checkIn) : DateTime.now();
DateTime _checkOutDate2 = checkOut.isNotEmpty? DateFormat.yMMMMd('en_US').parse(checkOut) : DateTime.now().add(Duration(days: 1));

final List<String> _options2 = ['1 guest', '2 guests', '3 guests'];
String _selectedOption2 = '1 guest';

final List<String> bed_options = ['All options', 'Lit double', 'Separate beds'];
String _selectedBedOption = 'All options';
// final List<String> meal_options = ['All options', 'Without meal', 'Breakfast', 'Breakfast + lunch or dinner','breakfast, lunch and dinner','All inclusive'];
final List<String> meal_options = ['All options', 'Without meal', 'Breakfast', 'All inclusive'];
String _selectedMealOption = 'All options';
final List<String> payement_options = ['All options', 'Pay now', 'Pay at the hotel'];
String _selectedPayementOption = 'All options';
final List<String> cancelTerm_options = ['All options', 'With free cancellation'];
String _selectedCancelTermOption = 'All options'; 


class HotelDetail extends StatefulWidget {
  
  @override
  detailshotelState createState() => detailshotelState();
}

class detailshotelState extends State<HotelDetail> {



  bool showAllRows = false;   

  @override
  void initState(){
    super.initState();    
    checkIn2 = checkIn.isNotEmpty ? checkIn 
                : checkOut.isNotEmpty? DateFormat.yMMMMd('en_US').format(DateFormat.yMMMMd('en_US').parse(checkOut).subtract(Duration(days : 1)))
                : DateFormat.yMMMMd('en_US').format(DateTime.now());
    checkOut2 = checkOut.isNotEmpty ? checkOut
                   : checkIn.isNotEmpty? DateFormat.yMMMMd('en_US').format((DateFormat.yMMMMd('en_US').parse(checkIn)).add(Duration(days : 1))) 
                   : DateFormat.yMMMMd('en_US').format(DateTime.now().add(Duration(days: 1)));        
    // _checkInDateController2 = TextEditingController(text: checkIn2);
    // _checkOutDateController2 = TextEditingController(text: checkOut2);
    // _checkInDateController2 = TextEditingController(text: DateFormat('dd-MM-yyyy').format(DateTime.parse(checkIn2))); 
    // _checkOutDateController2 = TextEditingController(text: DateFormat('dd-MM-yyyy').format(DateTime.parse(checkOut2)));                  
  }


  _selectDate(BuildContext context, bool isCheckInDate) {
    showDatePicker(
      context: context,
      initialDate: isCheckInDate ? _checkInDate2 : _checkOutDate2,
      firstDate: isCheckInDate ? DateTime.now() : _checkInDate2,
      lastDate: DateTime(2100),
    ).then((picked) {
      if (picked != null) {
        if (isCheckInDate) {
          setState(() {
            _checkInDate2 = picked;
            checkInPicked2 = true;

            _checkInDateController2.text = DateFormat('dd-MM-yyyy').format(_checkInDate2);
            checkIn2 = DateFormat.yMMMMd('en_US').format(_checkInDate2);
            checkOut2 = checkOutPicked2? checkOut2: DateFormat.yMMMMd('en_US').format(_checkInDate2.add(Duration(days: 1)));            
            // Ensure that the check-out date is always greater than the check-in date            
            if (_checkOutDate2.isBefore(_checkInDate2) || _checkOutDate2.day == _checkInDate2.day) {              
              _checkOutDate2 = _checkInDate2.add(Duration(days: 1));
              _checkOutDateController2.text = DateFormat('dd-MM-yyyy').format(_checkOutDate2);
              checkOut2 = DateFormat.yMMMMd('en_US').format(_checkInDate2.add(Duration(days: 1)));
            }
          });
        } else {
          setState(() {
            // Ensure check-out date is always greater than check-in date
            if (picked.isAfter(_checkInDate2)) {
              _checkOutDate2 = picked;
              checkOutPicked2 = true;

              _checkOutDateController2.text = DateFormat('dd-MM-yyyy').format(_checkOutDate2);
              checkOut2 = DateFormat.yMMMMd('en_US').format(_checkOutDate2);
              checkIn2 = checkInPicked2? checkIn2 : DateFormat.yMMMMd('en_US').format(_checkOutDate2.subtract(Duration(days: 1)));
            } else {
              _checkOutDate2 = _checkInDate2.add(Duration(days: 1));
              checkOutPicked2 = true;
              _checkOutDateController2.text = DateFormat('dd-MM-yyyy').format(_checkOutDate2);
              checkOut2 = DateFormat.yMMMMd('en_US').format(_checkOutDate2);
              checkIn2 = checkInPicked2? checkIn2 : DateFormat.yMMMMd('en_US').format(_checkOutDate2.subtract(Duration(days: 1)));
            }
          });
        }
      }
    });
  }

  updateDates(){
    setState(() {               
      checkIn = _checkInDateController2.text;           
      checkOut = _checkOutDateController2.text;      
    });
  }


  Future<dynamic> getHotelInfo() async {
      
      var url = Uri.parse('$secondBaseUrl/hotel/info');       
      

      var map = <String, dynamic>{};
      map['id'] = 1;

      try{
        final response = await http.post(
          url,                    
          headers: {            
            'Content-Type': 'application/json',            
          },
          body: jsonEncode(map),
        );
        
        final result = jsonDecode(response.body);
        // Logger().i(result);
        if (response.statusCode == 200) {
          return testModel.fromJson(result);
        } else {
          throw Exception('Failed to load hotel data');
        }
      }
      catch (e){
        Logger().e('Error : $e');
      }
    }

  final AsyncMemoizer _memoizer = AsyncMemoizer();

   Future memoizedgetHotelInfo() {
    return _memoizer.runOnce(() => getHotelInfo());
  }


 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
        body: Padding(
          padding: const EdgeInsets.only(left: 300),
          child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(),
        child: Column(
           crossAxisAlignment: CrossAxisAlignment.start, // Aligner le contenu à gauche

          children: [
            const SizedBox(height: 50),
            
           Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Dialogue"),
                                content: Text("Contenu du dialogue"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Fermer'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Container(
                          // width: 200,
                          width: quarter,
                          height: 50,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "New Search",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black
                                ),
                              ),
                              Icon(Icons.refresh),
                            ],
                          ),
                        ),
                      ),                      
                      Gap(2.w),
                     
                    Container(
                    // width: 550,
                    width: width3 - quarter - 2.w,
                    height: 50,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextButton(
                          onPressed: () {                            
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => HomePage(),
                              ),
                            );
                          },
                          child: Text("Home Page >"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Previous page"),
                        ),
                      ],
                    ),
                  ),
                    ],
                  ),
                ],
              ),

        SizedBox(height: 10,),


            Container(              
              width: width3,
              height: 120,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                 boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 5), // changes position of shadow
                        ),
                      ],
              ),
              
                                      child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon de favori
                              Icon(
                                Icons.favorite,
                                color: Colors.red, 
                              ),
                              SizedBox(width: 10), 
                              // Barre verticale
                              VerticalDivider(
                                color: Colors.grey, 
                                thickness: 1,
                                width: 20, 
                              ),
                              SizedBox(width: 10), 
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Novum Hotel Aldea Berlin Centrum',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Color.fromARGB(255, 36, 120, 247),
                                    ),
                                  ),
                                  Text(
                                    'Al Barsha Street 1, Dubai',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 36, 120, 247),
                                    ),
                                  ),
                                  Row(children: [ 
                                      Icon(Icons.location_on, size: 12, color: Colors.grey),
                                    Text(
                                    '190 m from the Financial Centre , 126 m from Bulowstrasse',
                                    style: TextStyle(
                                                fontSize: 13,
                                                 fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(255, 95, 100, 104), 
                                              ),
                                  ),],)
                                
                                ],
                                
                              ),                        SizedBox(height: 50),

                                Expanded(
                          child: SizedBox(),
                          
                        ),
                         Text('From 456 145 DZD', style: TextStyle(
                                                fontSize: 20,
                                                 fontWeight: FontWeight.bold,
                                                color: Colors.black
                                              ),),
                                              
                               
                            ],
                          ),
              
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
               Container(
                        // width: 300,
                        width: tier3 - 1.w,
                        height: 322,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Image.asset(
                                  '/images/images1.jpeg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  // Espacement entre les colonnes
                  // const SizedBox(width: 1), 
                  Gap(1.w/2),
                  // Deuxième colonne
                  Container(
                    // width: 500,
                    // height: 322,
                    
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            for (var i = 2; i <= 4; i++)
                              Container(
                                // width: 166,
                                width: tier3/2-1.w/2,
                                height: 160,
                                
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                // main image
                              child: Image.asset('/images/images$i.jpeg'), 
                              ),
                          ],
                        ),
                        // const SizedBox(height: 1),
                        Gap(1.w/2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            for (var i = 5; i <= 7; i++)
                              Container(
                              //  width: 166,
                              width : tier3/2-1.w/2,
                                height: 160,
                            
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                            child: Image.asset('/images/images$i.jpeg'), // Image locale
                       
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                // const SizedBox(width: 5),
                Gap(1.w/2),
                Container(
                  
        // width: 200,
        width: tier3/2+1.w,
        height: 322,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Excellent',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Text(
                '15 avis',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Text(
                    '8',
                    style: TextStyle(fontSize: 30, color: Colors.green),
                  ),
                  Icon(Icons.star, color: Colors.green),
                ],
              ),
              // const SizedBox(height: 10),
              Gap(5.h),
              const Text(
                'Remarques des clients:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              ratingBar('Rapport qualité/prix', 8),
              ratingBar('Emplacement', 8),
              ratingBar('Propreté', 8),
                 const SizedBox(height: 30),
        
              Container(
                width: tier3/2+3.w,
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: () {
                    
                  },
                  style: ElevatedButton.styleFrom(
                          primary: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                  child: const Text(
                    "Read reviews",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 11
                      ),
                  ),
                ),
              ),
            ],
          ),
        ),
                
              
            
        
                
              ],
            ),
            const SizedBox(height: 10),
            
                                              
                Container(
                    width: 212.w,
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 5), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Arrivée
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Check-in',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                                     Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            // text: '2 juin 2024, mer. ',
                                            text: "$checkIn2 ",
                                            style: TextStyle(
                                              fontSize: 15,
                                               fontWeight: FontWeight.bold,
                                              color: Colors.blue, 
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'After $earlyCheckIn',
                                            style: TextStyle(
                                              fontSize: 15,                                              
                                              color: Colors.grey, 
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                          ],
                        ),
                        const SizedBox(width: 16.0), 
                        // Départ
                       Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Check-out',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text.rich(
                                    TextSpan(
                                      children: [                                        
                                        TextSpan(
                                          // text: '5 juin 2024, mer. ',
                                          text: "$checkOut2 ",
                                          style: TextStyle(
                                            fontSize: 15, 
                                             fontWeight: FontWeight.bold,
                                            color: Colors.blue, 
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'Before $lateCheckOut',
                                          // text: 
                                          style: TextStyle(
                                            fontSize: 15, 
                                            color: Colors.grey, 
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ],
                        ),
                        // Expanded used so that it takes all the remaining space in the middle and the button would be at the right 
                        const Expanded(
                          child: SizedBox(),
                        ),
                        
                        ElevatedButton(
                         onPressed: () {
            
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return SizedBox(
                                    width: MediaQuery.of(context).size.width/3,
                                    height: (MediaQuery.of(context).size.height/3)/2,
                                    // height: 100,
                                    child: AlertDialog(
                                      title: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Available Hotels in $destination',                                            
                                            ),
                                          Text('for the period from $checkIn to $checkOut')
                                        ],
                                      ),
                                      content: Container(
                                        height: (MediaQuery.of(context).size.height/3)/2 + 12.h ,
                                        child: Column(
                                          children: [
                                            SizedBox(                                              
                                              width: MediaQuery.of(context).size.width/3 - 6.w,
                                              height: 60.h,                                            
                                              child: TextFormField(   
                                                controller: _destinationFieldController2,                                                                                                                                     
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                ),
                                              decoration: const InputDecoration( 
                                                border: OutlineInputBorder(),                                            
                                                labelText: 'Destination',
                                                labelStyle: TextStyle(fontSize: 11),                                              
                                                hintText: 'Choose your destination',
                                                hintStyle: TextStyle(fontSize: 12),
                                                // alignLabelWithHint: true,                                              
                                                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20)
                                              ),
                                            ),
                                            ),
                                            Gap(5.h),
                                            Row(
                                              children: [
                                                SizedBox(
                                                      // width: (MediaQuery.of(context).size.width/3 - 3.w)/4,
                                                      width: checkLength,
                                                      height: 60.h,
                                                      child: TextFormField(
                                                        onTap: () => _selectDate(context,true),                                                            
                                                        // onChanged: (value) => _selectDate(context, true),                                                    
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                        // initialValue: checkIn2,
                                                        controller: _checkInDateController2,                                              
                                                        decoration: const InputDecoration(
                                                          labelText: 'Check-in',
                                                          labelStyle: TextStyle(fontSize: 11),  
                                                          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20), 
                                                          border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.only(
                                                              topRight: Radius.circular(0), 
                                                              bottomRight: Radius.circular(0), 
                                                              topLeft: Radius.circular(4),
                                                              bottomLeft: Radius.circular(4)                                                    
                                                            ),
                                                          ),
                                                        ),                                                      
                                                        readOnly: true, 
                                                      ),
                                                    ),
                                                    // check-out
                                                    SizedBox(
                                                      // width: (MediaQuery.of(context).size.width/3 - 9.w)/4,
                                                      width: checkLength,
                                                      height: 60.h,
                                                      child: TextFormField(
                                                        onTap: () => _selectDate(context, false),
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                        // initialValue: checkOut,
                                                        controller: _checkOutDateController2,                                              
                                                        decoration: const InputDecoration(
                                                          labelText: 'Check-out',
                                                          labelStyle: TextStyle(fontSize: 11),  
                                                          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                                          border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.only(
                                                              topRight: Radius.circular(4), 
                                                              bottomRight: Radius.circular(4),
                                                              topLeft: Radius.circular(0),
                                                              bottomLeft: Radius.circular(0),
                                                            ),
                                                          ),
                                                        ),
                                                        readOnly: true, 
                                                      ),
                                                    ),
                                                    Gap(4.w),
                                                    Expanded(
                                                      child: SizedBox(
                                                        width: checkLength,
                                                        height: 70,
                                                        child: DropdownButtonFormField(                                              
                                                          value: _selectedOption2,
                                                          style: TextStyle(fontSize: 13),
                                                          decoration: const InputDecoration(
                                                            labelText: '1 room for',
                                                            labelStyle: TextStyle(fontSize: 11),  
                                                            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.only(
                                                                topRight: Radius.circular(4), 
                                                                bottomRight: Radius.circular(4),
                                                                topLeft: Radius.circular(4),
                                                                bottomLeft: Radius.circular(4),
                                                              ),
                                                            ),
                                                          ),
                                                          items: _options2.map((String option) {
                                                            return DropdownMenuItem(
                                                              value: option,
                                                              child: Text(option),
                                                            );
                                                          }).toList(),
                                                          onChanged: (value) {
                                                            setState(() {
                                                              _selectedOption2 = value.toString();
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),                                    
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            updateDates();
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Close'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                       style: ElevatedButton.styleFrom(
                          primary: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                  child: const Text(
                    "Change ",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                      ),
                  ),
                        ),
                      ],
                    ),
                  ),
        
            const SizedBox(height: 10),
          Container(
                  width: 212.w,
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 5), 
                      ),
                    ],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Rooms',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'For 27 nights, for 2 adults',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.all(40.0), 
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade100,                          
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          Container(
                            color: Colors.white,
                            // width: (MediaQuery.of(context).size.width/3)/2,
                            width: 0.2*212.w,
                            child: DropdownButtonFormField(                                              
                              value: _selectedBedOption,
                              style: TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                labelText: 'Beds',
                                labelStyle: TextStyle(
                                  fontSize: 3.sp,                                      
                                  ),  
                                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(4), 
                                    bottomRight: Radius.circular(4),
                                    topLeft: Radius.circular(4),
                                    bottomLeft: Radius.circular(4),
                                  ),
                                ),
                              ),
                              items: bed_options.map((String option) {
                                return DropdownMenuItem(
                                  value: option,
                                  child: Text(
                                    option,  
                                    style: TextStyle(
                                      fontSize: 3.sp
                                    ),                                       
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedBedOption = value.toString();
                                });
                              },
                            ),
                          ),
                        
                          Gap(6.w),
                        
                          Container(
                            color: Colors.white,
                            width: 0.2*212.w,                                
                            child: DropdownButtonFormField(                                              
                              value: _selectedMealOption,
                              style: TextStyle(fontSize: 13),
                              decoration: const InputDecoration(
                                labelText: 'Meals',
                                labelStyle: TextStyle(
                                  fontSize: 15,                                      
                                  ),  
                                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(4), 
                                    bottomRight: Radius.circular(4),
                                    topLeft: Radius.circular(4),
                                    bottomLeft: Radius.circular(4),
                                  ),
                                ),
                              ),
                              items: meal_options.map((String option) {
                                return DropdownMenuItem(
                                  value: option,
                                  child: Text(
                                    option,                                        
                                    ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedMealOption = value.toString();
                                });
                              },
                            ),
                          ),
                        
                          Gap(6.w),
                        
                          Container(
                            color: Colors.white,
                            width: 0.2*212.w,                                
                            child: DropdownButtonFormField(                                              
                              value: _selectedCancelTermOption,
                              style: TextStyle(fontSize: 3.sp,
                              overflow: TextOverflow.ellipsis),
                              decoration: InputDecoration(
                                labelText: 'Cancellation policy',
                                labelStyle: TextStyle(
                                  fontSize: 3.sp,                                      
                                  ),  
                                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(4), 
                                    bottomRight: Radius.circular(4),
                                    topLeft: Radius.circular(4),
                                    bottomLeft: Radius.circular(4),
                                  ),
                                ),
                              ),
                              items: cancelTerm_options.map((String option) {
                                return DropdownMenuItem(
                                  value: option,
                                  child: Text(
                                    option,
                                    // style: TextStyle(
                                    //   overflow: TextOverflow.ellipsis
                                    // ),
                                    ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCancelTermOption = value.toString();
                                });
                              },
                            ),
                          ),
                        
                          Gap(6.w),
                        
                          Container(
                            color: Colors.white,
                            width: 0.2*212.w,                                
                            child: DropdownButtonFormField(                                              
                              value: _selectedPayementOption,
                              style: TextStyle(fontSize: 3.sp),
                              decoration: InputDecoration(
                                labelText: 'Payement',
                                labelStyle: TextStyle(fontSize: 3.sp),  
                                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(4), 
                                    bottomRight: Radius.circular(4),
                                    topLeft: Radius.circular(4),
                                    bottomLeft: Radius.circular(4),
                                  ),
                                ),
                              ),
                              items: payement_options.map((String option) {
                                return DropdownMenuItem(
                                  value: option,
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      fontSize: 3.sp
                                    ),
                                    ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedPayementOption = value.toString();
                                });
                              },
                            ),
                          ),
                          
                        ],
                                                  ),
                    ),
               
                 
               
         
                SizedBox(height: 20),
                 Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Fond blanc
                    border: Border.all(color: Colors.black,width: 0.35,), // Bordure grise
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Première colonne pour l'image
                          Container(
                            child: Image.asset('/images/images5.jpeg'), // Image locale
                            width: 100,// Largeur de l'image
                            height: 100, // Hauteur de l'image
                          ),
                          // Deuxième colonne pour le titre
                          Expanded(
                            child: Container(
                                                          padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white, // Couleur de fond du conteneur
                                        borderRadius: BorderRadius.circular(1), // Coins arrondis
                                      
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Standard double chambre',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          Text('lit double'),
                                          Row(
                                            children: [
                                              Icon(Icons.king_bed),
                                              SizedBox(width: 5),
                                              Text('21m²'),
                                              Spacer(),
                                              Icon(Icons.bathtub),
                                              SizedBox(width: 5),
                                              Text('Salle de bain privative'),
                                            ],
                                          ),
                                          // Ajoutez d'autres éléments ici (par exemple, des icônes pour le Wi-Fi, la climatisation, etc.)
                                        ],
                                      ),
                                    
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                              Table(
                            border: TableBorder.all(width: 0.35, color: Colors.black),
                            children: [
                              TableRow(
        
                                children: [
                                  TableCell(
        
                                    child: Container(
                                  color:const Color.fromARGB(255, 59, 58, 58)  ,                          
                                        padding: EdgeInsets.all(8.0),
                                      child: const Center(
                                        child: Text(
                                          'Rom',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Container(
                                  color:const Color.fromARGB(255, 59, 58, 58)  ,                          
                                                 padding: EdgeInsets.all(8.0),
                                      child: const Center(
                                        child: Text(
                                          'Meals',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Container(
                                  color:const Color.fromARGB(255, 59, 58, 58)  ,                          
                                             padding: EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Text(
                                          'Cancellation',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                 TableCell(
                                    child: Container(
                                  color:const Color.fromARGB(255, 59, 58, 58)  ,                          
                                             padding: EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Text(
                                          'Net price',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                   TableCell(
                                    child: Container(
                                  color:const Color.fromARGB(255, 59, 58, 58)  ,                          
                                             padding: EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Text(
                                          'Payment type',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                   TableCell(
                                    child: Container(
                                  color:const Color.fromARGB(255, 59, 58, 58)  ,                          
                                             padding: EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Text(
                                          'Actions',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const TableRow(
                                children: [
                                  TableCell( child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                      SizedBox(width: 20),
        
                                    Text('Lit double'),
                                    Text('Repas non inclus'),
                                    Text('Type de couchage non garanti'),
                                    Text('Non fumeur'),
                                  ],
                                
                              ),
                                 ),
        
                              TableCell( child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 20),
        
                                    Text('Meals are not included'),
                               
                                  ],
                                
                              ),
                                 ),
        
         TableCell( child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 20),
        
                                    Text('AED until mar 28'),
                               
                                  ],
                                
                              ),
                                 ),
         TableCell( child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 20),
        
                                    Text('AED 379 : on the spot AED 15'),
                               
                                  ],
                                
                              ),
                                 ),
         TableCell( child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 20),
        
                                    Text('By wire transfer or by card'),
                               
                                  ],
                                
                              ),
                                 ),
        
          TableCell( child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 20),
        
                                    Text('By wire transfer or by card'),
                               
                                  ],
                                
                              ),
                                 ),
        
                               
                               

                                ],
                              ),
                               const TableRow(
                                children: [
                                  TableCell( child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                      SizedBox(width: 20),
        
                                    Text('Lit double'),
                                    Text('Repas non inclus'),
                                    Text('Type de couchage non garanti'),
                                    Text('Non fumeur'),
                                  ],
                                
                              ),
                                 ),
        
                              TableCell( child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 20),
        
                                    Text('Meals are not included'),
                               
                                  ],
                                
                              ),
                                 ),
        
         TableCell( child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 20),
        
                                    Text('AED until mar 28'),
                               
                                  ],
                                
                              ),
                                 ),
         TableCell( child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 20),
        
                                    Text('AED 379 : on the spot AED 15'),
                               
                                  ],
                                
                              ),
                                 ),
         TableCell( child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 20),
        
                                    Text('By wire transfer or by card'),
                               
                                  ],
                                
                              ),
                                 ),
  TableCell( child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 20),
        
                                    Text('By wire transfer or by card'),
                               
                                  ],
                                
                              ),
                                 ),
                                ],
                              ), const TableRow(
                                children: [
                                 TableCell( child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                      SizedBox(width: 20),
        
                                    Text('Lit double'),
                                    Text('Repas non inclus'),
                                    Text('Type de couchage non garanti'),
                                    Text('Non fumeur'),
                                  ],
                                
                              ),
                                 ),
        
                              TableCell( child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 20),
        
                                    Text('Meals are not included'),
                               
                                  ],
                                
                              ),
                                 ),
        
         TableCell( child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 20),
        
                                    Text('AED until mar 28'),
                               
                                  ],
                                
                              ),
                                 ),
         TableCell( child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 20),
        
                                    Text('AED 379 : on the spot AED 15'),
                               
                                  ],
                                
                              ),
                                 ),
         TableCell( child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 20),
        
                                    Text('By wire transfer or by card'),
                               
                                  ],
                                
                              ),
                                 ),
  TableCell( child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 20),
        
                                    Text('By wire transfer or by card'),
                               
                                  ],
                                
                              ),
                                 ),
                                ],
                              ),
                             
                              if (showAllRows)
                                const TableRow(
                                  children: [
                                    TableCell( child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                      SizedBox(width: 20),
        
                                    Text('Lit double'),
                                    Text('Repas non inclus'),
                                    Text('Type de couchage non garanti'),
                                    Text('Non fumeur'),
                                  ],
                                
                              ),
                                 ),
        
                              TableCell( child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 20),
        
                                    Text('Meals are not included'),
                               
                                  ],
                                
                              ),
                                 ),
        
         TableCell( child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 20),
        
                                    Text('AED until mar 28'),
                               
                                  ],
                                
                              ),
                                 ),
         TableCell( child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 20),
        
                                    Text('AED 379 : on the spot AED 15'),
                               
                                  ],
                                
                              ),
                                 ),
         TableCell( child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 20),
        
                                    Text('By wire transfer or by card'),
                               
                                  ],
                                
                              ),
                                 ),
                                   TableCell( child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 20),
        
                                    Text('By wire transfer or by card'),
                               
                                  ],
                                
                              ),
                                 ),
                                  ],
                                ),
                              if (showAllRows)
                                const TableRow(
                                  children: [
                                    TableCell( child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                      SizedBox(width: 20),
        
                                    Text('Lit double'),
                                    Text('Repas non inclus'),
                                    Text('Type de couchage non garanti'),
                                    Text('Non fumeur'),
                                  ],
                                
                              ),
                                 ),
        
                              TableCell( child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 20),
        
                                    Text('Meals are not included'),
                               
                                  ],
                                
                              ),
                                 ),
        
         TableCell( child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 20),
        
                                    Text('AED until mar 28'),
                               
                                  ],
                                
                              ),
                                 ),
         TableCell( child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 20),
        
                                    Text('AED 379 : on the spot AED 15'),
                               
                                  ],
                                
                              ),
                                 ),
         TableCell( child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 20),
        
                                    Text('By wire transfer or by card'),
                               
                                  ],
                                
                              ),
                                 ),
                                   TableCell( child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 20),
        
                                    Text('By wire transfer or by card'),
                               
                                  ],
                                
                              ),
                                 ),

                                  ],
                                ),
                              if (showAllRows)
                                TableRow(
                                  children: [
                                     TableCell( child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                      SizedBox(width: 20),
        
                                    Text('Lit double'),
                                    Text('Repas non inclus'),
                                    Text('Type de couchage non garanti'),
                                    Text('Non fumeur'),
                                  ],
                                
                              ),
                                 ),
        
                              TableCell( child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 20),
        
                                    Text('Meals are not included'),
                               
                                  ],
                                
                              ),
                                 ),
        
         TableCell( child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 20),
        
                                    Text('AED until mar 28'),
                               
                                  ],
                                
                              ),
                                 ),
         TableCell( child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 20),
        
                                    Text('AED 379 : on the spot AED 15'),
                               
                                  ],
                                
                              ),
                                 ),
         TableCell( child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 20),
        
                                    Text('By wire transfer or by card'),
                               
                                  ],
                                
                              ),
                                 ),
                                   TableCell(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () {                        
                        },
                        icon: Icon(Icons.add),
                        label: Text("Choose"),
                      ),
                    ],
                  ),
                ),
                                  ],
                                ),
                            ],
                          ),
                        
                          Container(
                            height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.black,width: 0.35,), // Bordure grise
                                    borderRadius: BorderRadius.circular(1.0),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Texte centré avec une icône de flèche vers le bas
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            showAllRows = !showAllRows;
                                          });
                                        },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              showAllRows? 'Afficher moins' : 'Afficher plus',
                                              style: const TextStyle(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Icon(showAllRows? Icons.arrow_drop_up : Icons.arrow_drop_down),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
        
                                SizedBox(height: 45),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white, 
                                    border: Border.all(color: Colors.grey), 
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          // Première colonne pour l'image
                                          Container(
                                            child: Image.asset('/images/images5.jpeg'), // Image localef
                                            height: 100, // Hauteur de l'image
                                          ),                          
                                          Expanded(
                                            child: Container(
                                            padding: EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  color: Colors.white, // Couleur de fond du conteneur
                                                  borderRadius: BorderRadius.circular(5), // Coins arrondis
                                                  
                                                ),
                                                child: const Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Standard double chambre',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    Text('lit double'),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.king_bed),
                                                        SizedBox(width: 5),
                                                        Text('21m²'),
                                                        Spacer(),
                                                        Icon(Icons.bathtub),
                                                        SizedBox(width: 5),
                                                        Text('Salle de bain privative'),
                                                      ],
                                                    ),
                                                    // Ajoutez d'autres éléments ici (par exemple, des icônes pour le Wi-Fi, la climatisation, etc.)
                                                  ],
                                                ),
                                              ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Table(
                                  border: TableBorder.all(width: 0.5, color: Color.fromARGB(255, 17, 17, 17)),
                                  children: [
                                    TableRow(
                                      children: [
                                        TableCell(
                                          child: Container(
                                        color:Colors.black,      
                                            padding: EdgeInsets.all(8.0),
                                            child: const Center(
                                              child: Text(
                                                'Room',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container( color:Colors.black  ,
                                          padding: EdgeInsets.all(8.0),
                                            child: const Center(
                                              child: Text(
                                                'Meals',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                        color:Colors.black  , 
                                        padding: EdgeInsets.all(8.0),
                                            child: Center(
                                              child: Text(
                                                'Titre Colonne 1',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(color:Colors.black  ,                             
                                          padding: EdgeInsets.all(8.0),
                                            child: Center(
                                              child: Text(
                                                'Titre Colonne 1',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(color:Colors.black  ,                                   
                                                padding: EdgeInsets.all(8.0),
                                            child: Center(
                                              child: Text(
                                                'Titre Colonne 1',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const TableRow(
                                      children: [
                                        TableCell(child: Text('Deluxe Room Non-smoking')),
                                        TableCell(child: Text('Meals are not included')),
                                        TableCell(child: Text('AED 0 until Mar 28')),
                                        TableCell(child: Text('AED 379')),
                                        TableCell(child: Text('By wire transfer or by card')),
                                      ],
                                    ),
                                    const TableRow(
                                      children: [
                                        TableCell(child: Text('Deluxe Room Non-smoking')),
                                        TableCell(child: Text('Meals are not included')),
                                        TableCell(child: Text('AED 0 until Mar 28')),
                                        TableCell(child: Text('AED 379')),
                                        TableCell(child: Text('By wire transfer or by card')),
                                      ],
                                    ), const TableRow(
                                      children: [
                                        TableCell(child: Text('Deluxe Room Non-smoking')),
                                        TableCell(child: Text('Meals are not included')),
                                        TableCell(child: Text('AED 0 until Mar 28')),
                                        TableCell(child: Text('AED 379')),
                                        TableCell(child: Text('By wire transfer or by card')),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        TableCell(child: Text('Room')),
                                        TableCell(child: Text('Meals')),
                                        TableCell(child: Text('Cancellation')),
                                        TableCell(child: Text('NET price')),
                                        TableCell(child: Text('Payment type')),
                                      ],
                                    ),
                                    if (showAllRows)
                                      TableRow(
                                        children: [
                                          TableCell(child: Text('Room')),
                                          TableCell(child: Text('Meals')),
                                          TableCell(child: Text('Cancellation')),
                                          TableCell(child: Text('NET price')),
                                          TableCell(child: Text('Payment type')),
                                        ],
                                      ),
                                    if (showAllRows)
                                      TableRow(
                                        children: [
                                          TableCell(child: Text('Room')),
                                          TableCell(child: Text('Meals')),
                                          TableCell(child: Text('Cancellation')),
                                          TableCell(child: Text('NET price')),
                                          TableCell(child: Text('Payment type')),
                                        ],
                                      ),
                                    if (showAllRows)
                                      TableRow(
                                        children: [
                                          TableCell(child: Text('Room')),
                                          TableCell(child: Text('Meals')),
                                          TableCell(child: Text('Cancellation')),
                                          TableCell(child: Text('NET price')),
                                          TableCell(child: Text('Payment type')),
                                        ],
                                      ),
                                  ],
                                ),
                        
                          Container(
                            height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.grey), 
                                    borderRadius: BorderRadius.circular(1.0),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      
                                      GestureDetector(
                                        onTap: () {
                                          // setState(() {
                                          //   showAllRows = !showAllRows;
                                          // });
                                        },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Afficher plus',
                                              style: TextStyle(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Icon(Icons.arrow_drop_down),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            
                          
                      ],
                    ),
                  ),
        
            
            Gap(20.h),

            Location(),

            Gap(20.h),

            // Description
            const HotelDescWidget(),

            Gap(20.h),

            // Amenities
            Container(
                width: 212.w,                             
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: 
                StreamBuilder(
                  stream: memoizedgetHotelInfo().asStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        heightFactor: 13.sp,
                        child: const CircularProgressIndicator(color: Colors.amber, ),
                      );
                    }
                  
                    var amenityGroups = snapshot.data?.amenity_groups;   
                                                                                                        
                    return 
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("What other amenities are there ?"),
                          Gap(16.h),
                          amenityGroups == null?
                          SizedBox (
                            height: MediaQuery.of(context).size.height-200,
                            child: const Center(
                              child: CircularProgressIndicator(color: Colors.amber, ),                      
                              )
                          )
                          :
                          GridView.builder(
                          
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: (amenityGroups?.length ?? 0),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              childAspectRatio: 0.5,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 2
                            ),
                            itemBuilder: (context, index) {
                              var amenityGroups = snapshot.data?.amenity_groups;
                              return                              
                              
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: 4.0),
                                        child: FaIcon(amenityGroups.elementAt(index).icon),
                                      ),
                                      Text(amenityGroups.elementAt(index).group_name.toString()),
                                    ],
                                  ),
                                  Gap(16.h),
                                  for (int j = 0;
                                      j < (amenityGroups.elementAt(index).amenities.length ?? 0);
                                      j++)
                                    Container(
                                      // mainAxisAlignment: MainAxisAlignment.start,
                                      // crossAxisAlignment: CrossAxisAlignment.start,
                                      child: 
                                        Text(amenityGroups
                                            .elementAt(index)
                                            .amenities
                                            .elementAt(j)
                                            .toString()),
                                        // Gap(10.h)
                                      
                                    ),
                                  // Gap(10.h),
                                ],
                              );
                            },
                          ), 
                        ],
                      );
                }
                
                ),
               ),

               Gap(20.h),               

          ],
        ),
      ),
    ),
    );
  }
}







  Widget ratingBar(String title, int score) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        LinearProgressIndicator(
          value: score / 10,
          color: Colors.green,
        ),
      ],
    );
  }

class Location extends StatefulWidget{
  @override
  State<Location> createState() => _LocationState();
}

class _LocationState extends State<Location> {

  Future<dynamic> getHotelLocation() async {
      
      var url = Uri.parse('$secondBaseUrl/hotel/info');       
      

      var map = <String, dynamic>{};
      map['id'] = 1;

      try{
        final response = await http.post(
          url,                    
          headers: {            
            'Content-Type': 'application/json',            
          },
          body: jsonEncode(map),
        );
        
        final result = jsonDecode(response.body);
        // Logger().i(result);
        if (response.statusCode == 200) {
          return testModel.fromJson(result);
        } else {
          throw Exception('Failed to load hotel data');
        }
      }
      catch (e){
        Logger().e('Error : $e');
      }
    }

    final AsyncMemoizer _memoizer1 = AsyncMemoizer();

   Future memoizedgetHotelLocation() {
    return _memoizer1.runOnce(() => getHotelLocation());
  }

  @override
  Widget build(BuildContext context){
    return Container(
              width: 212.w,
              padding: EdgeInsets.all(20),
              color: Colors.white,
              child: StreamBuilder(
                  stream: memoizedgetHotelLocation().asStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        heightFactor: 13.sp,
                        child: const CircularProgressIndicator(color: Colors.amber, ),
                      );
                    }
                  
                    var location = snapshot.data?.location;
                                                                                                        
                    return                   
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,                
                children: [
                  Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 18
                    ),
                    ),
                    Gap(10.h),
                  Text('Berlin, Zimmerstrasse 88'),
                  Gap(10.h),
                  //Map
                  Container(
                    width: 212.w - 10.w,
                    height: 400.h,
                    child: Expanded(
                      child: StaticsByCategory(
                        location: LatLng(45.5563, -122.677433)
                        )
                      ),
                  ),
                  Gap(10.h),
                  GridView.builder(
                    shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: (location?.length ?? 0),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              childAspectRatio: 0.8,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 2
                            ),
                            itemBuilder: (context, index) {                                                            
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(location.elementAt(index).group_name.toString()),
                                  Gap(10.h),
                                  for (int j = 0; j < (location.elementAt(index).regions.length ?? 0); j++)
                                    Text(
                                      overflow : TextOverflow.ellipsis,
                                      maxLines : 2,
                                      location.elementAt(index).regions.elementAt(j).toString(),
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: (2.8).sp
                                      ),
                                    ),
                                ],
                              );
                            }
                  ),
                  // Row(                    
                  //   mainAxisAlignment: MainAxisAlignment.start,
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     Container(
                  //       width: 212.w/4 - 5.w,
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           Text('Nearby places'),
                  //           Gap(10.h),
                  //           for (int j = 0; j < (location.elementAt(0).regions.length ?? 0); j++)
                  //             Text(
                  //               overflow : TextOverflow.ellipsis,
                  //               maxLines : 2,
                  //               location.elementAt(0).regions.elementAt(j).toString(),
                  //               style: TextStyle(
                  //                 color: Colors.blue,
                  //                 fontSize: (2.8).sp
                  //               ),
                  //             ),
                  //         ],
                  //       ),
                  //     ),
                  //     Gap(4.w),
                  //     Container(
                  //       width: 212.w/4 - 5.w,
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           Text('Landmarks'),
                  //           Gap(10.h),
                  //           for (int j = 0; j < (location.elementAt(1).regions.length ?? 0); j++)
                  //             Text(
                  //               overflow : TextOverflow.visible,
                  //               maxLines : 2,
                  //               location.elementAt(1).regions.elementAt(j).toString(),
                  //               style: TextStyle(
                  //                 color: Colors.blue,
                  //                 fontSize: (2.8).sp
                  //               ),
                  //               ),
                  //         ],
                  //       ),
                  //     ),
                  //     Gap(3.w),
                  //     Container(
                  //       width: 212.w/4 - 5.w,
                  //       child: Column(
                  //         mainAxisAlignment: MainAxisAlignment.start,
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           Text('Airports'),
                  //           Gap(10.h),
                  //           for (int j = 0; j < (location.elementAt(2).regions.length ?? 0); j++)
                  //             Text(
                  //               overflow : TextOverflow.visible,
                  //               maxLines : 2,
                  //               location.elementAt(2).regions.elementAt(j).toString(),
                  //               style: TextStyle(
                  //                 color: Colors.blue,
                  //                 fontSize: (2.8).sp
                  //               ),
                  //             ),
                  //         ],
                  //       ),
                  //     ),
                  //     Gap(3.w),
                  //     Container(
                  //       width: 212.w/4 - 5.w,
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           Text('Metro'),
                  //           Gap(10.h),
                  //           for (int j = 0; j < (location.elementAt(3).regions.length ?? 0); j++)
                  //             Text(
                  //               overflow : TextOverflow.ellipsis,
                  //               maxLines : 2,
                  //               location.elementAt(3).regions.elementAt(j).toString(),
                  //               style: TextStyle(
                  //                 color: Colors.blue,
                  //                 fontSize: (2.8).sp
                  //               ),
                  //             ),
                  //         ],
                  //       ),
                  //     ),
                  //   ],
                  // )
                ],
              );
                  }
              )
            );
  }
}


