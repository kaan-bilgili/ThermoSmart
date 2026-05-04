#include <WiFi.h>
#include <WiFiManager.h>
#include <PubSubClient.h>
#include <DHT.h>

// ===== PINLER =====
#define DHTPIN 4
#define DHTTYPE DHT11
#define LED_PIN 5

// ===== MQTT =====
const char* mqtt_server = "192.168.1.100";

WiFiClient espClient;
PubSubClient client(espClient);

// ===== DHT =====
DHT dht(DHTPIN, DHTTYPE);

// ===== TERMOSTAT =====
int setpoint = 22;

// ===== MQTT MESAJ GELİNCE =====
void callback(char* topic, byte* payload, unsigned int length) {
  String message;

  for (int i = 0; i < length; i++) {
    message += (char)payload[i];
  }

  Serial.print("Yeni setpoint: ");
  Serial.println(message);

  setpoint = message.toInt();
}

// ===== MQTT YENİDEN BAĞLAN =====
void reconnect() {
  while (!client.connected()) {
    Serial.print("MQTT baglaniyor...");

    if (client.connect("ESP32Thermostat")) {
      Serial.println("baglandi");
      client.subscribe("thermosmart/setpoint");
    } else {
      Serial.print("Hata kodu: ");
      Serial.println(client.state());
      delay(2000);
    }
  }
}

// ===== SETUP =====
void setup() {
  Serial.begin(115200);

  // WiFi bağlan (portal açılır)
  WiFiManager wm;
  wm.autoConnect("Thermostat-Setup");

  Serial.println("WiFi OK");

  // MQTT ayar
  client.setServer(mqtt_server, 1883);
  client.setCallback(callback);

  // Pinler
  pinMode(LED_PIN, OUTPUT);

  // DHT başlat
  dht.begin();
}

// ===== LOOP =====
void loop() {

  // MQTT bağlı mı?
  if (!client.connected()) {
    reconnect();
  }

  client.loop();

  // ===== SICAKLIK OKU =====
  float temperature = dht.readTemperature();

  if (isnan(temperature)) {
    Serial.println("DHT hata!");
    delay(2000);
    return;
  }

  // ===== MQTT GÖNDER =====
  char tempString[8];
  dtostrf(temperature, 1, 2, tempString);

  client.publish("thermosmart/temperature", tempString);

  Serial.print("Temp: ");
  Serial.println(tempString);

  // ===== TERMOSTAT =====
  if (temperature < setpoint - 1) {
    digitalWrite(LED_PIN, HIGH);
    Serial.println("Heating ON");
  }
  else if (temperature > setpoint + 1) {
    digitalWrite(LED_PIN, LOW);
    Serial.println("Heating OFF");
  }

  delay(3000);
}