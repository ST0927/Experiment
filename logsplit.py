'''
HTTP GETでデータレイクから被験者のデータを取得するプログラム
'''


import requests
import pandas as pd

from datetime import datetime
from pandas import json_normalize

url = "https://datalake.iopt.jp/v1/sensor_data"

now = datetime.now()
date_unix = now.timestamp()

user_mail = "shigeyuki.taira@gmail.com"

params = {"key": "t9eX8tyr7G_ZQk-2",
        "area":"1927",
        "type":"1927",
        "sensor_id": user_mail,
        "data_time": date_unix,
        }
print("Success!")

# HTTPリクエストを送信してデータを取得
try:
        response = requests.get(url, params=params)
        if response.status_code == 200:
                data = response.json()['body']
                print("Success:", data)
        else:
                print("Failed with status code:", response.status_code)
except Exception as e:
        print("Error:", str(e))

print("Success!!")

# JSONデータからネスト構造を平坦化してDataFrame(一次元配列)を作成,_区切り
df = pd.json_normalize(data, sep = '_')

# meta_data_timeの値をUNIXタイムスタンプにして保存、単位は秒(s)
df['meta_data_time'] = pd.to_datetime(df['meta_data_time'],unit = 's')

# inplaceをTrueにしないと元のdfが変更されない
df.set_index('meta_data_time',inplace = True)

# meta_sensor_idは落とすけどcsvのファイル名にしたさある
df.drop(['id', 'meta_area', 'meta_type', 'meta_sensor_id'], axis=1, inplace=True)
print(df)

# CSVファイルに書き出し
df.to_csv('sensor_data.csv', index=True)
print("Success!!!")
