import requests 
from bs4 import BeautifulSoup
import csv
import pandas as pd 

# 這裏只有八卦版（因為要18歲驗證）
# 還沒做翻頁！！！！現在只有第一頁

URL = "https://www.ptt.cc/bbs/Gossiping/index.html"

# set cookie in header
response = requests.get(URL, headers = {'cookie': 'over18=1'})
soup = BeautifulSoup(response.text, 'lxml')

a = soup.select(".title a")

url = []
for a_tags in a:
  url.append("https://www.ptt.cc"+str(a_tags.get('href')))

# # transform to pandas dataframe 
df = pd.DataFrame(url)  
    
# # save as csv
df.to_csv('post_url.csv')  