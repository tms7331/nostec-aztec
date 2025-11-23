# Nostec - Private Nostr on Aztec

<div align="center"><strong>Privacy-preserving social graph on Aztec Network</strong></div>
<div align="center">A decentralized social protocol combining Nostr's censorship resistance with Aztec's privacy guarantees</div>

<br />

## Overview

Nostec brings private social relationships to Nostr by leveraging Aztec Network's privacy-preserving smart contracts. The project implements a follower system where relationships are stored as encrypted notes, allowing users to maintain private social graphs while optionally proving credentials (like age verification) using zero-knowledge proofs.

## Features

<dl>
  <dt>Private Follower Relationships</dt>
  <dd>Store follower relationships as private notes on Aztec, keeping your social graph confidential while maintaining verifiable on-chain state.</dd>

  <dt>zkPassport Integration</dt>
  <dd>Verify credentials (like age verification) using zero-knowledge proofs from zkPassport without revealing sensitive personal information.</dd>

  <dt>Flexible Authentication</dt>
  <dd>Support for both proof-gated and permissionless follower notes, allowing different access models for different use cases.</dd>

  <dt>Nostr Compatibility</dt>
  <dd>Designed to integrate with existing Nostr infrastructure while adding privacy-preserving features through Aztec.</dd>

  <dt>Private Note Discovery</dt>
  <dd>Query follower notes privately using utility functions that decrypt and return only notes you have access to.</dd>
</dl>

## Architecture

### Smart Contract

The core contract (`Counter`) manages private follower relationships:

**Storage:**
- `owner`: Immutable public address of the contract owner
- `follower_notes`: Private map of follower notes indexed by user address

**Functions:**

- `constructor(owner)`: Initialize contract with owner address
- `get_owner()`: Returns contract owner (public)
- `add_follower_note_nocheck(nostr_pubkey, owner)`: Add a follower note without proof verification (private)
- `add_follower_note(circuitInputs, zk_id, nostr_pubkey, owner)`: Add a follower note with zkPassport proof verification (private)
- `get_nostr_pubkeys(owner)`: Retrieve all Nostr public keys for a given owner (unconstrained utility)
- `view_follower_notes(owner)`: View all follower notes for a given owner (unconstrained utility)

### FollowerNote

Custom note type storing encrypted follower relationships:

```noir
struct FollowerNote {
    randomness: Field,        // Privacy-preserving randomness
    nostr_pubkey: AztecAddress,  // Follower's Nostr public key
    owner: AztecAddress,      // Owner of this follower list
}
```

### zkPassport Integration

The contract supports zero-knowledge proof verification using zkPassport's proof system:

- Verifies HONK proofs on-chain
- Validates scoped nullifiers match expected zk_id
- Ensures proof inputs match expected formats (115 field vkey, 508 field proof, 7 public inputs)

## Setup

### Prerequisites

1. Install Aztec by following the instructions from [their documentation](https://docs.aztec.network/developers/getting_started)
2. Install dependencies:
   ```bash
   yarn install
   ```
3. Ensure Docker is installed and running (required for Aztec sandbox)
4. Node.js >= 22.0.0
5. Yarn >= 1.22.0

### Environment Configuration

Create a `.env` file in the project root with your configuration:

```env
PXE_URL=http://localhost:8080  # For local sandbox
# or
PXE_URL=https://api.aztec.network/devnet  # For devnet
```

## Build

Compile contracts and generate TypeScript artifacts:

```bash
yarn ccc
```

This runs:
- `yarn clean` - Removes all build artifacts
- `yarn compile` - Compiles Noir contracts using aztec-nargo
- `yarn codegen` - Generates TypeScript bindings from compiled contracts

## Running Tests

### Automated Testing

Tests automatically start and manage the Aztec sandbox:

```bash
yarn test  # Runs all tests (Noir + TypeScript)
```

### Separate Test Suites

```bash
yarn test:nr  # Noir contract tests only
yarn test:js  # TypeScript integration tests only
```

### Manual Sandbox Control

For debugging or multiple test runs:

```bash
aztec start --sandbox  # Start in separate terminal
yarn test              # Run tests against existing sandbox
```

## Deployment

### Local Sandbox

1. Start the sandbox:
   ```bash
   aztec start --sandbox
   ```

2. Deploy contracts:
   ```bash
   yarn deploy
   ```

3. Deploy an account:
   ```bash
   yarn deploy-account
   ```

### Devnet Deployment

Deploy to Aztec devnet:

```bash
yarn deploy::devnet
yarn deploy-account::devnet
```

### Contract Interaction

Interact with deployed contracts:

```bash
# Local
yarn interaction-existing-contract

# Devnet
yarn interaction-existing-contract::devnet
```

## Development Scripts

| Script | Description |
|--------|-------------|
| `yarn ccc` | Clean, compile, and codegen |
| `yarn fees` | Check transaction fees |
| `yarn get-block` | Retrieve block information |
| `yarn get-notes` | View notes for an address |
| `yarn multiple-wallet` | Test multi-wallet interactions |
| `yarn profile` | Profile contract deployment |
| `yarn clear-store` | Remove local storage |

All scripts support `::devnet` suffix for devnet execution.

## Project Structure

```
├── src/
│   ├── nr/
│   │   └── counter_contract/
│   │       └── src/
│   │           ├── main.nr              # Main contract
│   │           ├── follower_note.nr     # FollowerNote definition
│   │           ├── types.nr             # zkPassport proof types
│   │           └── test/                # Noir tests
│   ├── ts/                              # TypeScript tests
│   ├── artifacts/                       # Generated contract bindings
│   └── utils/                           # Utility functions
│       ├── create_account_from_env.ts
│       ├── deploy_account.ts
│       ├── setup_wallet.ts
│       └── sponsored_fpc.ts
├── scripts/                             # Deployment & interaction scripts
│   ├── deploy_contracts.ts
│   ├── deploy_account.ts
│   ├── interaction_existing_contract.ts
│   ├── get_notes.ts
│   ├── fees.ts
│   └── ...
├── config/                              # Configuration files
├── benchmarks/                          # Performance benchmarks
└── target/                              # Compiled Noir artifacts
```

## How It Works

### Adding a Follower (without proof)

1. User calls `add_follower_note_nocheck()` with Nostr public key and owner address
2. Contract creates an encrypted `FollowerNote`
3. Note is stored in the private set for the owner
4. Note is emitted using unconstrained onchain delivery for discoverability

### Adding a Follower (with zkPassport proof)

1. User generates a zkPassport proof (e.g., proving age > 18)
2. User calls `add_follower_note()` with proof inputs, zk_id, and follower info
3. Contract verifies the scoped nullifier matches expected zk_id
4. Contract verifies the HONK proof (currently commented out in code)
5. If valid, creates and stores the encrypted `FollowerNote`

### Querying Followers

1. User calls `get_nostr_pubkeys()` or `view_follower_notes()` as unconstrained functions
2. Contract decrypts notes the user has access to
3. Returns array of Nostr public keys or full note data

## Privacy Model

- **Private by Default**: Follower relationships are stored as encrypted notes
- **Selective Disclosure**: Only the owner can decrypt and view their follower list
- **On-Chain Privacy**: Transactions are private, revealing no information about social graph
- **Proof-Based Access**: Optional zkPassport integration for credential-gated relationships

## Development Workflow

1. Modify contracts in `src/nr/counter_contract/src/`
2. Run `yarn ccc` to rebuild
3. Write tests in `src/ts/` or `src/nr/counter_contract/src/test/`
4. Run `yarn test`
5. Deploy to sandbox/devnet for integration testing
6. Format code with `yarn lint:prettier`

## Benchmarking

Run performance benchmarks:

```bash
yarn benchmark  # Sandbox starts automatically
```

Tracks Gates, DA Gas, and L2 Gas metrics. Results saved to `benchmarks/` directory.

## Code Quality

Format TypeScript and JavaScript:

```bash
yarn lint:prettier
```

## Current Status

This project is under active development. Current focus areas:

- Testing contract functionality end-to-end
- Frontend integration
- zkPassport proof verification (currently disabled in contract)
- Broadcast encryption for group messaging
- Note discovery and indexing
- ENS/naming service integration

## Known Issues

- zkPassport proof verification is currently commented out in the contract (see `add_follower_note()` in main.nr:67-73)
- Some test files may need updates to match current contract structure

## Resources

- [Aztec Documentation](https://docs.aztec.network/)
- [Noir Language Documentation](https://noir-lang.org/)
- [Nostr Protocol](https://github.com/nostr-protocol/nostr)
- [zkPassport](https://zkpassport.id/)
- [Aztec Examples](https://github.com/AztecProtocol/aztec-examples)

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Write tests for your changes
4. Ensure tests pass (`yarn test`)
5. Format code (`yarn lint:prettier`)
6. Commit using conventional commits
7. Push and open a Pull Request

## License

MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built on [Aztec Boilerplate](https://github.com/defi-wonderland/aztec-boilerplate) by Wonderland
- zkPassport integration types courtesy of the zkPassport team
- Inspired by the Nostr protocol and Aztec privacy technology
