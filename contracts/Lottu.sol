pragma solidity >0.4.99 <0.6.0;

library Zero {
    function requireNotZero(address addr) internal pure {
        require(addr != address(0), "require not zero address");
    }

    function requireNotZero(uint val) internal pure {
        require(val != 0, "require not zero value");
    }

    function notZero(address addr) internal pure returns (bool) {
        return !(addr == address(0));
    }

    function isZero(address addr) internal pure returns (bool) {
        return addr == address(0);
    }

    function isZero(uint a) internal pure returns (bool) {
        return a == 0;
    }

    function notZero(uint a) internal pure returns (bool) {
        return a != 0;
    }
}

library Address {
    function toAddress(bytes memory source) internal pure returns (address addr) {
        assembly {addr := mload(add(source, 0x14))}
        return addr;
    }

    function isNotContract(address addr) internal view returns (bool) {
        uint length;
        assembly {length := extcodesize(addr)}
        return length == 0;
    }
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b > 0);
        // Solidity only automatically asserts when dividing by 0
        uint256 c = _a / _b;
        // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a);
        uint256 c = _a - _b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a);

        return c;
    }

}

library Percent {
    struct percent {
        uint num;
        uint den;
    }

    function mul(percent storage p, uint a) internal view returns (uint) {
        if (a == 0) {
            return 0;
        }
        return a * p.num / p.den;
    }

    function div(percent storage p, uint a) internal view returns (uint) {
        return a / p.num * p.den;
    }

    function sub(percent storage p, uint a) internal view returns (uint) {
        uint b = mul(p, a);
        if (b >= a) {
            return 0;
        }
        return a - b;
    }

    function add(percent storage p, uint a) internal view returns (uint) {
        return a + mul(p, a);
    }

    function toMemory(percent storage p) internal view returns (Percent.percent memory) {
        return Percent.percent(p.num, p.den);
    }

    function mmul(percent memory p, uint a) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }
        return a * p.num / p.den;
    }

    function mdiv(percent memory p, uint a) internal pure returns (uint) {
        return a / p.num * p.den;
    }

    function msub(percent memory p, uint a) internal pure returns (uint) {
        uint b = mmul(p, a);
        if (b >= a) {
            return 0;
        }
        return a - b;
    }

    function madd(percent memory p, uint a) internal pure returns (uint) {
        return a + mmul(p, a);
    }
}


contract Accessibility {
    address private owner;

    event OwnerChanged(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "access denied");
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function changeOwner(address _newOwner) onlyOwner public {
        require(_newOwner != address(0));
        emit OwnerChanged(owner, _newOwner);
        owner = _newOwner;
    }
}


contract TicketsStorage is Accessibility {
    using SafeMath for uint;
    using Percent for Percent.percent;

    struct Ticket {
        address payable wallet;
        uint[] numbers;
        uint typeLottu;
    }

    enum TypeLottu {FOUR, FIVE, SIX, SEVEN, FOUR_TURBO, FIVE_TURBO, SIX_TURBO, SEVEN_TURBO}
    uint[] private range = [20, 36, 45, 60, 20, 36, 45, 60];
    uint[] private countNumberLottu = [4, 5, 6, 7, 4, 5, 6, 7];
    uint[] private countTwist = [0, 0, 0, 0, 0, 0, 0, 0];
    uint[] private countTransaction = [5, 4, 2, 2, 5, 4, 2, 2];

    uint public priceTicket = 0.02 ether;
    uint public priceTicketTurbo = 0.008 ether;

    uint private stepEntropy = 1;
    uint private precisionPay = 4;

    uint private entropyNumber = 121;
    uint private typeLottuDefineWinner = 0;

    mapping(uint => mapping(uint => uint)) private countTickets;
    // currentRound -> typeLottu -> number ticket

    mapping(uint => mapping(uint => mapping(uint => Ticket))) private tickets;
    // currentRound -> typeLottu -> number ticket -> Ticket

    mapping(uint => mapping(address => uint)) private balancePlayer;
    // currentRound -> wallet -> balance player

    mapping(uint => mapping(address => uint)) private balanceWinner;
    // currentRound -> wallet -> balance winner

    mapping(uint => mapping(uint => uint[])) private happyTickets;
    // currentRound -> typeLottu -> array happy tickets

    mapping(uint => mapping(uint => mapping(uint => uint[]))) private winTickets;
    // currentRound -> typeLottu -> typeWinner -> array winner tickets

    Percent.percent private percentTicketPrize_1 = Percent.percent(874, 1000);          // 87.4 %
    Percent.percent private percentTicketPrize_2 = Percent.percent(10, 100);            // 10.0 %
    Percent.percent private percentTicketPrize_3 = Percent.percent(26, 1000);           // 2.6 %

    event LogMakeDistribution(uint roundLottery, uint roundDistibution);
    event LogHappyTicket(uint round, uint typeLottu, uint[] happyTicket);
    event LogWinnerTicket(uint round, uint typeLottu, uint numberTicket, uint countNumbers);
    event LogTest(uint[] value_1, uint value_2);

    //    function isWinner(uint round, uint numberTicket) public view returns (bool) {
    //        return tickets[round][numberTicket].winnerRound > 0;
    //    }

    function getBalancePlayer(uint round, address wallet) public view returns (uint) {
        return balancePlayer[round][wallet];
    }

    function getBalanceWinner(uint round, address wallet) public view returns (uint) {
        return balanceWinner[round][wallet];
    }

    function addBalanceWinner(uint round, address wallet, uint prize) public returns (uint) {
        balanceWinner[round][wallet] = balanceWinner[round][wallet].add(prize);
    }

    function ticketInfo(uint round, uint typeLottu, uint numberTicket) public view returns
    (address payable wallet, uint[] memory drawNumbers, uint typeL) {
        Ticket memory ticket = tickets[round][typeLottu][numberTicket];
        wallet = ticket.wallet;
        drawNumbers = ticket.numbers;
        typeL = ticket.typeLottu;
    }

    function newTicket(uint round, address payable wallet, uint[] memory numbers, uint typeLottu) public onlyOwner {
        uint priceOfToken = priceTicket;
        if (typeLottu > 3) {
            priceOfToken = priceTicketTurbo;
        }
        countTickets[round][typeLottu]++;
        Ticket storage ticket = tickets[round][typeLottu][countTickets[round][typeLottu]];
        ticket.wallet = wallet;
        ticket.typeLottu = typeLottu;
        ticket.numbers = numbers;
        balancePlayer[round][wallet] = balancePlayer[round][wallet].add(priceOfToken);
    }

    function processCalcWinnerNumbersAllUser(uint round, uint typeLottu, uint currIndex) internal {
        uint cnt = countTickets[round][typeLottu];
        uint maxCount = cnt.add(1);
        if (cnt > 0) {
            if (currIndex.add(countTransaction[typeLottu]) < maxCount) {
                maxCount = currIndex.add(countTransaction[typeLottu]);
            }
            for (uint i = currIndex; i < maxCount; i++) {
                uint calc = calcCountWinnerNumbersOneUser(happyTickets[round][typeLottu], tickets[round][typeLottu][i].numbers);
                if (calc > 0) {
                    winTickets[round][typeLottu][calc].push(i);
                    emit LogWinnerTicket(round, typeLottu, i, calc);
                }
            }
        }
    }

    function calcCountWinnerNumbersOneUser(uint[] memory numbersHappy, uint[] memory numbersUser) internal pure returns (uint countWinnerNumbers) {
        uint lenHappy = numbersHappy.length;
        uint lenUser = numbersUser.length;
        countWinnerNumbers = 0;
        if (lenHappy > 0 && lenUser > 0 && lenHappy == lenUser) {
            for (uint i = 0; i < lenHappy; i++) {
                for (uint j = 0; j < lenUser; j++) {
                    if (numbersHappy[i] == numbersUser[j]) {
                        countWinnerNumbers++;
                    }
                }
            }
        }
    }

    function calcCostTicket(uint typeLottu, uint repeat) public view onlyOwner returns (uint cost) {
        if (typeLottu > 3) {
            cost = priceTicketTurbo;
        } else {
            cost = priceTicket;
        }
        cost = cost.mul(repeat);
    }

    function clearRound() public {
        if (entropyNumber > 300) {
            entropyNumber = 121;
        }
    }

    function defineWinner(uint round) public onlyOwner returns (bool isFinishDefineWinner){
        isFinishDefineWinner = false;
        if (countTwist[typeLottuDefineWinner] > 0) {
            if (defineWinnerByTypeLottu(round, typeLottuDefineWinner)) {
                typeLottuDefineWinner++;
                if (typeLottuDefineWinner == 8) {
                    isFinishDefineWinner = true;
                }
            }
        } else {
            typeLottuDefineWinner++;
            if (typeLottuDefineWinner == 8) {
                isFinishDefineWinner = true;
            }
        }
    }

    function defineWinnerByTypeLottu(uint round, uint typelottu) internal returns (bool) {
        if (countTwist[typelottu] > 0) {
            countTwist[typelottu] = countTwist[typelottu].sub(1);
            processCalcWinnerNumbersAllUser(round, typelottu, countTwist[typelottu].mul(countTransaction[typelottu]).add(1));
            return false;
        }
        return true;
    }

    function calcPrizeWinner(uint round, uint typeLottu) public view onlyOwner returns
    (
        uint prize_1,
        uint prize_2,
        uint prize_3,
        uint[] memory winNumberTickets_1,
        uint[] memory winNumberTickets_2,
        uint[] memory winNumberTickets_3
    ){
        uint amountPrize = 0;
        if (typeLottu < 4) {
            amountPrize = countTickets[round][typeLottu].mul(priceTicket);

            prize_1 = percentTicketPrize_1.mmul(amountPrize);
            uint countWinner_1 = winTickets[round][typeLottu][typeLottu.add(4)].length;
            if (countWinner_1 > 0) {
                prize_1 = roundEth(prize_1.div(countWinner_1), 4);
            } else {
                prize_1 = 0;
            }
            winNumberTickets_1 = winTickets[round][typeLottu][typeLottu.add(4)];

            prize_2 = percentTicketPrize_2.mmul(amountPrize);
            uint countWinner_2 = winTickets[round][typeLottu][typeLottu.add(3)].length;
            if (countWinner_2 > 0) {
                prize_2 = roundEth(prize_2.div(countWinner_2), 4);
            } else {
                prize_2 = 0;
            }
            winNumberTickets_2 = winTickets[round][typeLottu][typeLottu.add(3)];

            prize_3 = percentTicketPrize_3.mmul(amountPrize);
            uint countWinner_3 = winTickets[round][typeLottu][typeLottu.add(2)].length;
            if (countWinner_3 > 0) {
                prize_3 = roundEth(prize_3.div(countWinner_3), 4);
            } else {
                prize_3 = 0;
            }
            winNumberTickets_3 = winTickets[round][typeLottu][typeLottu.add(2)];
        } else {
            amountPrize = countTickets[round][typeLottu].mul(priceTicketTurbo);
            prize_1 = amountPrize;
            uint countWinner_1 = winTickets[round][typeLottu][typeLottu].length;
            uint countWinner_2 = winTickets[round][typeLottu][typeLottu.sub(1)].length;

            if (countWinner_1.add(countWinner_2) > 0) {
                prize_1 = roundEth(prize_1.div(countWinner_1.add(countWinner_2)), 4);
            } else {
                prize_1 = 0;
            }
            winNumberTickets_1 = winTickets[round][typeLottu][typeLottu];
            prize_2 = prize_1;
            winNumberTickets_2 = winTickets[round][typeLottu][typeLottu.sub(1)];

            prize_3 = 0;
        }
    }

    function getCountTickets(uint round, uint typeLottu) public view returns (uint) {
        return countTickets[round][typeLottu];
    }

    function defineCountTwist(uint round) public {
        // type 0 - 5 * 16 = 80
        // type 1 - 4 * 25 = 100
        // type 2 - 2 * 36 = 72
        // type 3 - 2 * 49 = 98
        for (uint typeLottu = 0; typeLottu < 8; typeLottu++) {
            countTwist[typeLottu] = countTwist[typeLottu].add(countTickets[round][typeLottu].div(countTransaction[typeLottu]));
            if ((countTickets[round][typeLottu] % countTransaction[typeLottu]) > 0) {
                countTwist[typeLottu] = countTwist[typeLottu].add(1);
            }
        }
        typeLottuDefineWinner = 0;
    }

    function getHappyTickets(uint round, uint typeLottu) public view returns (uint[] memory value) {
        value = happyTickets[round][typeLottu];
    }

    function getWinTickets(uint round, uint typeLottu, uint typeWin) public view returns (uint[] memory value) {
        value = winTickets[round][typeLottu][typeWin];
    }

    //    function addBalanceWinner(uint round, uint amountPrize, uint happyNumber) public onlyOwner {
    //        balanceWinner[round][tickets[round][happyNumber].wallet] = balanceWinner[round][tickets[round][happyNumber].wallet].add(amountPrize);
    //    }

    function makeAllHappyNumber(uint round) public onlyOwner {
        for (uint i = 0; i < 8; i++) {
            makeHappyNumber(round, i);
        }
    }

    function makeHappyNumber(uint round, uint typeLottu) internal {
        for (uint i = 0; i < countNumberLottu[typeLottu]; i++) {
            uint happyNumber = findHappyNumbers(round, typeLottu);
            happyTickets[round][typeLottu].push(happyNumber);
        }
        //for test's
        if (round == 3 && typeLottu == 2) {
            happyTickets[round][typeLottu] = [1, 3, 12, 19, 32, 42];
        }

        emit LogHappyTicket(round, typeLottu, happyTickets[round][typeLottu]);
    }

    function findHappyNumbers(uint round, uint typeLottu) public onlyOwner returns (uint) {
        uint happyNumber = getRandomNumber(range[typeLottu]);
        while (checkRepeatNumber(happyNumber, round, typeLottu) == true) {
            happyNumber++;
            if (happyNumber > range[typeLottu]) {
                happyNumber = 1;
            }
        }
        return happyNumber;
    }

    function checkRepeatNumber(uint happyNumber, uint round, uint typeLottu) internal view returns (bool isRepeat) {
        isRepeat = false;
        uint lenArray = happyTickets[round][typeLottu].length;
        if (lenArray > 0) {
            for (uint i = 0; i < lenArray; i++) {
                if (happyTickets[round][typeLottu][i] == happyNumber) {
                    isRepeat = true;
                }
            }
        }
    }

    function getRandomNumber(uint rangeNumber) internal returns (uint) {
        entropyNumber = entropyNumber.add(1);
        uint randomFirst = maxRandom(block.number, msg.sender).div(now);
        uint randomNumber = randomFirst.mul(entropyNumber) % (66);
        randomNumber = randomNumber % rangeNumber;
        return randomNumber + 1;
    }

    function maxRandom(uint blockn, address entropy) internal view returns (uint randomNumber) {
        return uint(keccak256(
                abi.encodePacked(
                    blockhash(blockn),
                    entropy)
            ));
    }

    function roundEth(uint numerator, uint precision) public pure returns (uint round) {
        if (precision > 0 && precision < 18) {
            uint256 _numerator = numerator / 10 ** (18 - precision - 1);
            _numerator = (_numerator) / 10;
            round = (_numerator) * 10 ** (18 - precision);
        }
    }


}

contract Lottu is Accessibility {
    using SafeMath for uint;

    using Address for *;
    using Zero for *;

    TicketsStorage private m_tickets;
    mapping(address => bool) private notUnigue;

    address payable public advertisingFundWallet;
    address payable public commissionsWallet;
    address payable public technicalWallet;
    address payable public supportWallet;
    address payable public maintenanceWallet;

    address payable public adminWallet;

    uint public transferTypeLottu;
    uint public countTransfer;

    bool public isTwist;
    bool public isTransferPrize;

    uint public constant PRICE_OF_TOKEN = 0.003 ether;

    uint public currentRound;
    uint public totalEthRaised;
    uint public totalTicketBuyed;

    uint public uniquePlayer;

    bool public isDemo;
    uint public simulateDate;

    // more events for easy read from blockchain
    event LogNewTicket(address indexed addr, uint when, uint round, uint[] numbers);
    event LogBalanceChanged(uint when, uint balance);
    event LogChangeTime(uint newDate, uint oldDate);
    event LogRefundEth(address indexed player, uint value);
    event LogWinnerDefine(uint roundLottery, uint typeWinner, uint step);
    event ChangeAddressWallet(address indexed owner, address indexed newAddress, address indexed oldAddress);
    event SendToAdministrationWallet(address indexed wallet, uint amount);
    event LogMsgData(bytes msgData, uint length);
    event TransferPrizeToWallet(address indexed wallet, uint round, uint typeLottu, uint prize);
    event MakeTransfer(uint round, uint typeLottu, uint prize_1, uint prize_2, uint prize_3,
        uint[] winTickets_1, uint[] winTickets_2, uint[] winTickets_3);
    event LogTesting(string data);
    event Paid(address indexed _from, uint _value);

    modifier balanceChanged {
        _;
        emit LogBalanceChanged(getCurrentDate(), address(this).balance);
    }

    modifier notFromContract() {
        require(msg.sender.isNotContract(), "only externally accounts");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == adminWallet, "access denied");
        _;
    }

    constructor() public {
        m_tickets = new TicketsStorage();
        adminWallet = msg.sender;
        currentRound = 1;
        m_tickets.clearRound();
    }

    function() external payable {
        if (msg.value >= PRICE_OF_TOKEN && msg.data.length > 6) {
            emit Paid(msg.sender, msg.value);
            emit LogMsgData(msg.data, msg.data.length);
            buyTicket(msg.sender, convertMsgData(msg.data));
        } else {
            refundEth(msg.sender, msg.value);
        }
    }

//    function convertMsgData(bytes memory data) internal pure returns (uint[] memory numbers) { //for test's
    function convertMsgData(bytes memory data) public pure returns (uint[] memory numbers) { //for test's
        if (data.length > 0) {
            uint[] memory newNumbers = new uint [](data.length);
            for (uint i = 0; i < newNumbers.length; i++) {
                newNumbers[i] = bytes1ToUInt(data[i]);
            }
            numbers = newNumbers;
        }
    }

    function getHappyTickets(uint round, uint typeLottu) public view returns (uint[] memory value) {
        value = m_tickets.getHappyTickets(round, typeLottu);
    }

    function getWinTickets(uint round, uint typeLottu, uint typeWin) public view returns (uint[] memory value) {
        value = m_tickets.getWinTickets(round, typeLottu, typeWin);
    }

    function getTicketInfo(uint round, uint typeLottu, uint index) public view returns
    (address payable wallet, uint[] memory drawNumbers, uint typeL) {
        (wallet, drawNumbers, typeL) = m_tickets.ticketInfo(round, typeLottu, index);
    }

    function balanceETH() external view returns (uint) {
        return address(this).balance;
    }

    function refundEth(address payable _player, uint _value) internal returns (bool) {
        require(_player.notZero());
        _player.transfer(_value);
        emit LogRefundEth(_player, _value);
    }

    function buyTicket(address payable _addressPlayer, uint[] memory msgData) public payable notFromContract balanceChanged {
        uint investment = msg.value;
        require(!isTwist, "Ticket purchase is prohibited during the twist");
        require(!isTransferPrize, "Ticket purchase is prohibited during the transfer prize");
        (uint typeLottu, uint repeat, uint[] memory numbers) = parseMsgData(msgData);
        require(repeat < 20, "Maximum number of draws exceeded");

        uint amountEth = m_tickets.calcCostTicket(typeLottu, repeat);
        require(investment >= amountEth, "Investment must be greater than the cost of tickets");

        if (investment > amountEth) {
            refundEth(msg.sender, investment.sub(amountEth));
        }

        for (uint i = 0; i < repeat.add(1); i++) {
            m_tickets.newTicket(currentRound.add(i), _addressPlayer, numbers, typeLottu);
            emit LogNewTicket(_addressPlayer, now, currentRound.add(i), numbers);
            totalTicketBuyed++;
        }


        if (!notUnigue[_addressPlayer]) {
            notUnigue[_addressPlayer] = true;
            uniquePlayer++;
        }
        totalEthRaised = totalEthRaised.add(amountEth);
    }

    function parseMsgData(uint[] memory msgData) internal pure returns (uint typeLottu, uint repeat, uint[] memory numbers) {
        typeLottu = msgData[0];
        repeat = msgData[1];
        numbers = new uint [](msgData.length - 2);
        for (uint i = 2; i < msgData.length; i++) {
            numbers[i - 2] = msgData[i];
        }
    }

    function makeTwists() public notFromContract onlyAdmin {
        if (!isTwist) {
            m_tickets.makeAllHappyNumber(currentRound);
            m_tickets.defineCountTwist(currentRound);
            isTwist = true;
        } else {
            if (m_tickets.defineWinner(currentRound)) {
                isTwist = false;
                isTransferPrize = true;
                transferTypeLottu = 0;
                countTransfer = 0;
                //sendToAdministration();
            }
        }
    }

    function transferPrize() public notFromContract onlyAdmin returns (bool) {
        if (isTransferPrize) {
            while (transferTypeLottu < 8) {
                makeTransferPrizeByTypeLottu(transferTypeLottu);
                transferTypeLottu++;
                if (countTransfer > 80) {
                    countTransfer = 0;
                    return false;
                }
            }
            if (transferTypeLottu > 7) {
                currentRound++;
                isTransferPrize = false;
                m_tickets.clearRound();
                return true;
            }
        }
    }

    function makeTransferPrizeByTypeLottu(uint typeLottu) internal returns (bool) {
        (
        uint prize_1,
        uint prize_2,
        uint prize_3,
        uint[] memory winNumberTickets_1,
        uint[] memory winNumberTickets_2,
        uint[] memory winNumberTickets_3
        ) = m_tickets.calcPrizeWinner(currentRound, typeLottu);
        emit MakeTransfer(currentRound, typeLottu, prize_1, prize_2, prize_3, winNumberTickets_1,  winNumberTickets_2, winNumberTickets_3);
        if (typeLottu < 4) {
            transferPrizeByTypeWinner(prize_1, winNumberTickets_1, typeLottu);
            transferPrizeByTypeWinner(prize_2, winNumberTickets_2, typeLottu);
            transferPrizeByTypeWinner(prize_3, winNumberTickets_3, typeLottu);
        } else {
            transferPrizeByTypeWinner(prize_1, winNumberTickets_1, typeLottu);
            transferPrizeByTypeWinner(prize_2, winNumberTickets_2, typeLottu);
        }
    }

    function transferPrizeByTypeWinner(uint prize, uint[] memory winNumberTickets, uint typeLottu) internal returns (bool) {
        if (prize > 0 && winNumberTickets.length > 0) {
            if (address(this).balance > prize.mul(winNumberTickets.length)) {
                for (uint i=0; i<winNumberTickets.length; i++) {
                    (address payable wallet,,) = m_tickets.ticketInfo(currentRound, typeLottu, winNumberTickets[i]);
                    countTransfer++;
                    addBalanceWinner(currentRound, wallet, prize);
                    wallet.transfer(prize);
                    emit TransferPrizeToWallet(wallet, currentRound, typeLottu, prize);
                }
                return true;
            } else {
                return false;
            }
        }
    }

    function getBalancePlayer(uint round, address wallet) external view returns (uint) {
        return m_tickets.getBalancePlayer(round, wallet);
    }

    function getBalanceWinner(uint round, address wallet) external view returns (uint) {
        return m_tickets.getBalanceWinner(round, wallet);
    }

    function addBalanceWinner(uint round, address wallet, uint prize) internal returns (uint) {
        return m_tickets.addBalanceWinner(round, wallet, prize);
    }

    function getCurrentDate() public view returns (uint) {
        if (isDemo) {
            return simulateDate;
        }
        return now;
    }

    function setSimulateDate(uint _newDate) external onlyOwner {
        if (isDemo) {
            require(_newDate > simulateDate);
            emit LogChangeTime(_newDate, simulateDate);
            simulateDate = _newDate;
        }
    }

    function setDemo() external onlyOwner {
        if (uniquePlayer == 0) {
            isDemo = true;
        }
    }

    function getCountTickets(uint round, uint typeLottu) public view returns (uint countTickets) {
        countTickets = m_tickets.getCountTickets(round, typeLottu);
    }

    function findHappyNumbers(uint round, uint typeLottu) public returns (uint numb) {
        numb = m_tickets.findHappyNumbers(round, typeLottu);
    }

    function setAdministrationWallet(address payable newWallet, uint index) external onlyOwner {
        require(newWallet != address(0) && index < 5);
        address payable oldWallet = address(0);
        if (index == 0) {
            oldWallet = advertisingFundWallet;
            advertisingFundWallet = newWallet;
        }
        if (index == 1) {
            oldWallet = commissionsWallet;
            commissionsWallet = newWallet;
        }
        if (index == 2) {
            oldWallet = technicalWallet;
            technicalWallet = newWallet;
        }
        if (index == 3) {
            oldWallet = supportWallet;
            supportWallet = newWallet;
        }
        if (index == 4) {
            oldWallet = maintenanceWallet;
            maintenanceWallet = newWallet;
        }
        if (index == 5) {
            oldWallet = adminWallet;
            adminWallet = newWallet;
        }
        emit ChangeAddressWallet(msg.sender, newWallet, oldWallet);
    }

    function sendToAdministration() internal {
        require(advertisingFundWallet != address(0), "advertising Fund wallet address is 0х0");
        require(commissionsWallet != address(0), "commissions wallet address is 0х0");
        require(technicalWallet != address(0), "technical wallet address is 0х0");
        require(supportWallet != address(0), "support wallet address is 0х0");
        require(maintenanceWallet != address(0), "maintenance wallet address is 0х0");

        uint amount = m_tickets.roundEth(address(this).balance.div(10), 4);
        if (amount > 0) {
            advertisingFundWallet.transfer(amount);
            emit SendToAdministrationWallet(advertisingFundWallet, amount);
            commissionsWallet.transfer(amount);
            emit SendToAdministrationWallet(commissionsWallet, amount);
            technicalWallet.transfer(amount);
            emit SendToAdministrationWallet(technicalWallet, amount);
            supportWallet.transfer(amount);
            emit SendToAdministrationWallet(supportWallet, amount);
            maintenanceWallet.transfer(amount);
            emit SendToAdministrationWallet(maintenanceWallet, amount);
        }
    }

    function bytes1ToUInt(bytes1 b) public pure returns (uint number){
        number = (uint(uint8(b) >> 4) & 0xF) * 10 + uint(uint8(b) & 0xF);
    }

}
