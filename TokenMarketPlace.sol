// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol"; 

contract TokenMarketPlace is Ownable {

using SafeERC20 for IERC20;
using SafeMath for uint256;

uint256 public tokenPrice = 2e16 wei; // 0.02 ether per GLD token//2*10^!6
uint256 public sellerCount = 1;
uint256 public buyerCount=1;
uint public prevAdjustedRatio;

IERC20 public gldToken;

event TokenPriceUpdated(uint256 newPrice);
event TokenBought(address indexed buyer, uint256 amount, uint256 totalCost);
event TokenSold(address indexed seller, uint256 amount, uint256 totalEarned);
event TokensWithdrawn(address indexed owner, uint256 amount);
event EtherWithdrawn(address indexed owner, uint256 amount);
event CalculateTokenPrice(uint256 priceToPay);

constructor(address _gldtoken) Ownable(msg.sender) {
    gldToken=IERC20(_gldtoken);
}


function adjustTokenPriceBasedOnDemand() public {
   uint marketDemandRatio = buyerCount.mul(1e18).div(sellerCount); 
   uint smoothingFactor = 1e18;
   uint adjustedRatio = marketDemandRatio.add(smoothingFactor).div(2);
   if(prevAdjustedRatio!=adjustedRatio){
   uint newTokenPrice =  tokenPrice.mul(adjustedRatio).div(1e18);
   uint minimumPrice = 2e16;
   if(newTokenPrice<minimumPrice){
     tokenPrice = minimumPrice;
   }
   tokenPrice = newTokenPrice;
   }
}

// Buy tokens from the marketplace
function buyGLDToken(uint256 _amountOfToken) public payable {
   require(_amountOfToken>0,"Amount of Tokens should be greater than 0");
   uint PayToAmount=calculateTokenPrice(_amountOfToken);
   console.log("amount to pay : ",PayToAmount);
   require(PayToAmount==msg.value,"Invalid amount paid!");

   buyerCount++;
       
   gldToken.safeTransfer(msg.sender,_amountOfToken);

   emit TokenBought(msg.sender,_amountOfToken,PayToAmount);
}

function calculateTokenPrice(uint _amountOfToken) public returns(uint){
    require(_amountOfToken>0,"Amount of Token should be greater than 0");
    adjustTokenPriceBasedOnDemand();
    uint AmountToPay=tokenPrice.mul(_amountOfToken).div(1e18);
    console.log("amount to pay : ",AmountToPay);

    return AmountToPay;
   
}
// Sell tokens back to the marketplace
function sellGLDToken(uint256 amountOfToken) public {

    require(gldToken.balanceOf(msg.sender)>=amountOfToken,"Invalid amount of token");

    uint PriceToPay = calculateTokenPrice(amountOfToken);
    
    gldToken.safeTransferFrom(msg.sender,address(this),amountOfToken);
    (bool reciept,)=payable(msg.sender).call{value:PriceToPay}("");  
    require(reciept,"Transaction failed");
    console.log("Amount recieved :",PriceToPay);
    sellerCount++;
    emit TokenSold(msg.sender,amountOfToken,PriceToPay);
}





// Owner can withdraw excess tokens from the contract
function withdrawTokens(uint256 amount) public onlyOwner {
   require(gldToken.balanceOf(address(this))>=amount,"Out of balance");
   gldToken.safeTransfer(msg.sender,amount);
 emit TokensWithdrawn(msg.sender,amount);

}

// Owner can withdraw accumulated Ether from the contract
function withdrawEther(uint256 amount) public payable onlyOwner {
   require(address(this).balance>=amount,"Out of balance");
   (bool success,)= payable(msg.sender).call{value:amount}("");
   require(success,"Transaction failed!");
   emit EtherWithdrawn(msg.sender,amount);
}
}
