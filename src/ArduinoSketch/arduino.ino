#include <SoftwareSerial.h>
SoftwareSerial BTserial(10, 11); // RX | TX

float input_voltage = 0.0;
float temp=0.0;


void setup()
{
  BTserial.begin(9600);
   
   
}
void loop()
{

//Conversion formula for voltage
   
   int analog_value = analogRead(A0);
   input_voltage = (analog_value * 5) / 1024.0;

  
   if (input_voltage < 0.1)
   {
     input_voltage=0.0;
   }

    BTserial.print(input_voltage);

    delay(300);
}
