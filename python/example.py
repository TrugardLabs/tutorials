import os
import requests
import json

api_key = os.environ['TRUGARD_API_KEY']

url = 'https://api.trugard.ai/tg/query'

headers = {
    'x-apikey': api_key
}

## See https://apidocs.trugard.ai/example-queries for examples

#query = '''
#query{
#  contract(network: ETH id:"0x8355048D74888569ad9f9675ae9B6920F54b9985")
#  {
#    
#    facets{features{category{category} threat{risk confidence} notes{key value} timestamp}
#           threats{category{category} threat{risk confidence} id of timestamp notes{key value}}}
#    network
#    deploy{block{number hash timestamp} hash index from to}
#    address
#    name 
#    contractData{... on CodeSize{initcode{size} bytecode{size} disassembly{size} verified{size}}}
#    signatures{functions}
#    metadata{key value}
#    standards
#    opcodes{name qty}
#    errors
#  }
#}
#'''
query = '''
query {
contracts(network: ETH , example: {signatures: {functions: ["0xbf120ae5"]}}) {
    name
    deploy { to from block{ timestamp number hash }}
    standards
    signatures { functions }
   contractData{... on CodeSize{initcode{operation size} bytecode{operation size} disassembly{operation size} verified{operation size}}}
    metadata { key value }
    opcodes {
      name
      qty
    } 
    facets{
      features{
        category{
          category
        }
        threat{
          risk
          confidence
        }
        id
      }
    }
    }
}
'''

response = requests.post(url, json={'query': query}, headers=headers)

data = response.json()['data']
#print(json.dumps(data, indent=2))

## print out all of the data keys
tab_space = ' ' * 6
for key in data.keys():
    print('Type: ', key)
    print('Keys:')
    data2 = data[key]
    if type(data2) == list:
        for key2 in data2[0].keys():
            
            print(tab_space, key2)
    else:
        for key2 in data2.keys():
            print(tab_space, key2)



