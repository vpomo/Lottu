var Lottu = artifacts.require("./Lottu.sol");
//import assertRevert from './helpers/assertRevert';
import sendTransaction from './helpers/sendTransaction';

var contractSL;


contract('Lottu', (accounts) => {
    var owner = accounts[0]; // for test
    var decimal = Number(1e18);

    var buyEthOne = Number(0.06 * decimal);
    var buyEthTwo = Number(0.007 * decimal);
    var buyEthThree = Number(0.5 * decimal);
    var buyEthFor = Number(0.01 * decimal);

    var msgData_0 = [0, 1, 2, 5, 9, 19];
    var msgData_4 = [4, 0, 3, 4, 14, 20];
    var msgData_1 = [1, 1, 4, 9, 12, 19, 32];
    var msgData_5 = [5, 0, 5, 12, 17, 20, 33];
    var msgData_2 = [2, 1, 1, 3, 12, 19, 32, 42];
    var msgData_6 = [6, 0, 7, 6, 15, 20, 33, 44];
    var msgData_3 = [3, 1, 8, 8, 12, 19, 32, 42, 53];
    var msgData_7 = [7, 0, 2, 10, 13, 20, 33, 44, 57];

    it('should deployed contract Lottu', async () => {
        assert.equal(undefined, contractSL);
        contractSL = await Lottu.deployed();
        assert.notEqual(undefined, contractSL);
    });

    it('get address contract', async () => {
        assert.notEqual(undefined, contractSL.address);
    });

    it('check buy tickets', async () => {
        // msgData = [type, repeat, numbers[]]
        await contractSL.setDemo({from: accounts[0]});
        await contractSL.setSimulateDate(1541066480); //Thu, 01 Nov 2018 10:01:20 GMT

        await contractSL.buyTicket(accounts[0], msgData_0, {from: accounts[0], value: buyEthOne});
        await contractSL.buyTicket(accounts[1], msgData_1, {from: accounts[1], value: buyEthOne});
        await contractSL.buyTicket(accounts[2], msgData_2, {from: accounts[2], value: buyEthOne});
        await contractSL.buyTicket(accounts[3], msgData_3, {from: accounts[3], value: buyEthOne});

        await contractSL.buyTicket(accounts[4], msgData_4, {from: accounts[4], value: buyEthOne});
        await contractSL.buyTicket(accounts[5], msgData_5, {from: accounts[5], value: buyEthOne});
        await contractSL.buyTicket(accounts[6], msgData_6, {from: accounts[6], value: buyEthOne});
        await contractSL.buyTicket(accounts[7], msgData_7, {from: accounts[7], value: buyEthOne});

        var uniquePlayer = await contractSL.uniquePlayer.call();
        assert.equal(8, Number(uniquePlayer));
        // console.log("uniquePlayer", Number(uniquePlayer));
        var totalTickets = await contractSL.totalTicketBuyed.call();
        assert.equal(12, Number(totalTickets));
        // console.log("totalTickets", Number(totalTickets));

        var totalEthRaised = await contractSL.totalEthRaised.call();
        assert.equal(0.08, Number(totalEthRaised / decimal));
        // console.log("totalEthRaised", Number(totalEthRaised/decimal));

        var balanceEth = await contractSL.balanceETH.call();
        assert.equal(0.08, Number(balanceEth / decimal));
        // console.log("balanceEth", Number(balanceEth/decimal));

        //await contractSL.sssssss();

    });

    /*
    it('check date twist', async ()  => {
        await contractSL.buyTicket(accounts[3], {from:accounts[3], value: buyEthThree});
    await contractSL.buyTicket(accounts[4], {from:accounts[4], value: buyEthThree});

    var totalTickets = await contractSL.totalTicketBuyed.call();
    assert.equal(112, Number(totalTickets));
    //console.log("totalTickets", Number(totalTickets));

    await contractSL.setSimulateDate(1541293500); //Sun, 04 Nov 2018 01:05:00 GMT
    var isSunday = await contractSL.isSunday(1541293500);
    assert.equal(true, isSunday);
    //console.log("isSunday", isSunday);

    // var testDemo = await contractSL.testDemo(1);
    // console.log("testDemo", Number(testDemo));
    // testDemo = await contractSL.testDemo(2);
    // console.log("testDemo", Number(testDemo));
    });
    */

    it('check make distribution', async () => {
        var isTwist = await contractSL.isTwist.call();
        assert.equal(false, isTwist);
        // console.log("isTwist", isTwist);

        await contractSL.makeTwists();
        isTwist = await contractSL.isTwist.call();
        assert.equal(true, isTwist);
        // console.log("isTwist", isTwist);

        var arrayHappyTickets = await contractSL.getHappyTickets(1, 0);
        //console.log("arrayHappyTickets", arrayHappyTickets);
        assert.equal(4, arrayHappyTickets.length);


        while (isTwist) {
            await contractSL.makeTwists();
            isTwist = await contractSL.isTwist.call();
        }

        isTwist = await contractSL.isTwist.call();
        assert.equal(false, isTwist);
        // console.log("isTwist", isTwist);

        // await contractSL.sssssss();
    });

    it('check transfer prize', async () => {
        var administrationWallet = await contractSL.administrationWallet.call();

        var balanceEth = await contractSL.balanceETH.call();
        assert.equal(0.08, Number(balanceEth / decimal));
        //console.log("balanceEth", Number(balanceEth / decimal));

        var isTransferPrize = await contractSL.isTransferPrize.call();
        assert.equal(true, isTransferPrize);
        //console.log("isTransferPrize", isTransferPrize);

        while (isTransferPrize) {
            await contractSL.transferPrize();
            isTransferPrize = await contractSL.isTransferPrize.call();
        }

        // await contractSL.transferPrize();
        // //await contractSL.transferPrize();

        var isTransferPrize = await contractSL.isTransferPrize.call();
        assert.equal(false, isTransferPrize);
        //console.log("isTransferPrize after while", isTransferPrize);

        balanceEth = await contractSL.balanceETH.call();
        assert.equal(0.08, Number(balanceEth / decimal));
        //console.log("balanceEth for SL", Number(balanceEth / decimal));
    });

    it('check new round & tickets from previous round', async () => {
        await contractSL.setSimulateDate(1541380200); //Mon, 05 Nov 2018 01:10:00 GMT
        var isTransferPrize = await contractSL.isTransferPrize.call();
        assert.equal(false, isTransferPrize);
        //console.log("isTransferPrize", isTransferPrize);
        var isTwist = await contractSL.isTwist.call();
        assert.equal(false, isTwist);
        var currentRound = await contractSL.currentRound.call();
        assert.equal(2, Number(currentRound));

        await contractSL.buyTicket(accounts[0], msgData_0, {from: accounts[0], value: buyEthOne});
        await contractSL.buyTicket(accounts[1], msgData_1, {from: accounts[1], value: buyEthOne});
        await contractSL.buyTicket(accounts[2], msgData_2, {from: accounts[2], value: buyEthOne});
        await contractSL.buyTicket(accounts[3], msgData_3, {from: accounts[3], value: buyEthOne});

        var countTicketsType_0 = await contractSL.getCountTickets(2, 0);
        assert.equal(2, Number(countTicketsType_0));
        // console.log("countTicketsType_0", Number(countTicketsType_0));
        var countTicketsType_1 = await contractSL.getCountTickets(2, 1);
        assert.equal(2, Number(countTicketsType_1));
        // console.log("countTicketsType_1", Number(countTicketsType_1));
        var countTicketsType_2 = await contractSL.getCountTickets(2, 2);
        assert.equal(2, Number(countTicketsType_2));
        // console.log("countTicketsType_2", Number(countTicketsType_2));

        await contractSL.makeTwists();
        isTwist = await contractSL.isTwist.call();
        assert.equal(true, isTwist);
        while (isTwist) {
            await contractSL.makeTwists();
            isTwist = await contractSL.isTwist.call();
        }
        isTwist = await contractSL.isTwist.call();
        assert.equal(false, isTwist);

        var isTransferPrize = await contractSL.isTransferPrize.call();
        assert.equal(true, isTransferPrize);
        //console.log("isTransferPrize", isTransferPrize);
        while (isTransferPrize) {
            await contractSL.transferPrize();
            isTransferPrize = await contractSL.isTransferPrize.call();
        }
        var isTransferPrize = await contractSL.isTransferPrize.call();
        assert.equal(false, isTransferPrize);
    });

    it('check happy tickets', async ()  => {
        await contractSL.buyTicket(accounts[2], msgData_2, {from: accounts[2], value: buyEthOne});

        var balanceEth = await contractSL.balanceETH.call();
        // assert.equal(0.18, Number(balanceEth / decimal));
        // console.log("balanceEth", Number(balanceEth / decimal));

        await contractSL.makeTwists();
        isTwist = await contractSL.isTwist.call();
        assert.equal(true, isTwist);
        while (isTwist) {
            await contractSL.makeTwists();
            isTwist = await contractSL.isTwist.call();
        }

        var isTransferPrize = await contractSL.isTransferPrize.call();
        assert.equal(true, isTransferPrize);
        //console.log("isTransferPrize", isTransferPrize);
        while (isTransferPrize) {
            await contractSL.transferPrize();
            isTransferPrize = await contractSL.isTransferPrize.call();
        }

        var arrayWinTickets = await contractSL.getWinTickets(3, 2, 6);
        assert.equal(2, Number(arrayWinTickets.length));
        // console.log("arrayWinTickets 6", arrayWinTickets.length);
        assert.equal(1, Number(arrayWinTickets[0]));
        assert.equal(2, Number(arrayWinTickets[1]));
        // console.log("arrayWinTickets[0]", arrayWinTickets[0]);

        var balanceWinner = await contractSL.getBalanceWinner.call(3, accounts[2]);
        assert.equal(0.0348, Number(balanceWinner / decimal));
        // console.log("balanceWinner", Number(balanceWinner / decimal));

        var balanceEth = await contractSL.balanceETH.call();
        // assert.equal(0.1437, Number(balanceEth / decimal));
        // console.log("balanceEth", Number(balanceEth / decimal));

        //await contractSL.sssssss();

    });

    it('check send eth to address of contract', async ()  => {
        await sendTransaction({
            from: accounts[3],
            to: contractSL.address,
            value: buyEthOne,
            gas: 2000000,
            data: accounts[0].toLowerCase(),
        });

    });

});
