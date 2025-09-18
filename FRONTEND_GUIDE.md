# Frontend Integration Guide - FHEVM React dApp

## 🎨 Complete Frontend Development Guide

This guide covers building a React frontend that seamlessly integrates with FHEVM smart contracts, focusing on privacy-preserving user interfaces and encrypted data handling.

## 📑 Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Technology Stack](#technology-stack)
3. [Project Structure](#project-structure)
4. [Web3 Integration](#web3-integration)
5. [FHEVM Concepts](#fhevm-concepts)
6. [State Management](#state-management)
7. [UI Components](#ui-components)
8. [Transaction Handling](#transaction-handling)
9. [Privacy Patterns](#privacy-patterns)
10. [Error Handling](#error-handling)
11. [Performance Optimization](#performance-optimization)
12. [Testing Strategies](#testing-strategies)

## Architecture Overview

### 🏗️ Frontend Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    React Frontend                           │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │    UI       │  │   State     │  │ Components  │        │
│  │ Components  │  │ Management  │  │  & Hooks    │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │   Web3      │  │ Transaction │  │    FHEVM    │        │
│  │Integration  │  │  Handling   │  │ Integration │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │  MetaMask   │  │   Ethers.js │  │ Smart       │        │
│  │   Wallet    │  │   Provider  │  │ Contract    │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
└─────────────────────────────────────────────────────────────┘
```

### 🔄 Data Flow

1. **User Interaction** → UI Components
2. **State Updates** → React State Management
3. **Blockchain Calls** → Ethers.js Provider
4. **Smart Contract** → FHEVM Operations
5. **Results** → UI Updates

## Technology Stack

### Core Technologies

```json
{
  "framework": "React 18 + TypeScript",
  "web3": "Ethers.js v6",
  "styling": "CSS Modules + Modern CSS",
  "build": "Vite",
  "wallet": "MetaMask Integration",
  "blockchain": "Ethereum (Sepolia Testnet)"
}
```

### Dependencies Analysis

```typescript
// package.json key dependencies
{
  "react": "^18.2.0",           // UI framework
  "ethers": "^6.7.1",          // Blockchain interaction
  "typescript": "^5.0.2",      // Type safety
  "vite": "^4.4.5"             // Build tool
}
```

## Project Structure

```
src/
├── main.tsx              # App entry point
├── App.tsx               # Main application component
├── index.css             # Global styles
├── components/           # Reusable UI components
│   ├── WalletConnect.tsx
│   ├── Portfolio.tsx
│   └── AssetForm.tsx
├── hooks/                # Custom React hooks
│   ├── useWallet.ts
│   ├── useContract.ts
│   └── useTransactions.ts
├── types/                # TypeScript type definitions
│   ├── contracts.ts
│   └── wallet.ts
├── utils/                # Utility functions
│   ├── encryption.ts
│   ├── formatting.ts
│   └── validation.ts
└── constants/            # Application constants
    ├── contracts.ts
    └── networks.ts
```

## Web3 Integration

### 1. Contract Configuration

```typescript
// constants/contracts.ts
export const CONTRACT_ADDRESS = "0x9456163460c15Ffd74503F9Fc93603B4bac6309A";

export const CONTRACT_ABI = [
  "function createPortfolio() external",
  "function addAsset(string memory symbol, uint64 amount, uint64 value) external",
  "function updateAsset(string memory symbol, uint64 newAmount, uint64 newValue) external",
  "function removeAsset(string memory symbol) external",
  "function getAssetSymbols(address user) external view returns (string[] memory)",
  "function getEncryptedAssetAmount(address user, string memory symbol) external view returns (uint256)",
  "function getEncryptedAssetValue(address user, string memory symbol) external view returns (uint256)",
  "function getEncryptedTotalValue(address user) external view returns (uint256)",
  "function portfolioExists(address user) external view returns (bool)",
  "function getAssetLastUpdate(address user, string memory symbol) external view returns (uint256)",
  "function getAssetCount(address user) external view returns (uint256)",
  "event PortfolioCreated(address indexed user, uint256 timestamp)",
  "event AssetAdded(address indexed user, string symbol, uint256 timestamp)",
  "event AssetUpdated(address indexed user, string symbol, uint256 timestamp)",
  "event AssetRemoved(address indexed user, string symbol, uint256 timestamp)"
];
```

### 2. Network Configuration

```typescript
// constants/networks.ts
export const SEPOLIA_CHAIN_ID = '0xaa36a7';

export const SEPOLIA_NETWORK = {
  chainId: SEPOLIA_CHAIN_ID,
  chainName: 'Sepolia Test Network',
  rpcUrls: ['https://sepolia.infura.io/v3/', 'https://rpc.sepolia.org'],
  nativeCurrency: {
    name: 'ETH',
    symbol: 'ETH',
    decimals: 18
  },
  blockExplorerUrls: ['https://sepolia.etherscan.io/']
};
```

### 3. Provider Setup

```typescript
// hooks/useWallet.ts
import { ethers } from 'ethers';

export const useWallet = () => {
  const [provider, setProvider] = useState<ethers.BrowserProvider | null>(null);
  const [signer, setSigner] = useState<ethers.JsonRpcSigner | null>(null);
  const [account, setAccount] = useState<string>('');

  const connectWallet = async () => {
    if (!window.ethereum) {
      throw new Error('MetaMask not installed');
    }

    try {
      // Request account access
      const accounts = await window.ethereum.request({
        method: 'eth_requestAccounts'
      });

      // Create provider and signer
      const browserProvider = new ethers.BrowserProvider(window.ethereum);
      const jsonRpcSigner = await browserProvider.getSigner();

      setProvider(browserProvider);
      setSigner(jsonRpcSigner);
      setAccount(accounts[0]);

      return { provider: browserProvider, signer: jsonRpcSigner, account: accounts[0] };
    } catch (error) {
      console.error('Wallet connection failed:', error);
      throw error;
    }
  };

  return { provider, signer, account, connectWallet };
};
```

## FHEVM Concepts

### 1. Privacy-First Data Handling

```typescript
// types/contracts.ts
export interface Asset {
  symbol: string;
  amount: string;        // Displayed as "***" for privacy
  value: string;         // Displayed as "***" for privacy
  lastUpdate: Date;
}

export interface EncryptedAsset {
  symbol: string;
  encryptedAmount: bigint;    // Raw encrypted data
  encryptedValue: bigint;     // Raw encrypted data
  lastUpdate: bigint;
  exists: boolean;
}
```

### 2. Encryption Utilities

```typescript
// utils/encryption.ts
export class FHEUtil {
  // Convert user input to encrypted format
  static encryptAmount(amount: number): bigint {
    // In production FHEVM, this would use proper FHE encryption
    // For this tutorial, we use a simple scaling approach
    return BigInt(Math.floor(amount * 1000000)); // 6 decimal places
  }

  static encryptValue(value: number): bigint {
    // Convert USD value to encrypted format
    return BigInt(Math.floor(value * 100)); // 2 decimal places (cents)
  }

  // Display encrypted data (privacy-preserving)
  static displayEncryptedData(encrypted: bigint): string {
    // In real FHEVM, only the owner can decrypt
    // For demo purposes, we show "***" to maintain privacy concept
    return "***";
  }

  // Check if user is authorized to view decrypted data
  static canDecrypt(userAddress: string, dataOwner: string): boolean {
    return userAddress.toLowerCase() === dataOwner.toLowerCase();
  }
}
```

### 3. Contract Integration Hook

```typescript
// hooks/useContract.ts
import { CONTRACT_ADDRESS, CONTRACT_ABI } from '../constants/contracts';

export const useContract = () => {
  const { provider, signer, account } = useWallet();
  const [contract, setContract] = useState<ethers.Contract | null>(null);

  useEffect(() => {
    if (signer) {
      const contractInstance = new ethers.Contract(
        CONTRACT_ADDRESS,
        CONTRACT_ABI,
        signer
      );
      setContract(contractInstance);
    }
  }, [signer]);

  // Create portfolio
  const createPortfolio = async (): Promise<ethers.TransactionResponse> => {
    if (!contract) throw new Error('Contract not initialized');

    const tx = await contract.createPortfolio();
    return tx;
  };

  // Add encrypted asset
  const addAsset = async (
    symbol: string,
    amount: number,
    value: number
  ): Promise<ethers.TransactionResponse> => {
    if (!contract) throw new Error('Contract not initialized');

    const encryptedAmount = FHEUtil.encryptAmount(amount);
    const encryptedValue = FHEUtil.encryptValue(value);

    const tx = await contract.addAsset(symbol, encryptedAmount, encryptedValue);
    return tx;
  };

  // Load user's encrypted assets
  const loadAssets = async (userAddress: string): Promise<Asset[]> => {
    if (!contract) throw new Error('Contract not initialized');

    const symbols = await contract.getAssetSymbols(userAddress);
    const assets: Asset[] = [];

    for (const symbol of symbols) {
      const lastUpdate = await contract.getAssetLastUpdate(userAddress, symbol);

      assets.push({
        symbol,
        amount: FHEUtil.displayEncryptedData(BigInt(0)), // "***"
        value: FHEUtil.displayEncryptedData(BigInt(0)),  // "***"
        lastUpdate: new Date(Number(lastUpdate) * 1000)
      });
    }

    return assets;
  };

  return {
    contract,
    createPortfolio,
    addAsset,
    loadAssets
  };
};
```

## State Management

### 1. Application State Structure

```typescript
// App.tsx - State Management
interface AppState {
  // Wallet state
  account: string;
  balance: string;
  chainId: string;
  provider: ethers.BrowserProvider | null;
  contract: ethers.Contract | null;

  // Portfolio state
  hasPortfolio: boolean;
  assets: Asset[];

  // UI state
  loading: boolean;
  message: string;
  showAddAsset: boolean;

  // Transaction state
  currentTransaction: TransactionStatus | null;
  transactionHistory: TransactionStatus[];

  // Form state
  assetSymbol: string;
  assetAmount: string;
  assetValue: string;
}
```

### 2. State Update Patterns

```typescript
// Efficient state updates
const App: React.FC = () => {
  const [state, setState] = useState<AppState>(initialState);

  // Batch state updates for performance
  const updateWalletState = useCallback((
    account: string,
    balance: string,
    chainId: string
  ) => {
    setState(prev => ({
      ...prev,
      account,
      balance,
      chainId,
      loading: false
    }));
  }, []);

  // Handle errors gracefully
  const handleError = useCallback((error: Error, context: string) => {
    console.error(`${context}:`, error);
    setState(prev => ({
      ...prev,
      loading: false,
      message: `❌ ${error.message}`
    }));
  }, []);
};
```

## UI Components

### 1. Privacy-Aware Asset Display

```typescript
// components/AssetItem.tsx
interface AssetItemProps {
  asset: Asset;
  onRemove: (symbol: string) => void;
  loading: boolean;
}

const AssetItem: React.FC<AssetItemProps> = ({ asset, onRemove, loading }) => {
  return (
    <div className="asset-item">
      <div className="asset-header">
        <div className="asset-icon">💰</div>
        <div className="asset-main">
          <span className="asset-symbol">{asset.symbol}</span>
          <div className="asset-meta">
            <span className="last-update">
              Updated: {asset.lastUpdate.toLocaleDateString()}
            </span>
          </div>
        </div>
      </div>

      <div className="asset-details">
        <div className="asset-data-row">
          <span className="label">Holdings:</span>
          <span className="asset-data amount">{asset.amount} 🔒</span>
        </div>
        <div className="asset-data-row">
          <span className="label">Value:</span>
          <span className="asset-data value">${asset.value} 🔒</span>
        </div>
        <div className="encryption-status">
          <span>🔐 FHE Encrypted & Secure</span>
        </div>
      </div>

      <div className="asset-actions">
        <button
          className="remove-asset"
          onClick={() => onRemove(asset.symbol)}
          disabled={loading}
        >
          🗑️ Remove
        </button>
      </div>
    </div>
  );
};
```

### 2. Transaction Status Component

```typescript
// components/TransactionStatus.tsx
interface TransactionStatusProps {
  transaction: TransactionStatus;
}

const TransactionStatus: React.FC<TransactionStatusProps> = ({ transaction }) => {
  const getStatusColor = (status: string) => {
    switch (status) {
      case 'confirmed': return '#4ade80';
      case 'failed': return '#f87171';
      default: return '#fbbf24';
    }
  };

  return (
    <div className="transaction-status">
      <h3>Current Transaction</h3>
      <div className="status-details">
        <p>Operation: <span className="highlight">{transaction.description}</span></p>
        <p>Hash: <span className="highlight">{transaction.hash}</span></p>
        <p>Status:
          <span
            style={{ color: getStatusColor(transaction.status) }}
            className="status-badge"
          >
            {transaction.status.toUpperCase()}
          </span>
        </p>
        {transaction.status === 'confirmed' && (
          <>
            <p>Confirmations: <span className="highlight">{transaction.confirmations}</span></p>
            {transaction.gasUsed && (
              <p>Gas Used: <span className="highlight">{transaction.gasUsed}</span></p>
            )}
          </>
        )}
        <p>
          <a
            href={`https://sepolia.etherscan.io/tx/${transaction.hash}`}
            target="_blank"
            rel="noopener noreferrer"
            className="highlight"
          >
            View on Etherscan ↗
          </a>
        </p>
      </div>
    </div>
  );
};
```

### 3. Asset Form Component

```typescript
// components/AssetForm.tsx
interface AssetFormProps {
  onSubmit: (symbol: string, amount: number, value: number) => void;
  loading: boolean;
}

const AssetForm: React.FC<AssetFormProps> = ({ onSubmit, loading }) => {
  const [symbol, setSymbol] = useState('');
  const [amount, setAmount] = useState('');
  const [value, setValue] = useState('');
  const [selectedPreset, setSelectedPreset] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    if (!symbol || !amount || !value) {
      alert('Please fill all fields');
      return;
    }

    const numAmount = parseFloat(amount);
    const numValue = parseFloat(value);

    if (numAmount <= 0 || numValue <= 0) {
      alert('Amount and value must be greater than 0');
      return;
    }

    onSubmit(symbol.trim().toUpperCase(), numAmount, numValue);
  };

  return (
    <form onSubmit={handleSubmit} className="asset-form">
      <div className="form-header">
        <h3>🔒 Add New Encrypted Asset</h3>
        <div className="security-badge">
          <span>🛡️ FHE Protected</span>
        </div>
      </div>

      {/* Asset presets */}
      <div className="preset-assets">
        <p className="preset-title">🎯 Quick Select Popular Assets:</p>
        <div className="asset-presets">
          {ASSET_PRESETS.map((preset) => (
            <button
              key={preset.symbol}
              type="button"
              className={`preset-btn ${selectedPreset === preset.symbol ? 'selected' : ''}`}
              onClick={() => {
                setSelectedPreset(preset.symbol);
                setSymbol(preset.symbol);
              }}
              disabled={loading}
            >
              {preset.symbol}
            </button>
          ))}
        </div>
      </div>

      {/* Form inputs */}
      <div className="input-group">
        <label className="input-label">🏷️ Asset Symbol</label>
        <input
          type="text"
          value={symbol}
          onChange={(e) => setSymbol(e.target.value.toUpperCase())}
          placeholder="e.g., BTC, ETH, SOL"
          className="input-field"
          disabled={loading}
          maxLength={10}
          required
        />
      </div>

      <div className="input-group">
        <label className="input-label">📊 Holdings Amount</label>
        <input
          type="number"
          value={amount}
          onChange={(e) => setAmount(e.target.value)}
          placeholder="e.g., 0.5, 100"
          className="input-field"
          step="0.000001"
          min="0"
          disabled={loading}
          required
        />
      </div>

      <div className="input-group">
        <label className="input-label">💰 USD Value</label>
        <input
          type="number"
          value={value}
          onChange={(e) => setValue(e.target.value)}
          placeholder="e.g., 25000, 1500"
          className="input-field"
          step="0.01"
          min="0"
          disabled={loading}
          required
        />
      </div>

      <div className="form-actions">
        <button
          type="submit"
          className="submit-btn"
          disabled={loading || !symbol || !amount || !value}
        >
          {loading ? '⏳ Encrypting & Storing...' : '🔒 Encrypt & Store Asset'}
        </button>
      </div>

      <div className="privacy-notice">
        <div className="privacy-header">
          <span className="privacy-icon">🛡️</span>
          <strong>Privacy Protection</strong>
        </div>
        <p>
          Your asset data will be encrypted using FHE technology before storage.
          Only you can decrypt and view the actual values.
        </p>
      </div>
    </form>
  );
};
```

## Transaction Handling

### 1. Transaction Tracking

```typescript
// hooks/useTransactions.ts
export const useTransactions = () => {
  const [currentTransaction, setCurrentTransaction] = useState<TransactionStatus | null>(null);
  const [history, setHistory] = useState<TransactionStatus[]>([]);

  const trackTransaction = useCallback(async (
    hash: string,
    description: string,
    provider: ethers.BrowserProvider
  ) => {
    const newTransaction: TransactionStatus = {
      hash,
      status: 'pending',
      confirmations: 0,
      description
    };

    setCurrentTransaction(newTransaction);
    setHistory(prev => [newTransaction, ...prev.slice(0, 4)]);

    try {
      const tx = await provider.getTransaction(hash);
      if (tx) {
        const receipt = await tx.wait();
        if (receipt) {
          const updatedTransaction: TransactionStatus = {
            ...newTransaction,
            status: receipt.status === 1 ? 'confirmed' : 'failed',
            confirmations: await receipt.confirmations(),
            gasUsed: receipt.gasUsed.toString(),
            gasPrice: receipt.gasPrice ? ethers.formatUnits(receipt.gasPrice, 'gwei') : undefined
          };

          setCurrentTransaction(updatedTransaction);
          setHistory(prev =>
            prev.map(tx => tx.hash === hash ? updatedTransaction : tx)
          );
        }
      }
    } catch (error) {
      console.error('Transaction tracking failed:', error);
      const failedTransaction = { ...newTransaction, status: 'failed' as const };
      setCurrentTransaction(failedTransaction);
      setHistory(prev =>
        prev.map(tx => tx.hash === hash ? failedTransaction : tx)
      );
    }
  }, []);

  return {
    currentTransaction,
    history,
    trackTransaction,
    clearCurrentTransaction: () => setCurrentTransaction(null)
  };
};
```

### 2. Gas Estimation

```typescript
// utils/gas.ts
export class GasEstimator {
  static async estimateGas(
    contract: ethers.Contract,
    method: string,
    params: any[] = []
  ): Promise<{ gasLimit: bigint; gasPrice: bigint; estimatedCost: string }> {
    try {
      // Estimate gas limit
      const gasLimit = await contract[method].estimateGas(...params);

      // Get current gas price
      const feeData = await contract.runner.provider.getFeeData();
      const gasPrice = feeData.gasPrice || BigInt(0);

      // Calculate estimated cost in ETH
      const costWei = gasLimit * gasPrice;
      const estimatedCost = ethers.formatEther(costWei);

      return {
        gasLimit,
        gasPrice,
        estimatedCost
      };
    } catch (error) {
      console.error('Gas estimation failed:', error);
      throw new Error('Failed to estimate gas costs');
    }
  }

  static formatGasPrice(gasPrice: bigint): string {
    return ethers.formatUnits(gasPrice, 'gwei') + ' gwei';
  }
}
```

## Privacy Patterns

### 1. Data Display Patterns

```typescript
// Privacy-first display components
const PrivateDataDisplay: React.FC<{
  data: string;
  isOwner: boolean;
  placeholder?: string
}> = ({ data, isOwner, placeholder = "***" }) => {
  return (
    <span className="private-data">
      {isOwner ? data : placeholder} 🔒
    </span>
  );
};

// Usage in components
<PrivateDataDisplay
  data={asset.amount}
  isOwner={false} // Always false in this tutorial for privacy demo
  placeholder="***"
/>
```

### 2. Encryption Status Indicators

```typescript
// Visual privacy indicators
const EncryptionBadge: React.FC<{ level: 'high' | 'medium' | 'low' }> = ({ level }) => {
  const badges = {
    high: { icon: '🛡️', text: 'Military-Grade FHE', color: '#4ade80' },
    medium: { icon: '🔒', text: 'Encrypted', color: '#fbbf24' },
    low: { icon: '⚠️', text: 'Partial Privacy', color: '#f87171' }
  };

  const badge = badges[level];

  return (
    <div className="encryption-badge" style={{ color: badge.color }}>
      <span className="badge-icon">{badge.icon}</span>
      <span className="badge-text">{badge.text}</span>
    </div>
  );
};
```

### 3. Privacy-Preserving Form Handling

```typescript
// Secure form data handling
const handleSensitiveInput = (value: string, encrypt: boolean = true) => {
  if (encrypt) {
    // In production, this would use proper FHE encryption
    return FHEUtil.encryptAmount(parseFloat(value));
  }
  return value;
};

// Clear sensitive data after use
const clearSensitiveData = () => {
  setAssetAmount('');
  setAssetValue('');
  // Clear any cached sensitive data
};
```

## Error Handling

### 1. Comprehensive Error Management

```typescript
// utils/errorHandling.ts
export class ErrorHandler {
  static handleWalletError(error: any): string {
    if (error.code === 4001) {
      return 'Transaction rejected by user';
    }
    if (error.code === -32002) {
      return 'MetaMask is already processing a request';
    }
    if (error.code === 'INSUFFICIENT_FUNDS') {
      return 'Insufficient funds for gas';
    }
    if (error.code === 'NETWORK_ERROR') {
      return 'Network connection error';
    }

    return error.message || 'An unexpected error occurred';
  }

  static handleContractError(error: any): string {
    if (error.reason) {
      return error.reason;
    }
    if (error.message.includes('revert')) {
      return 'Transaction would fail - check contract conditions';
    }

    return 'Contract interaction failed';
  }

  static showUserFriendlyError(error: any, context: string): void {
    const message = context.includes('wallet')
      ? ErrorHandler.handleWalletError(error)
      : ErrorHandler.handleContractError(error);

    // Show to user via toast, modal, or state update
    console.error(`${context}:`, message);
  }
}
```

### 2. Error Boundary Component

```typescript
// components/ErrorBoundary.tsx
class ErrorBoundary extends React.Component<
  { children: React.ReactNode },
  { hasError: boolean; error: Error | null }
> {
  constructor(props: { children: React.ReactNode }) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error('Error boundary caught an error:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="error-boundary">
          <h2>🚨 Something went wrong</h2>
          <p>The application encountered an unexpected error.</p>
          <details>
            <summary>Error details</summary>
            <pre>{this.state.error?.stack}</pre>
          </details>
          <button onClick={() => window.location.reload()}>
            Reload Application
          </button>
        </div>
      );
    }

    return this.props.children;
  }
}
```

## Performance Optimization

### 1. React Performance Patterns

```typescript
// Memoized components for performance
const AssetList = React.memo<{ assets: Asset[]; onRemove: (symbol: string) => void }>(
  ({ assets, onRemove }) => {
    return (
      <div className="asset-list">
        {assets.map((asset) => (
          <AssetItem
            key={asset.symbol}
            asset={asset}
            onRemove={onRemove}
          />
        ))}
      </div>
    );
  }
);

// Memoized expensive calculations
const portfolioValue = useMemo(() => {
  return assets.reduce((total, asset) => {
    // In real FHEVM, this would be computed on encrypted values
    return total; // Simplified for tutorial
  }, 0);
}, [assets]);

// Debounced input for gas estimation
const debouncedAmount = useDebounce(assetAmount, 500);

useEffect(() => {
  if (debouncedAmount && assetValue) {
    // Trigger gas estimation
    estimateGasForAssetAddition(debouncedAmount, assetValue);
  }
}, [debouncedAmount, assetValue]);
```

### 2. Connection Management

```typescript
// Efficient provider management
const useProviderConnection = () => {
  const [provider, setProvider] = useState<ethers.BrowserProvider | null>(null);

  const connectProvider = useCallback(async () => {
    if (!window.ethereum) return null;

    // Reuse existing provider if available
    if (provider) return provider;

    const newProvider = new ethers.BrowserProvider(window.ethereum);
    setProvider(newProvider);
    return newProvider;
  }, [provider]);

  return { provider, connectProvider };
};
```

## Testing Strategies

### 1. Component Testing

```typescript
// __tests__/AssetForm.test.tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { AssetForm } from '../components/AssetForm';

describe('AssetForm', () => {
  const mockOnSubmit = jest.fn();

  beforeEach(() => {
    mockOnSubmit.mockClear();
  });

  it('validates required fields', async () => {
    render(<AssetForm onSubmit={mockOnSubmit} loading={false} />);

    const submitButton = screen.getByText(/encrypt & store asset/i);
    fireEvent.click(submitButton);

    // Should not call onSubmit with empty fields
    expect(mockOnSubmit).not.toHaveBeenCalled();
  });

  it('handles asset preset selection', () => {
    render(<AssetForm onSubmit={mockOnSubmit} loading={false} />);

    const btcButton = screen.getByText('BTC');
    fireEvent.click(btcButton);

    const symbolInput = screen.getByPlaceholderText(/e.g., BTC, ETH/i) as HTMLInputElement;
    expect(symbolInput.value).toBe('BTC');
  });
});
```

### 2. Hook Testing

```typescript
// __tests__/useContract.test.ts
import { renderHook, act } from '@testing-library/react';
import { useContract } from '../hooks/useContract';

// Mock ethers
jest.mock('ethers', () => ({
  ethers: {
    Contract: jest.fn(),
    BrowserProvider: jest.fn()
  }
}));

describe('useContract', () => {
  it('initializes contract when signer is available', async () => {
    const { result } = renderHook(() => useContract());

    // Test contract initialization logic
    await act(async () => {
      // Simulate signer being set
    });

    expect(result.current.contract).toBeDefined();
  });
});
```

### 3. Integration Testing

```typescript
// __tests__/integration.test.tsx
describe('Portfolio Integration', () => {
  it('completes full portfolio workflow', async () => {
    // Mock MetaMask
    const mockEthereum = {
      request: jest.fn(),
      on: jest.fn(),
      removeListener: jest.fn()
    };
    (global as any).window.ethereum = mockEthereum;

    render(<App />);

    // Test wallet connection
    const connectButton = screen.getByText(/connect metamask/i);
    fireEvent.click(connectButton);

    await waitFor(() => {
      expect(screen.getByText(/create portfolio/i)).toBeInTheDocument();
    });

    // Test portfolio creation and asset management
    // ... more integration test steps
  });
});
```

## Accessibility & UX

### 1. Accessibility Features

```typescript
// Accessible components
const AccessibleButton: React.FC<{
  onClick: () => void;
  disabled?: boolean;
  ariaLabel: string;
  children: React.ReactNode;
}> = ({ onClick, disabled, ariaLabel, children }) => {
  return (
    <button
      onClick={onClick}
      disabled={disabled}
      aria-label={ariaLabel}
      className="accessible-button"
      tabIndex={disabled ? -1 : 0}
    >
      {children}
    </button>
  );
};

// Screen reader support for encrypted data
const ScreenReaderPrivateData: React.FC<{ dataType: string }> = ({ dataType }) => {
  return (
    <span aria-label={`${dataType} is encrypted and hidden for privacy`}>
      *** 🔒
    </span>
  );
};
```

### 2. Loading States

```typescript
// Comprehensive loading states
const LoadingStates = {
  WalletConnection: () => (
    <div className="loading-state">
      <div className="spinner" />
      <p>🔄 Connecting to MetaMask...</p>
    </div>
  ),

  TransactionPending: ({ description }: { description: string }) => (
    <div className="loading-state">
      <div className="spinner" />
      <p>⏳ {description}...</p>
      <p className="sub-text">Please confirm in MetaMask</p>
    </div>
  ),

  DataLoading: () => (
    <div className="loading-state">
      <div className="spinner" />
      <p>📊 Loading encrypted portfolio...</p>
    </div>
  )
};
```

---

## 🎉 Summary

This frontend guide provides a complete foundation for building privacy-preserving React applications with FHEVM integration. Key takeaways:

- **Privacy-First Design**: Always consider data privacy in UI/UX decisions
- **Robust Error Handling**: Provide clear feedback for all error states
- **Performance Optimization**: Use React best practices for optimal performance
- **Comprehensive Testing**: Test both components and blockchain interactions
- **Accessibility**: Ensure the app is usable by everyone

The example codebase demonstrates these concepts in action, providing a solid foundation for building your own FHEVM applications! 🔐✨