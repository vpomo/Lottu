const Web3 = require('web3');
const web3 = new Web3();
const Tx = require('ethereumjs-tx');

var addressContractRopsten = '0x27649832722a5a8f8d5269afc887ed87b186f51c';
var addressContractTokenRopsten = '0xc2784e9a212307bb7b781d4913fb90d0a59d448a';

var fs = require('fs');
var abiContractSL = fs.readFileSync('abi-lottery.txt', 'utf8');
var abiContractToken = fs.readFileSync('abi-token.txt', 'utf8');

var myWallet = '0x5a204d1ca98e8de8566b20951e55f9d710e65947';
var myPrivateKey = 'ED4F8ECCC108FAEED0BFEBEA1CE81FEF66E58AF7A236A72A556CCBF924BD9285';

var decimalToken = 1e18;
var gasPriceGwei = 8 * 1e9; //10 GWEY
var gasLimit = 8000000;

contract = web3.eth.contract(JSON.parse(abiContractSL)).at(addressContractRopsten);
contractToken = web3.eth.contract(JSON.parse(abiContractToken)).at(addressContractTokenRopsten);

web3.setProvider(new web3.providers.HttpProvider('https://ropsten.infura.io/v3/3c062145785d483c83f468a78df99a55'));
if (!web3.isConnected())
    console.log("not connected");
else
    console.log("connected");
web3.eth.defaultAccount = web3.eth.accounts[0];

lottery();
//updateDividend();

// buyTickets(0.45);
// buyTickets(0.45);

function lottery() {
    web3.eth.getBlock("latest", false, function (error, gasLimit) {
        const rawTransaction = {
            from: myWallet,
            to: addressContractRopsten,
            nonce: web3.toHex(web3.eth.getTransactionCount(myWallet)),
            gasPrice: web3.toHex(gasPriceGwei),
            gasLimit: gasLimit.gasLimit,
            value: 0,
            data: contract.makeTwists.getData({from: myWallet})
        };

        let privateKey = new Buffer(myPrivateKey, 'hex');
        var tx = new Tx(rawTransaction);
        tx.sign(privateKey);
        var serializedTx = '0x' + tx.serialize().toString('hex');

        console.log("makeTwists ...");
        web3.eth.sendRawTransaction(serializedTx, function (err, txHash) {
            console.log(err, txHash);
            var pended = false;
            if (err != undefined) {
                console.log("Error transaction");
                lottery();
            }
            if (err == null) {
                while (!pended) {
                    pended = isPendingTransaction(txHash);
                    // setTimeout(function () {
                    //     pended = isPendingTransaction(txHash);
                    // }, 10000);
                }
                // setTimeout(function () {
                //     sleep(1000);
                // }, 30000);
                // setTimeout(function () {
                //     sleep(1000);
                // }, 30000);

                console.log("Transaction is pended");
                var isTwist = contract.isTwist.call();
                console.log("isTwist = " + isTwist);
                if (isTwist) {
                    numberCurrentTwist = contract.numberCurrentTwist.call();
                    console.log("numberCurrentTwist = " + numberCurrentTwist);
                    lottery();
                } else {
                    updateDividend();
                }
            }

        });
    });

}

function buyTickets(sendEth) {
    var oldEth = sendEth;
    sendEth = sendEth * decimalToken;
    console.log("sendEth = " + sendEth);

    const rawTransaction = {
        from: myWallet,
        to: addressContractRopsten,
        nonce: web3.toHex(web3.eth.getTransactionCount(myWallet)),
        gasPrice: web3.toHex(gasPriceGwei),
        gasLimit: web3.toHex(gasLimit),
        value: sendEth,
        data: contract.buyTicket.getData(myWallet, {from: myWallet})
    };

    let privateKey = new Buffer(myPrivateKey, 'hex');
    var tx = new Tx(rawTransaction);
    tx.sign(privateKey);
    console.log("Validation:", tx.validate());
    var serializedTx = '0x' + tx.serialize().toString('hex');

    console.log("buyTickets ...");
    web3.eth.sendRawTransaction(serializedTx, function (err, txHash) {
        console.log(err, txHash);
        var pended = false;
        if (err != undefined) {
            console.log("Error transaction");
            buyTickets(oldEth);
        }
        if (err == null) {
            while (!pended) {
                pended = isPendingTransaction(txHash);
                // setTimeout(function () {
                //     pended = isPendingTransaction(txHash);
                // }, 10000);
            }
            console.log("Transaction is pended");
        }

    });
}

function updateDividend() {

    const rawTransaction = {
        from: myWallet,
        to: addressContractTokenRopsten,
        nonce: web3.toHex(web3.eth.getTransactionCount(myWallet)),
        gasPrice: web3.toHex(gasPriceGwei),
        gasLimit: web3.toHex(gasLimit),
        value: 0,
        data: contractToken.updateDividend.getData({from: myWallet})
    };

    let privateKey = new Buffer(myPrivateKey, 'hex');
    var tx = new Tx(rawTransaction);
    tx.sign(privateKey);
    console.log("Validation:", tx.validate());
    var serializedTx = '0x' + tx.serialize().toString('hex');

    console.log("updateDividend ...");
    web3.eth.sendRawTransaction(serializedTx, function (err, txHash) {
        console.log(err, txHash);
        var pended = false;
        if (err != undefined) {
            console.log("Error transaction");
            updateDividend();
        }
        if (err == null) {
            while (!pended) {
                 pended = isPendingTransaction(txHash);
                // setTimeout(function () {
                //     pended = isPendingTransaction(txHash);
                // }, 10000);
            }
            pended = isPendingTransaction(txHash);
            console.log("Transaction is pended");
        }

    });
}

function isPendingTransaction(txHash) {
    data = web3.eth.getTransaction(txHash);
    if (data == null || data.blockNumber == undefined) {
        return false;
    } else {
        setTimeout(function () {
        }, 10000);
        return true;
    }
}

function sleep(milliseconds) {
    var start = new Date().getTime();
    for (var i = 0; i < 1e7; i++) {
        if ((new Date().getTime() - start) > milliseconds) {
            break;
        }
    }
}
