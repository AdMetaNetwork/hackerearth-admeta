// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts@4.2.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.2.0/utils/math/SafeMath.sol";
import "@openzeppelin/contracts@4.2.0/utils/cryptography/SignatureChecker.sol";
import "@openzeppelin/contracts@4.2.0/proxy/utils/Initializable.sol";
import "@identity.com/gateway-protocol-eth/contracts/Gated.sol";

contract Advertisements is Ownable, Initializable, Gated {
    using SafeMath for uint256;

    constructor(address gatewayTokenContract, uint gatekeeperNetwork)
    Gated(gatewayTokenContract, gatekeeperNetwork) {
    }

    struct Ad {
        uint category;
        address publisher;
        uint256 inventory;
        uint256 reward;
        string metadata;
        string target;
        string title;
        bool approved;
    }

    struct UserLevel {
        uint level;
        address user;
        uint256 score;
        string categoryScores;
    }

    address public signer;

    Ad[] private _ads;
    UserLevel[] private _usersLevel;

    mapping(uint256 => uint256) private _adCompleted;
    mapping(uint256 => mapping(address => bool)) private _adUsers;
    mapping(uint => bool) public _categories;

    event CreateAd(uint256 indexed adIndex, address user);
    event CompleteAd(uint256 indexed adIndex, address user, uint256 rewardAmount);

    function initialize(address signer_, uint256[] calldata categories) external initializer {
        require(signer_ != address(0), "Signer can not be zero address.");
        signer = signer_;
        for (uint256 i = 0; i < categories.length; i++) {
            _setCategory(categories[i], true);
        }
    }


    receive() external payable {}
    function setUserLevel(uint level, uint256 score, string memory categoryScore) external gated {

        bool userExists = false;
        for (uint i = 0; i < _usersLevel.length; i++) {
            if (_usersLevel[i].user == msg.sender) {
                _usersLevel[i].level = level;
                _usersLevel[i].score = score;
                _usersLevel[i].categoryScores = categoryScore;
                userExists = true;
                break;
            }
        }

        if (!userExists) {
            _usersLevel.push(UserLevel(level, msg.sender, score, categoryScore));
        }
    }

    function getUserLevel() external onlyOwner view returns(UserLevel memory) {
        require(_usersLevel.length != 0, "There is no data");
        uint count = 0;
        for (uint i = 0; i < _usersLevel.length; i++) {
            if (_usersLevel[i].user == msg.sender) {
                count = i;
                break;
            }
        }
        return UserLevel(_usersLevel[count].level, _usersLevel[count].user, _usersLevel[count].score, _usersLevel[count].categoryScores);
    }

    function userLevelLength()  external view returns(uint256) {
        return _usersLevel.length;
    }

    function setSigner(address newOne) external onlyOwner {
        require(signer != newOne, "There is no change");
        signer = newOne;
    }

    function batchSetCategory(uint256[] calldata categories, bool[] calldata states) external onlyOwner {
        require(categories.length == states.length, "Diff array length");
        for (uint256 i = 0; i < categories.length; i++) {
            _setCategory(categories[i], states[i]);
        }
    }



    function createAd(string memory metadata, string memory title, string memory target, uint category, uint256 inventory, uint256 reward) external payable {
        uint256 requiredAmount = inventory.mul(reward);
        require(msg.value == requiredAmount, "Insufficient balance to create ad.");
        require(_categories[category] == true, "Category does not exist.");

        _ads.push(Ad(category, msg.sender, inventory, reward, metadata, target, title, false));

        emit CreateAd(_ads.length.sub(1), msg.sender);
    }

    function approveAd(uint256 adIndex) external onlyOwner {
        require(_ads[adIndex].approved == false, "Ad approved.");
        _ads[adIndex].approved = true;
    }

    function completeAd(uint256 adIndex, bytes memory signature) external {
        require(adIndex < _ads.length, "Ad index over flow");
        require(!_adUsers[adIndex][msg.sender], "User has already completed this ad.");
        require(verifyComplete(adIndex, msg.sender, signature), "Invalid signature.");
        require(_adCompleted[adIndex] < _ads[adIndex].inventory, "Over ad inventory");

        _adUsers[adIndex][msg.sender] = true;
        _adCompleted[adIndex] = _adCompleted[adIndex].add(1);
        payable(msg.sender).transfer(_ads[adIndex].reward);

        emit CompleteAd(adIndex, msg.sender, _ads[adIndex].reward);
    }

    function matchAd(uint _category, address user) external gated view returns (uint256) {
        for (uint256 i = 0; i < _ads.length; i++) {
            if (_ads[i].category == _category && !_adUsers[i][user] && _ads[i].approved) {
                return i;
            }
        }
        revert("No ads available for this user.");
    }

    function adLength() external view returns(uint256) {
        return _ads.length;
    }

    function adInfo(uint256 adIndex) external view returns(uint, address, uint256, uint256, string memory, string memory, string memory, bool) {
        Ad memory ad = _ads[adIndex];
        return (ad.category, ad.publisher, ad.inventory, ad.reward, ad.metadata, ad.title, ad.target, ad.approved);
    }


    function findAdsByPublisher(address publisher) external view returns (Ad[] memory) {
        uint count = 0;
        for (uint i = 0; i < _ads.length; i++) {
            if (_ads[i].publisher == publisher) {
                count++;
            }
        }
        Ad[] memory result = new Ad[](count);
        count = 0;
        for (uint i = 0; i < _ads.length; i++) {
            if (_ads[i].publisher == publisher) {
                result[count] = _ads[i];
                count++;
            }
        }
        return result;
    }

    function allAds() external onlyOwner view returns (Ad[] memory) {
        return _ads;
    }

    function adCompletedAmount(uint256 adIndex) external view returns(uint256) {
        return _adCompleted[adIndex];
    }

    function verifyComplete(uint256 adIndex, address user, bytes memory signature) public view returns(bool) {
        bytes32 message = keccak256(abi.encodePacked(adIndex, user, address(this)));
        bytes32 hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", message));
        return SignatureChecker.isValidSignatureNow(signer, hash, signature);
    }

    function _setCategory(uint256 category, bool state) internal {
        _categories[category] = state;
    }
}
