import paho.mqtt.client as mqtt

def on_connect(client, userdata, flags,rc):
	if rc == 0:
		print("Connected to  Mosquitto!")
		client.subscribe("thermosmart/#")
	else:
		print(f"connection failed with code {rc}")

def on_message(client, userdata, msg):
	topic = msg.topic
	value = msg.payload.decode()
	print(f"received -> topic: {topic} | Value: {value}")

client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message

client.connect("localhost", 1883)
client.loop_forever()
