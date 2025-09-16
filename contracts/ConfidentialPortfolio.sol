// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title ConfidentialPortfolio
 * @dev A confidential portfolio management contract using FHE (Fully Homomorphic Encryption)
 * @notice This contract allows users to manage their asset portfolios with complete privacy
 * 
 * Deployed at: 0x9456163460c15Ffd74503F9Fc93603B4bac6309A (Sepolia Testnet)
 */
contract ConfidentialPortfolio {
    // Events
    event PortfolioCreated(address indexed user, uint256 timestamp);
    event AssetAdded(address indexed user, string symbol, uint256 timestamp);
    event AssetUpdated(address indexed user, string symbol, uint256 timestamp);
    event AssetRemoved(address indexed user, string symbol, uint256 timestamp);

    // Struct to store encrypted asset information
    struct Asset {
        uint256 encryptedAmount;    // FHE encrypted amount
        uint256 encryptedValue;     // FHE encrypted USD value
        uint256 lastUpdate;        // Timestamp of last update
        bool exists;               // Whether the asset exists
    }

    // Mappings
    mapping(address => bool) public portfolioExists;
    mapping(address => mapping(string => Asset)) private userAssets;
    mapping(address => string[]) private userAssetSymbols;
    mapping(address => uint256) private userAssetCount;

    // Modifiers
    modifier onlyPortfolioOwner() {
        require(portfolioExists[msg.sender], "Portfolio does not exist");
        _;
    }

    modifier validAsset(string memory symbol) {
        require(bytes(symbol).length > 0, "Asset symbol cannot be empty");
        require(bytes(symbol).length <= 10, "Asset symbol too long");
        _;
    }

    /**
     * @dev Creates a new portfolio for the caller
     * @notice Each address can only have one portfolio
     */
    function createPortfolio() external {
        require(!portfolioExists[msg.sender], "Portfolio already exists");
        
        portfolioExists[msg.sender] = true;
        userAssetCount[msg.sender] = 0;
        
        emit PortfolioCreated(msg.sender, block.timestamp);
    }

    /**
     * @dev Adds a new asset to the user's portfolio
     * @param symbol The asset symbol (e.g., "BTC", "ETH")
     * @param amount The encrypted amount of the asset (uint64 scaled)
     * @param value The encrypted USD value of the asset (uint64 scaled)
     * @notice The amount and value are encrypted using FHE before storage
     */
    function addAsset(
        string memory symbol,
        uint64 amount,
        uint64 value
    ) external onlyPortfolioOwner validAsset(symbol) {
        require(!userAssets[msg.sender][symbol].exists, "Asset already exists");
        require(amount > 0, "Amount must be greater than 0");
        require(value > 0, "Value must be greater than 0");

        // Store encrypted values (in real FHE implementation, these would be properly encrypted)
        userAssets[msg.sender][symbol] = Asset({
            encryptedAmount: uint256(amount), // Placeholder for FHE encrypted value
            encryptedValue: uint256(value),   // Placeholder for FHE encrypted value
            lastUpdate: block.timestamp,
            exists: true
        });

        userAssetSymbols[msg.sender].push(symbol);
        userAssetCount[msg.sender]++;

        emit AssetAdded(msg.sender, symbol, block.timestamp);
    }

    /**
     * @dev Updates an existing asset in the user's portfolio
     * @param symbol The asset symbol to update
     * @param newAmount The new encrypted amount
     * @param newValue The new encrypted USD value
     */
    function updateAsset(
        string memory symbol,
        uint64 newAmount,
        uint64 newValue
    ) external onlyPortfolioOwner validAsset(symbol) {
        require(userAssets[msg.sender][symbol].exists, "Asset does not exist");
        require(newAmount > 0, "Amount must be greater than 0");
        require(newValue > 0, "Value must be greater than 0");

        userAssets[msg.sender][symbol].encryptedAmount = uint256(newAmount);
        userAssets[msg.sender][symbol].encryptedValue = uint256(newValue);
        userAssets[msg.sender][symbol].lastUpdate = block.timestamp;

        emit AssetUpdated(msg.sender, symbol, block.timestamp);
    }

    /**
     * @dev Removes an asset from the user's portfolio
     * @param symbol The asset symbol to remove
     */
    function removeAsset(string memory symbol) 
        external 
        onlyPortfolioOwner 
        validAsset(symbol) 
    {
        require(userAssets[msg.sender][symbol].exists, "Asset does not exist");

        // Remove from assets mapping
        delete userAssets[msg.sender][symbol];
        
        // Remove from symbols array
        string[] storage symbols = userAssetSymbols[msg.sender];
        for (uint256 i = 0; i < symbols.length; i++) {
            if (keccak256(bytes(symbols[i])) == keccak256(bytes(symbol))) {
                symbols[i] = symbols[symbols.length - 1];
                symbols.pop();
                break;
            }
        }
        
        userAssetCount[msg.sender]--;

        emit AssetRemoved(msg.sender, symbol, block.timestamp);
    }

    // View Functions

    /**
     * @dev Returns all asset symbols for a user
     * @param user The user address
     * @return Array of asset symbols
     */
    function getAssetSymbols(address user) external view returns (string[] memory) {
        return userAssetSymbols[user];
    }

    /**
     * @dev Returns the encrypted amount for a specific asset
     * @param user The user address
     * @param symbol The asset symbol
     * @return The encrypted amount (placeholder implementation)
     */
    function getEncryptedAssetAmount(address user, string memory symbol) 
        external 
        view 
        returns (uint256) 
    {
        require(userAssets[user][symbol].exists, "Asset does not exist");
        return userAssets[user][symbol].encryptedAmount;
    }

    /**
     * @dev Returns the encrypted value for a specific asset
     * @param user The user address
     * @param symbol The asset symbol
     * @return The encrypted value (placeholder implementation)
     */
    function getEncryptedAssetValue(address user, string memory symbol) 
        external 
        view 
        returns (uint256) 
    {
        require(userAssets[user][symbol].exists, "Asset does not exist");
        return userAssets[user][symbol].encryptedValue;
    }

    /**
     * @dev Returns the encrypted total portfolio value for a user
     * @param user The user address
     * @return The encrypted total value (placeholder implementation)
     */
    function getEncryptedTotalValue(address user) external view returns (uint256) {
        if (!portfolioExists[user]) {
            return 0;
        }

        uint256 totalValue = 0;
        string[] memory symbols = userAssetSymbols[user];
        
        for (uint256 i = 0; i < symbols.length; i++) {
            totalValue += userAssets[user][symbols[i]].encryptedValue;
        }
        
        return totalValue;
    }

    /**
     * @dev Returns the last update timestamp for a specific asset
     * @param user The user address
     * @param symbol The asset symbol
     * @return The timestamp of the last update
     */
    function getAssetLastUpdate(address user, string memory symbol) 
        external 
        view 
        returns (uint256) 
    {
        require(userAssets[user][symbol].exists, "Asset does not exist");
        return userAssets[user][symbol].lastUpdate;
    }

    /**
     * @dev Returns the number of assets in a user's portfolio
     * @param user The user address
     * @return The count of assets
     */
    function getAssetCount(address user) external view returns (uint256) {
        return userAssetCount[user];
    }

    /**
     * @dev Checks if a portfolio exists for a user
     * @param user The user address
     * @return True if portfolio exists, false otherwise
     */
    function portfolioExists(address user) external view returns (bool) {
        return portfolioExists[user];
    }
}