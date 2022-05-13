const {ethers} = require("hardhat")


const contractAddress = < Contract address >
const abi = < Contract ABI >

const main = async () => {

    const txFirst = await ethers.provider.getTransaction(
        < Transaction hash >
    )

    const txData = {
        gasPrice: txFirst.gasPrice,
        gasLimit: txFirst.gasLimit,
        value: txFirst.value,
        nonce: txFirst.nonce,
        data: txFirst.data,
        to: txFirst.to,
        chainId: txFirst.chainId
    }

    const serializeData = ethers.utils.serializeTransaction(txData)
    const txHash = ethers.utils.keccak256(serializeData)

    const signature = { r: txFirst.r, s: txFirst.s, v: txFirst.v}

    let pubKey = ethers.utils.recoverPublicKey(txHash, signature)
    const addr = ethers.utils.recoverAddress(txHash, signature)
    pubKey = `0x${pubKey.slice(4)}`

    console.log("Public key:", pubKey)
    console.log("Address:", addr)

    const contract = new ethers.Contract(contractAddress, abi, ethers.provider)
    const isComplete = await contract.isComplete()

    const signer = await contract.connect(ethers.provider.getSigner())
    const txSolver = await signer.authenticate(pubKey)
    
    await txSolver.wait()

    const isComplete = await contract.isComplete()
    console.log("Comlete?", isComplete)

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
