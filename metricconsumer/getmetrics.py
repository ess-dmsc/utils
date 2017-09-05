import json
import pickle
import requests


if __name__ == '__main__':
    r = requests.get('http://localhost:8080/render?target=kafka.kafka.server.BrokerTopicMetrics.BytesInPerSec.15MinuteRate&format=pickle&from=-5min')
    data = pickle.loads(r.content)
    print(data[0])
