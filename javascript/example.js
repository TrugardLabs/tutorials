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
