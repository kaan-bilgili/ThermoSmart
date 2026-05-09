#include <WiFi.h>
#include <PubSubClient.h>

const char* ssid = "thermosmart";
const char* password = "thermosmart";

const char* mqtt_server = "192.168.1.100";

WiFiClient espClient;
PubSubClient client(espClient);

int setpoint = 22;

void callback(char* topic, byte* payload, unsigned int length) {
  String message = "";

  for (int i = 0; i < length; i++) {
    message += (char)payload[i];
  }

  Serial.print("Yeni setpoint: ");
  Serial.println(message);

  setpoint = message.toInt();
}

void connectWiFi() {
  Serial.println("WiFi baglaniyor...");

  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println();
  Serial.println("WiFi BAGLANDI");
  Serial.print("ESP IP: ");
  Serial.println(WiFi.localIP());
}

void reconnect() {
  while (!client.connected()) {
    Serial.println("MQTT connect deneniyor...");

    if (client.connect("ESP32TEST")) {
      Serial.println("MQTT CONNECT BASARILI");

      client.subscribe("thermosmart/setpoint");

    } else {
      Serial.print("MQTT FAIL: ");
      Serial.println(client.state());
      delay(3000);
    }
  }
}

void setup() {
  Serial.begin(115200);

  connectWiFi();

  client.setServer(mqtt_server, 1883);
  client.setCallback(callback);
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }

  client.loop();

  float temperature = 25.0;

  char tempString[8];
  dtostrf(temperature, 1, 2, tempString);

  client.publish("thermosmart/temperature", tempString);
 nm
  Serial.print("Dummy Temp: ");
  Serial.println(tempString);

  delay(3000);
}