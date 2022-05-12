/*********
  Web Server Code adapted from: Rui Santos:
    https://RandomNerdTutorials.com/esp32-websocket-server-arduino/
*********/

// Libraries for Web Sockets
#include <WiFi.h>
#include <AsyncTCP.h>
#include <ESPAsyncWebServer.h>
// Camera Libraries
#include "esp_camera.h"
#include <Base64.h>

// UART Pin definitions
#define RXD2 12
#define TXD2 13

// Pin definition for CAMERA_MODEL_AI_THINKER
#define PWDN_GPIO_NUM     32
#define RESET_GPIO_NUM    -1
#define XCLK_GPIO_NUM      0
#define SIOD_GPIO_NUM     26
#define SIOC_GPIO_NUM     27

#define Y9_GPIO_NUM       35
#define Y8_GPIO_NUM       34
#define Y7_GPIO_NUM       39
#define Y6_GPIO_NUM       36
#define Y5_GPIO_NUM       21
#define Y4_GPIO_NUM       19
#define Y3_GPIO_NUM       18
#define Y2_GPIO_NUM        5
#define VSYNC_GPIO_NUM    25
#define HREF_GPIO_NUM     23
#define PCLK_GPIO_NUM     22

// network credentials
const char* ssid = "The Diggs";
const char* password = "6903Bmore";

String GMST = String("GMST");
String GLUX = String("GLUX");
String GLED = String("GLED");
String GLMD = String("GLMD");
String GIMG = String("GIMG");
String SLMA = String("SLMA");
String SLMM = String("SLMM");
String WPMP = String("WPMP");
String SWON = String("SWON");
String SWOF = String("SWOF");
String DONE = String("DONE");
String MST = String("MST: ");
String LUX = String("LUX: ");
String LED = String("LED: ");
String LMD = String("LMD: ");

int mstValue = 0;
int luxValue = 0;
// lightMode 0 = automatic, 1 = manual
int lightMode = 0;

int i = 0;

// Create AsyncWebServer object on port 80
AsyncWebServer server(80);
AsyncWebSocket ws("/ws");

const char index_html[] PROGMEM = R"rawliteral(
<!DOCTYPE HTML><html>
<head>
  <title>ESP Web Server</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="icon" href="data:,">
  <style>
  html {
    font-family: Arial, Helvetica, sans-serif;
    text-align: center;
  }
  h1 {
    font-size: 1.8rem;
    color: white;
  }
  h2{
    font-size: 1.5rem;
    font-weight: bold;
    color: #143642;
  }
  .topnav {
    overflow: hidden;
    background-color: #143642;
  }
  body {
    margin: 0;
  }
  .content {
    padding: 5px;
    max-width: 600px;
    margin: 0 auto;
  }
  .card {
    background-color: #F8F7F9;;
    padding-top:2px;
    padding-bottom:2px;
  }
  .button {
    padding: 2px 2px;
    font-size: 12px;
    text-align: center;
    outline: none;
    color: #fff;
    background-color: #0f8b8d;
    border: none;
    border-radius: 3px;
    -webkit-touch-callout: none;
    -webkit-user-select: none;
    -khtml-user-select: none;
    -moz-user-select: none;
    -ms-user-select: none;
    user-select: none;
    -webkit-tap-highlight-color: rgba(0,0,0,0);
   }
   /*.button:hover {background-color: #0f8b8d}*/
   .state {
     font-size: 1.5rem;
     color:#8c8c8c;
     font-weight: bold;
   }
  </style>
<title>ESP Web Server</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="icon" href="data:,">
</head>
<body>
  <div class="topnav">
    <h1>ESP WebSocket Server</h1>
  </div>
  <div class="content">
    <div class="card">
      <h2>UART</h2>
      <p><button id="GMST" class="button">Send GMST</button></p>
    </div>
    <div class="card">
      <h2>UART</h2>
      <p><button id="GLUX" class="button">Send GLUX</button></p>
    </div>
    <div class="card">
      <h2>UART</h2>
      <p><button id="GLED" class="button">Send GLED</button></p>
    </div>
    <div class="card">
      <h2>UART</h2>
      <p><button id="GLMD" class="button">Send GLMD</button></p>
    </div>
    <div class="card">
      <h2>Camera</h2>
      <p><button id="GIMG" class="button">Send GIMG</button></p>
    </div>
    <div class="card">
      <h2>UART</h2>
      <p><button id="WPMP" class="button">Send WPMP</button></p>
    </div>
    <div class="card">
      <h2>UART</h2>
      <p><button id="SLMA" class="button">Send SLMA</button></p>
    </div>
    <div class="card">
      <h2>UART</h2>
      <p><button id="SLMM" class="button">Send SLMM</button></p>
    </div>
    <div class="card">
      <h2>UART</h2>
      <p><button id="SL10" class="button">Send SL10</button></p>
    </div>
    <div class="card">
      <h2>UART</h2>
      <p><button id="SL45" class="button">Send SL45</button></p>
    </div>
  </div>
<script>
  var gateway = `ws://${window.location.hostname}/ws`;
  var websocket;
  window.addEventListener('load', onLoad);
  function initWebSocket() {
    console.log('Trying to open a WebSocket connection...');
    websocket = new WebSocket(gateway);
    websocket.onopen    = onOpen;
    websocket.onclose   = onClose;
    websocket.onmessage = onMessage; // <-- add this line
  }
  function onOpen(event) {
    console.log('Connection opened');
  }
  function onClose(event) {
    console.log('Connection closed');
    setTimeout(initWebSocket, 2000);
  }
  function onMessage(event) {
    console.log('response set');
  }
  function onLoad(event) {
    initWebSocket();
    initButton();
  }
  function initButton() {
    document.getElementById('GMST').addEventListener('click', gmst);
    document.getElementById('GLUX').addEventListener('click', glux);
    document.getElementById('GLED').addEventListener('click', gled);
    document.getElementById('GLMD').addEventListener('click', glmd);
    document.getElementById('GIMG').addEventListener('click', gimg);
    document.getElementById('WPMP').addEventListener('click', wpmp);
    document.getElementById('SLMA').addEventListener('click', slma);
    document.getElementById('SLMM').addEventListener('click', slmm);
    document.getElementById('SL10').addEventListener('click', sl10);
    document.getElementById('SL45').addEventListener('click', sl45);
  }
  function gmst(){
    websocket.send("GMST");
  }
  function glux(){
    websocket.send("GLUX");
  }
  function gled(){
    websocket.send("GLED");
  }
  function glmd(){
    websocket.send("GLMD");
  }
  function gimg(){
    websocket.send("GIMG");
  }
  function wpmp(){
    websocket.send("WPMP");
  }
  function slma(){
    websocket.send("SLMA");
  }
  function slmm(){
    websocket.send("SLMM");
  }
  function sl10(){
    websocket.send("SL10");
  }
  function sl45(){
    websocket.send("SL45");
  }
</script>
</body>
</html>
)rawliteral";

void handleWebSocketMessage(void *arg, uint8_t *data, size_t len) {
  Serial.println("handling websocket message");
  AwsFrameInfo *info = (AwsFrameInfo*)arg;
  if (info->final && info->index == 0 && info->len == len && info->opcode == WS_TEXT) {
    data[len] = 0;
    String data_string = String((char *) data);
    if (GMST == data_string) {
      // 0 param for GMessage indicates GMST
      int val = GetMessage(0);
      if (val == -1) {
        ws.textAll(MST + "-1");
      } else {
        ws.textAll(MST + String(val));
      }
    } else if (GLUX == data_string) {
      // 1 param for GMessage indicates GLUX
      int val = GetMessage(1);
      if (val == -1) {
        ws.textAll(LUX + "-1");
      } else {
        ws.textAll(LUX + String(val));
      }
    } else if (GLED.compareTo(data_string) == 0) {
      // 2 param for GMessage indicates GLED
      int val = GetMessage(2);
      if (val == -1) {
        ws.textAll(LED + "-1");
      } else {
        ws.textAll(LED + String(val));
      }
    } else if (GLMD.compareTo(data_string) == 0) {
      if (lightMode == 0) {
        ws.textAll(LMD + "MA");
      } else {
        ws.textAll(LMD + "MM");
      }
    } else if (GIMG.compareTo(data_string) == 0) {
      // get the photo and send it over websocket
      capturePhoto();
    } else if (WPMP.compareTo(data_string) == 0) {
      int success = PWater();
      if (success == -1) {
        // bad news for kyle
      } else {
        // good news for kyle
      }
    } else if (data_string.substring(0,1).equals(String("S"))) { 
      Serial.println("in set commands");
      if (SMessage(data_string) == 0) {
        // Tell Kyle it went well
        // ws.textAll("good news");
      } else {
        // Tell Kyle it went not so well
      }
    } else {
      Serial.println("command invalid");
      ws.textAll("Invalid command sent");
    }
  }
}


/* 
 *  Sends a message to the STM 32, and takes in a parameter
 *  that enumerates which message to send. Select values:
 *  0: GMST
 *  1: GLUX
 *  2: GLED
 *  x: error???
 *  
 *  Returns the value on success, -1 on failure.
 */
int GetMessage(int select) {
  // Clear UART receive line (may not be needed)
  while(Serial2.available()) {
    Serial2.read();
  }
  // Send message
  switch(select) {
    case 0:
      Serial.println("sending GMST");
      Serial2.print(GMST+'\0');
      break;
    case 1:
      Serial.println("sending GLUX");
      Serial2.print(GLUX+'\0');
      break;
    case 2:
      Serial.println("sending GLED");
      Serial2.print(GLED+'\0');
      break;
    default:
      return -1;
  }
  // Blocking statement to wait until sending is complete (may not be needed)
  Serial2.flush();
  // Wait a half second for data to propagate (may not be needed)
  delay(500);
  // read from rx line
  while(Serial2.available()) {
    String received = Serial2.readStringUntil('\0');
    Serial.println("got in return: "+received);
    if (received.toInt() != 0) {
      return received.toInt();
    } else {
      return -1;
    }
  }
  return -1;
}

/* 
 *  Takes in SLMA, SLMM, and SLXX messages. It will 
 *  set the lightMode variable based on 0 = SLMA, and
 *  1 = SLMM. Otherwise it will send the message to the STM
 *  
 *  Returns 0 if successful, -1 if failure.
 */
int SMessage(String msg) {
  // Clear UART receive line (may not be needed)
  while(Serial2.available()) {
    Serial2.read();
  }
  if (msg.substring(0,2).compareTo(String("SL")) == 0) {
    String toSend = msg.substring(0,4);
    if (SLMA.compareTo(toSend) == 0) {
      lightMode = 0;
    } else if (SLMM.compareTo(toSend) == 0) {
      lightMode = 1;
    }
    Serial.println("sending "+toSend);
    Serial2.print(toSend+'\0');
    Serial2.flush();
    delay(500);
    // read from rx line
    return receivedDone();
  } else {
    Serial.println("set command invalid");
  }
  return -1;
}

/* 
 *  Turns the pump off and on, this uses some checking to
 *  ensure everything happens. This is because watering
 *  is crucial, and so is turning the pump off.
 *  
 *  Returns 0 on success, -1 if failed.
 */
int PWater(){
   // Clear UART receive line (may not be needed)
  while(Serial2.available()) {
    Serial2.read();
  }
  int pumpOn = 0;
  int attempts = 0;
  int pumpOff = 0;
  int off_att = 0;
  while (!pumpOn && attempts < 3) {
    Serial.println("turning pump on");
    Serial2.print(SWON+'\0');
    Serial2.flush();
    delay(500);
    // check if pump turned on
    int check = receivedDone();
    if (check == 0) {
      Serial.println("Pump is on");
      pumpOn = 1;
    }
    attempts = attempts + 1;
  }
  delay(2500);
  while(Serial2.available()) {
    Serial2.read();
  }
  while (!pumpOff && off_att < 3) {
    Serial.println("turning pump off");
    Serial2.print(SWOF+'\0');
    Serial2.flush();
    // check if pump turned off
    delay(500);
    int check = receivedDone();
    if (check == 0) {
      Serial.println("Pump is off");
      pumpOff = 1;
    }
    off_att = off_att + 1;
  }
  if (pumpOn == 1 && pumpOff == 1) {
    return 0;
  } else {
    return -1;
  }
}

/*
 * Checks to see if the STM got the message and performed
 * it successfully.
 * 
 * Returns 0 if successful, -1 on failure.
 */
int receivedDone() {
  while(Serial2.available()) {
    String received = Serial2.readStringUntil('\0');
    if (received.compareTo(String("DONE")) == 0){
      return 0;
    } else {
      return -1;
    }
  }
  return -1;
}

void onEvent(AsyncWebSocket *server, AsyncWebSocketClient *client, AwsEventType type,
             void *arg, uint8_t *data, size_t len) {
  switch (type) {
    case WS_EVT_CONNECT:
      Serial.printf("WebSocket client #%u connected from %s\n", client->id(), client->remoteIP().toString().c_str());
      break;
    case WS_EVT_DISCONNECT:
      Serial.printf("WebSocket client #%u disconnected\n", client->id());
      break;
    case WS_EVT_DATA:
      handleWebSocketMessage(arg, data, len);
      break;
    case WS_EVT_PONG:
    case WS_EVT_ERROR:
      break;
  }
}

void initWebSocket() {
  ws.onEvent(onEvent);
  server.addHandler(&ws);
}

String processor(const String& var){
  Serial.println(var);
  return String();
}

void setup(){
  // Serial port for debugging purposes
  Serial.begin(115200);
  
  // Connect to Wi-Fi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi..");
  }
  WiFi.setSleep(false);

  // Print ESP Local IP Address
  Serial.println(WiFi.localIP());

  initWebSocket();

  // Route for root / web page
  server.on("/", HTTP_GET, [](AsyncWebServerRequest *request){
    request->send_P(200, "text/html", index_html, processor);
  });

  // Start server
  server.begin();

  // Camera Capture setup
  camera_config_t config;
  config.ledc_channel = LEDC_CHANNEL_0;
  config.ledc_timer = LEDC_TIMER_0;
  config.pin_d0 = Y2_GPIO_NUM;
  config.pin_d1 = Y3_GPIO_NUM;
  config.pin_d2 = Y4_GPIO_NUM;
  config.pin_d3 = Y5_GPIO_NUM;
  config.pin_d4 = Y6_GPIO_NUM;
  config.pin_d5 = Y7_GPIO_NUM;
  config.pin_d6 = Y8_GPIO_NUM;
  config.pin_d7 = Y9_GPIO_NUM;
  config.pin_xclk = XCLK_GPIO_NUM;
  config.pin_pclk = PCLK_GPIO_NUM;
  config.pin_vsync = VSYNC_GPIO_NUM;
  config.pin_href = HREF_GPIO_NUM;
  config.pin_sscb_sda = SIOD_GPIO_NUM;
  config.pin_sscb_scl = SIOC_GPIO_NUM;
  config.grab_mode = CAMERA_GRAB_LATEST;
  config.pin_pwdn = PWDN_GPIO_NUM;
  config.pin_reset = RESET_GPIO_NUM;
  config.xclk_freq_hz = 20000000;
  config.pixel_format = PIXFORMAT_JPEG; 
  config.frame_size = FRAMESIZE_SVGA; // FRAMESIZE_ + QVGA|CIF|VGA|SVGA|XGA|SXGA|UXGA
  config.jpeg_quality = 12;
  config.fb_count = 1;

  // Init Camera
  esp_err_t err = esp_camera_init(&config);
  if (err != ESP_OK) {
    Serial.printf("Camera init failed with error 0x%x", err);
    return;
  }
  
  Serial.println("Configuration Complete");
  Serial2.begin(9600, SERIAL_8N1, RXD2, TXD2);
}

void loop() {
  ws.cleanupClients();
  // delay(1);
}

// Capture Photo and send over websockets
void capturePhoto() {
  camera_fb_t * fb = NULL; // pointer

  // Take a photo with the camera
  Serial.println("Taking a photo...");
  fb = esp_camera_fb_get();
  if (!fb) {
    Serial.println("Camera capture failed");
  }
    
  String encoded = base64::encode(fb->buf, fb->len);

  // do websockets
  ws.textAll(encoded);
  esp_camera_fb_return(fb);  
  Serial.println("Sent photo over ws");
}
