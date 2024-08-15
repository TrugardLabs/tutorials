#!/bin/bash

api_key=$TRUGARD_API_KEY
url="https://api.trugard.ai/tg/query"

# Use the Trugard API docs to modify the query as needed
# https://apidocs.trugard.ai/example-queries
query='
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
'
query="$(echo $query | tr -d '\n' | sed 's/"/\\"/g')"


echo "Query: $query"


response=$(curl -X POST -H "Content-Type: application/json" -H "x-apikey: $api_key" -d "{\"query\":\"$query\"}" "$url")

if [ -z "$response" ]; then
  echo "Error: Empty response from the API. Please check your API key and network connection."
  exit 1
fi

if echo "$response" | jq -e '.errors' >/dev/null; then
  echo "Error: $(echo "$response" | jq -r '.errors[0].message')"
  echo "Response: $response"
  exit 1
fi

data=$(echo "$response" | jq -r '.data')

if [ -z "$data" ] || [ "$data" = "null" ]; then
  echo "Error: Empty or null data returned from the API."
  echo "Response: $response"
  exit 1
fi

tab_space="      "
keys=$(echo "$data" | jq -r 'keys[]')
for key in $keys; do
  echo "Type: $key"
  echo "Keys:"
  data2=$(echo "$data" | jq -r ".$key")
  if echo "$data2" | jq -e 'type == "array"' >/dev/null; then
    # contracts response
    keys2=$(echo "$data2" | jq -r '.[0] | keys[]')
    for key2 in $keys2; do
      echo "$tab_space $key2"
    done
  else
    # contract response
    keys2=$(echo "$data2" | jq -r 'keys[]')
    for key2 in $keys2; do
      echo "$tab_space $key2"
    done
  fi
done

echo "Response: $response"
