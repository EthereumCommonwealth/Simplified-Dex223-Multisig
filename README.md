# Simplified Multisig

Base version: https://github.com/EthereumCommonwealth/Callisto-Lords-Multisig/blob/main/Callisto_Multisig.sol

This is a simple multisig smart-contract.

By default it is set up for 4 owners but existing owners can add/remove other owners via voting.

The multisig can execute any transactions signed by owner's addresses since it accepts _to, _value and _data parameters and then executes a tx with the accepted values.

In order to adjust the internal variables of the multisig owners must submit a transaction that would make multisig execute it's own function i.e. tell multisig to call itself with the required update parameters.

The multisig supports a "threshold system" and 3 votes out of 4 are required by default for a vote to pass.

There is a vote threshold expiry feature in this multisig that reduces the amount of votes required for a transaction to get approved over time. It operates in cycles (by default a cycle length is 40 days) i.e. for a transaction that was submitted 40 days ago the voting threshold would be reduced by 1. For a transaction submitted 80 days ago the threshold would be reduced by 2.

Threshold can't be less than 1 for security reasons so we wouldn't end up in a situation where 0 owners are required to execute something.

Votes "AGAINST" are recorded and affect the vote threshold reduction feature so that it wouldn't reduce the threshold for proposals that some of the owners don't approve.
