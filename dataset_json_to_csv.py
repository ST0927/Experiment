"""
データセットから質問と画像のデータだけをcsvとして保存し直すプログラム
画像はcsvに直接入らないのでローカルのファイルパスでひとまず代用、DBがベストだと思う
(4/14)csvの画像idに一致する画像だけで新しくフォルダを作成し、それをGithubリポジトリに保存する
"""

import pandas as pd
import requests
import json
import os
import shutil

# GQAデータセット
# ロード
GQA = '/Users/shigeyuki-t/Desktop/GQA/questions1/test_all_questions.json'
with open(GQA,'r',encoding='utf-8') as file:
    GQA_data = json.load(file)
# questionとimageIdを500行抽出,items()はキーとバリューを返すからvalueのみ使いたいなら_を入れる
GQA_df = pd.DataFrame([{'question': details['question'],'imageId': details['imageId']} for _, details in list(GQA_data.items())[:500]]) 

# csvに画像は追加できないのでファイルパスで代用
images_directory = '/Users/shigeyuki-t/Desktop/GQA/images'
def find_image_path(image_id):
    for root, dirs, files in os.walk(images_directory): # os.walkはroot,dirs,filesの３つのタプルを返すからdirの受け皿は必要
        for file in files:
            if file.startswith(image_id):
                return os.path.join(root, file)
    return "None"
GQA_df['file_path'] = GQA_df['imageId'].apply(find_image_path)





def add_gitLink(image_id):
    gitLink = "https://github.com/ST0927/Experiment/blob/main/Images/" + str(image_id) + ".jpg"
    return gitLink

GQA_df["GithubLink"] = GQA_df['imageId'].apply(add_gitLink)


# csv変換
csv_file_path = '/Users/shigeyuki-t/Desktop/GQA_dataset.csv'
GQA_df.to_csv(csv_file_path, index=True)

# # 使う画像のみを新規フォルダに保存
# newFolder_directory = '/Users/shigeyuki-t/Desktop/Images_firstExperiment'
# def send_newFolder(image_id):
#     if not os.path.exists(newFolder_directory):
#         os.makedirs(newFolder_directory)
#     for root,dirs,files in os.walk(images_directory):
#         for file in files:
#             if file.startswith(image_id):
#                 source_path = os.path.join(root, file)
#                 forwarding_path = os.path.join(newFolder_directory, file)
#                 shutil.copy(source_path, forwarding_path)
#                 return forwarding_path
#     return "None"
# folder_path = GQA_df['imageId'].apply(send_newFolder)

print(GQA_df)

"""
# Cornell NLVR　
NL_VR = 'https://raw.githubusercontent.com/lil-lab/nlvr/master/nlvr2/data/balanced/balanced_dev.json'
NL_VR_response = requests.get(NL_VR)
json_objects = NL_VR_response.text.strip().split('\n') #strip():空白（スペース、タブ等）を落とす。split：\nは改行として行に格納する
data = [json.loads(obj) for obj in json_objects] #json_objectsの各要素をobjを介してロードし、別のリストとして作成。jsonに階層構造があるときに使う
data_selection = [{'sentence': obj['sentence'], 'left_url': obj['left_url'],'right_url': obj['right_url']} for obj in data if 'sentence' in obj and 'left_url' in obj and 'right_url' in obj]
"""
