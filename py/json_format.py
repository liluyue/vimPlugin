import vim
import json
buffer=vim.current.buffer
range=vim.current.range
print(range)
list=buffer[range.start:range.end+1]
data=" ".join(list)
#print(data)
dataJson=json.loads(data)
dataDicts=json.dumps(dataJson,indent=4)
#print(dataDicts)
buffer[range.start:range.end+1]=dataDicts.split("\n")
