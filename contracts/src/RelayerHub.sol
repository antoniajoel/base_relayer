// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title RelayerHub
 * @notice Manages sponsors, tracks usage, and enforces limits
 */
contract RelayerHub is Ownable {
    struct Sponsor {
        address sponsor;
        uint256 dailyLimit;
        uint256 dailyUsed;
        uint256 lastReset;
        bool active;
    }

    struct Usage {
        address user;
        uint256 count;
        uint256 lastReset;
    }

    mapping(address => Sponsor) public sponsors;
    mapping(address => Usage) public userUsage;
    mapping(address => bool) public allowlistedContracts;

    uint256 public defaultDailyLimit = 100;
    uint256 public userDailyLimit = 10;
    uint256 public constant DAY = 86400;

    event SponsorAdded(address indexed sponsor, uint256 dailyLimit);
    event SponsorRemoved(address indexed sponsor);
    event SponsorLimitUpdated(address indexed sponsor, uint256 newLimit);
    event ContractAllowlisted(address indexed contractAddress);
    event ContractRemoved(address indexed contractAddress);
    event TransactionRelayed(address indexed user, address indexed sponsor, uint256 gasUsed);

    constructor() Ownable(msg.sender) {}

    /**
     * @notice Add a sponsor
     * @param sponsor The sponsor address
     * @param dailyLimit Daily transaction limit for this sponsor
     */
    function addSponsor(address sponsor, uint256 dailyLimit) external onlyOwner {
        require(sponsor != address(0), "RelayerHub: invalid sponsor");
        require(!sponsors[sponsor].active, "RelayerHub: sponsor already exists");

        sponsors[sponsor] = Sponsor({
            sponsor: sponsor,
            dailyLimit: dailyLimit,
            dailyUsed: 0,
            lastReset: block.timestamp,
            active: true
        });

        emit SponsorAdded(sponsor, dailyLimit);
    }

    /**
     * @notice Remove a sponsor
     * @param sponsor The sponsor address
     */
    function removeSponsor(address sponsor) external onlyOwner {
        require(sponsors[sponsor].active, "RelayerHub: sponsor not found");
        delete sponsors[sponsor];
        emit SponsorRemoved(sponsor);
    }

    /**
     * @notice Update sponsor daily limit
     * @param sponsor The sponsor address
     * @param newLimit New daily limit
     */
    function updateSponsorLimit(address sponsor, uint256 newLimit) external onlyOwner {
        require(sponsors[sponsor].active, "RelayerHub: sponsor not found");
        sponsors[sponsor].dailyLimit = newLimit;
        emit SponsorLimitUpdated(sponsor, newLimit);
    }

    /**
     * @notice Allowlist a contract
     * @param contractAddress The contract address to allowlist
     */
    function allowlistContract(address contractAddress) external onlyOwner {
        allowlistedContracts[contractAddress] = true;
        emit ContractAllowlisted(contractAddress);
    }

    /**
     * @notice Remove contract from allowlist
     * @param contractAddress The contract address to remove
     */
    function removeContract(address contractAddress) external onlyOwner {
        allowlistedContracts[contractAddress] = false;
        emit ContractRemoved(contractAddress);
    }

    /**
     * @notice Check if a sponsor can relay a transaction
     * @param sponsor The sponsor address
     * @param user The user address
     * @param to The target contract address
     * @return canRelay Whether the transaction can be relayed
     */
    function canRelay(address sponsor, address user, address to) external view returns (bool canRelay) {
        // Check sponsor exists and is active
        if (!sponsors[sponsor].active) {
            return false;
        }

        // Check contract is allowlisted (if allowlist is enforced)
        // For MVP, we allow all contracts, but this can be enforced later
        // if (!allowlistedContracts[to]) {
        //     return false;
        // }

        // Reset daily usage if needed
        Sponsor memory sponsorData = sponsors[sponsor];
        if (block.timestamp - sponsorData.lastReset >= DAY) {
            return sponsorData.dailyLimit > 0;
        }

        // Check sponsor limit
        if (sponsorData.dailyUsed >= sponsorData.dailyLimit) {
            return false;
        }

        // Check user limit
        Usage memory usage = userUsage[user];
        if (block.timestamp - usage.lastReset >= DAY) {
            return true; // User limit resets, can relay
        }

        return usage.count < userDailyLimit;
    }

    /**
     * @notice Record a relayed transaction
     * @param sponsor The sponsor address
     * @param user The user address
     * @param gasUsed Gas used for the transaction
     */
    function recordRelay(address sponsor, address user, uint256 gasUsed) external {
        require(sponsors[sponsor].active, "RelayerHub: invalid sponsor");

        // Update sponsor usage
        Sponsor storage sponsorData = sponsors[sponsor];
        if (block.timestamp - sponsorData.lastReset >= DAY) {
            sponsorData.dailyUsed = 0;
            sponsorData.lastReset = block.timestamp;
        }
        sponsorData.dailyUsed++;

        // Update user usage
        Usage storage usage = userUsage[user];
        if (block.timestamp - usage.lastReset >= DAY) {
            usage.count = 0;
            usage.lastReset = block.timestamp;
        }
        usage.count++;

        emit TransactionRelayed(user, sponsor, gasUsed);
    }

    /**
     * @notice Get sponsor info
     * @param sponsor The sponsor address
     * @return The sponsor data
     */
    function getSponsor(address sponsor) external view returns (Sponsor memory) {
        return sponsors[sponsor];
    }

    /**
     * @notice Get user usage
     * @param user The user address
     * @return The usage data
     */
    function getUserUsage(address user) external view returns (Usage memory) {
        return userUsage[user];
    }

    /**
     * @notice Set default daily limit
     * @param newLimit New default limit
     */
    function setDefaultDailyLimit(uint256 newLimit) external onlyOwner {
        defaultDailyLimit = newLimit;
    }

    /**
     * @notice Set user daily limit
     * @param newLimit New user limit
     */
    function setUserDailyLimit(uint256 newLimit) external onlyOwner {
        userDailyLimit = newLimit;
    }
}

