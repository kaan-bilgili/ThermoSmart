#include <WiFi.h>
#include <PubSubClient.h>

const char* ssid = "";
const char* password = "";
const char* mqtt_server = "";

WiFiClient espClient;
PubSubClient client(espClient);

int setpoint = 22;

void callback(char* topic, byte* payload, unsigned int length) {
  String message;
  for (int i = 0; i < length; i++) {
    message += (char)payload[i];
  }
  Serial.print("Setpoint received: ");
  Serial.println(message);
  setpoint = message.toInt();
}

void reconnect() {
  while (!client.connected()) {
    Serial.print("Connecting MQTT...");
    if (client.connect("ESP32Thermostat")) {
      Serial.println("connected");
      client.subscribe("thermosmart/setpoint");
    } else {
      Serial.print("failed ");
      Serial.println(client.state());
      delay(2000);
    }
  }
}

void setup() {
  Serial.begin(115200);
  WiFi.begin(ssid, password);
  Serial.print("Connecting WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("OK");
  client.setServer(mqtt_server, 1883);
  client.setCallback(callback);
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  float temperature = random(20, 30);
  char tempString[8];
  dtostrf(temperature, 1, 2, tempString);
  client.publish("thermosmart/temperature", tempString);
  Serial.print("Temperature sent: ");
  Serial.println(tempString);

  delay(3000);
}