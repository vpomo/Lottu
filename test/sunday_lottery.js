var Lottu = artifacts.require("./Lottu.sol");
//import assertRevert from './helpers/assertRevert';

var contractSL;


contract('Lottu', (accounts) => {
    var owner = accounts[0]; // for test
var decimal = Number(1e18)  ;

var buyEthOne = Number(0.06*decimal);
var buyEthTwo = Number(0.007*decimal);
var buyEthThree = Number(0.5*decimal);
var buyEthFor = Number(0.01*decimal);

it('should deployed contract Lottu', async ()  => {
    assert.equal(undefined, contractSL);
contractSL = await Lottu.deployed();
assert.notEqual(undefined, contractSL);
});

it('get address contract', async ()  => {
    assert.notEqual(undefined, contractSL.address);
});

it('check buy tickets', async ()  => {
    await contractSL.setDemo({from:accounts[0]});
    await contractSL.setSimulateDate(1541066480); //Thu, 01 Nov 2018 10:01:20 GMT
    var msgData = [2,1,23,45,12,10];

    await contractSL.buyTicket(accounts[1], msgData, {from:accounts[1], value: buyEthOne});

    var uniquePlayer = await contractSL.uniquePlayer.call();
    assert.equal(1, Number(uniquePlayer));
    // console.log("uniquePlayer", Number(uniquePlayer));
    var totalTickets = await contractSL.totalTicketBuyed.call();
    assert.equal(1, Number(totalTickets));
    // console.log("totalTickets", Number(totalTickets));

    var totalEthRaised = await contractSL.totalEthRaised.call();
    assert.equal(0.003, Number(totalEthRaised/decimal));
    // console.log("totalEthRaised", Number(totalEthRaised/decimal));

    var balanceEth = await contractSL.balanceETH.call();
    assert.equal(0.003, Number(balanceEth/decimal));
    // console.log("balanceEth", Number(balanceEth/decimal));

    await contractSL.sssssss();

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

/*
it('check make distribution', async ()  => {
    await contractSL.makeTwists();

var isTwist = await contractSL.isTwist.call();
assert.equal(true, isTwist);
// console.log("isTwist", isTwist);

var countWinnersDistrib = await contractSL.getCountWinnersDistrib();
// console.log("countWinnersDistrib");
// console.log(Number(countWinnersDistrib[0]), Number(countWinnersDistrib[1]),
//     Number(countWinnersDistrib[2]),Number(countWinnersDistrib[3]),Number(countWinnersDistrib[4]));
assert.equal(1, Number(countWinnersDistrib[0]));
assert.equal(1, Number(countWinnersDistrib[1]));
assert.equal(4, Number(countWinnersDistrib[2]));
assert.equal(11, Number(countWinnersDistrib[3]));
assert.equal(39, Number(countWinnersDistrib[4]));

var payEachWinnersDistrib = await contractSL.getPayEachWinnersDistrib();
// console.log("payEachWinnersDistrib");
// console.log(Number(payEachWinnersDistrib[0]/decimal), Number(payEachWinnersDistrib[1]/decimal),
//     Number(payEachWinnersDistrib[2]/decimal),Number(payEachWinnersDistrib[3]/decimal),
//     Number(payEachWinnersDistrib[4]/decimal));
// 0.2118 0.1179 0.0354 0.0214 0.0106
// 0.2117 0.1179 0.0353 0.0214 0.0091
// 0.211 0.117 0.035 0.021 0.007
assert.equal(0.2012, Number(payEachWinnersDistrib[0]/decimal));
assert.equal(0.112, Number(payEachWinnersDistrib[1]/decimal));
assert.equal(0.0336, Number(payEachWinnersDistrib[2]/decimal));
assert.equal(0.0203, Number(payEachWinnersDistrib[3]/decimal));
assert.equal(0.01, Number(payEachWinnersDistrib[4]/decimal));

});
*/

/*
it('check make twist', async ()  => {

var administrationWallet = await contractSL.administrationWallet.call();

var balanceEth = await contractSL.balanceETH.call();
assert.equal(1.12, Number(balanceEth/decimal));
// console.log("balanceEth", Number(balanceEth/decimal));

var numberCurrentTwist = await contractSL.numberCurrentTwist.call();
assert.equal(2, Number(numberCurrentTwist));
// console.log("numberCurrentTwist", Number(numberCurrentTwist));

for (var i=0; i< Number(numberCurrentTwist); i++) {
    await contractSL.makeTwists();
}


isTwist = await contractSL.isTwist.call();
assert.equal(false, isTwist);
// console.log("isTwist", isTwist);

balanceEth = await contractSL.balanceETH.call();
assert.equal(0, Number(balanceEth/decimal));
// console.log("balanceEth for SL", Number(balanceEth/decimal));



});
*/

/*
it('check happy tickets', async ()  => {
    var lengthArrayHappyTickets = await contractSL.getLengthArrayHappyTickets(1);
assert.equal(56, Number(lengthArrayHappyTickets));
// console.log("lengthArrayHappyTickets", Number(lengthArrayHappyTickets));

// for (var i=0; i<lengthArrayHappyTickets;i++) {
//     var memberArrayHappyTickets = await contractSL.getMemberArrayHappyTickets(1, i);
//     console.log("memberArrayHappyTickets[" + i + "] = " + Number(memberArrayHappyTickets));
// }

});
*/

/*
    it('check new round', async ()  => {
        await contractSL.setSimulateDate(1541380200); //Mon, 05 Nov 2018 01:10:00 GMT

        await contractSL.buyTicket(accounts[5], {from:accounts[5], value: buyEthThree});
        await contractSL.buyTicket(accounts[6], {from:accounts[6], value: buyEthThree});
        await contractSL.buyTicket(accounts[7], {from:accounts[7], value: buyEthThree});

        await contractSL.setSimulateDate(1541898600); //Sun, 11 Nov 2018 01:10:00 GMT

        await contractSL.makeTwists();

        var isTwist = await contractSL.isTwist.call();
        assert.equal(true, isTwist);
        // console.log("isTwist", isTwist);

        var countWinnersDistrib = await contractSL.getCountWinnersDistrib();
        // console.log("countWinnersDistrib");
        // console.log(Number(countWinnersDistrib[0]), Number(countWinnersDistrib[1]),
        //     Number(countWinnersDistrib[2]),Number(countWinnersDistrib[3]),Number(countWinnersDistrib[4]));
        assert.equal(1, Number(countWinnersDistrib[0]));
        assert.equal(1, Number(countWinnersDistrib[1]));
        assert.equal(6, Number(countWinnersDistrib[2]));
        assert.equal(15, Number(countWinnersDistrib[3]));
        assert.equal(52, Number(countWinnersDistrib[4]));

        var numberCurrentTwist = await contractSL.numberCurrentTwist.call();
        assert.equal(4, Number(numberCurrentTwist));
        // console.log("numberCurrentTwist", Number(numberCurrentTwist));

        for (var i=0; i< Number(numberCurrentTwist); i++) {
            await contractSL.makeTwists();
        }

        isTwist = await contractSL.isTwist.call();
        assert.equal(false, isTwist);

        var lengthArrayHappyTickets = await contractSL.getLengthArrayHappyTickets(2);
        assert.equal(75, Number(lengthArrayHappyTickets));
        // console.log("lengthArrayHappyTickets", Number(lengthArrayHappyTickets));

        // for (var i=0; i<lengthArrayHappyTickets;i++) {
        //     var memberArrayHappyTickets = await contractSL.getMemberArrayHappyTickets(2, i);
        //     console.log("memberArrayHappyTickets[" + i + "] = " + Number(memberArrayHappyTickets));
        // }


    });
*/

});
