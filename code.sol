// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.7;

import "./Donor.sol";

struct Charity{
        uint256 id;
        int256 votes;
        address[] donators;
        address[] voters;
        uint256 requiredAmount;
        uint256 collectedAmount;
        string charityName;
        string description;
        address payable charityAddress;
        uint256 dueDate;
        bool isOpen;
}

contract Recieve{
    uint256 public charityCount = 0;
    Charity[] public charityList;

    function updateCharity(uint256 i) internal {
        if (charityList[i].requiredAmount - charityList[i].collectedAmount == 0 ||
            charityList[i].dueDate < block.timestamp ||
             charityList[i].votes < -100) {
                charityList[i].isOpen = false;

            }
    }

    function closeAllExpired() 
    public 
    {
        for(uint256 i=0;i<charityCount;++i) {
            updateCharity(i);
        }
    }
    
    //oracle goes brrrrrr
    function verify(Charity memory _charity) internal pure returns(bool){
        if(_charity.votes>=0 && _charity.requiredAmount>0)
         return true;
        else 
         return false;
    }

    function addCharity(string memory _charity,string memory _description,uint256 _amount,address payable _address,uint256 _dueDate) 
    public 
    {
        address[] memory tempDonors;
        address[] memory tempAddresses;
        Charity memory _temp = Charity(charityCount,0,tempDonors,tempAddresses,_amount,0,_charity,_description,_address,_dueDate,true);
        bool flag = verify(_temp);
        require(flag);
         charityList.push (_temp);
         charityCount++;
        
    }

    function removeCharity(uint256 _id)
    public
    {
        charityList[_id].isOpen = false;
    }

    function numberOfOpenChairites() public view returns(uint256) {
      uint256 count=0;
      for(uint256 i=0;i<charityCount;++i) {
            if (charityList[i].isOpen) {
                ++count;
            }
        }
        return count;
    }

    function vote(Donator memory donator) public {
        
    }

  function contributeToCharity(uint charityIndex) public payable {
    require(charityList[charityIndex].isOpen);
    require((charityList[charityIndex].requiredAmount - charityList[charityIndex].collectedAmount) - msg.value >= 0);

    charityList[charityIndex].collectedAmount += msg.value;
    charityList[charityIndex].charityAddress.transfer(msg.value);
    charityList[charityIndex].votes++;
    updateCharity(charityIndex);


    charityList[charityIndex].donators.push(msg.sender);
  }

}
