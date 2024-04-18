import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:my_app/commons/global_variables.dart';
import 'package:my_app/hotel_detail.dart';
import 'package:my_app/hotel_search.dart';
// import 'package:fl_chart/fl_chart.dart',

String destination = "";
TextEditingController _destinationFieldController = TextEditingController();

// String checkIn = DateFormat.yMMMMd('en_US').format(DateTime.now());
// String checkOut = DateFormat.yMMMMd('en_US').format(DateTime.now().add(Duration(days: 1)));
// String checkIn = "";
// String checkOut = "";

String checkIn = checkInPicked2 ? checkIn2 
              : checkOut2.isNotEmpty? DateFormat.yMMMMd('en_US').format(DateFormat.yMMMMd('en_US').parse(checkOut2).subtract(Duration(days : 1)))
              : DateFormat.yMMMMd('en_US').format(DateTime.now());
String checkOut = checkOutPicked2 ? checkOut2
              : checkInPicked2? DateFormat.yMMMMd('en_US').format((DateFormat.yMMMMd('en_US').parse(checkIn2)).add(Duration(days : 1))) 
              : DateFormat.yMMMMd('en_US').format(DateTime.now().add(Duration(days: 1)));  

bool checkInPicked = false;
bool checkOutPicked = false;

String earlyCheckIn = "12:00";
String lateCheckOut = "15:00";

TextEditingController _checkInDateController = TextEditingController();
TextEditingController _checkOutDateController = TextEditingController();
DateTime _checkInDate = DateTime.now();
DateTime _checkOutDate = DateTime.now().add(Duration(days: 1));


class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: TabbedPage(),
    );
  }
}

class TabbedPage extends StatefulWidget {
  @override
  State<TabbedPage> createState() => _TabbedPageState();
}

class _TabbedPageState extends State<TabbedPage> with TickerProviderStateMixin {    

  // tabs controllers
  late TabController mainController;
  late TabController secondController;


  final List<String> _options = ['1 guest', '2 guests', '3 guests'];
  String _selectedOption = '1 guest';

  String _selectedCheckInOption = 'Select the time';
  final List<String> _optionsCheckIn = ['Select the time','12:00','13:00', '14:00'];
  String _selectedCheckOutOption = 'Select the time';
  final List<String> _optionsCheckOut = ['Select the time','13:00', '14:00','15:00'];

  int selectedStarNb = -1;
  int selectedmeal = -1;
  final List<String> stars = ['No stars', '2 stars', '3 stars', '4 stars', '5 stars'];
  final List<String> meals = ['RO', 'BB', 'HB', 'FB', 'AI'];

  int freeCancel24h = 0;
  int freeCancel4d = 0;
  int AutoCancel24h = 0;
  int AutoCancel4d = 0;

  bool freeCancellation = false;

  @override
  void initState(){
    super.initState();
    mainController = TabController(length: 4, vsync: this);    
    secondController = TabController(length: 3, vsync: this);    
    mainController.addListener(_handleMainTabSelection);    
    secondController.addListener(_handleSecondTabSelection);   

    // checkIn = checkInPicked2 ? checkIn2 
    //           : checkOut2.isNotEmpty? DateFormat.yMMMMd('en_US').format(DateFormat.yMMMMd('en_US').parse(checkOut2).subtract(Duration(days : 1)))
    //           : DateFormat.yMMMMd('en_US').format(DateTime.now());
    // checkOut = checkOutPicked2 ? checkOut2
    //           : checkInPicked2? DateFormat.yMMMMd('en_US').format((DateFormat.yMMMMd('en_US').parse(checkIn2)).add(Duration(days : 1))) 
    //           : DateFormat.yMMMMd('en_US').format(DateTime.now().add(Duration(days: 1)));  
  }

  void _handleMainTabSelection() {    
    setState(() {
      secondController.index = mainController.index;
    });
  }

  void _handleSecondTabSelection() {    
    setState(() {
      mainController.index = secondController.index;
    });
  }  

  @override
  void dispose() {
    mainController.removeListener(_handleMainTabSelection);
    secondController.removeListener(_handleSecondTabSelection);
    mainController.dispose();
    secondController.dispose();
    super.dispose();
  }

  updateDestination(){
    setState(() {            
      destination = _destinationFieldController.text;      
    });
  }

  _selectDate(BuildContext context, bool isCheckInDate) {
    showDatePicker(
      context: context,
      initialDate: isCheckInDate ? _checkInDate : _checkOutDate,
      firstDate: isCheckInDate ? DateTime.now() : _checkInDate,
      lastDate: DateTime(2100),
    ).then((picked) {
      if (picked != null) {
        if (isCheckInDate) {
          setState(() {
            _checkInDate = picked;
            checkInPicked = true;

            _checkInDateController.text = DateFormat('dd-MM-yyyy').format(_checkInDate);
            checkIn = DateFormat.yMMMMd('en_US').format(_checkInDate);
            checkOut = checkOutPicked? checkOut: DateFormat.yMMMMd('en_US').format(_checkInDate.add(Duration(days: 1)));              
            // Ensure check-out date is always greater than check-in date
            if (_checkOutDate.isBefore(_checkInDate) || _checkOutDate.day == _checkInDate.day) {
              _checkOutDate = _checkInDate.add(Duration(days: 1));
              _checkOutDateController.text = DateFormat('dd-MM-yyyy').format(_checkOutDate);
              checkOut = DateFormat.yMMMMd('en_US').format(_checkInDate.add(Duration(days: 1)));
            }
          });
        } else {
          setState(() {
            // Ensure check-out date is always greater than check-in date
            if (picked.isAfter(_checkInDate)) {
              _checkOutDate = picked;
              checkOutPicked = true;
              _checkOutDateController.text = DateFormat('dd-MM-yyyy').format(_checkOutDate);
              checkOut = DateFormat.yMMMMd('en_US').format(_checkOutDate);
              checkIn = checkInPicked? checkIn: DateFormat.yMMMMd('en_US').format(_checkOutDate.subtract(Duration(days: 1)));
            } else {
              _checkOutDate = _checkInDate.add(Duration(days: 1));
              checkOutPicked = true;
              _checkOutDateController.text = DateFormat('dd-MM-yyyy').format(_checkOutDate);
              checkOut = DateFormat.yMMMMd('en_US').format(_checkOutDate);
              checkIn = checkInPicked? checkIn: DateFormat.yMMMMd('en_US').format(_checkOutDate.subtract(Duration(days: 1)));
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [                        
            TabBar(
              controller: mainController,
              isScrollable: true,
              indicatorSize: TabBarIndicatorSize.label,              
              tabs: [                
                Tab(
                  child: Row(
                    children: [
                      Icon(Icons.hotel), 
                      Gap(4),
                      Text('Hotels')
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    children: [
                      Icon(Icons.airplane_ticket), 
                      Gap(4),
                      Text('Air tickets')
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    children: [
                      Icon(Icons.airport_shuttle_rounded), 
                      Gap(4),
                      Text('Transfers')
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    children: [
                      Icon(Icons.car_rental), 
                      Gap(4),
                      Text('Car rentals')
                    ],
                  ),
                ),
              ],
            ),
            // SizedBox(height: 16),
            // Stack(
            //   children: [
            //     // child: 
            //     Container(
            //       height: MediaQuery.of(context).size.height /2,
            //       width: MediaQuery.of(context).size.width / 2,
            //       color: Colors.amber,
            //       child : Center(
            //         child: Container(
            //           width: MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width/3),
            //           height: MediaQuery.of(context).size.height / 2 - 50,                    
            //           color: Colors.white,
            //         ),
            //       ),
            //     ),

            //     // scrollable content
                
            //   ],
            // ),
            Expanded(
              child: 
              PageView(
                
                onPageChanged: (index) {
                  mainController.index = index;
                  _handleMainTabSelection();
                },
                children: [
                  _buildInnerTabBarView(0),
                  _buildInnerTabBarView(1),
                  _buildInnerTabBarView(2),
                  Center(child: Text('Car Rentals Content')),
                  // _buildOuterTab4Content(),
                ],
              )
              // TabBarView(
              //   controller: mainController,
              //   children: [                  
              //     Hotels(),
              //     Center(child: Text('Air Tickets Content')),                
              //     Center(child: Text('Transfers Content')),                  
              //     Center(child: Text('Car Rentals Content')),
              //   ],
              // ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInnerTabBarView(int outerTabIndex) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('/images/sea.jpg'),
              fit : BoxFit.fill
              )
          ),
        ),
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [                  
                  Gap(40.h),
                  Container(                                          
                        height: 300.h,
                        width: 250.w,                        
                        decoration : BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                spreadRadius: 2, 
                                blurRadius: 5, 
                                offset: Offset(0, 2),
                              )
                            ]
                          ),
                    child: DefaultTabController(
                      length: 3,
                      child: Column(
                        children: [                          
                          Material(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),    
                            color: Colors.transparent,                        
                            child: TabBar(
                              controller: secondController,
                              isScrollable: true,
                              tabAlignment: TabAlignment.start,
                              indicator: BoxDecoration(                                  
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10), 
                                  ),
                                ),
                              indicatorSize: TabBarIndicatorSize.tab,
                              indicatorColor: Colors.transparent,
                              // indicatorPadding: EdgeInsets.only(bottom: 2.0),
                              tabs: [
                                Tab(text: 'Hotels'),
                                Tab(text: 'Air Tickets'),
                                Tab(text: 'Transfers'),
                              ],
                            ),
                          ),
                          Expanded(
                              child: TabBarView(
                                // controller: secondController,
                                children: [
                                  Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 10,),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [ 
                                            // SizedBox(width: 16.0),
                                            Gap(4.w),
                                            SizedBox(
                                              // width: 270,
                                              width: destinationFieldLength,
                                              height: 60.h,
                                              // constraints: const BoxConstraints(maxWidth: 200, maxHeight: 90),
                                              child: TextFormField(   
                                                controller: _destinationFieldController, 
                                                // onTap: () {
                                                //   Logger().i(_destinationFieldController.text);
                                                //   updateDestination();
                                                // },                                                                                        
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
                                            Gap(4.w),
                                  
                                            SizedBox(
                                              width: checkLength,
                                              height: 70,
                                              child: TextFormField(
                                                onTap: () => _selectDate(context,true),
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                ),
                                                controller: _checkInDateController,                                              
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
                                            SizedBox(
                                              width: checkLength,
                                              height: 70,
                                              child: TextFormField(
                                                onTap: () => _selectDate(context, false),
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                ),
                                                controller: _checkOutDateController,                                              
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
                                  
                                            // SizedBox(width: 16.0),
                                            Gap(4.w),
                                  
                                            // number of guests in the room
                                            SizedBox(
                                              width: checkLength,
                                              height: 70,
                                              child: DropdownButtonFormField(                                              
                                                value: _selectedOption,
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
                                                items: _options.map((String option) {
                                                  return DropdownMenuItem(
                                                    value: option,
                                                    child: Text(option),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    _selectedOption = value.toString();
                                                  });
                                                },
                                              ),
                                            ),
                                                                              
                                            Gap(4.w),
                                            
                                            // ElevatedButton(                                              
                                            //   onPressed: () {},
                                            //   child: Text('Submit'),
                                            // ),
                                  
                                            InkWell(
                                              onTap: (){
                                                // if(_destinationFieldController.text.isNotEmpty){
                                                  updateDestination();
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) => const HotelSearch(),
                                                    ),
                                                  );
                                                // }
                                              },
                                              child: Container(
                                                
                                                decoration: BoxDecoration(
                                                  color: Colors.amber,
                                                  borderRadius: BorderRadius.circular(4),                                                
                                                ),
                                                width: checkLength,
                                                height: 50,
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  'Search',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    // fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            )
                                  
                                            
                                          ],
                                        ),
                                        SizedBox(height: 2),
                                  
                                        Column(
                                          // mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [                                          
                                            const Padding(
                                              padding: EdgeInsets.only(left: 16),
                                              child: Text(
                                                  'Additional parameters',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14
                                                  ),
                                              ),
                                            ),
                                            // SizedBox(height: 16),
                                            Gap(15.h),
                                            Row(    
                                              mainAxisAlignment: MainAxisAlignment.start, 
                                              crossAxisAlignment: CrossAxisAlignment.start,                                       
                                              children: [   
                                                // SizedBox(width: 16),    
                                                Gap(4.w),                                       
                                                SizedBox(
                                                  // width: 270,
                                                  // height: 70,
                                                  height: 60.h,
                                                  width: citizenshipFieldLength,
                                                  // constraints: const BoxConstraints(maxWidth: 200, maxHeight: 90),
                                                  child: TextFormField(                                                                                            
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                    decoration: const InputDecoration( 
                                                      border: OutlineInputBorder(),                                            
                                                      labelText: 'Guests\'citizenship',
                                                      labelStyle: TextStyle(fontSize: 11),                                              
                                                      hintText: 'Choose your city',
                                                      hintStyle: TextStyle(fontSize: 12),
                                                      // alignLabelWithHint: true,                                              
                                                      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20)
                                                    ),
                                                  ),
                                                ),
                                                // SizedBox(width: 16),
                                                Gap(4.w),
                                  
                                                //stars
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: List.generate(
                                                    stars.length,
                                                    (index) => GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          selectedStarNb = index;
                                                        });
                                                      },
                                                      child: Container(
                                                        // width: 80,
                                                        width: (250.w/3)/stars.length + 4.w,
                                                        height: 42.h,
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.only(
                                                            topLeft: Radius.circular(index == 0 ? 4: 0),
                                                            bottomLeft: Radius.circular(index == 0 ? 4: 0),
                                                            topRight: Radius.circular(index == 4 ? 4: 0),                                                          
                                                            bottomRight: Radius.circular(index == 4 ? 4: 0)                                                         
                                                          ),
                                                          border: Border.all(
                                                            color: Colors.grey
                                                          )
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            SizedBox(height: 8),
                                                            Text(                                                            
                                                              stars[index],
                                                              style: const TextStyle(
                                                                color: Colors.black,
                                                              ),
                                                            ),
                                                            SizedBox(height: 8),
                                                            Container(
                                                              width: 50,
                                                              height: 4,
                                                              // decoration: BoxDecoration(
                                                              //   borderRadius: BorderRadius.circular(4)
                                                              // ),
                                                              color: index == selectedStarNb ? Colors.amber : Colors.grey,
                                                            ),                                                        
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                                                  
                                                Gap(4.w),
                                  
                                                // meals
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: List.generate(
                                                    meals.length,
                                                    (index) => GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          selectedmeal = index;
                                                        });
                                                      },
                                                      child: Container(
                                                        // width: 50,
                                                        width: (250.w/4)/meals.length - 2.w,
                                                        height: 50,
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.only(
                                                            topLeft: Radius.circular(index == 0 ? 4: 0),
                                                            bottomLeft: Radius.circular(index == 0 ? 4: 0),
                                                            topRight: Radius.circular(index == 4 ? 4: 0),                                                          
                                                            bottomRight: Radius.circular(index == 4 ? 4: 0)                                                         
                                                          ),
                                                          border: Border.all(
                                                            color: Colors.grey
                                                          )
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            SizedBox(height: 8),
                                                            Text(                                                            
                                                              meals[index],
                                                              style: const TextStyle(
                                                                color: Colors.black,
                                                              ),
                                                            ),
                                                            SizedBox(height: 8),
                                                            Container(
                                                              width: 30,
                                                              height: 4,
                                                              // decoration: BoxDecoration(
                                                              //   borderRadius: BorderRadius.circular(4)
                                                              // ),
                                                              color: index == selectedmeal ? Colors.amber : Colors.grey,
                                                            ),                                                        
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),                                                                                            
                                  
                                              ],
                                            ),
                                            
                                          ]                                        
                                        ),
                                  
                                        // SizedBox(height: 8,),
                                        Gap(10.h),
                                        
                                        // early check in/out
                                        Row(
                                          children: 
                                          [
                                            Padding(
                                              padding: EdgeInsets.only(left: 4.w),
                                              child: SizedBox(
                                                height: 70,
                                                // width: 200,
                                                width: citizenshipFieldLength,
                                                child: DropdownButtonFormField(                                              
                                                        value: _selectedCheckInOption,
                                                        style: TextStyle(fontSize: 13),
                                                        decoration: const InputDecoration(
                                                          labelText: 'Early check-in',
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
                                                        items: _optionsCheckIn.map((String option) {
                                                          return DropdownMenuItem(
                                                            value: option,
                                                            child: Text(option),
                                                          );
                                                        }).toList(),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            _selectedCheckInOption = value.toString();
                                                            earlyCheckIn = _selectedCheckInOption;
                                                          });
                                                        },
                                                      ),
                                              ),
                                            ),
                                  
                                            // SizedBox(width: 16),
                                            Gap(4.w),
                                            SizedBox(
                                                height: 70,
                                                width: citizenshipFieldLength,
                                                child: DropdownButtonFormField(                                              
                                                        value: _selectedCheckOutOption,
                                                        style: TextStyle(fontSize: 13),
                                                        decoration: const InputDecoration(
                                                          labelText: 'Early check-out',
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
                                                        items: _optionsCheckOut.map((String option) {
                                                          return DropdownMenuItem(
                                                            value: option,
                                                            child: Text(option),
                                                          );
                                                        }).toList(),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            _selectedCheckOutOption = value.toString();
                                                            lateCheckOut = _selectedCheckOutOption;
                                                          });
                                                        },
                                                      ),
                                            ),
                                            // free cancellation
                                            SizedBox(
                                              height: 70,
                                              width: 300,
                                              child: CheckboxListTile(
                                                activeColor: Colors.green,
                                                title: Text(
                                                  'Free cancellation', 
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 14
                                                  ),
                                                  ),
                                                value: freeCancellation,
                                                onChanged: (value) {
                                                  setState(() {
                                                    freeCancellation = value!;
                                                  });
                                                },
                                                controlAffinity: ListTileControlAffinity.leading,                                            
                                              ),
                                            ),
                                          ] 
                                        ),
                                        
                                      ],
                                    )
                                  ),
                                  Center(child: Text('air tickets tab content')),
                                  Center(child: Text('transfers tab content'))
                                ],
                              )
                            )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        
      ],
    );
  }
}


class Hotels extends StatefulWidget{
  // final TabController secondController;
  const Hotels({super.key});


// Hotels({super.key});
@override
_HotelsState createState() => _HotelsState();
}

class _HotelsState extends State<Hotels> {
  // TextEditingController _dateController = TextEditingController();
  // DateTime _selectedDate = DateTime.now();

  // TextEditingController _checkInDateController = TextEditingController();
  // TextEditingController _checkOutDateController = TextEditingController();
  // DateTime _checkInDate = DateTime.now();
  // DateTime _checkOutDate = DateTime.now().add(Duration(days: 1));

  final List<String> _options = ['1 guest', '2 guests', '3 guests'];
  String _selectedOption = '1 guest';

  String _selectedCheckInOption = 'Select the time';
  final List<String> _optionsCheckIn = ['Select the time','12:00','13:00', '14:00'];
  String _selectedCheckOutOption = 'Select the time';
  final List<String> _optionsCheckOut = ['Select the time','13:00', '14:00','15:00'];

  int selectedStarNb = -1;
  int selectedmeal = -1;
  final List<String> stars = ['No stars', '2 stars', '3 stars', '4 stars', '5 stars'];
  final List<String> meals = ['RO', 'BB', 'HB', 'FB', 'AI'];

  int freeCancel24h = 0;
  int freeCancel4d = 0;
  int AutoCancel24h = 0;
  int AutoCancel4d = 0;

  bool freeCancellation = false;

  // Future<void> _selectDate(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: _selectedDate ?? DateTime.now(),
  //     firstDate: DateTime(2013),
  //     lastDate: DateTime.now(),
  //   );
  //   if (picked != null && picked != _selectedDate) {
  //     setState(() {
  //       _selectedDate = picked;
  //       // _dateController.text = _selectedDate.toString(); // Set the selected date to the text field
  //       _dateController.text = DateFormat('dd-MM-yyyy').format(_selectedDate);
  //     });
  //   }
  // }
  

  //  _selectDate(BuildContext context) {
  //   showDatePicker(
  //     context: context,
  //     initialDate: _selectedDate ?? DateTime.now(),
  //     firstDate: DateTime(1900),
  //     lastDate: DateTime.now(),
  //   ).then((picked) {
  //     if (picked != null && picked != _selectedDate) {        
  //       // setState(() {
  //         _selectedDate = picked;
  //         _dateController.text =
  //             DateFormat('dd-MM-yyyy').format(_selectedDate); // Format the selected date
  //       // });
  //     }
  //   });
  // }

  _selectDate(BuildContext context, bool isCheckInDate) {
  showDatePicker(
    context: context,
    initialDate: isCheckInDate ? _checkInDate : _checkOutDate,
    firstDate: isCheckInDate ? DateTime.now() : _checkInDate,
    lastDate: DateTime(2100),
  ).then((picked) {
    if (picked != null) {
      if (isCheckInDate) {
        setState(() {
          _checkInDate = picked;
          _checkInDateController.text = DateFormat('dd-MM-yyyy').format(_checkInDate);
          // Ensure check-out date is always greater than check-in date
          if (_checkOutDate.isBefore(_checkInDate)) {
            _checkOutDate = _checkInDate.add(Duration(days: 1));
            _checkOutDateController.text = DateFormat('dd-MM-yyyy').format(_checkOutDate);
          }
        });
      } else {
        setState(() {
          // Ensure check-out date is always greater than check-in date
          if (picked.isAfter(_checkInDate)) {
            _checkOutDate = picked;
            _checkOutDateController.text = DateFormat('dd-MM-yyyy').format(_checkOutDate);
          } else {
            _checkOutDate = _checkInDate.add(Duration(days: 1));
            _checkOutDateController.text = DateFormat('dd-MM-yyyy').format(_checkOutDate);
          }
        });
      }
    }
  });
}

  @override
  void initState(){
    super.initState();
    // secondController = TabController(length: 3, vsync: this);
    // secondController.addListener(_handleSecondTabSelection);
  }

  // void _handleSecondTabSelection() {    
  //   setState(() {
  //     mainController.index = secondController.index;
  //   });
  // }


  @override
  Widget build(BuildContext){
    return DefaultTabController(
      length: 2,
      child: Stack(
          children: [
            Container(
              // height: MediaQuery.of(context).size.height,
              // width: MediaQuery.of(context).size.width,
              // color: Colors.amber,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('/images/sea.jpg'),
                  fit : BoxFit.fill
                  )
              ),
            ),
            
            Positioned.fill(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 30,),
                    // Gap(30.h),
                    Container(
                      height: MediaQuery.of(context).size.height / 2 - 50,                    
                      width: MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width/3),
                      // color: Colors.white,
                      decoration : BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 2, // Adjust the spread radius
                              blurRadius: 5, // Adjust the blur radius
                              offset: Offset(0, 2),
                            )
                          ]
                        ),
                        child: DefaultTabController(
                        length: 3,
                        child:
                        Column(
                          children: [
                            const Material(
                              color: Colors.amber,
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              child: TabBar(       
                                // splashFactory: NoSplash.splashFactory,
                                // overlayColor: MaterialStateProperty.resolveWith<Color?>(
                                //   (Set<MaterialState> states) {
                                //     return states.contains(MaterialState.selected) ? Colors.blue : Colors.transparent;
                                //   },
                                // ),   
                                isScrollable: true,
                                unselectedLabelStyle: TextStyle(                                
                                ),
                                tabAlignment: TabAlignment.start,
                                // labelPadding: EdgeInsets.only(bottom: 5),
                                dividerColor: Colors.amber,
                                dividerHeight: 3,
                                indicatorColor: Colors.white,
                                indicatorSize: TabBarIndicatorSize.tab,
                                indicatorWeight: 4,
                                // indicatorPadding: EdgeInsets.only(right: 2),                                
                                
                                indicator: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6))
                                // gradient: LinearGradient(
                                //     colors: [Colors.redAccent, Colors.orangeAccent]
                                //   ),
                                ),
                                // indicator: BoxDecoration(
                                //   borderRadius: BorderRadius.circular(50),
                                // ),
                                labelStyle: TextStyle(
                                  color: Colors.black,
                                  // backgroundColor: Colors.white                                  
                                ),
                                tabs: [
                                  Tab(text: 'Hotels'),
                                  Tab(text: 'Air Tickets'),
                                  Tab(text: 'Transfers'),
                                ]
                              ),
                            ),
                            Expanded(
                              child: TabBarView(
                                // controller: secondController,
                                children: [
                                  Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 10,),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [ 
                                            SizedBox(width: 16.0),
                                            SizedBox(
                                              width: 270,
                                              height: 70,
                                              // constraints: const BoxConstraints(maxWidth: 200, maxHeight: 90),
                                              child: TextFormField(                                                                                            
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
                                            SizedBox(width: 16.0), 
                                  
                                            SizedBox(
                                              // width: 150,
                                              width: checkLength,
                                              height: 70,
                                              child: TextFormField(
                                                onTap: () => _selectDate(context,true),
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                ),
                                                controller: _checkInDateController,                                              
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
                                            SizedBox(
                                              width: checkLength,
                                              height: 70,
                                              child: TextFormField(
                                                onTap: () => _selectDate(context, false),
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                ),
                                                controller: _checkOutDateController,                                              
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
                                  
                                            // SizedBox(width: 16.0),
                                            Gap(4.w), 
                                  
                                            // number of guests in the room
                                            SizedBox(
                                              // width: 120,
                                              width: checkLength,
                                              height: 70,
                                              child: DropdownButtonFormField(                                              
                                                value: _selectedOption,
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
                                                items: _options.map((String option) {
                                                  return DropdownMenuItem(
                                                    value: option,
                                                    child: Text(option),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    _selectedOption = value.toString();
                                                  });
                                                },
                                              ),
                                            ),
                                  
                                            // SizedBox(width: 16.0), 
                                            Gap(4.w),
                                            
                                            // ElevatedButton(                                              
                                            //   onPressed: () {},
                                            //   child: Text('Submit'),
                                            // ),
                                  
                                            InkWell(
                                              onTap: (){
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) => const HotelSearch(),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                
                                                decoration: BoxDecoration(
                                                  color: Colors.amber,
                                                  borderRadius: BorderRadius.circular(4),                                                
                                                ),
                                                width: 150,
                                                height: 50,
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  'Search',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    // fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            )
                                  
                                            
                                          ],
                                        ),
                                        SizedBox(height: 2),
                                  
                                        Column(
                                          // mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [                                          
                                            const Padding(
                                              padding: EdgeInsets.only(left: 16),
                                              child: Text(
                                                  'Additional parameters',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14
                                                  ),
                                              ),
                                            ),
                                            SizedBox(height: 16),
                                            Row(    
                                              mainAxisAlignment: MainAxisAlignment.start, 
                                              crossAxisAlignment: CrossAxisAlignment.start,                                       
                                              children: [   
                                                SizedBox(width: 16),                                           
                                                SizedBox(
                                                  width: 270,
                                                  height: 70,
                                                  // constraints: const BoxConstraints(maxWidth: 200, maxHeight: 90),
                                                  child: TextFormField(                                                                                            
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                    decoration: const InputDecoration( 
                                                      border: OutlineInputBorder(),                                            
                                                      labelText: 'Guests\'citizenship',
                                                      labelStyle: TextStyle(fontSize: 11),                                              
                                                      hintText: 'Choose your city',
                                                      hintStyle: TextStyle(fontSize: 12),
                                                      // alignLabelWithHint: true,                                              
                                                      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20)
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 16),
                                  
                                                //stars
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: List.generate(
                                                    5,
                                                    (index) => GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          selectedStarNb = index;
                                                        });
                                                      },
                                                      child: Container(
                                                        width: 80,
                                                        height: 50,
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.only(
                                                            topLeft: Radius.circular(index == 0 ? 4: 0),
                                                            bottomLeft: Radius.circular(index == 0 ? 4: 0),
                                                            topRight: Radius.circular(index == 4 ? 4: 0),                                                          
                                                            bottomRight: Radius.circular(index == 4 ? 4: 0)                                                         
                                                          ),
                                                          border: Border.all(
                                                            color: Colors.grey
                                                          )
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            SizedBox(height: 8),
                                                            Text(                                                            
                                                              stars[index],
                                                              style: const TextStyle(
                                                                color: Colors.black,
                                                              ),
                                                            ),
                                                            SizedBox(height: 8),
                                                            Container(
                                                              width: 50,
                                                              height: 4,
                                                              // decoration: BoxDecoration(
                                                              //   borderRadius: BorderRadius.circular(4)
                                                              // ),
                                                              color: index == selectedStarNb ? Colors.amber : Colors.grey,
                                                            ),                                                        
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                  
                                                SizedBox(width: 16,),
                                  
                                                // meals
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: List.generate(
                                                    5,
                                                    (index) => GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          selectedmeal = index;
                                                        });
                                                      },
                                                      child: Container(
                                                        width: 50,
                                                        height: 50,
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.only(
                                                            topLeft: Radius.circular(index == 0 ? 4: 0),
                                                            bottomLeft: Radius.circular(index == 0 ? 4: 0),
                                                            topRight: Radius.circular(index == 4 ? 4: 0),                                                          
                                                            bottomRight: Radius.circular(index == 4 ? 4: 0)                                                         
                                                          ),
                                                          border: Border.all(
                                                            color: Colors.grey
                                                          )
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            SizedBox(height: 8),
                                                            Text(                                                            
                                                              meals[index],
                                                              style: const TextStyle(
                                                                color: Colors.black,
                                                              ),
                                                            ),
                                                            SizedBox(height: 8),
                                                            Container(
                                                              width: 30,
                                                              height: 4,
                                                              // decoration: BoxDecoration(
                                                              //   borderRadius: BorderRadius.circular(4)
                                                              // ),
                                                              color: index == selectedmeal ? Colors.amber : Colors.grey,
                                                            ),                                                        
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),                                                                                            
                                  
                                              ],
                                            ),
                                            
                                          ]                                        
                                        ),
                                  
                                        SizedBox(height: 8,),
                                        
                                        // early check in/out
                                        Row(
                                          children: 
                                          [
                                            Padding(
                                              padding: EdgeInsets.only(left: 16),
                                              child: SizedBox(
                                                height: 70,
                                                width: 200,
                                                child: DropdownButtonFormField(                                              
                                                        value: _selectedCheckInOption,
                                                        style: TextStyle(fontSize: 13),
                                                        decoration: const InputDecoration(
                                                          labelText: 'Early check-in',
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
                                                        items: _optionsCheckIn.map((String option) {
                                                          return DropdownMenuItem(
                                                            value: option,
                                                            child: Text(option),
                                                          );
                                                        }).toList(),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            _selectedCheckInOption = value.toString();
                                                          });
                                                        },
                                                      ),
                                              ),
                                            ),
                                  
                                            SizedBox(width: 16),
                                            SizedBox(
                                                height: 70,
                                                width: 200,
                                                child: DropdownButtonFormField(                                              
                                                        value: _selectedCheckOutOption,
                                                        style: TextStyle(fontSize: 13),
                                                        decoration: const InputDecoration(
                                                          labelText: 'Early check-out',
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
                                                        items: _optionsCheckOut.map((String option) {
                                                          return DropdownMenuItem(
                                                            value: option,
                                                            child: Text(option),
                                                          );
                                                        }).toList(),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            _selectedCheckOutOption = value.toString();
                                                          });
                                                        },
                                                      ),
                                            ),
                                            // free cancellation
                                            SizedBox(
                                              height: 70,
                                              width: 300,
                                              child: CheckboxListTile(
                                                activeColor: Colors.green,
                                                title: Text(
                                                  'Free cancellation', 
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 14
                                                  ),
                                                  ),
                                                value: freeCancellation,
                                                onChanged: (value) {
                                                  setState(() {
                                                    freeCancellation = value!;
                                                  });
                                                },
                                                controlAffinity: ListTileControlAffinity.leading,                                            
                                              ),
                                            ),
                                          ] 
                                        ),
                                        
                                      ],
                                    )
                                  ),
                                  Center(child: Text('air tickets tab content')),
                                  Center(child: Text('transfers tab content'))
                                ],
                              )
                            )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height : 100),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Payment information
                      Container(
                        height: MediaQuery.of(context).size.height / 2 - 100,
                        width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width/3))/2 - 16,
                        decoration: 
                        BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 2, 
                              blurRadius: 5, 
                              offset: Offset(0, 2),
                            )
                          ]
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 30),
                            Padding(
                              padding: EdgeInsets.only(left: 16),
                              child: Text(
                                'Payment information',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(width: 16),

                      // Free cancellation
                      Container(
                        height: MediaQuery.of(context).size.height / 2 - 100,
                        // width: MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width/3),  
                        width: ((MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width/3))/2)/2 - 8,
                        decoration: 
                        BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 2, // Adjust the spread radius
                              blurRadius: 5, // Adjust the blur radius
                              offset: Offset(0, 2),
                            )
                          ]
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 30),
                            Padding(
                              padding: EdgeInsets.only(left: 16),
                              child: Text(
                                'Free Cancellation',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18
                                ),
                              ),
                            ),
                            SizedBox(height: 30),
                            Padding(
                              padding: EdgeInsets.only(left: 30),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    '${freeCancel24h}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 24,
                                      color: Colors.grey
                                    ),
                                 ),
                                 
                                  Text(
                                    '  ends in 24 hours',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: Colors.grey.shade400
                                    ),
                                 ),                               
                              ]
                              ),
                            ),
                            //line
                            Padding(
                              padding: EdgeInsets.only(top: 20, bottom: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                // crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(                                  
                                    width: ((MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width/3))/2)/2 - 50,
                                    height: 1,
                                    // decoration: BoxDecoration(
                                    //   borderRadius: BorderRadius.circular(4)
                                    // ),
                                    color: Colors.grey.shade300,
                                  ),
                                ]
                              ),
                            ), 
                            Padding(
                              padding: EdgeInsets.only(left: 30),
                              child: Row(
                                children: [
                                  Text(
                                    '${freeCancel4d}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 24,
                                      color: Colors.grey
                                    ),
                                  ),
                                  Text(
                                    '  ends in 4 working days',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      color: Colors.grey.shade400
                                    ),
                                  ),
                                ],
                              )
                            
                            ),
                            
                            // Padding(
                            //   padding: EdgeInsets.only(left: 16),
                            //   child: Text(
                            //     '${freeCancel24h}  ends in 24 hours',
                            //     style: TextStyle(
                            //       fontWeight: FontWeight.w500,
                            //       fontSize: 18
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),

                      SizedBox(width: 16),

                      // Automatic cancellation
                      Container(
                        height: MediaQuery.of(context).size.height / 2 - 100,
                        // width: MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width/3),  
                        width: ((MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width/3))/2)/2 - 8,                        
                        decoration: 
                        BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 2, // Adjust the spread radius
                              blurRadius: 5, // Adjust the blur radius
                              offset: Offset(0, 2),
                            )
                          ]
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 30),
                            Padding(
                              padding: EdgeInsets.only(left: 16),
                              child: Text(
                                'Automatic cancellation',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18
                                ),
                              ),
                            ),

                            SizedBox(height: 30),
                            Padding(
                              padding: EdgeInsets.only(left: 30),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    '${freeCancel24h}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 24,
                                      color: Colors.grey
                                    ),
                                 ),
                                 
                                  Text(
                                    '  ends in 24 hours',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: Colors.grey.shade400
                                    ),
                                 ),                               
                              ]
                              ),
                            ),
                            //line
                            Padding(
                              padding: EdgeInsets.only(top: 20, bottom: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                // crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(                                  
                                    width: ((MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width/3))/2)/2 - 50,
                                    height: 1,
                                    // decoration: BoxDecoration(
                                    //   borderRadius: BorderRadius.circular(4)
                                    // ),
                                    color: Colors.grey.shade300,
                                  ),
                                ]
                              ),
                            ), 
                            Padding(
                              padding: EdgeInsets.only(left: 30),
                              child: Row(
                                children: [
                                  Text(
                                    '${freeCancel4d}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 24,
                                      color: Colors.grey
                                    ),
                                  ),
                                  Text(
                                    '  ends in 4 working days',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      color: Colors.grey.shade400
                                    ),
                                  ),
                                ],
                              )
                            
                            ),
                          ],
                        ),
                      ),
                      
                    ]
                  ),
                  SizedBox(height: 40),                

                  Padding(
                    padding: EdgeInsets.only(left: (MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width/3)) ) / 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                        'Financial Information',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                        ),
                      ),]
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height / 2 - 100,
                        width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width/3))/2 - 8,
                        decoration: 
                        BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 2, 
                              blurRadius: 5, 
                              offset: Offset(0, 2),
                            )
                          ]
                        ),
                      ),
                      SizedBox(width: 16),
                      Container(
                        height: MediaQuery.of(context).size.height / 2 - 100,
                        width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width/3))/2 - 8,
                        decoration: 
                        BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 2, 
                              blurRadius: 5, 
                              offset: Offset(0, 2),
                            )
                          ]
                        ),
                      ),
                      SizedBox(height: 30)
                    ],
                  ),
                  
                ]
                   
                ),
              ),
            ),

            // Positioned(
            //   top: MediaQuery.of(context).size.height/2,
            //   left: 0,
            //   right: 0,
            //   child: Container(
            //     height: MediaQuery.of(context).size.height /2,
            //     width: MediaQuery.of(context).size.width / 2,
            //     color: Colors.white,
            //     // decoration: BoxDecoration(
            //     //   image: DecorationImage(
            //     //     image: AssetImage('assets/images/plan.png'), 
            //     //     fit: BoxFit.cover,
            //     //   ),
            //     // ),
            //   ),
            // ),
            
            // Positioned(
            //   bottom: 0,
            //   left: 0,
            //   right: 0,
              // child: Container(
              //   height: MediaQuery.of(context).size.height / 2,
              //   color: Colors.white, 
              //   child: Center(
              //     child: Column(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Container(
              //           // Define the size of the tab bar container
              //           width: MediaQuery.of(context).size.width / 3, //300
              //           height: MediaQuery.of(context).size.height / 7, //150,
              //           child: TabBar(
              //             tabs: [
              //               Tab(text: 'Tab 1'),
              //               Tab(text: 'Tab 2'),
              //             ],
              //           ),
              //         ),
              //         SizedBox(height: 10),
              //         Expanded(
              //           child: Container(
              //             // Define the size of the tab bar view
              //             // width: double.infinity,
              //             width: MediaQuery.of(context).size.width / 3,
              //             height: MediaQuery.of(context).size.height / 3,
              //             child: TabBarView(
              //               children: [
              //                 Center(child: Text('Content of Tab 1')),
              //                 Center(child: Text('Content of Tab 2')),
              //               ],
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            // ),
          ],
        ),
      );
  }
}