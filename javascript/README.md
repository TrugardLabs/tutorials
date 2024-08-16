# Integrating with the Trugard API using JavaScript

In this tutorial, we'll walk through setting up a JavaScript environment and making authenticated requests to the Trugard API to query and display smart contract data.

## Prerequisites
- Node.js installed
- A Trugard API key for authentication
- A blank project directory

## Steps

1. **Set up a new Node.js project**

   Create a new directory for your project and navigate into it:

   ```bash
   mkdir trugard-api-demo
   cd trugard-api-demo
   ```

   Initialize a new Node.js project:

   ```bash
   npm init -y
   ```

   This creates a `package.json` file with default settings.

2. **Install required packages**

   Install the `axios` library for making HTTP requests:

   ```bash
   npm install axios
   ```

3. **Set up authentication**

   Store your Trugard API key securely as an environment variable:

   ```bash
   export TRUGARD_API_KEY=your-api-key-here
   ```

   Create a JavaScript file called `main.js` in the project directory:

   ```bash
   touch main.js
   ```

   In your JavaScript file, access the API key:

   ```javascript
   const apiKey = process.env.TRUGARD_API_KEY;
   ```

4. **Make an authenticated request to the Trugard API**

   Use the `axios` library to make an authenticated GraphQL query:

   ```javascript
   const axios = require('axios');

   const apiKey = process.env.TRUGARD_API_KEY;
   const url = 'https://api.trugard.ai/tg/query';

   const headers = {
     'x-apikey': apiKey
   };

   // Use the Trugard API docs to modify the query as needed
   // https://apidocs.trugard.ai/example-queries
   const query = `
     query {
       contract(network: ETH id: "0x8355048D74888569ad9f9675ae9B6920F54b9985") {
         facets {
           features {
             category { category }
             threat { risk confidence }
             notes { key value }
             timestamp
           }
           threats {
             category { category }
             threat { risk confidence }
             id
             of
             timestamp
             notes { key value }
           }
         }
         network
         deploy {
           block { number hash timestamp }
           hash
           index
           from
           to
         }
         address
         name
         contractData {
           ... on CodeSize {
             initcode { size }
             bytecode { size }
             disassembly { size }
             verified { size }
           }
         }
         signatures { functions }
         metadata { key value }
         standards
         opcodes { name qty }
         errors
       }
     }
   `;

   axios.post(url, { query }, { headers })
     .then(response => {
       // Handle the response data
       const data = response.data.data;
       console.log(JSON.stringify(data, null, 2));
     })
     .catch(error => {
       console.error('Error:', error);
     });
   ```

   This sends a POST request to the Trugard GraphQL endpoint with the query, including the API key in the header.

5. **Parse and display the response data**

   Extract the relevant data from the JSON response, add this code inside the `then` block:

   ```javascript
   const data = response.data.data;
   console.log(JSON.stringify(data, null, 2));
   ```
   Here we use `JSON.stringify` to pretty-print the JSON response.


   If the data is an array, you can iterate over it and print each contract/item.

   If the data is an object, you can access specific keys and values.
   

   Here's an example of printing the keys of the response data:

   ```javascript
   const tabSpace = ' '.repeat(6);
   for (const key in data) {
     console.log('Type:', key);
     console.log('Keys:');
     const data2 = data[key];
     if (Array.isArray(data2)) { // contracts response
       for (const key2 in data2[0]) {
         console.log(tabSpace, key2);
       }
     } else { // contract response  
       for (const key2 in data2) {
         console.log(tabSpace, key2);
       }
     }
   }
   ```

   Here's what the complete axios.post looks like:

   ```javascript
   axios.post(url, { query }, { headers })
    .then(response => {
      // Handle the response data
      const data = response.data.data;
      console.log(JSON.stringify(data, null, 2));

      // Parse and display the response data
      const tabSpace = ' '.repeat(6);
      for (const key in data) {
        console.log('Type:', key);
        console.log('Keys:');
        const data2 = data[key];
        if (Array.isArray(data2)) { // contracts response
          for (const key2 in data2[0]) {
            console.log(tabSpace, key2);
          }
        } else { // contract response
          for (const key2 in data2) {
            console.log(tabSpace, key2);
          }
        }
      }
    })
    .catch(error => {
      console.error('Error:', error);
    });
   ```

6. **Run the script**

   Run the script:

   ```bash
   node main.js
   ```

## Summary

By following these steps, you should now have a JavaScript script that:
1. Authenticates with the Trugard API using your API key
2. Sends a GraphQL query to fetch contract details  
3. Parses the response data and displays the contract details