from bs4 import BeautifulSoup
import requests
import json
from time import sleep

for i in range(1, 3):
    url =  "https://bcorporation.net/directory?page=" + str(i)
    page = requests.get(url)
    if page.status_code < 200 and page.status_code >=300:
        print('INVALID URL')
        break 
    print(url)
    source = requests.get(url).text
    soup = BeautifulSoup(source, 'lxml')
    data = {}
    for details in soup.find_all('div', class_ = 'card__text', style= 'overflow: visible;'):
        name = details.h3.text
        work = details.find('div', class_ = 'field-item even') 
        location = details.find('div', class_ = 'field-name-field-country') #.split(':')[1] 
        if work is not None:
            work = work.text
        if location is not None:
            location = location.text.split(':')[1]
        data[name] = {"work": work, "location": location}
    json_out = json.dumps(data, ensure_ascii=False)
    with open("json_data.txt", 'w', encoding = 'utf-8') as f:
        f.write(json_out)
    with open("count.txt", 'w') as numb:
        numb.write(str(i))