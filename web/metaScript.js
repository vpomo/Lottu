var adrressContractRopsten = "0x27649832722a5a8f8d5269afc887ed87b186f51c";
var adrressContractMain = "0xe4a60882c473e008b4e1c942bd73addf50483825";
var adrressContractKovan = "0x31bd0b78664a1a4e68655e09bbe4f89508490361";
var contract;
var EMPTY_VALUE = "---";
var limitStep = 5;

var decimal = 1e18;

window.addEventListener('load', function () {
    // Checking if Web3 has been injected by the browser (Mist/MetaMask)
    if (typeof web3 !== 'undefined') {
        // Use Mist/MetaMask's provider
        console.log("Web3 detected!");
        window.web3 = new Web3(web3.currentProvider);
        // Now you can start your app & access web3 freely:
        var currentNetwork = web3.version.network;
        startApp();
    } else {
        console.log("Please use Chrome or Firefox, install the Metamask extension and retry the request!");
    }
})

function startApp() {
    contract = initContract();
    var myWalletAddress = web3.eth.accounts[0];

    contract.getCurrentDate( function (error, data) {
        console.log("getCurrentDate = " + data);
        var gmt = data;
        $('#gmt').html(timeConverter(gmt));
        contract.isSunday(gmt, function (error, data) {
            console.log("isSunday = " + data);
            var isSunday = data;
        });
    });

    contract.totalEthRaised( function (error, data) {
        console.log("totalEthRaised = " + data);
        var totalEthRaised = Number(data /decimal);
        $('#allEth').html(totalEthRaised);
        $.get('https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=BTC,USD,EUR', function(result) {
            console.log("Загрузка курса eth/usd завершена: " + JSON.stringify(result));
            let ratio = result.USD;
            $('#allUsd').html(Number(totalEthRaised*ratio).toFixed(2));
        });
    });

    contract.balanceETH( function (error, data) {
        console.log("balanceETH = " + data);
        var allEth = data/decimal;
        $('#balanceETH').html(allEth);
    });

    contract.uniquePlayer( function (error, data) {
        var countUniquePlayer = Number(data);
        console.log("countUniquePlayer = " + data);
        $('#cntUniquePlayer').html(countUniquePlayer);
    });

    contract.currentRound( function (error, data) {
        console.log("currentRound = " + data);
        var currentRound = Number(data);
        $('#currentRound').html(currentRound.toFixed(0));

        contract.getCountTickets(currentRound, function (error, data) {
            console.log("countTicketsCurrentRound = " + data);
            var countTicketsCurrentRound = Number(data);
            $('#countTicketsCurrentRound').html(countTicketsCurrentRound);
            var amountMainPrize = countTicketsCurrentRound*0.01*0.1891
            $('#amountMainPrize').html(amountMainPrize.toFixed(4));

        });

        contract.getLengthArrayHappyTickets(currentRound-1, function (error, data) {
            console.log("countTicketsLastRound = " + data);
            var countHappyTickets = Number(data);
            $('#countHappyTicketsLastRound').html(countHappyTickets);
            var arrayHappyTickets = "";
            for(var i=0; i< countHappyTickets; i++) {
                contract.getMemberArrayHappyTickets(currentRound-1, i, function (error, data) {
                    arrayHappyTickets = arrayHappyTickets + data +" / ";
                    //console.log("arrayHappyTickets = " + arrayHappyTickets);
                    $('#happyNumbersLastRound').html(arrayHappyTickets);
                });
            }

        });


        contract.getCountTickets(currentRound-1, function (error, data) {
            console.log("countTicketsLastRound = " + data);
            var countTicketsLastRound = Number(data);
            $('#countTicketsLastRound').html(countTicketsLastRound);
        });

        contract.getBalanceWinner(currentRound-1, myWalletAddress, function (error, data) {
            console.log("balanceWinnerCurr = " + data/decimal);
            var balanceWinnerCurr = Number(data/decimal);
            $('#balanceWinnerCurr').html(balanceWinnerCurr.toFixed(4));
        });

    });

    contract.numberCurrentTwist( function (error, data) {
        var numberCurrentTwist = Number(data);
        console.log("numberCurrentTwist = " + data);
        $('#countRoundPlay').html(numberCurrentTwist);
    });

    contract.getCountWinnersDistrib( function (error, data) {
        console.log("сountWinnersDistrib = " + JSON.stringify(data));
        var countTypeWinner = Number(data[0]) + " / " + Number(data[1]) + " / " + Number(data[2]) + " / " +
            Number(data[3]) + " / " + Number(data[4]);
        $('#countTypeWinner').html(countTypeWinner);
    });

    contract.getPayEachWinnersDistrib( function (error, data) {
        console.log("payEachWinnersDistrib = " + JSON.stringify(data));
        var amountTypeWinner = Number(data[0]/decimal).toFixed(4) + " / " + Number(data[1]/decimal).toFixed(4) + " / " + Number(data[2]/decimal).toFixed(4) +
            " / " + Number(data[3]/decimal).toFixed(4) + " / " + Number(data[4]/decimal).toFixed(4);
        $('#amountTypeWinner').html(amountTypeWinner);
    });

    contract.isTwist( function (error, data) {
        var isTwist = data;
        console.log("isTwist = " + data);
        if (isTwist) {
            $('#status').html("Розыгрыш призов ...");
        } else {
            $('#status').html("Покупка лотерейных билетов ...");
        }
    });


}

$(document).ready(function () {
});

function makeTable(network) {
    console.log("making table ...");
    var arrayTransactions = [];

    if (network == 1) {
        arrayTransactions = [];
        $.get('https://api.etherscan.io/api?module=account&action=txlist&address=' + adrressContractMain + '&sort=asc', function(result) {
            console.log("Загрузка завершена: " + JSON.stringify(result));
            // let ratio = result.USD;
            // $('#allUsd').html(Number(allEth*ratio).toFixed(2));

        });
    }
    if (network == 3) {
        arrayTransactions = [];
        $.get('https://api-ropsten.etherscan.io/api?module=account&action=txlist&address=' + adrressContractRopsten + '&sort=asc', function(result) {
            var parseJson = result.result;
            console.log("Чтение таблицы: " + parseJson.length);
            var step = limitStep;
            for (var i=parseJson.length-1; i > -1; i--) {
                arrayTransactions.push({time: timeConverter(parseJson[i].timeStamp), eth: Number(parseJson[i].value/decimal),
                    hash: parseJson[i].hash});
                step--;
                if (step == 0) {
                    i = -1;
                }
            }
            drawTable(arrayTransactions, network);
        });
    }
    if (network == 42) {
        arrayTransactions = [];
        $.get('https://api-kovan.etherscan.io/api?module=account&action=txlist&address=' + adrressContractRopsten + '&sort=asc', function(result) {
            var parseJson = result.result;
            console.log("Чтение таблицы: " + parseJson.length);
            var step = limitStep;
            for (var i=parseJson.length-1; i > -1; i--) {
                arrayTransactions.push({time: timeConverter(parseJson[i].timeStamp), eth: Number(parseJson[i].value/decimal),
                    hash: parseJson[i].hash});
                step--;
                if (step == 0) {
                    i = -1;
                }
            }
            drawTable(arrayTransactions, network);
        });
    }

}

function drawTable(arrayTransactions, network) {
    var strHtml = "";
    if(arrayTransactions != ""){
        var parseTable = arrayTransactions;
        if (network == 1) {
            for(var j = 0; j < parseTable.length; j++){
                strHtml = strHtml + '<tr>' + '<td id="u7191-4">'+ parseTable[j].time + '</td>' + '<td id="u7194-41">' + '&nbsp;&nbsp;' + parseTable[j].eth + ' ETH' +
                    '</td>' + '<td id="u7101-41">' + '&nbsp;&nbsp;' + '<a href="https://etherscan.io/tx/' + parseTable[j].hash + '">'+ parseTable[j].hash + '</a></td>';
                strHtml = strHtml + '</tr>';
            }
        }
        if (network == 3) {
            for(var j = 0; j < parseTable.length; j++){
                strHtml = strHtml + '<tr>' + '<td id="u7191-4">'+ parseTable[j].time + '</td>' + '<td id="u7194-41">' + '&nbsp;&nbsp;' + parseTable[j].eth + ' ETH' +
                    '</td>' + '<td id="u7101-41">' + '&nbsp;&nbsp;' + '<a href="https://ropsten.etherscan.io/tx/' + parseTable[j].hash + '">'+ parseTable[j].hash + '</a></td>';
                strHtml = strHtml + '</tr>';
            }
        }
        //console.log("strHtml", strHtml);
        $('#myTableBody').html(strHtml);
    }
}

function buyTicket() {
    console.log("buy tickets ...");
    var myWalletAddress = web3.eth.accounts[0];
    var receiveEth = Number($('#investment').val()) * decimal;
    console.log("receiveEth = " + receiveEth);
    contract.buyTicket(myWalletAddress, {from: web3.eth.accounts[0], value: receiveEth}, function (error, data) {
    });

}

function makeTwist() {
    console.log("makeTwist ...");
    contract.makeTwists( function (error, data) {
        console.log("error making twist: ", error);
        console.log("data making twist: ", data);
    });
}

function getRefBonus() {
    console.log("get RefBonus ...");
    contract.getMyReferrerBonus(function (error, data) {
        console.log("getMyReferrerBonus = " + data);
    });
}

function simulateDate() {
    console.log("simulateDate ...");
    var simulateDate = $('#simulateDate').val();
    contract.setSimulateDate(simulateDate, function (error, data) {
    });

}

function timeConverter(UNIX_timestamp){
    var a = new Date(UNIX_timestamp * 1000);
    // var months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    var months = ['01','02','03','04','05','06','07','08','09','10','11','12'];
    var year = a.getFullYear();
    var month = months[a.getMonth()];
    var date = a.getDate();
    var hour = a.getHours();
    var min = a.getMinutes();
    var sec = a.getSeconds();
    var time = date + '/' + month + '/' + year + '/' + hour + ':' + min + ':' + sec ;
    return time;
}

function initContract() {
    var address = {
        "1": adrressContractMain,
        "3": adrressContractRopsten,
        "42": adrressContractKovan
    }
    var current_network = web3.version.network;
    var myWalletAddress = web3.eth.accounts[0];
    if (myWalletAddress == undefined) {
        console.log("Your wallet is closed!");
    }
    $('#walletAddress').html(myWalletAddress);

    makeTable(current_network);

    var abiContract = [
        {
            "constant": false,
            "inputs": [
                {
                    "name": "_addressPlayer",
                    "type": "address"
                }
            ],
            "name": "buyTicket",
            "outputs": [],
            "payable": true,
            "stateMutability": "payable",
            "type": "function"
        },
        {
            "constant": false,
            "inputs": [
                {
                    "name": "_newOwner",
                    "type": "address"
                }
            ],
            "name": "changeOwner",
            "outputs": [],
            "payable": false,
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "constant": false,
            "inputs": [],
            "name": "makeTwists",
            "outputs": [],
            "payable": false,
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "constant": false,
            "inputs": [
                {
                    "name": "_newWallet",
                    "type": "address"
                }
            ],
            "name": "setAdministrationWallet",
            "outputs": [],
            "payable": false,
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "constant": false,
            "inputs": [],
            "name": "setDemo",
            "outputs": [],
            "payable": false,
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "constant": false,
            "inputs": [
                {
                    "name": "_number",
                    "type": "uint256"
                }
            ],
            "name": "setMaxNumberStepCircle",
            "outputs": [],
            "payable": false,
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "constant": false,
            "inputs": [
                {
                    "name": "_newDate",
                    "type": "uint256"
                }
            ],
            "name": "setSimulateDate",
            "outputs": [],
            "payable": false,
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "name": "_administrationWallet",
                    "type": "address"
                }
            ],
            "payable": false,
            "stateMutability": "nonpayable",
            "type": "constructor"
        },
        {
            "payable": true,
            "stateMutability": "payable",
            "type": "fallback"
        },
        {
            "anonymous": false,
            "inputs": [
                {
                    "indexed": true,
                    "name": "addr",
                    "type": "address"
                },
                {
                    "indexed": false,
                    "name": "when",
                    "type": "uint256"
                },
                {
                    "indexed": false,
                    "name": "round",
                    "type": "uint256"
                }
            ],
            "name": "LogNewTicket",
            "type": "event"
        },
        {
            "anonymous": false,
            "inputs": [
                {
                    "indexed": false,
                    "name": "when",
                    "type": "uint256"
                },
                {
                    "indexed": false,
                    "name": "balance",
                    "type": "uint256"
                }
            ],
            "name": "LogBalanceChanged",
            "type": "event"
        },
        {
            "anonymous": false,
            "inputs": [
                {
                    "indexed": false,
                    "name": "newDate",
                    "type": "uint256"
                },
                {
                    "indexed": false,
                    "name": "oldDate",
                    "type": "uint256"
                }
            ],
            "name": "LogChangeTime",
            "type": "event"
        },
        {
            "anonymous": false,
            "inputs": [
                {
                    "indexed": true,
                    "name": "player",
                    "type": "address"
                },
                {
                    "indexed": false,
                    "name": "value",
                    "type": "uint256"
                }
            ],
            "name": "LogRefundEth",
            "type": "event"
        },
        {
            "anonymous": false,
            "inputs": [
                {
                    "indexed": false,
                    "name": "roundLottery",
                    "type": "uint256"
                },
                {
                    "indexed": false,
                    "name": "typeWinner",
                    "type": "uint256"
                },
                {
                    "indexed": false,
                    "name": "step",
                    "type": "uint256"
                }
            ],
            "name": "LogWinnerDefine",
            "type": "event"
        },
        {
            "anonymous": false,
            "inputs": [
                {
                    "indexed": true,
                    "name": "owner",
                    "type": "address"
                },
                {
                    "indexed": true,
                    "name": "newAddress",
                    "type": "address"
                },
                {
                    "indexed": true,
                    "name": "oldAddress",
                    "type": "address"
                }
            ],
            "name": "ChangeAddressWallet",
            "type": "event"
        },
        {
            "anonymous": false,
            "inputs": [
                {
                    "indexed": false,
                    "name": "balanceContract",
                    "type": "uint256"
                }
            ],
            "name": "SendToAdministrationWallet",
            "type": "event"
        },
        {
            "anonymous": false,
            "inputs": [
                {
                    "indexed": false,
                    "name": "currentRound",
                    "type": "uint256"
                },
                {
                    "indexed": false,
                    "name": "numberCurrentTwist",
                    "type": "uint256"
                }
            ],
            "name": "Play",
            "type": "event"
        },
        {
            "anonymous": false,
            "inputs": [
                {
                    "indexed": true,
                    "name": "previousOwner",
                    "type": "address"
                },
                {
                    "indexed": true,
                    "name": "newOwner",
                    "type": "address"
                }
            ],
            "name": "OwnerChanged",
            "type": "event"
        },
        {
            "constant": true,
            "inputs": [],
            "name": "administrationWallet",
            "outputs": [
                {
                    "name": "",
                    "type": "address"
                }
            ],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [],
            "name": "balanceETH",
            "outputs": [
                {
                    "name": "",
                    "type": "uint256"
                }
            ],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [],
            "name": "currentRound",
            "outputs": [
                {
                    "name": "",
                    "type": "uint256"
                }
            ],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [
                {
                    "name": "round",
                    "type": "uint256"
                },
                {
                    "name": "wallet",
                    "type": "address"
                }
            ],
            "name": "getBalancePlayer",
            "outputs": [
                {
                    "name": "",
                    "type": "uint256"
                }
            ],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [
                {
                    "name": "round",
                    "type": "uint256"
                },
                {
                    "name": "wallet",
                    "type": "address"
                }
            ],
            "name": "getBalanceWinner",
            "outputs": [
                {
                    "name": "",
                    "type": "uint256"
                }
            ],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [
                {
                    "name": "round",
                    "type": "uint256"
                }
            ],
            "name": "getCountTickets",
            "outputs": [
                {
                    "name": "countTickets",
                    "type": "uint256"
                }
            ],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [],
            "name": "getCountWinnersDistrib",
            "outputs": [
                {
                    "name": "countWinRound_1",
                    "type": "uint256"
                },
                {
                    "name": "countWinRound_2",
                    "type": "uint256"
                },
                {
                    "name": "countWinRound_3",
                    "type": "uint256"
                },
                {
                    "name": "countWinRound_4",
                    "type": "uint256"
                },
                {
                    "name": "countWinRound_5",
                    "type": "uint256"
                }
            ],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [],
            "name": "getCurrentDate",
            "outputs": [
                {
                    "name": "",
                    "type": "uint256"
                }
            ],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [
                {
                    "name": "round",
                    "type": "uint256"
                }
            ],
            "name": "getLengthArrayHappyTickets",
            "outputs": [
                {
                    "name": "length",
                    "type": "uint256"
                }
            ],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [
                {
                    "name": "round",
                    "type": "uint256"
                },
                {
                    "name": "index",
                    "type": "uint256"
                }
            ],
            "name": "getMemberArrayHappyTickets",
            "outputs": [
                {
                    "name": "value",
                    "type": "uint256"
                }
            ],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [],
            "name": "getPayEachWinnersDistrib",
            "outputs": [
                {
                    "name": "payEachWin_1",
                    "type": "uint256"
                },
                {
                    "name": "payEachWin_2",
                    "type": "uint256"
                },
                {
                    "name": "payEachWin_3",
                    "type": "uint256"
                },
                {
                    "name": "payEachWin_4",
                    "type": "uint256"
                },
                {
                    "name": "payEachWin_5",
                    "type": "uint256"
                }
            ],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [],
            "name": "getStepTransfer",
            "outputs": [
                {
                    "name": "stepTransferVal",
                    "type": "uint256"
                },
                {
                    "name": "remainTicketVal",
                    "type": "uint256"
                }
            ],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [
                {
                    "name": "round",
                    "type": "uint256"
                },
                {
                    "name": "index",
                    "type": "uint256"
                }
            ],
            "name": "getTicketInfo",
            "outputs": [
                {
                    "name": "wallet",
                    "type": "address"
                },
                {
                    "name": "winnerRound",
                    "type": "uint256"
                }
            ],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [],
            "name": "isDemo",
            "outputs": [
                {
                    "name": "",
                    "type": "bool"
                }
            ],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [
                {
                    "name": "timestamp",
                    "type": "uint256"
                }
            ],
            "name": "isSunday",
            "outputs": [
                {
                    "name": "",
                    "type": "bool"
                }
            ],
            "payable": false,
            "stateMutability": "pure",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [],
            "name": "isTwist",
            "outputs": [
                {
                    "name": "",
                    "type": "bool"
                }
            ],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [],
            "name": "MAX_TOKENS_BUY",
            "outputs": [
                {
                    "name": "",
                    "type": "uint256"
                }
            ],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [],
            "name": "maxNumberStepCircle",
            "outputs": [
                {
                    "name": "",
                    "type": "uint256"
                }
            ],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [],
            "name": "MIN_TICKETS_BUY_FOR_ROUND",
            "outputs": [
                {
                    "name": "",
                    "type": "uint256"
                }
            ],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [],
            "name": "numberCurrentTwist",
            "outputs": [
                {
                    "name": "",
                    "type": "uint256"
                }
            ],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [],
            "name": "PRICE_OF_TOKEN",
            "outputs": [
                {
                    "name": "",
                    "type": "uint256"
                }
            ],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [],
            "name": "simulateDate",
            "outputs": [
                {
                    "name": "",
                    "type": "uint256"
                }
            ],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [],
            "name": "totalEthRaised",
            "outputs": [
                {
                    "name": "",
                    "type": "uint256"
                }
            ],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [],
            "name": "totalTicketBuyed",
            "outputs": [
                {
                    "name": "",
                    "type": "uint256"
                }
            ],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [],
            "name": "uniquePlayer",
            "outputs": [
                {
                    "name": "",
                    "type": "uint256"
                }
            ],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        }
    ];

    var contract = web3.eth.contract(abiContract).at(address[current_network]);
    console.log("Contract initialized successfully");
    console.log("current_network = " + current_network);
    console.log("myWalletAddress = " + myWalletAddress);

    return contract;
}

function resetting() {
    location.reload();
}

