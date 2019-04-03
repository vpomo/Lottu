pragma solidity >0.4.99 <0.6.0;

contract Parameters {

    uint public constant PRICE_OF_TOKEN = 0.003 ether;
    uint public constant MAX_TOKENS_BUY = 80;
    uint public constant MIN_TICKETS_BUY_FOR_ROUND = 80;

    uint public maxNumberStepCircle = 40;

    uint public currentRound;
    uint public totalEthRaised;
    uint public totalTicketBuyed;

    uint public uniquePlayer;

    uint public numberCurrentTwist;

    bool public isTwist;

    bool public isDemo;
    uint public simulateDate;

}

library Zero {
    function requireNotZero(address addr) internal pure {
        require(addr != address(0), "require not zero address");
    }

    function requireNotZero(uint val) internal pure {
        require(val != 0, "require not zero value");
    }

    function notZero(address addr) internal pure returns(bool) {
        return !(addr == address(0));
    }

    function isZero(address addr) internal pure returns(bool) {
        return addr == address(0);
    }

    function isZero(uint a) internal pure returns(bool) {
        return a == 0;
    }

    function notZero(uint a) internal pure returns(bool) {
        return a != 0;
    }
}

library Address {
    function toAddress(bytes memory source) internal pure returns(address addr) {
        assembly { addr := mload(add(source,0x14)) }
        return addr;
    }

    function isNotContract(address addr) internal view returns(bool) {
        uint length;
        assembly { length := extcodesize(addr) }
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
        require(_b > 0); // Solidity only automatically asserts when dividing by 0
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
        return a*p.num/p.den;
    }

    function div(percent storage p, uint a) internal view returns (uint) {
        return a/p.num*p.den;
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
        return a*p.num/p.den;
    }

    function mdiv(percent memory p, uint a) internal pure returns (uint) {
        return a/p.num*p.den;
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


contract TicketsStorage is Accessibility, Parameters  {
    using SafeMath for uint;
    using Percent for Percent.percent;

    struct Ticket {
        address payable wallet;
        uint[] numbers;
        uint typeLottu;
    }

    uint public constant TYPE_4X20 = 4;
    uint public constant TYPE_4X20_TURBO = 4;
    uint public constant TYPE_5X36 = 5;
    uint public constant TYPE_5X36_TURBO = 4;
    uint public constant TYPE_6X45 = 6;

    enum TypeLottu {FOUR, FIVE, SIX, SEVEN, FOUR_TURBO, FIVE_TURBO, SIX_TURBO, SEVEN_TURBO}
    uint[] private range = [20, 36, 45, 60, 20, 36, 45, 60];
    uint[] private countNumberLottu = [4, 5, 6, 7, 4, 5, 6, 7];

    uint public priceTicket = 0.02 ether;
    uint public priceTicketTurbo = 0.008 ether;

    uint public constant TYPE_7X60 = 7;

    uint private stepEntropy = 1;
    uint private precisionPay = 4;

    uint private remainStepTS;
    uint private countStepTS;

    uint private entropyNumber = 121;

    mapping (uint => mapping (uint => uint)) private countTickets;
    // currentRound -> typeLottu -> number ticket

    mapping (uint => mapping (uint => mapping (uint => Ticket))) private tickets;
    // currentRound -> typeLottu -> number ticket -> Ticket

    mapping (uint => mapping (address => uint)) private balancePlayer;
    // currentRound -> wallet -> balance player

    mapping (uint => mapping (address => uint)) private balanceWinner;
    // currentRound -> wallet -> balance winner

    mapping (uint => mapping (uint => uint[])) private happyTickets;
    // currentRound -> typeLottu -> array happy tickets

    Percent.percent private percentTicketPrize_2 = Percent.percent(1,100);            // 1.0 %
    Percent.percent private percentTicketPrize_3 = Percent.percent(4,100);            // 4.0 %
    Percent.percent private percentTicketPrize_4 = Percent.percent(10,100);            // 10.0 %
    Percent.percent private percentTicketPrize_5 = Percent.percent(35,100);            // 35.0 %

    Percent.percent private percentAmountPrize_1 = Percent.percent(1797,10000);            // 17.97%
    Percent.percent private percentAmountPrize_2 = Percent.percent(1000,10000);            // 10.00%
    Percent.percent private percentAmountPrize_3 = Percent.percent(1201,10000);            // 12.01%
    Percent.percent private percentAmountPrize_4 = Percent.percent(2000,10000);            // 20.00%
    Percent.percent private percentAmountPrize_5 = Percent.percent(3502,10000);            // 35.02%


    event LogMakeDistribution(uint roundLottery, uint roundDistibution);
    event LogHappyTicket(uint round, uint typeLottu, uint[] happyTicket);

//    function isWinner(uint round, uint numberTicket) public view returns (bool) {
//        return tickets[round][numberTicket].winnerRound > 0;
//    }

    function getBalancePlayer(uint round, address wallet) public view returns (uint) {
        return balancePlayer[round][wallet];
    }

//    function getBalanceWinner(uint round, address wallet) public view returns (uint) {
//        return balanceWinner[round][wallet];
//    }

    function ticketInfo(uint round, uint typeLottu, uint numberTicket) public view returns(address payable wallet) {
        Ticket memory ticket = tickets[round][typeLottu][numberTicket];
        wallet = ticket.wallet;
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

    function calcCostTicket(uint typeLottu, uint repeat) public view onlyOwner returns (uint cost) {
        if (typeLottu > 3) {
            cost = priceTicketTurbo;
        } else {
            cost = priceTicket;
        }
        cost = cost.mul(repeat);
    }

    function clearRound(uint round) public {
        entropyNumber = 121;
    }

    function makeDistribution(uint round, uint typelottu, uint priceOfToken) public onlyOwner {
        uint count = countTickets[round][TYPE_4X20];
        uint amountEthCurrentRound = count.mul(priceOfToken);

        if (happyTickets[round][typelottu].length > 0) {
            delete happyTickets[round][typelottu];
        }
    }

    function getCountTickets(uint round, uint typeLottu) public view returns (uint) {
        return countTickets[round][typeLottu];
    }

    function getCountTwist(uint countsTickets, uint maxCountTicketByStep) public returns(uint countTwist) {
        countTwist = countsTickets.div(2).div(maxCountTicketByStep);
        if (countsTickets > countTwist.mul(2).mul(maxCountTicketByStep)) {
            remainStepTS = countsTickets.sub(countTwist.mul(2).mul(maxCountTicketByStep));
            countTwist++;
        }
        countStepTS = countTwist;

    }

    function getHappyTickets(uint round, uint typeLottu) public view returns (uint[] memory value) {
        value =  happyTickets[round][typeLottu];
    }

    function getStepTransfer() public view returns (uint stepTransfer, uint remainTicket) {
        stepTransfer = countStepTS;
        remainTicket = remainStepTS;
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
        emit LogHappyTicket(round, typeLottu, happyTickets[round][typeLottu]);
    }

    function findHappyNumbers(uint round, uint typeLottu) public onlyOwner returns(uint) {
        uint happyNumber = getRandomNumber(range[typeLottu]);
        uint numberMember = 0;
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

    function getRandomNumber(uint range) internal returns(uint) {
        entropyNumber = entropyNumber.add(1);
        uint randomFirst = maxRandom(block.number, msg.sender).div(now);
        uint randomNumber = randomFirst.mul(entropyNumber) % (66);
        randomNumber = randomNumber % range;
        return randomNumber + 1;
    }

    function maxRandom(uint blockn, address entropy) internal view returns (uint randomNumber) {
        return uint(keccak256(
                abi.encodePacked(
                    blockhash(blockn),
                    entropy)
            ));
    }

    function roundEth(uint numerator, uint precision) internal pure returns(uint round) {
        if (precision > 0 && precision < 18) {
            uint256 _numerator = numerator / 10 ** (18 - precision - 1);
            _numerator = (_numerator) / 10;
            round = (_numerator) * 10 ** (18 - precision);
        }
    }


}

contract Lottu is Accessibility, Parameters {
    using SafeMath for uint;

    using Address for *;
    using Zero for *;

    TicketsStorage private m_tickets;
    Parameters private m_parameters;
    mapping (address => bool) private notUnigue;

    uint public constant TYPE_4X20 = 4;
    uint public constant TYPE_5X36 = 5;
    uint public constant TYPE_6X45 = 6;
    uint public constant TYPE_7X60 = 7;

    address payable public administrationWallet;

    uint private remainStep;
    uint private countStep;

    // more events for easy read from blockchain
    event LogNewTicket(address indexed addr, uint when, uint round, uint[] numbers);
    event LogBalanceChanged(uint when, uint balance);
    event LogChangeTime(uint newDate, uint oldDate);
    event LogRefundEth(address indexed player, uint value);
    event LogWinnerDefine(uint roundLottery, uint typeWinner, uint step);
    event ChangeAddressWallet(address indexed owner, address indexed newAddress, address indexed oldAddress);
    event SendToAdministrationWallet(uint balanceContract);
    event Play(uint currentRound, uint numberCurrentTwist);
    event LogMsgData(bytes msgData);
    event LogTesting(uint[] data);

    modifier balanceChanged {
        _;
        emit LogBalanceChanged(getCurrentDate(), address(this).balance);
    }

    modifier notFromContract() {
        require(msg.sender.isNotContract(), "only externally accounts");
        _;
    }

    constructor(address payable _administrationWallet) public {
        require(_administrationWallet != address(0));
        administrationWallet = _administrationWallet;
        m_tickets = new TicketsStorage();
        m_parameters = new Parameters();
        currentRound = 1;
        m_tickets.clearRound(currentRound);
    }

    function() external payable {
        if (msg.value >= PRICE_OF_TOKEN) {
            emit LogMsgData(msg.data);
            //uint[] storage arrMsgData = [0, 2,12,24,32,36];
            //buyTicket(msg.sender, arrMsgData);
        } else if (msg.value.isZero()) {
            makeTwists();
        } else {
            refundEth(msg.sender, msg.value);
        }
    }

    function getHappyTickets(uint round, uint typeLottu) public view returns (uint[] memory value) {
        value =  m_tickets.getHappyTickets(round, typeLottu);
    }

    function getTicketInfo(uint round, uint typeLottu, uint index) public view returns (address payable wallet) {
        (wallet) =  m_tickets.ticketInfo(round, typeLottu, index);
    }

    function getStepTransfer() public view returns (uint stepTransferVal, uint remainTicketVal) {
        (stepTransferVal, remainTicketVal) = m_tickets.getStepTransfer();
    }

    function loadCountStep() internal {
        (countStep, remainStep) = m_tickets.getStepTransfer();
    }

    function balanceETH() external view returns(uint) {
        return address(this).balance;
    }

    function refundEth(address payable _player, uint _value) internal returns (bool) {
        require(_player.notZero());
        _player.transfer(_value);
        emit LogRefundEth(_player, _value);
    }

    function buyTicket(address payable _addressPlayer, uint[] memory msgData) public payable notFromContract balanceChanged {
        uint investment =  msg.value;
        require(!isTwist, "Ticket purchase is prohibited during the twist");
        (uint typeLottu, uint repeat, uint[] memory numbers) = parseMsgData(msgData);
        require(repeat < 20, "Maximum number of draws exceeded");

        emit LogTesting(numbers);
        uint amountEth = m_tickets.calcCostTicket(typeLottu, repeat);
        require(investment >= amountEth, "Investment must be greater than the cost of tickets");

        if (investment > amountEth) {
            refundEth(msg.sender, investment.sub(amountEth));
        }

        for (uint i=0; i < repeat.add(1); i++) {
            m_tickets.newTicket(currentRound.add(i), _addressPlayer, numbers, typeLottu);
            emit LogNewTicket(_addressPlayer, now, currentRound.add(i), numbers);
        }

        totalTicketBuyed++;

        if (!notUnigue[_addressPlayer]) {
            notUnigue[_addressPlayer] = true;
            uniquePlayer++;
        }
        totalEthRaised = totalEthRaised.add(amountEth);
    }

    function parseMsgData(uint[] memory msgData) internal pure returns (uint typeLottu, uint repeat, uint[] memory numbers) {
        typeLottu = msgData[0];
        repeat = msgData[1];
        numbers = new uint [](msgData.length-2);
        for (uint i = 2; i < msgData.length; i++) {
            numbers[i-2] = msgData[i];
        }
    }

    function getDigitFromByte(byte input) private pure returns(uint digit) {
        byte val = input & 0x0f;
        if (val == 0x00) {
            digit = 0;
        } else if (val == 0x01) {
            digit = 1;
        } else if (val == 0x02) {
            digit = 2;
        } else if (val == 0x03) {
            digit = 3;
        } else if (val == 0x04) {
            digit = 4;
        } else if (val == 0x05) {
            digit = 5;
        } else if (val == 0x06) {
            digit = 6;
        } else if (val == 0x07) {
            digit = 7;
        } else if (val == 0x08) {
            digit = 8;
        } else if (val == 0x09) {
            digit = 9;
        } else if (val == 0x0a) {
            digit = 10;
        } else if (val == 0x0b) {
            digit = 11;
        } else if (val == 0x0c) {
            digit = 12;
        } else if (val == 0x0d) {
            digit = 13;
        } else if (val == 0x0e) {
            digit = 14;
        } else if (val == 0x0f) {
            digit = 15;
        }
    }

    function makeTwists() public notFromContract {
        m_tickets.makeAllHappyNumber(currentRound);

        uint countTickets = m_tickets.getCountTickets(currentRound, TYPE_4X20);
        require(countTickets > MIN_TICKETS_BUY_FOR_ROUND, "the number of tickets purchased must be >= MIN_TICKETS_BUY_FOR_ROUND");
        if (!isTwist) {
            numberCurrentTwist = m_tickets.getCountTwist(countTickets, maxNumberStepCircle);
            m_tickets.makeDistribution(currentRound, TYPE_4X20, PRICE_OF_TOKEN);
            isTwist = true;
            loadCountStep();
        } else {
            if (numberCurrentTwist > 0) {
                play(currentRound, maxNumberStepCircle);
                emit Play(currentRound, numberCurrentTwist);
                numberCurrentTwist--;
                if (numberCurrentTwist == 0) {
                    isTwist = false;
                    currentRound++;
                    m_tickets.clearRound(currentRound);
                    sendToAdministration();
                }
            }
        }
    }

    function play(uint round, uint maxCountTicketByStep) internal {
        uint countTransfer = 0;
        uint numberTransfer = 0;
        if (remainStep > 0) {
            if (countStep > 1) {
                countTransfer = maxCountTicketByStep;
            } else {
                countTransfer = remainStep;
            }
        } else {
            countTransfer = maxCountTicketByStep;
        }

        if (countStep > 0) {
            countStep--;
        }
    }

    function transferPrize(uint amountPrize, uint round, uint typeLottu) internal returns(bool) {
        if (address(this).balance > amountPrize) {
            uint happyNumber = m_tickets.findHappyNumbers(round, typeLottu);
//            m_tickets.addBalanceWinner(currentRound, amountPrize, happyNumber);
            (address payable wallet) =  m_tickets.ticketInfo(round, typeLottu, happyNumber);
            wallet.transfer(amountPrize);
            return true;
        } else {
            return false;
        }
    }

    function setMaxNumberStepCircle(uint256 _number) external onlyOwner {
        require(_number > 0);
        maxNumberStepCircle = _number;
    }

    function getBalancePlayer(uint round, address wallet) external view returns (uint) {
        return m_tickets.getBalancePlayer(round, wallet);
    }

//    function getBalanceWinner(uint round, address wallet) external view returns (uint) {
//        return m_tickets.getBalanceWinner(round, wallet);
//    }

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

    function setAdministrationWallet(address payable _newWallet) external onlyOwner {
        require(_newWallet != address(0));
        address payable _oldWallet = administrationWallet;
        administrationWallet = _newWallet;
        emit ChangeAddressWallet(msg.sender, _newWallet, _oldWallet);
    }

    function sendToAdministration() internal {
        require(administrationWallet != address(0), "wallet address is not 0");
        uint amount = address(this).balance;

        if (amount > 0) {
            if (administrationWallet.send(amount)) {
                emit SendToAdministrationWallet(amount);
            }
        }
    }

}
