import requests 
from bs4 import BeautifulSoup
import csv
import pandas as pd 

# 爬內文跟回文
# 目前這裏只先爬八卦版的第一頁裡面的文章

df = pd.read_csv('post_url.csv')
df = df.rename(columns={'0': "url"})

# 先試五篇
df = df.head(5)

def content_crawler(URL):
  content = []
  response = requests.get(URL, headers = {'cookie': 'over18=1'})
  soup = BeautifulSoup(response.text, 'lxml')
  return soup.text

result = [content_crawler(x) for x in df["url"]]
# soup.select(".title a").get('href')
df = pd.DataFrame(result)  
    
# # save as csv
df.to_csv('post_content.csv')  