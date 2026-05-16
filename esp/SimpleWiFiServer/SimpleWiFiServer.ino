#include <WiFi.h>
#include <WiFiManager.h>
#include <PubSubClient.h>
<<<<<<< Updated upstream

#define LED_PIN 2   // D4 = GPIO2

const char* mqtt_server = "192.168.43.120"; // Raspberry Pi IP
=======
#include <DHT.h>
#include <Preferences.h>

// ===== DHT =====
#define DHTPIN 4
#define DHTTYPE DHT11

// ===== LED =====
#define LED_PIN 5
>>>>>>> Stashed changes

// ===== RESET BUTTON =====
// Bu pine bağlı butona 3 saniye basılı tutulursa WiFi ayarları sıfırlanır
#define RESET_PIN 0  // ESP32 üzerindeki BOOT butonu

WiFiClient espClient;
PubSubClient client(espClient);
<<<<<<< Updated upstream
=======
DHT dht(DHTPIN, DHTTYPE);
Preferences preferences;
>>>>>>> Stashed changes

char mqtt_server[40] = "192.168.1.100";
int setpoint = 22;

<<<<<<< Updated upstream
void callback(char* topic, byte* payload, unsigned int length) {
  String message;

  for (int i = 0; i < length; i++) {
=======
// MQTT callback
void callback(char *topic, byte *payload, unsigned int length)
{
  String message = "";
  for (int i = 0; i < length; i++)
  {
>>>>>>> Stashed changes
    message += (char)payload[i];
  }

  Serial.print("Setpoint received: ");
  Serial.println(message);

<<<<<<< Updated upstream
  setpoint = message.toInt();
}

void reconnect() {
  while (!client.connected()) {
    Serial.print("Connecting MQTT...");

    if (client.connect("ESP32Thermostat")) {
      Serial.println("connected");
=======
  int newSetpoint = message.toInt();
  if (newSetpoint > 0)
  {
    setpoint = newSetpoint;
  }
}

void connectWiFi()
{
  WiFiManager wifiManager;

  // Portal açık kalma süresi (saniye) - bu süre dolunca kaydedilmiş ayarla devam eder
  wifiManager.setConfigPortalTimeout(120);

  // MQTT sunucu IP'sini de portal üzerinden ayarlanabilir yap
  WiFiManagerParameter mqtt_param("mqtt", "MQTT Sunucu IP", mqtt_server, 40);
  wifiManager.addParameter(&mqtt_param);

  Serial.println("WiFi baglaniyor...");

  // Kayıtlı WiFi varsa direkt bağlanır.
  // Yoksa "ThermoSmart-Setup" adlı AP açar, kullanıcı bağlanıp tarayıcıda ayarlar.
  if (!wifiManager.autoConnect("ThermoSmart-Setup", "thermosetup"))
  {
    Serial.println("WiFi baglanti basarisiz, yeniden baslatiliyor...");
    delay(3000);
    ESP.restart();
  }

  // Portal üzerinden girilen MQTT IP'yi kaydet
  strncpy(mqtt_server, mqtt_param.getValue(), 40);
  preferences.begin("thermosmart", false);
  preferences.putString("mqtt_ip", mqtt_server);
  preferences.end();

  Serial.println("WiFi BAGLANDI");
  Serial.print("ESP IP: ");
  Serial.println(WiFi.localIP());
  Serial.print("MQTT Sunucu: ");
  Serial.println(mqtt_server);
}

void reconnect()
{
  while (!client.connected())
  {
    Serial.println("MQTT connect deneniyor...");
    if (client.connect("ESP32TEST"))
    {
      Serial.println("MQTT CONNECT BASARILI");
>>>>>>> Stashed changes
      client.subscribe("thermosmart/setpoint");
    } else {
      Serial.print("failed ");
      Serial.println(client.state());
      delay(2000);
    }
  }
}

<<<<<<< Updated upstream
void setup() {
  Serial.begin(115200);

 
  WiFiManager wm;
  wm.autoConnect("Thermostat-Setup");

  Serial.println("WiFi Connected!");
=======
void checkResetButton()
{
  pinMode(RESET_PIN, INPUT_PULLUP);
  delay(100);

  if (digitalRead(RESET_PIN) == LOW)
  {
    unsigned long pressStart = millis();
    Serial.println("Reset butonu basili, 3 saniye bekle...");

    while (digitalRead(RESET_PIN) == LOW)
    {
      if (millis() - pressStart >= 3000)
      {
        Serial.println("WiFi ayarlari sifirlanıyor...");
        WiFiManager wifiManager;
        wifiManager.resetSettings();
        preferences.begin("thermosmart", false);
        preferences.clear();
        preferences.end();
        delay(1000);
        ESP.restart();
      }
    }
  }
}

void setup()
{
  Serial.begin(115200);
  pinMode(LED_PIN, OUTPUT);

  // Kaydedilmiş MQTT IP varsa yükle
  preferences.begin("thermosmart", true);
  String saved_mqtt = preferences.getString("mqtt_ip", "192.168.1.100");
  preferences.end();
  saved_mqtt.toCharArray(mqtt_server, 40);

  checkResetButton();

  dht.begin();
  delay(2000);

  connectWiFi();
>>>>>>> Stashed changes

  client.setServer(mqtt_server, 1883);
  client.setCallback(callback);

  pinMode(LED_PIN, OUTPUT);
}

<<<<<<< Updated upstream
void loop() {
  if (!client.connected()) {
=======
void loop()
{
  if (WiFi.status() != WL_CONNECTED)
  {
    connectWiFi();
  }

  if (!client.connected())
  {
>>>>>>> Stashed changes
    reconnect();
  }

  client.loop();


  float temperature = random(20, 30);

  char tempString[8];
  dtostrf(temperature, 1, 2, tempString);

  client.publish("thermosmart/temperature", tempString);

  Serial.print("Temperature sent: ");
  Serial.println(tempString);


  if (temperature < setpoint - 1) {
    digitalWrite(LED_PIN, HIGH);  // LED ON
    Serial.println("Heating ON");
  }
  else if (temperature > setpoint + 1) {
    digitalWrite(LED_PIN, LOW);   // LED OFF
    Serial.println("Heating OFF");
  }

  delay(3000);
}
