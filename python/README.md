# Integrating with the Trugard API using Python

In this tutorial, we'll walk through setting up a Python environment and making authenticated requests to the Trugard API to query and display smart contract data.

## Prerequisites
- Pyenv installed
- A Trugard API key for authentication
- A blank project directory

## Steps

1. **Set up a Python 3.12 environment using pyenv**

   First, install Python 3.12 using pyenv. 
   Make sure you are in the project directory:
   
   ```bash
   pyenv install 3.12.1
   ```

   Create a new virtual environment for the project:

   ```bash
   pyenv virtualenv 3.12.1 trugard-api-demo
   pyenv local trugard-api-demo
   ```

   This creates an isolated Python environment for our project and activates it.


2. **Install required packages**

   Install the `requests` library for making HTTP requests:

   ```bash
   pip install requests
   ```

3. **Set up authentication**

   Store your Trugard API key securely as an environment variable:

   ```bash
   export TRUGARD_API_KEY=your-api-key-here
   ```

   Create a python script called `main.py` in the project directory:

   ```bash
   touch main.py
   ```

   In your Python script, access the API key:

   ```python
   import os

   api_key = os.environ['TRUGARD_API_KEY']
   ```

4. **Make an authenticated request to the Trugard API**

   Use the `requests` library to make an authenticated GraphQL query:

   ```python
    import os
    import requests
    import json

    api_key = os.environ['TRUGARD_API_KEY']

    url = 'https://api.trugard.ai/tg/query'

    headers = {
        'x-apikey': api_key
    }

    ## Use our docs to modify the query as needed
    ## https://apidocs.trugard.ai/example-queries

    query = '''
    query{
    contract(network: ETH id:"0x8355048D74888569ad9f9675ae9B6920F54b9985")
    {
        
        facets{features{category{category} threat{risk confidence} notes{key value} timestamp}
            threats{category{category} threat{risk confidence} id of timestamp notes{key value}}}
        network
        deploy{block{number hash timestamp} hash index from to}
        address
        name 
        contractData{... on CodeSize{initcode{size} bytecode{size} disassembly{size} verified{size}}}
        signatures{functions}
        metadata{key value}
        standards
        opcodes{name qty}
        errors
    }
    }
    '''

    response = requests.post(url, json={'query': query}, headers=headers)
   ```

   This sends a POST request to the Trugard GraphQL endpoint with the query, including the API key in the header.


5. **Parse and display the response data**

   Extract the relevant data from the JSON response:

   ```python
    data = response.json()['data']
    print(json.dumps(data, indent=2))
   ```

   Here we use the `json.dumps` function to pretty-print the JSON response.

   ### Advanced Parsing: Iterating over the response data

   If the data is a list, you can iterate over it and print each contract/item.

   If the data is a dictionary, you can access specific keys and values.

   Here's an example of printing the 'Keys' of the response data, 
   no matter what type it is:

   ```python
    tab_space = ' ' * 6
    for key in data.keys():
        print('Type: ', key)
        print('Keys:')
        data2 = data[key]
        if type(data2) == list:  # contracts response
            for k in data2[0].keys():
                print(tab_space, k)
        else:  # contract response
            for k in data2.keys():
                print(tab_space, k)
    ```

    Here's an example of printing the 'Keys' for 'contracts' 

    ```bash
    Type:  contracts
    Keys:
           name
           deploy
           standards
           signatures
           contractData
           metadata
           opcodes
           facets
    ```

6. **Run the script**

   Run the script:

   ```bash
   python main.py
   ```

## Summary

By following these steps, you should now have a Python script that:
1. Authenticates with the Trugard API using your API key
2. Sends a GraphQL query to fetch contract details
3. Parses the response data and displays the contract details
