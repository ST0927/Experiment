
import pandas as pd

file_path = '/Users/shigeyuki-t/Desktop/FirstExperiment/分析用/05.csv'
dataset = pd.read_csv(file_path)
print(dataset.head(3))
dataset.info()
dataset.describe()

predict_param = dataset['isAnswerCorrect']

