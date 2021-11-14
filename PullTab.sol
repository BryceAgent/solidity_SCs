// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "https://raw.githubusercontent.com/smartcontractkit/chainlink/master/contracts/src/v0.6/VRFConsumerBase.sol";

contract PullTab is VRFConsumerBase {
    // VRF variables
    bytes32 keyHash;
    uint256 fee;
    uint256 randomResult;
    // Lottery variables
    uint256 odds;
    uint256 score;
    address payable house;  // my wallet - change to contract address and add withdraw function?
    address payable bettor;
    event Received(address bettor, uint256 bet);
    event Conclusion(string result);
    
    string public message = "Price is .00001 eth for 1 ticket, max payout .003";
    
    modifier onlyVRFC() {
        require(msg.sender == 0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B);
        _;
    }
    
    function play() public payable {
        require(msg.value == .00001 * 10 ** 18, "Price is .00001 eth for 1 ticket");
        bettor = payable(msg.sender);
        emit Received(msg.sender, msg.value);
        getRandom();
    }
    
    // get random result
    constructor() VRFConsumerBase(0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B, // Rinkeby VRF coordinator
    0x01BE23585060835E02B77ef475b0Cc51aA1e0709 // LINK token Rinkeby
    ) public {
        keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
        fee = 	0.1 * 10 ** 18 ; // Rinkeby LINK
        house = payable(msg.sender);
    }
    
    function getRandom() internal returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee);
    }
    
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = randomness;
        outcome(randomResult);
    }
    
    // get outcome and send eth to appropriate account
    function outcome(uint256 _random) internal onlyVRFC {
        odds = 6389;
        score = _random % odds;
        if(score > 1453){
            // house.transfer(.00001 * 10 ** 18); // replace with withdraw function for sum payout?
            emit Conclusion("You lose!");
        }
        if((score >= 79) && (score < 1454)){
            bettor.transfer(.00001 * 10 ** 18);
            emit Conclusion("You win!");
        }
        if((score >= 49) && (score < 79)){
            bettor.transfer(.00002 * 10 ** 18);
            emit Conclusion("You win!");
        }
        if((score >= 37) && (score < 49)){
            bettor.transfer(.00004 * 10 ** 18);
            emit Conclusion("You win!");
        }
        if((score >= 17) && (score <37)){
            bettor.transfer(.00025 * 10 ** 18);
            emit Conclusion("You win!");
        }
        if((score >= 11) && (score < 17)){
            bettor.transfer(.0005 * 10 ** 18);
            emit Conclusion("You win!");
        }
        if((score >= 9) && (score < 11)){
            bettor.transfer(.001 * 10 ** 18);
            emit Conclusion("You win!");
        }
        if(score < 9){
            bettor.transfer(.003 * 10 ** 18);
            emit Conclusion("You win!");
        }
        
    }
    
    function withdraw(uint256 _amount) public {
        require(msg.sender == house);
        require(_amount <= address(this).balance);
        house.transfer(_amount);
    }
    
}
