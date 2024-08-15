Certainly! Here's the updated tutorial with the correct code sections and information:

# Integrating with the Trugard API using Bash

In this tutorial, we'll walk through setting up a Bash environment and making authenticated requests to the Trugard API to query and display smart contract data.

## Prerequisites
- Bash shell installed
- `curl` command-line tool installed
- `jq` command-line JSON processor installed
- A Trugard API key for authentication

## Steps

1. **Set up authentication**

   Store your Trugard API key securely as an environment variable:

   ```bash
   export TRUGARD_API_KEY=your-api-key-here
   ```

2. **Create a Bash script**

    ### Step 2.1: Set up variables
    Create a Bash script called `main.sh` in the project directory, and add the 
    following lines at the top of the script to set the API key and URL:
    ```bash
    api_key=$TRUGARD_API_KEY
    url="https://api.trugard.ai/tg/query"
    ```

    ### Step 2.2: Define the GraphQL query
    
    Below the api and url declarations, add the following to define the GraphQL query:
    ```bash
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
    ```

    See https://apidocs.trugard.ai/example-queries for other examples.

    ### Step 2.3: Format the query string

    Next, add the following to format the query string:
    ```bash
    query="$(echo $query | tr -d '\n' | sed 's/"/\\"/g')"
    ```

    This part formats the `query` string by removing newline characters and escaping double quotes. It uses the `echo` command to output the `query` string, `tr -d '\n'` to remove newline characters, and `sed 's/"/\\"/g'` to escape double quotes. The formatted query is then assigned back to the `query` variable.

    ### Step 2.4: Send the API request
    
    Next, let's send the API request:
    ```bash
    response=$(curl -X POST -H "Content-Type: application/json" -H "x-apikey: $api_key" -d "{\"query\":\"$query\"}" "$url")
    ```

    This part sends a POST request to the Trugard API using the `curl` command. It includes the following options:
    - `-X POST`: Specifies the HTTP method as POST.
    - `-H "Content-Type: application/json"`: Sets the `Content-Type` header to `application/json`.
    - `-H "x-apikey: $api_key"`: Sets the `x-apikey` header with the value of the `api_key` variable.
    - `-d "{\"query\":\"$query\"}"`: Sets the request body with the formatted `query` string.
    - `"$url"`: Specifies the URL of the Trugard API endpoint.

    The response from the API is stored in the `response` variable.

    ### Step 2.5: Error handling

    Next, add the following to handle errors:

    ```bash
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
    ```

    - If the `response` variable is empty, it means there was no response from the API. An error message is displayed, and the script exits with a status code of 1.
    - If the `response` contains an `errors` field, it indicates an error occurred during the API request. The script extracts the error message using `jq` and displays it along with the full response. The script then exits with a status code of 1.
    - The script extracts the `data` field from the response using `jq` and stores it in the `data` variable.
    - If the `data` variable is empty or contains the value "null", it means the API returned empty or null data. An error message is displayed along with the full response, and the script exits with a status code of 1.

    ### Step 2.6: Parse and display the response data

    Finally, add the following to parse and display the response data:
    ```bash
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
    ```

    This section:
    - Defines a variable `tab_space` to store spaces for indentation.
    - Uses `jq` to extract the keys from the `data` object and stores them in the `keys` variable.
    - Iterates over each key using a `for` loop.
    - For each key, it displays the type of data (e.g., "contracts" or "contract") and the associated keys.
    - If the value associated with a key is an array (indicating a "contracts" response), it extracts the keys from the first element of the array using `jq` and displays them with indentation.
    - If the value associated with a key is an object (indicating a "contract" response), it extracts the keys from the object using `jq` and displays them with indentation.
    - Finally, it prints the complete `response` from the API for reference.

3. **Make the script executable**

   Open a terminal and navigate to the directory where you saved the `trugard_query.sh` script. Run the following command to make the script executable:

   ```bash
   chmod +x trugard_query.sh
   ```

4. **Run the script**

   Execute the script by running:

   ```bash
   ./trugard_query.sh
   ```


## Summary

By following these steps, you should now have a Python script that:
1. Authenticates with the Trugard API using your API key
2. Sends a GraphQL query to fetch contract details
3. Parses the response data and displays the contract details