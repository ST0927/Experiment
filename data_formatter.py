import csv
import pandas as pd
import json

csv_path_1 = '/Users/shigeyuki-t/Desktop/FirstExperiment/編集用/0506.csv'
csv_path_2 = '/Users/shigeyuki-t/Desktop/FirstExperiment/編集用/0513.csv'

def csv_formatter(csv_path):
    filtered_rows = []
    with open(csv_path, 'r') as csvfile:
        reader = csv.DictReader(csvfile,  delimiter='\t', quotechar='"')
        for row in reader:
            filtered_rows.append(row)
    df = pd.DataFrame(filtered_rows)
    df = df.drop(columns=['id','area','type'])
    test_ids = ['shigeyuki.taira@gmail.com','shigeyuki.taira@ubi-lab.com','shigeyuki.syukatsu@gmail.com','shigeyuki.naist@gmail.com']
    df = df[~df['sensor_id'].isin(test_ids)]
    return df

df1 = csv_formatter(csv_path_1)
df2 = csv_formatter(csv_path_2)
print(df1.head(5))

print(df2.head(5))

df_merged = pd.concat([df1, df2], ignore_index=True)

def parse_json_column(row):
    try:
        return pd.Series(json.loads(row['body']))
    except json.JSONDecodeError:
        return pd.Series()

df_json = df_merged.apply(parse_json_column, axis=1)
df_parsed = pd.concat([df_merged, df_json], axis=1)
df_parsed = df_parsed.drop(columns=['body'])
print(df_parsed.head(5))

csv_create_location = '/Users/shigeyuki-t/Desktop/FirstExperiment/分析用/05.csv'
df_parsed.to_csv(csv_create_location, index=True)