pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";


/// @title BanklessDAO Subscription
/// Smart Contract @author Gajesh Naik (Twitter - @robogajesh)
/// @notice To grant full access to the Discord channels to non member of the DAO through a subscription

contract BanklessSubscription is Ownable, ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // Info of each user that stakes LP tokens.
    mapping (address => UserInfo) public userInfo;

    IERC20 public bank;

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 validTill;
    }

    constructor(address _bank) public ERC721("BanklessDAO Subscription", "BANK-SUB") {
        bank = IERC20(address(_bank));
    }

    // Buy NFT
    function buyNFT(uint256 months) external returns (bool) {
        UserInfo storage user = userInfo[msg.sender];

        // Ensure an approval is done here.
        bank.transferFrom(msg.sender, address(this), 2000000000000000000000*months); // Transfer tokens from sender to contract, external fees WILL apply, so be careful with distribution.

        // update user validity
        if (user.validTill > 0) {
            user.validTill = user.validTill.add(2592000*months);
        } else {
            user.validTill = block.timestamp + 2592000*months;
            mintNFT();
        }
        return true;
    }

    function mintNFT() internal returns (uint256)
    {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, 'https://ipfs.io/ipfs/QmTxdWhoiD1viXKyUThthcXVxYzWsp3FBCA3XcbiFpq8Ur?filename=bankless.png');
        return newItemId;
    }
}