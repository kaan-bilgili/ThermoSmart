#include <DHT.h>

#define DHTPIN 4      // DATA pini
#define DHTTYPE DHT11

DHT dht(DHTPIN, DHTTYPE);

void setup() {
  Serial.begin(115200);
  dht.begin();
}

void loop() {

  float humidity = dht.readHumidity();
  float temperature = dht.readTemperature();

  if (isnan(humidity) || isnan(temperature)) {
    Serial.println("Sensor okunamadi!");
    return;
  }

  Serial.print("Sicaklik: ");
  Serial.print(temperature);
  Serial.println(" °C");

  Serial.print("Nem: ");
  Serial.print(humidity);
  Serial.println(" %");

  Serial.println("----------------");

  delay(2000);
}