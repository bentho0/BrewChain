# BrewChain

A decentralized brewing and fermentation mastery reward system for incentivizing craft brewing excellence on Stacks blockchain.

## Features

- Brewing activity tracking with fermentation time-based rewards
- Brewer fermentation level progression with mastery bonus multipliers
- Brew token accumulation and redemption system
- Yeast preservation mechanism with time-based penalties
- Comprehensive brewery statistics and analytics

## Smart Contract Functions

### Public Functions
- `start-brew-activity` - Begin brewing fermentation session
- `complete-brew-batch` - Complete batch and earn rewards
- `claim-brew-rewards` - Claim accumulated brew tokens
- `preserve-yeast` - Preserve yeast for enhanced rewards
- `release-preserved-yeast` - Release preserved yeast with potential penalties

### Read-Only Functions
- `get-brew-activity-count` - Get user's total brew activities
- `get-brew-token-balance` - Get user's brew token balance
- `get-fermentation-level` - Get user's fermentation mastery level
- `get-brewery-stats` - Get overall brewery statistics

## Reward System
- Base reward: 22 tokens per batch
- Fermentation bonus: 8 tokens per level (max level 12)
- Yeast preservation multiplier: 4x for preserved yeast
- Brewery capacity: 1.8M total tokens

## Usage

Deploy the contract to create a brewing system where craft brewers can track their fermentation activities, earn rewards, and preserve yeast for enhanced benefits.

## License

MIT