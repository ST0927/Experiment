'''
GQAのデータセットが８万件くらいあってストレージ圧迫してるし一個ずつ削除も手間なのでコード化
'''

import os

# 'images'フォルダのパスを指定
directory_path = '/Users/shigeyuki-t/Desktop/GQA/images'

# ディレクトリ内の全ファイルをループ処理
for filename in os.listdir(directory_path):
    # ファイル名が'n'で始まらない場合、そのファイルを削除
    if not filename.startswith('n'):
        file_path = os.path.join(directory_path, filename)
        try:
            os.remove(file_path)
            print(f'{filename} を削除しました。')
        except Exception as e:
            print(f'{filename} の削除中にエラーが発生しました: {e}')
