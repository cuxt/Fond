import requests

url = "http://ft.10jqka.com.cn/standardgwapi/api/iFindService/query/v1/ifind_web?reqtype=p00868"

payload = {
  'edate': "20250504",
  'zqlx': "全部",
  'tableConfig': "{\"title\":\"可转债行情\",\"columns\":[{\"headName\":\"代码\",\"headField\":\"jydm\",\"visible\":true,\"type\":\"THSCODE\"},{\"headName\":\"名称\",\"headField\":\"jydm_mc\",\"visible\":true,\"type\":\"STRING\"},{\"headName\":\"交易日期\",\"headField\":\"p00868_f002\",\"visible\":true,\"type\":\"DATE\"},{\"headName\":\"前收盘价\",\"headField\":\"p00868_f016\",\"visible\":true,\"type\":\"DOUBLE\"},{\"headName\":\"开盘价\",\"headField\":\"p00868_f007\",\"visible\":true,\"type\":\"DOUBLE\"},{\"headName\":\"最高价\",\"headField\":\"p00868_f006\",\"visible\":true,\"type\":\"DOUBLE\"},{\"headName\":\"最低价\",\"headField\":\"p00868_f001\",\"visible\":true,\"type\":\"DOUBLE\"},{\"headName\":\"收盘价\",\"headField\":\"p00868_f028\",\"visible\":true,\"type\":\"DOUBLE\"},{\"headName\":\"涨跌\",\"headField\":\"p00868_f011\",\"visible\":true,\"type\":\"DOUBLE\"},{\"headName\":\"涨跌幅(%)\",\"headField\":\"p00868_f005\",\"visible\":true,\"type\":\"DOUBLE\"},{\"headName\":\"已计息天数\",\"headField\":\"p00868_f014\",\"visible\":true,\"type\":\"INTEGER\"},{\"headName\":\"应计利息\",\"headField\":\"p00868_f008\",\"visible\":true,\"type\":\"DOUBLE\"},{\"headName\":\"剩余期限(年)\",\"headField\":\"p00868_f003\",\"visible\":true,\"type\":\"DOUBLE\"},{\"headName\":\"当期收益率(%)\",\"headField\":\"p00868_f026\",\"visible\":true,\"type\":\"DOUBLE\"},{\"headName\":\"纯债到期收益率(%)\",\"headField\":\"p00868_f023\",\"visible\":true,\"type\":\"DOUBLE\"},{\"headName\":\"纯债价值\",\"headField\":\"p00868_f004\",\"visible\":true,\"type\":\"DOUBLE\"},{\"headName\":\"纯债溢价\",\"headField\":\"p00868_f012\",\"visible\":true,\"type\":\"DOUBLE\"},{\"headName\":\"纯债溢价率(%)\",\"headField\":\"p00868_f017\",\"visible\":true,\"type\":\"DOUBLE\"},{\"headName\":\"转股价格\",\"headField\":\"p00868_f024\",\"visible\":true,\"type\":\"DOUBLE\"},{\"headName\":\"转股比例\",\"headField\":\"p00868_f019\",\"visible\":true,\"type\":\"DOUBLE\"},{\"headName\":\"转换价值\",\"headField\":\"p00868_f027\",\"visible\":true,\"type\":\"DOUBLE\"},{\"headName\":\"转股溢价\",\"headField\":\"p00868_f018\",\"visible\":true,\"type\":\"DOUBLE\"},{\"headName\":\"转股溢价率(%)\",\"headField\":\"p00868_f022\",\"visible\":true,\"type\":\"DOUBLE\"},{\"headName\":\"转股市盈率\",\"headField\":\"p00868_f021\",\"visible\":true,\"type\":\"DOUBLE\"},{\"headName\":\"转股市净率\",\"headField\":\"p00868_f015\",\"visible\":true,\"type\":\"DOUBLE\"},{\"headName\":\"套利空间\",\"headField\":\"p00868_f010\",\"visible\":true,\"type\":\"DOUBLE\"},{\"headName\":\"平价/底价\",\"headField\":\"p00868_f025\",\"visible\":true,\"type\":\"DOUBLE\"},{\"headName\":\"期限(年)\",\"headField\":\"p00868_f009\",\"visible\":true,\"type\":\"DOUBLE\"},{\"headName\":\"发行日期\",\"headField\":\"p00868_f029\",\"visible\":true,\"type\":\"DATE\"},{\"headName\":\"票面利率/发行参考利率(%)\",\"headField\":\"p00868_f013\",\"visible\":true,\"type\":\"DOUBLE\"},{\"headName\":\"交易市场\",\"headField\":\"p00868_f020\",\"visible\":true,\"type\":\"STRING\"},{\"headName\":\"债券类型\",\"headField\":\"p00868_f030\",\"visible\":true,\"type\":\"STRING\"}]}",
  'enableAi': "true",
  'enableCopilot': "true",
  'guid': "26008AA09-7ca41867-a470-482a-975d-2e49e2f19872",
  'begin': "101",
  'count': "411",
  'webPage': "1"
}

headers = {
  'User-Agent': "Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.105 Safari/537.36",
  'Accept': "application/json, text/plain, */*",
  'Accept-Encoding': "gzip, deflate",
  'Origin': "http://ft.10jqka.com.cn",
  'sw8': "1-MzFjZjQzYTQtN2M4OS00ZTQyLWExNjctN2EwNTgwYTI4MWI5-YWY3ZjI4N2EtZjE3OS00NTk3LTk0OWYtZWUxOWE5N2Q1YzY5-0-aWZpbmQtamF2YS10aGVtYXRpYy1iZmY8YnJvd3Nlcj4=-cGNfY2xpZW50XzEuMA==-L3Jvb3Q=-ZnQuMTBqcWthLmNvbS5jbg==",
  'Referer': "http://ft.10jqka.com.cn/standardgwapi/bff/thematic_bff/topic/B0005.html?version=1.10.12.415&mac=00-00-00-00-00-00",
  'Accept-Language': "zh-CN,zh;q=0.9,zh-TW;q=0.8,en;q=0.7",
  'Cookie': "v=A28Nk8IOVG6DzVBSv_SBs1yG_oh6FMM2XWjHKoH8C17l0IF0ieRThm04V3-S; sessionid=157c4bf7394ad4ba00d0fea54adba7764; jgbsessid=f4f8d14449551207d9878e659683660a; THSFT_USERID=ztzqr029; u_name=ztzqr029; userid=763322145; user=Onp0enFyMDI5Ojo6Ojo1NCwxMTAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMCwyNDs2NCwxMTExMTExMTExMTExMTExMTExMTExMTEsMjQ7ODEsMTExMTExMTExMTExMTExMTExMTExMTExLDI0OzgyLDExMTExMTExMTExMDAwMDEwMDAwMDAwMCwyNDs4NywxMTExMTExMTAwMTExMTEwMTExMTAxMTEsMjQ7MTAwLDExMTEwMTExMTExMTExMTExMTAsMjQ6Ojo6NzYzMzIyMTQ1OjE3NDYzNDU0MDU6Ojo6ODY0MDA6OjE1N2M0YmY3Mzk0YWQ0YmEwMGQwZmVhNTRhZGJhNzc2NDpkZWZhdWx0XzQ6MA%3D%3D; ticket=7ef63e09e8b9c53b7d713004faaec807; escapename=ztzqr029; version=1.10.12.415; securities=0; platform=w; ftuser_pf=00; ifindlang=cn; iFindRedGreenSet=0; AllVersion=1.10.12.415.001"
}

response = requests.post(url, data=payload, headers=headers)

print(response.text)