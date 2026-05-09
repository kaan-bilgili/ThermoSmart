#include <WiFi.h>
#include <PubSubClient.h>
#include <DHT.h>

// ===== WIFI =====
const char *ssid = "thermosmart";
const char *password = "thermosmart";

// ===== MQTT =====
const char *mqtt_server = "192.168.1.100";

// ===== DHT =====
#define DHTPIN 4
#define DHTTYPE DHT11

// ===== LED =====
#define LED_PIN 5

WiFiClient espClient;
PubSubClient client(espClient);
DHT dht(DHTPIN, DHTTYPE);

int setpoint = 22;

// MQTT callback
void callback(char *topic, byte *payload, unsigned int length)
{
  String message = "";

  for (int i = 0; i < length; i++)
  {
    message += (char)payload[i];
  }

  Serial.print("Yeni setpoint: ");
  Serial.println(message);

  int newSetpoint = message.toInt();

  if (newSetpoint > 0)
  {
    setpoint = newSetpoint;
  }
}

// WiFi connect
void connectWiFi()
{
  Serial.println("WiFi baglaniyor...");

  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED)
  {
    delay(500);
    Serial.print(".");
  }

  Serial.println();
  Serial.println("WiFi BAGLANDI");
  Serial.print("ESP IP: ");
  Serial.println(WiFi.localIP());
}

// MQTT reconnect
void reconnect()
{
  while (!client.connected())
  {
    Serial.println("MQTT connect deneniyor...");

    if (client.connect("ESP32TEST"))
    {
      Serial.println("MQTT CONNECT BASARILI");

      client.subscribe("thermosmart/setpoint");
      Serial.println("Subscribed OK");
    }
    else
    {
      Serial.print("MQTT FAIL: ");
      Serial.println(client.state());
      delay(3000);
    }
  }
}

void setup()
{
  Serial.begin(115200);

  pinMode(LED_PIN, OUTPUT);

  dht.begin();
  delay(2000); // DHT settle

  connectWiFi();

  client.setServer(mqtt_server, 1883);
  client.setCallback(callback);
}

void loop()
{

  if (WiFi.status() != WL_CONNECTED)
  {
    connectWiFi();
  }

  if (!client.connected())
  {
    reconnect();
  }

  client.loop();

  float temperature = dht.readTemperature();

  if (isnan(temperature))
  {
    Serial.println("DHT okuma hatasi");
    delay(2000);
    return;
  }

  char tempString[8];
  dtostrf(temperature, 1, 2, tempString);

  client.publish("thermosmart/temperature", tempString);

  Serial.print("Temp: ");
  Serial.print(tempString);
  Serial.print(" | Setpoint: ");
  Serial.println(setpoint);

  if (temperature < setpoint - 1)
  {
    digitalWrite(LED_PIN, HIGH);
    Serial.println("Heating ON");
  }
  else if (temperature > setpoint + 1)
  {
    digitalWrite(LED_PIN, LOW);
    Serial.println("Heating OFF");
  }

  delay(3000);
}