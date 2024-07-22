/**
 *Submitted for verification at testnet.bscscan.com on 2023-06-06
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Sweepstake {
    address owner; // address of owner
    string name; // name of sweepstake
    uint256 public stakeCount = 1;

    struct StakeStruct {
        string name;
        uint256 prize;
        address winner;
        address[] participants;
        uint256 startDate;
        uint256 endDate;
        bool isCompleted;
    }
    mapping(uint256 => StakeStruct) public stakeDetails; // winner selected
    State state; // state of the contract

    // three states of the contract, open to enter, winner is selected, prize is claimed
    enum State {
        Opened,
        Selected,
        Claimed
    }

    /// @notice log sweepstake state Opened
    /// @param _name name of sweepstake
    event LogOpened(string _name);

    /// @notice log sweepstake state Selected
    /// @param _winner player was selected to be the winner
    event LogSelected(address _winner);

    /// @notice log sweepstake state Claimed
    /// @param _winner winner that claimed the prize
    event LogClaimed(address _winner);

    /// @notice log caller entered into sweepstake
    /// @param _player player entered into sweepstake
    event LogEntered(address _player);

    /// @notice log random number selected
    /// @param _number random number selected
    event LogRandomNumber(uint _number);

    /// @notice constructor creates a new sweepstake
    /// @param _name name of the sweepstake
    /// @param _owner the caller the constructor
    /// @dev emit LogOpened event
    constructor(string memory _name, address _owner) {
        owner = _owner;
        name = _name;
    }

    /// @notice accept funds
    // function() external payable {}

    /// @notice modifier to check if caller is owner
    modifier isOwner() {
        require(msg.sender == owner, 'Caller is not owner');
        _;
    }

    /// @notice modifier to check if caller is not owner
    modifier isNotOwner() {
        require(msg.sender != owner, 'Caller is owner');
        _;
    }

    /// @notice modifier to check if sweepstake is opened to enter

    /// @notice modifier to check if caller is winner
    modifier isWinner(uint256 _index) {
        require(
            msg.sender == stakeDetails[_index].winner,
            'Caller is not the winner'
        );
        _;
    }

    /// @notice modifier check if sweepstake has players entered
    modifier hasPlayers(uint256 _index) {
        require(
            stakeDetails[_index].participants.length > 0,
            "There's no player in this sweepstake"
        );
        _;
    }

    function createSweepStake(
        string memory _name,
        uint256 _prize,
        uint256 _startDate,
        uint256 _endDate
    ) public payable {
        require(_prize >= msg.value, 'prize can not be zero');
        require(_startDate > block.timestamp, 'start time incorrect');
        require(_endDate > _startDate, 'end time incorrect');
        stakeDetails[stakeCount] = StakeStruct({
            name: _name,
            prize: _prize,
            winner: address(0),
            participants: new address[](0),
            startDate: _startDate,
            endDate: _endDate,
            isCompleted: false
        });
        stakeCount++;
    }

    function sendPrizeBackToCreator(uint256 _index) public isOwner {
        require(
            stakeDetails[_index].endDate <= block.timestamp,
            "didn't reasched end time"
        );
        payable(owner).transfer(stakeDetails[_index].prize);
    }

    /// @notice function to enter sweepstake
    /// @dev emit LogEntered event
    function enterSweepstake(uint256 _index) public isNotOwner {
        stakeDetails[_index].participants.push(msg.sender);
        emit LogEntered(msg.sender);
    }

    /// @notice funnction to select a winner among players randomly
    /// @dev emit LogSelected event
    /// @dev emit LogRandomNumber event
    function selectWinner(uint256 _index) public isOwner hasPlayers(_index) {
        // random number selected based string encoded using time, caller address and block difficulty
        require(
            stakeDetails[_index].endDate <= block.timestamp,
            "didn't reasched end time"
        );
        require(!stakeDetails[_index].isCompleted, 'sweep stake completed');
        uint randomNumber = uint(
            keccak256(
                abi.encodePacked(block.timestamp, msg.sender, block.difficulty)
            )
        ) % stakeDetails[_index].participants.length;

        stakeDetails[_index].winner = stakeDetails[_index].participants[
            randomNumber
        ];

        emit LogSelected(stakeDetails[_index].winner);
        emit LogRandomNumber(randomNumber);
    }

    /// @notice function returns owner of the sweepstake
    /// @return sweepstake owner address
    function getOwner() public view returns (address) {
        return owner;
    }

    /// @notice function returns winner of the sweepstake
    /// @return winner address
    function getWinner(uint256 _index) public view returns (address) {
        return stakeDetails[_index].winner;
    }

    /// @notice function returns a list of players that entered the sweepstake
    /// @return an array of addresses of players
    function getPlayers(uint256 _index) public view returns (address[] memory) {
        return stakeDetails[_index].participants;
    }

    /// @notice function allows winner to claim prize of sweepstake
    /// @dev emit LogClaimed event
    function claimPrize(uint256 _index) public payable isWinner(_index) {
        require(!stakeDetails[_index].isCompleted, 'sweepStake is claimed');
        payable(msg.sender).transfer(stakeDetails[_index].prize);
        stakeDetails[_index].isCompleted = true;
        emit LogClaimed(msg.sender);
    }

    /// @notice function returns balance of sweepstake
    /// @return balance of sweepstake
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
