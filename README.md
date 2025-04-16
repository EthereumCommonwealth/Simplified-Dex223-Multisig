# Simplified Multisig

Base version: https://github.com/EthereumCommonwealth/Callisto-Lords-Multisig/blob/main/Callisto_Multisig.sol

This is a simple multisig smart-contract.

By default it is set up for 4 owners but existing owners can add/remove other owners via voting.

The multisig can execute any transactions signed by owner's addresses.

The multisig supports a "threshold system" and 3 votes out of 4 are required by default for a vote to pass.

With this multisig at least one VETO vote is required to decline a transaction. If some voters abstained from voting and haven't case their votes in 40 days then the multisig treats them as votes "FOR" i.e. if just one owner would propose a transaction and no other owners would vote against it in 40 dyas then this transaction can be executed.
