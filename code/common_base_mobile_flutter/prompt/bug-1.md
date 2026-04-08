import '../widgets/health_card.dart';
       ^
lib/screens/elder/elder_home_screen.dart:14:3: Error: Type 'HealthDashboard' not 
found.
  HealthDashboard? _dashboard;
  ^^^^^^^^^^^^^^^
lib/screens/elder/elder_home_screen.dart:14:3: Error: 'HealthDashboard' isn't a  
type.
  HealthDashboard? _dashboard;
  ^^^^^^^^^^^^^^^
lib/screens/elder/elder_home_screen.dart:31:30: Error: The getter 'HealthService'
isn't defined for the type '_ElderHomeScreenState'.
 - '_ElderHomeScreenState' is from
 'package:common_base_mobile_flutter/screens/elder/elder_home_screen.dart'       
 ('lib/screens/elder/elder_home_screen.dart').
Try correcting the name to the name of an existing getter, or defining a getter  
or field named 'HealthService'.
      final response = await HealthService.getDashboard();
                             ^^^^^^^^^^^^^
lib/screens/elder/elder_home_screen.dart:34:24: Error: The getter
'HealthDashboard' isn't defined for the type '_ElderHomeScreenState'.
 - '_ElderHomeScreenState' is from
 'package:common_base_mobile_flutter/screens/elder/elder_home_screen.dart'       
 ('lib/screens/elder/elder_home_screen.dart').
Try correcting the name to the name of an existing getter, or defining a getter  
or field named 'HealthDashboard'.
          _dashboard = HealthDashboard.fromJson(response.data!);
                       ^^^^^^^^^^^^^^^
lib/screens/elder/elder_home_screen.dart:152:26: Error: The method 'AlertBanner' 
isn't defined for the type '_ElderHomeScreenState'.
 - '_ElderHomeScreenState' is from
 'package:common_base_mobile_flutter/screens/elder/elder_home_screen.dart'       
 ('lib/screens/elder/elder_home_screen.dart').
Try correcting the name to the name of an existing method, or defining a method  
named 'AlertBanner'.
                  child: AlertBanner(alerts: _dashboard!.alerts, onTap: () {}),  
                         ^^^^^^^^^^^
lib/screens/elder/elder_home_screen.dart:179:21: Error: The method 'HealthCard'  
isn't defined for the type '_ElderHomeScreenState'.
 - '_ElderHomeScreenState' is from
 'package:common_base_mobile_flutter/screens/elder/elder_home_screen.dart'       
 ('lib/screens/elder/elder_home_screen.dart').
Try correcting the name to the name of an existing method, or defining a method  
named 'HealthCard'.
                    HealthCard(
                    ^^^^^^^^^^
lib/screens/elder/elder_home_screen.dart:189:21: Error: The method 'HealthCard'  
isn't defined for the type '_ElderHomeScreenState'.
 - '_ElderHomeScreenState' is from
 'package:common_base_mobile_flutter/screens/elder/elder_home_screen.dart'       
 ('lib/screens/elder/elder_home_screen.dart').
Try correcting the name to the name of an existing method, or defining a method  
named 'HealthCard'.
                    HealthCard(
                    ^^^^^^^^^^
lib/screens/elder/elder_home_screen.dart:199:21: Error: The method 'HealthCard'  
isn't defined for the type '_ElderHomeScreenState'.
 - '_ElderHomeScreenState' is from
 'package:common_base_mobile_flutter/screens/elder/elder_home_screen.dart'       
 ('lib/screens/elder/elder_home_screen.dart').
Try correcting the name to the name of an existing method, or defining a method  
named 'HealthCard'.
                    HealthCard(
                    ^^^^^^^^^^
lib/screens/elder/elder_home_screen.dart:207:21: Error: The method 'HealthCard'  
isn't defined for the type '_ElderHomeScreenState'.
 - '_ElderHomeScreenState' is from
 'package:common_base_mobile_flutter/screens/elder/elder_home_screen.dart'       
 ('lib/screens/elder/elder_home_screen.dart').
Try correcting the name to the name of an existing method, or defining a method  
named 'HealthCard'.
                    HealthCard(
                    ^^^^^^^^^^
lib/screens/elder/elder_home_screen.dart:216:21: Error: The method 'HealthCard'  
isn't defined for the type '_ElderHomeScreenState'.
 - '_ElderHomeScreenState' is from
 'package:common_base_mobile_flutter/screens/elder/elder_home_screen.dart'       
 ('lib/screens/elder/elder_home_screen.dart').
Try correcting the name to the name of an existing method, or defining a method  
named 'HealthCard'.
                    HealthCard(
                    ^^^^^^^^^^
lib/screens/elder/elder_home_screen.dart:224:21: Error: The method 'StepCard'    
isn't defined for the type '_ElderHomeScreenState'.
 - '_ElderHomeScreenState' is from
 'package:common_base_mobile_flutter/screens/elder/elder_home_screen.dart'       
 ('lib/screens/elder/elder_home_screen.dart').
Try correcting the name to the name of an existing method, or defining a method  
named 'StepCard'.
                    StepCard(data: _dashboard?.steps),
                    ^^^^^^^^
lib/screens/elder/elder_home_screen.dart:232:26: Error: The method 'SleepCard'   
isn't defined for the type '_ElderHomeScreenState'.
 - '_ElderHomeScreenState' is from
 'package:common_base_mobile_flutter/screens/elder/elder_home_screen.dart'       
 ('lib/screens/elder/elder_home_screen.dart').
Try correcting the name to the name of an existing method, or defining a method  
named 'SleepCard'.
                  child: SleepCard(data: _dashboard?.sleep),
                         ^^^^^^^^^
lib/screens/elder/elder_home_screen.dart:237:24: Error: The method
'MedicationReminder' isn't defined for the type '_ElderHomeScreenState'.
 - '_ElderHomeScreenState' is from
 'package:common_base_mobile_flutter/screens/elder/elder_home_screen.dart'       
 ('lib/screens/elder/elder_home_screen.dart').
Try correcting the name to the name of an existing method, or defining a method  
named 'MedicationReminder'.
                child: MedicationReminder(
                       ^^^^^^^^^^^^^^^^^^
lib/screens/elder/elder_home_screen.dart:240:44: Error: The getter
'HealthService' isn't defined for the type '_ElderHomeScreenState'.
 - '_ElderHomeScreenState' is from
 'package:common_base_mobile_flutter/screens/elder/elder_home_screen.dart'       
 ('lib/screens/elder/elder_home_screen.dart').
Try correcting the name to the name of an existing getter, or defining a getter  
or field named 'HealthService'.
                    final response = await HealthService.recordMedication(id);   
                                           ^^^^^^^^^^^^^
Unsupported operation: Unsupported invalid type InvalidType(<invalid>)
(InvalidType).