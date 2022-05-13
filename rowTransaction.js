const ethers = require('ethers');


async function main() {

  let privatekey = "<Private key>";
  let wallet = new ethers.Wallet(privatekey);

  console.log('Using wallet address ' + wallet.address);

  let transaction = {
    to: "<Recepient address>",
    value: 0,
    data: '0x48656c6c6f',
    gasLimit: '100000',
    maxPriorityFeePerGas: ethers.utils.parseUnits('10', 'gwei'),
    maxFeePerGas: ethers.utils.parseUnits('30', 'gwei'),
    nonce: 2,
    type: 2,
    chainId: 3
  };

  // sign and serialize the transaction
  let rawTransaction = await wallet.signTransaction(transaction).then(ethers.utils.serializeTransaction(transaction));

  // print the raw transaction hash
  console.log('Raw txhash string ' + rawTransaction);

}

main();
