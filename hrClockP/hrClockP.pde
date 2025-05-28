import processing.serial.*;
import java.time.*;
import java.time.format.*;
//import java.time.DateTimeFormatter;

Serial myPort;  // Create object from Serial class
String val;     // Data received from the serial port

int bpm = -1;
int conf = 0;
int status = 0;
Instant ourTime;
Instant prevTime;
double heartrateFactor = 1;

void setup()
{
  size(800, 400);
  ourTime = Instant.now();
  prevTime = ourTime;
  // I know that the first port in the serial list on my mac
  // is Serial.list()[0].
  // On Windows machines, this generally opens COM1.
  // Open whatever port is the one you're using.
  //print(Serial.list());
  String portName = Serial.list()[2]; //change the 0 to a 1 or 2 etc. to match your port
  myPort = new Serial(this, portName, 115200);
}

void draw()
{
  background(250, 50, 100);
  readData();
  updateHRFactor();
  updateTime();

  showTime();
  if (bpm > 0) {
    showBpm();
  } else {
    textSize(40);
    text("Press down... :)", width/2, height/2 - 50);
  }
}

void readData() {
  if ( myPort.available() > 0)
  {  // If data is available,
    val = myPort.readStringUntil('\n');         // read it and store it in val
    println(val); //print it out in the console



    if (val != null) {
      
  if (val.contains("Status")) {
    String statusString = val.split(": ")[1].trim();
    status = Integer.parseInt(statusString);
    
    if (status != 3) {
      bpm = -1;
    }
  }
      
      if (val.contains("Confidence")) {
        String confidenceString = val.split(": ")[1].trim();
        conf = Integer.parseInt(confidenceString);
      }

      if (conf > 90 && status == 3) {
        if (val.contains("Heartrate")) {
          println(":)");

          String bpmString = val.split(": ")[1].trim();
          println(bpmString);

          if (!bpmString.equals("0")) {
            bpm = Integer.parseInt(bpmString);
          }

          println(bpm);
        }
      }
    }
  }
}

void updateHRFactor() {
  if (bpm < 70 && bpm > 0) {
    heartrateFactor = .50;
  } else if (bpm > 75) {
    heartrateFactor = 1.5;
  } else {
    heartrateFactor = 1.06;
  }
}

void updateTime() {
  Instant currTime = Instant.now();
  Duration diff = Duration.between(prevTime, currTime);
  prevTime = currTime;
  //diff = Duration.ofMillis((long) diff.toMillis()*heartrateFactor);
  double ourDiffDouble = diff.toMillis()*heartrateFactor;
  long ourDiffLong = (long) ourDiffDouble;
  Duration ourDiff = Duration.ofMillis(ourDiffLong);
  ourTime = ourTime.plus(ourDiff);
  //print(currTime);
}

void showTime() {
  textSize(45);
  textAlign(CENTER);

//  text(hour()+ ":" + minute() + ":" + second(), width/2, height/2);
  String ourTimeString = ourTime.atZone(ZoneOffset.of("-04:00")).format(DateTimeFormatter.ofPattern("HH:mm:ss"));
  text(ourTimeString, width/2, height/2);
  String nowTimeString = Instant.now().atZone(ZoneOffset.of("-04:00")).format(DateTimeFormatter.ofPattern("HH:mm:ss"));
  text(nowTimeString, width/2, height/2+50);

}

void showBpm() {
  textSize(45);
  textAlign(CENTER);

  text(bpm, width/2, height/2 - 50);
}
