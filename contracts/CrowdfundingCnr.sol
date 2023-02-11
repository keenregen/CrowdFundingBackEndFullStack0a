// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

// error codes
error CrowdfundingCnr__NotDeployer();

contract CrowdfundingCnr {
    struct Campaign {
        address holder;
        string title;
        string description;
        uint256 targetAmount;
        uint256 deadline;
        uint256 collectedAmount;
        string image;
        address[] donators;
        uint256[] donations;
    }

    mapping (uint256 => Campaign) public s_campaigns;

    uint256 public s_numOfCampaigns = 0;


    address private immutable i_deployer;

    // modifiers

    modifier onlyDeployer {
        // require(msg.sender == i_deployer, "Sender must be contract deployer.");
        // gas efficient way for errors
        if (msg.sender != i_deployer) revert CrowdfundingCnr__NotDeployer();
        _;
    }

    // Functions (const, rec, fallback, external, public, internal, private, view/pure)

    // called when the contract is deployed
     constructor() {
          i_deployer = msg.sender;
     }


    function  initNewCampaign(
    address _holder,
    string memory _title, 
    string memory _description, 
    uint256 _targetAmount, 
    uint256 _deadline,
    string memory _image
    ) public onlyDeployer returns (uint256)  {
        Campaign storage campaign = s_campaigns[s_numOfCampaigns];

        require(campaign.deadline < block.timestamp, "The deadline should be a date in the future.");

        campaign.holder = _holder;
        campaign.title = _title;
        campaign.description = _description;
        campaign.targetAmount = _targetAmount;
        campaign.deadline = _deadline;
        campaign.collectedAmount = 0;
        campaign.image = _image;

        s_numOfCampaigns++;

        return s_numOfCampaigns - 1;
        
    }

    function donateToCampaign(uint256 _id) public payable {
        // control the repo if not done

        s_campaigns[_id].donators.push(msg.sender);

        s_campaigns[_id].donations.push(msg.value);

        (bool sent,) = payable(s_campaigns[_id].holder).call{value: msg.value}("");

        if (sent) {
            s_campaigns[_id].collectedAmount = s_campaigns[_id].collectedAmount + msg.value;
        }
    }

    function getDonators(uint256 _id) public view returns (address[] memory, uint256[] memory){

        return (s_campaigns[_id].donators, s_campaigns[_id].donations);
    }

    function getCampaigns() public view returns (Campaign[] memory) {
        Campaign[] memory allCampaigns = new Campaign[](s_numOfCampaigns);

        for (uint i = 0; i < s_numOfCampaigns; i++) {

            allCampaigns[i] = s_campaigns[i];

        }

        return allCampaigns; 
    }
}