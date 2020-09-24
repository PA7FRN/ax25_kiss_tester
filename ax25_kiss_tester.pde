import processing.serial.*;
import java.util.Date;
import controlP5.*;

public static final int COMPORT_ROW     =  10;
public static final int TX_DELAY_ROW    =  40;
public static final int PERSISTENCE_ROW =  70;
public static final int SLOT_TIME_ROW   = 100;
public static final int ACTION_ROW1     = 130; 
public static final int ACTION_ROW2     = 160; 
public static final int ACTION_ROW3     = 190; 

public static final int VALUE_HIGHT  =  20;
public static final int BUTTON_HIGHT =  20;
public static final int DROP_HIGHT   = 100;

public static final int LABEL_COL    =  10;
public static final int VALUE_COL    = 110;
public static final int VALUE_WIDTH  =  60;
public static final int DROP_WIDTH   = 240;
public static final int UNIT_COL     = 170;
public static final int BUTTON_COL   = 200;
public static final int BUTTON_WIDTH = 150;

public static final int ACTION_COL1  =  20;
public static final int ACTION_COL2  = 180;

public static final int DEFAULT_PERSISTENCE =  25;
public static final int DEFAULT_TX_DELAY    = 500;
public static final int DEFAULT_SLOT_TIME   = 100;

public static final byte FEND  = (byte)0xC0;
public static final byte FESC  = (byte)0xDB;
public static final byte TFEND = (byte)0xDC;
public static final byte TFESC = (byte)0xDD;

public static final int KS_UNDEF    = 0;
public static final int KS_GET_CMD  = 1;
public static final int KS_GET_DATA = 2;
public static final int KS_ESCAPE   = 3;

public static final byte CMD_DATA_FRAME    = (byte)0x00;
public static final byte CMD_TX_DELAY      = (byte)0x01;
public static final byte CMD_P             = (byte)0x02;
public static final byte CMD_SLOT_TIME     = (byte)0x03;
public static final byte CMD_TX_TAIL       = (byte)0x04;
public static final byte CMD_FULL_DUPLEX   = (byte)0x05;
public static final byte CMD_SET_HARDWARE  = (byte)0x06;
public static final byte MAX_KISS_CMD      = (byte)0x07;
public static final byte CMD_UNDEF         = (byte)0x80;
public static final byte MIN_KISS_CMD      = (byte)0xFD;
public static final byte CMD_LOOPBACK_TEST = (byte)0xFE;
public static final byte CMD_RETURN        = (byte)0xFF;


ControlP5 cp5;

Serial myPort; 
Textarea lblStatus;

long txTimer = 0;
long connectTimer = 0;
boolean comConnecting = false;
boolean comConnected = false;
boolean txBusy = false;
boolean beakon = false;
int _kissInState;
boolean _readAddress=true;

void setup() {  
  size(370, 220);
  PFont font = createFont("arial",15);
  PFont buttonFont = createFont("arial",15);

  cp5 = new ControlP5(this);

  cp5.addTextlabel("lblTxDelay")
     .setText("TX Delay:")
     .setPosition(LABEL_COL, TX_DELAY_ROW)
     .setColor(color(0))
     .setFont(font)
     ;
  
  cp5.addTextfield("txtTxDelay")
     .setPosition(VALUE_COL, TX_DELAY_ROW)
     .setSize(VALUE_WIDTH, VALUE_HIGHT)
     .setFont(font)
     .setAutoClear(false)
     .setColor(color(0))
     .setColorBackground(color(255))
     .setColorForeground(color(0,0,255))
     .setColorCursor(color(0))
     .setLabel("")
     .setText(str(DEFAULT_TX_DELAY))
     ;

  cp5.addBang("set_tx_delay")
     .setPosition(BUTTON_COL,TX_DELAY_ROW)
     .setSize(BUTTON_WIDTH, BUTTON_HIGHT)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
     .setFont(buttonFont)
     ;    

  cp5.addTextlabel("lblTxDelayUnit")
     .setText("ms")
     .setPosition(UNIT_COL, TX_DELAY_ROW)
     .setColor(color(0))
     .setFont(font)
     ;
  
  cp5.addTextlabel("lblPersistence")
     .setText("Persistence:")
     .setPosition(LABEL_COL, PERSISTENCE_ROW)
     .setColor(color(0))
     .setFont(font)
     ;
  
  cp5.addTextfield("txtPersistence")
     .setPosition(VALUE_COL, PERSISTENCE_ROW)
     .setSize(VALUE_WIDTH, VALUE_HIGHT)
     .setFont(font)
     .setAutoClear(false)
     .setColor(color(0))
     .setColorBackground(color(255))
     .setColorForeground(color(0,0,255))
     .setColorCursor(color(0))
     .setLabel("")
     .setText(str(DEFAULT_PERSISTENCE))
     ;

  cp5.addTextlabel("lblPersistenceUnit")
     .setText("%")
     .setPosition(UNIT_COL, PERSISTENCE_ROW)
     .setColor(color(0))
     .setFont(font)
     ;
  
  cp5.addBang("set_persistence")
     .setPosition(BUTTON_COL,PERSISTENCE_ROW)
     .setSize(BUTTON_WIDTH,BUTTON_HIGHT)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
     .setFont(buttonFont)
     ;    

  cp5.addTextlabel("lblSlotTime")
     .setText("Slot Time:")
     .setPosition(LABEL_COL, SLOT_TIME_ROW)
     .setColor(color(0))
     .setFont(font)
     ;
  
  cp5.addTextfield("txtSlotTime")
     .setPosition(VALUE_COL, SLOT_TIME_ROW)
     .setSize(VALUE_WIDTH, VALUE_HIGHT)
     .setFont(font)
     .setAutoClear(false)
     .setColor(color(0))
     .setColorBackground(color(255))
     .setColorForeground(color(0,0,255))
     .setColorCursor(color(0))
     .setLabel("")
     .setText(str(DEFAULT_SLOT_TIME))
     ;

  cp5.addTextlabel("lblSlotTimeUnit")
     .setText("ms")
     .setPosition(UNIT_COL, SLOT_TIME_ROW)
     .setColor(color(0))
     .setFont(font)
     ;
  
  cp5.addBang("set_slot_time")
     .setPosition(BUTTON_COL, SLOT_TIME_ROW)
     .setSize(BUTTON_WIDTH,BUTTON_HIGHT)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
     .setFont(buttonFont)
     ;    

  cp5.addBang("full_duplex")
     .setPosition(ACTION_COL1, ACTION_ROW1)
     .setSize(BUTTON_WIDTH, BUTTON_HIGHT)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
     .setFont(buttonFont)
     ;    

  cp5.addBang("half_duplex")
     .setPosition(ACTION_COL2, ACTION_ROW1)
     .setSize(BUTTON_WIDTH, BUTTON_HIGHT)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
     .setFont(buttonFont)
     ;    

  cp5.addBang("start_loopback")
     .setPosition(ACTION_COL1, ACTION_ROW2)
     .setSize(BUTTON_WIDTH, BUTTON_HIGHT)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
     .setFont(buttonFont)
     ;    

  cp5.addBang("stop_loopback")
     .setPosition(ACTION_COL2, ACTION_ROW2)
     .setSize(BUTTON_WIDTH, BUTTON_HIGHT)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
     .setFont(buttonFont)
     ;    

  cp5.addBang("start_beakon")
     .setPosition(ACTION_COL1, ACTION_ROW3)
     .setSize(BUTTON_WIDTH, BUTTON_HIGHT)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
     .setFont(buttonFont)
     ;    

  cp5.addBang("stop_beakon")
     .setPosition(ACTION_COL2, ACTION_ROW3)
     .setSize(BUTTON_WIDTH, BUTTON_HIGHT)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
     .setFont(buttonFont)
     ;    

  cp5.addTextlabel("lblComPort")
     .setText("COM Port:")
     .setPosition(LABEL_COL, COMPORT_ROW)
     .setColor(color(0))
     .setFont(font)
     ;
  
  cp5.addScrollableList("COM_Port")
     .setPosition(VALUE_COL, COMPORT_ROW+5)
     .setSize(DROP_WIDTH,DROP_HIGHT)
     .setBarHeight(VALUE_HIGHT)
     .setItemHeight(VALUE_HIGHT)
//     .setFont(buttonFont)
     .setColorActive(color(150,150,255))
     .setColorBackground(color(255))
     .setColorForeground(color(128,128,255))
     .setColorCaptionLabel(color(0))
     .setColorLabel(color(0))
     .setColorValue(color(0))
     .setColorValueLabel(color(0))
     .addItems(Serial.list())
     .setOpen(false)
     ; 

}

void draw() {
  background(240);
  if (comConnected) {
    rxMessage();
    if (beakon) {
      long currentMillis = millis();
      if ((currentMillis - txTimer) > 10000) {
        sendPacket();
      }
    }
  }
  else if (comConnecting) {
    long currentMillis = millis();
    if ((currentMillis - connectTimer) > 200) {
     comConnecting = false;
     comConnected = true;
    }
  }
}

void COM_Port(int n) {
  if (comConnected) {
    comConnected = false;
    myPort.clear();
    myPort.stop();
  }
  println("-----------------------------");
  printArray(Serial.list());
  println("Connecting to -> " + Serial.list()[n]);
  println(cp5.get(ScrollableList.class, "COM_Port").getItem(n).get("text"));
  println("-----------------------------");
  myPort = new Serial(this,Serial.list()[n], 9600);
  comConnecting = true;
  connectTimer = millis();
}

public void set_tx_delay() {
  int intTxDelay = Integer.parseInt(cp5.get(Textfield.class,"txtTxDelay").getText());
  byte btTxDelay = byte(round(intTxDelay/10));
  sendCommand(byte(CMD_TX_DELAY), btTxDelay);
}

public void set_persistence() {
  int intPersistenceProc = Integer.parseInt(cp5.get(Textfield.class,"txtPersistence").getText());
  byte btPersistence = byte(round(intPersistenceProc*256/100)-1);
  sendCommand(byte(CMD_P), btPersistence);
}

public void set_slot_time() {
  int intSlotTime = Integer.parseInt(cp5.get(Textfield.class,"txtSlotTime").getText());
  byte btSlotTime = byte(round(intSlotTime/10));
  sendCommand(byte(CMD_SLOT_TIME), btSlotTime);
}

public void full_duplex() {
  sendCommand(byte(CMD_FULL_DUPLEX), (byte)0x01);
}

public void half_duplex() {
  sendCommand(byte(CMD_FULL_DUPLEX), (byte)0x00);
}

public void start_loopback() {
  sendCommand(byte(CMD_LOOPBACK_TEST), (byte)0x01);
}

public void stop_loopback() {
  sendCommand(byte(CMD_LOOPBACK_TEST), (byte)0x00);
}

public void start_beakon() {
  if (comConnected) {
    beakon = true;
    sendPacket();
  }
}

public void stop_beakon() {
  beakon = false;
}

void sendPacket() {
  txTimer = millis();
  if (!txBusy) {
    txBusy = true;

    byte[] startBytes = {FEND, CMD_DATA_FRAME}; 

    String destination = "APDR13p";
    byte[] destAddr = new byte[7];
    for (int i=0; i<7; i++) {
      byte addrByte = (byte)destination.charAt(i);
      addrByte <<= 1;
      destAddr[i] = addrByte;
    }

    String source = "NOCALL ";
    byte[] sourceAddr = new byte[7];
    for (int i=0; i<7; i++) {
      byte addrByte = (byte)source.charAt(i);
      addrByte <<= 1;
      sourceAddr[i] = addrByte;
    }
      
    String digi1 = "WIDE1 1";
    byte[] digiAddr1 = new byte[7];
    for (int i=0; i<7; i++) {
      byte addrByte = (byte)digi1.charAt(i);
      addrByte <<= 1;
      digiAddr1[i] = addrByte;
    }

    String digi2 = "WIDE2 2";
    byte[] digiAddr2 = new byte[7];
    for (int i=0; i<7; i++) {
      byte addrByte = (byte)digi2.charAt(i);
      addrByte <<= 1;
      digiAddr2[i] = addrByte;
    }
    digiAddr2[6] += 1; 
      
    byte[] controlPidBytes = {(byte)0x03, (byte)0xf0}; 
      
    myPort.write(startBytes);
    myPort.write(destAddr);
    myPort.write(sourceAddr);
    myPort.write(digiAddr1);
    myPort.write(digiAddr2);
    myPort.write(controlPidBytes);
    myPort.write(")TEST!1905.56N/07251.25EH");
    myPort.write(FEND);
    txBusy = false;
  }
}

void sendCommand(byte cmd,byte param) {
  if (comConnected) {
    if (!txBusy) {
      txBusy = true;
      txTimer = millis();
      myPort.write(FEND);
      myPort.write(cmd);
      myPort.write(param);
      myPort.write(FEND);
      txTimer = millis();
      txBusy = false;
    }
  }
}

void rxMessage() {
  if ( myPort.available() > 0) {  
    processKissInByte((byte)myPort.read());
  }  
}

void processKissInByte(byte newByte) {
  switch (_kissInState) {
    case KS_UNDEF:
      if (newByte == FEND) {
        _kissInState = KS_GET_CMD;
      }
      break;
    case KS_GET_CMD:
      if (newByte != FEND) {
        if (newByte == 0) {
          _kissInState = KS_GET_DATA;
          print(
            year()+ "/" + 
            month()+"/" + 
            day()+ " " + 
            nf(hour(),2) + ":" + 
            nf(minute(),2) + ":" + 
            nf(second(),2) + " "
          );
        }
        else {
          _kissInState = KS_UNDEF;
        }
      }
      break;
    case KS_GET_DATA:
      if (newByte == FESC) {
        _kissInState = KS_ESCAPE;
      }
      else if (newByte == FEND) {
        println(""); 
        _readAddress = true;
        _kissInState = KS_GET_CMD;
      }
      else {
        printByte(newByte);
      }
      break;
    case KS_ESCAPE:
      if (newByte == TFEND) {
        printByte(FEND);
        _kissInState = KS_GET_DATA;
      }
      else if (newByte == TFESC) {
        printByte(FESC);
        _kissInState = KS_GET_DATA;
      }
      else {
        _kissInState = KS_UNDEF;
      }
      break;
  }
}

void printByte(byte newByte) {
  if (_readAddress) {
    _readAddress = (newByte & 0x01) != 0x01;
    newByte = byteBitShift(newByte, 1);
  }
  print((char)newByte); 
}
  
byte byteBitShift(byte val, int bitCount) {
  int intByte = val;
  intByte &= 0x00FF;
  intByte >>= bitCount; 
  return byte(intByte);
}
