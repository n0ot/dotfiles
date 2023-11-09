import requests
resp = requests.get("https://nikocarpenter.com/ip")
resp.raise_for_status()
print(resp.text)
