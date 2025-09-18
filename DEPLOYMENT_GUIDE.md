# Complete Deployment Guide - Hello FHEVM dApp

## 🚀 Step-by-Step Deployment Tutorial

This guide will walk you through deploying your FHEVM dApp from development to production, covering both smart contracts and frontend deployment.

## 📋 Prerequisites Checklist

Before starting, ensure you have:

- ✅ **Node.js** (v16 or higher) installed
- ✅ **MetaMask** browser extension
- ✅ **Git** for version control
- ✅ **Code editor** (VS Code recommended)
- ✅ **Sepolia testnet ETH** (from faucets)
- ✅ **Infura/Alchemy account** (for RPC access)

## 🛠️ Environment Setup

### 1. Clone the Repository

```bash
# Clone the repository
git clone <your-repository-url>
cd dapp

# Install dependencies
npm install
```

### 2. Environment Configuration

Create a `.env` file in the project root:

```bash
# Create .env file
touch .env
```

Add the following environment variables:

```env
# .env file contents
PRIVATE_KEY=your_wallet_private_key_here
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_PROJECT_ID
ETHERSCAN_API_KEY=your_etherscan_api_key_here
REPORT_GAS=false
```

### 3. Getting Required Credentials

#### Private Key (MetaMask)
```bash
# In MetaMask:
# 1. Click account menu (top right)
# 2. Account details
# 3. Export Private Key
# 4. Enter password
# 5. Copy the private key (starts with 0x)
```

#### Infura Project ID
```bash
# At infura.io:
# 1. Create free account
# 2. Create new project
# 3. Select "Web3 API"
# 4. Copy Project ID from dashboard
# 5. Your RPC URL: https://sepolia.infura.io/v3/YOUR_PROJECT_ID
```

#### Etherscan API Key
```bash
# At etherscan.io:
# 1. Create free account
# 2. Go to API Keys section
# 3. Create new API key
# 4. Copy the generated key
```

### 4. Get Test ETH

You'll need Sepolia ETH for deployment and testing:

**Sepolia Faucets:**
- [SepoliaFaucet.com](https://sepoliafaucet.com/)
- [Infura Sepolia Faucet](https://www.infura.io/faucet/sepolia)
- [Alchemy Sepolia Faucet](https://sepoliafaucet.com/)

```bash
# Check your balance
# In MetaMask, switch to Sepolia network
# Your address should show ETH balance > 0.01 ETH
```

## 📦 Smart Contract Deployment

### 1. Compile Contracts

```bash
# Compile the smart contracts
npx hardhat compile

# Expected output:
# Compiling 1 file with 0.8.19
# Compilation finished successfully
```

### 2. Test Locally (Optional but Recommended)

```bash
# Start local Hardhat node
npx hardhat node

# In a new terminal, deploy to local network
npx hardhat run scripts/deploy.js --network localhost
```

### 3. Deploy to Sepolia Testnet

```bash
# Deploy to Sepolia testnet
npx hardhat run scripts/deploy.js --network sepolia

# Expected output:
# 🚀 Starting deployment of ConfidentialPortfolio contract...
# 📝 Deploying contracts with account: 0x...
# 💰 Account balance: 0.5 ETH
# ⏳ Deploying contract...
# ✅ ConfidentialPortfolio deployed to: 0x...
```

### 4. Verify Contract on Etherscan

```bash
# Verify the deployed contract
npx hardhat verify --network sepolia YOUR_CONTRACT_ADDRESS

# Example:
npx hardhat verify --network sepolia 0x9456163460c15Ffd74503F9Fc93603B4bac6309A

# Expected output:
# Successfully verified contract ConfidentialPortfolio
```

### 5. Update Frontend Configuration

After successful deployment, update the contract address in your frontend:

```typescript
// In src/App.tsx, update the contract address
const CONTRACT_ADDRESS = "YOUR_NEW_CONTRACT_ADDRESS";

// Example:
const CONTRACT_ADDRESS = "0x9456163460c15Ffd74503F9Fc93603B4bac6309A";
```

## 🌐 Frontend Deployment

### Option 1: Vercel Deployment (Recommended)

#### Step 1: Prepare for Deployment

```bash
# Build the project
npm run build

# Test the build locally
npm run preview
```

#### Step 2: Deploy to Vercel

```bash
# Install Vercel CLI
npm install -g vercel

# Login to Vercel
vercel login

# Deploy
vercel

# Follow the prompts:
# ? Set up and deploy "~/dapp"? [Y/n] Y
# ? Which scope? Your Username
# ? Link to existing project? [y/N] N
# ? What's your project's name? hello-fhevm-dapp
# ? In which directory is your code located? ./
```

#### Step 3: Configure Environment Variables (Vercel)

In the Vercel dashboard:
1. Go to your project settings
2. Navigate to "Environment Variables"
3. Add production environment variables if needed

### Option 2: Netlify Deployment

```bash
# Build the project
npm run build

# Install Netlify CLI
npm install -g netlify-cli

# Login and deploy
netlify login
netlify deploy --prod --dir=dist
```

### Option 3: Traditional Web Hosting

```bash
# Build the project
npm run build

# The dist/ folder contains all static files
# Upload the contents of dist/ to your web server
```

## 🔧 Configuration Management

### Development vs Production

Create different configurations for different environments:

```typescript
// config.ts
export const config = {
  development: {
    contractAddress: "0x...", // Local deployment
    rpcUrl: "http://localhost:8545",
    chainId: 31337
  },
  production: {
    contractAddress: "0x9456163460c15Ffd74503F9Fc93603B4bac6309A",
    rpcUrl: "https://sepolia.infura.io/v3/YOUR_PROJECT_ID",
    chainId: 11155111
  }
};
```

### Environment-Specific Builds

```bash
# Development build
npm run dev

# Production build
npm run build

# Production preview
npm run preview
```

## 🧪 Testing Your Deployment

### 1. Smart Contract Testing

```bash
# Run contract tests
npx hardhat test

# Test with gas reporting
REPORT_GAS=true npx hardhat test

# Test specific functions
npx hardhat test --grep "should create portfolio"
```

### 2. Frontend Testing

```bash
# Start development server
npm run dev

# Test the following functionality:
# 1. MetaMask connection
# 2. Network switching to Sepolia
# 3. Portfolio creation
# 4. Asset addition/removal
# 5. Transaction confirmation
```

### 3. End-to-End Testing Checklist

- [ ] **Wallet Connection**: MetaMask connects successfully
- [ ] **Network Detection**: App detects and switches to Sepolia
- [ ] **Contract Interaction**: All contract functions work
- [ ] **Transaction Tracking**: Transaction status updates properly
- [ ] **Error Handling**: Appropriate error messages display
- [ ] **Gas Estimation**: Gas costs display correctly
- [ ] **Responsive Design**: Works on mobile devices

## 🐛 Troubleshooting Common Issues

### Contract Deployment Issues

#### Issue: "Insufficient funds"
```bash
# Solution: Get more Sepolia ETH
# Check balance:
npx hardhat run --network sepolia scripts/check-balance.js

# Get more ETH from faucets
```

#### Issue: "Network not supported"
```bash
# Solution: Check hardhat.config.js
# Ensure Sepolia network is configured correctly:
sepolia: {
  url: process.env.SEPOLIA_RPC_URL,
  accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
  chainId: 11155111,
}
```

#### Issue: "Private key error"
```bash
# Solution: Check .env file
# Ensure PRIVATE_KEY is set correctly
# Private key should start with 0x
```

### Frontend Deployment Issues

#### Issue: "Build fails"
```bash
# Solution: Check for TypeScript errors
npm run type-check

# Fix any type errors, then rebuild
npm run build
```

#### Issue: "Contract not found"
```bash
# Solution: Update contract address in frontend
# Check that CONTRACT_ADDRESS matches deployed contract
const CONTRACT_ADDRESS = "0xYOUR_DEPLOYED_ADDRESS";
```

### Runtime Issues

#### Issue: "MetaMask connection fails"
```bash
# Solution: Check network configuration
# Ensure MetaMask is on Sepolia testnet
# Check that contract address is correct
```

#### Issue: "Transaction reverts"
```bash
# Solution: Check contract state
# Ensure portfolio exists before adding assets
# Verify asset doesn't already exist
# Check sufficient ETH balance for gas
```

## 📊 Monitoring and Analytics

### Contract Monitoring

```bash
# Monitor contract events
npx hardhat run scripts/monitor-events.js --network sepolia

# Check contract state
npx hardhat console --network sepolia
```

### Frontend Analytics

Add monitoring to track user interactions:

```typescript
// Add to your frontend
const trackEvent = (event: string, data: any) => {
  // Google Analytics, Mixpanel, etc.
  console.log('Event:', event, data);
};

// Track user actions
trackEvent('portfolio_created', { user: account });
trackEvent('asset_added', { symbol, amount });
```

## 🔒 Security Considerations

### Smart Contract Security

- **Access Control**: Ensure only authorized users can modify data
- **Input Validation**: Validate all user inputs
- **Gas Limits**: Set appropriate gas limits
- **Emergency Stops**: Consider adding pause functionality

### Frontend Security

- **Environment Variables**: Never expose private keys in frontend
- **Input Sanitization**: Validate all user inputs
- **HTTPS**: Always use HTTPS in production
- **Content Security Policy**: Implement CSP headers

### Best Practices

```typescript
// Good: Environment-based configuration
const CONTRACT_ADDRESS = process.env.REACT_APP_CONTRACT_ADDRESS;

// Bad: Hardcoded private information
const PRIVATE_KEY = "0x..."; // Never do this!
```

## 📈 Performance Optimization

### Smart Contract Optimization

```solidity
// Gas-efficient patterns used in the contract:

// 1. Early returns
if (!portfolioExists[user]) {
    return 0;
}

// 2. Storage packing
struct Asset {
    uint256 encryptedAmount;
    uint256 encryptedValue;
    uint256 lastUpdate;
    bool exists; // Packed efficiently
}

// 3. Batch operations where possible
```

### Frontend Optimization

```typescript
// Efficient React patterns:

// 1. Memoization
const expensiveValue = useMemo(() => {
  return calculatePortfolioValue(assets);
}, [assets]);

// 2. Debounced input
const debouncedAmount = useDebounce(amount, 500);

// 3. Connection caching
const provider = useMemo(() => {
  return new ethers.BrowserProvider(window.ethereum);
}, []);
```

## 🚀 Going to Production

### Pre-Production Checklist

- [ ] **Contracts audited** (for mainnet deployment)
- [ ] **Comprehensive testing** completed
- [ ] **Error handling** implemented
- [ ] **Performance optimized**
- [ ] **Security reviewed**
- [ ] **Documentation complete**
- [ ] **Monitoring setup**

### Mainnet Deployment

When ready for mainnet:

```bash
# Update hardhat.config.js for mainnet
mainnet: {
  url: process.env.MAINNET_RPC_URL,
  accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
  chainId: 1,
}

# Deploy to mainnet (be very careful!)
npx hardhat run scripts/deploy.js --network mainnet
```

### Production Monitoring

Set up monitoring for:
- Contract interactions
- Error rates
- Performance metrics
- User analytics
- Security alerts

---

## 🎉 Congratulations!

You've successfully deployed your first FHEVM dApp! Your confidential portfolio management system is now live and ready for users to create privacy-preserving portfolios.

### Next Steps

1. **Share your dApp** with the community
2. **Gather user feedback** and iterate
3. **Explore advanced FHEVM features**
4. **Consider additional privacy features**
5. **Plan for mainnet deployment**

Remember to keep learning and building with privacy-first principles! 🔐✨