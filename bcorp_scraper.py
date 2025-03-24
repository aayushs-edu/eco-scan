from bs4 import BeautifulSoup
import requests
import json
from time import sleep

with open("count.txt", 'r') as counter:
    a = counter.read()
    if a is None or a == '':
        a = 0
    else:
        a = int(a)

with open("json_data.txt", 'r', encoding="utf-8") as hello:
    x = hello.read()
    if x is None or x == "":
        data = {}
    else:  
        data = json.loads(x) 

i = a
while i < 377:
    url =  "https://bcorporation.net/directory?page=" + str(i)
    page = requests.get(url)
    if page.status_code < 200 and page.status_code >=300:
        print('INVALID URL')
        break 
    print(url)
    i+=1
    source = requests.get(url).text
    soup = BeautifulSoup(source, 'lxml')
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