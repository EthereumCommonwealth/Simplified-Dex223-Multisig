// SPDX-License-Identifier: No License (None)
pragma solidity ^0.8.0;

contract Dex223_MultisigV2 {

    event TransactionProposed(
        uint256 indexed txId,
        address indexed proposer,
        address indexed to,
        uint256 value,
        bytes data
    );
    
    struct Tx
    {
        address to;
        uint256 value;
        bytes   data;
        
        uint256 proposed_timestamp;
        bool    executed;
        mapping (address => bool) signed_by;
        
        uint256 num_approvals;
        uint256 num_votes;
        uint256 required_approvals;
    }
    
    mapping (uint256 => Tx)   public txs;
    mapping (address => bool) public owner;
    uint256 public num_owners;
    uint256 public vote_pass_threshold;
    uint256 public num_TXs         = 0;
    uint256 public execution_delay = 10 hours;
    
    modifier onlyOwner
    {
        require(owner[msg.sender], "Only owner is allowed to do this");
        _;
    }
    
    constructor (address _owner1, address _owner2, uint256 _vote_threshold) {
        owner[_owner1]      = true;
        owner[_owner2]      = true;
        num_owners          = 2;
        vote_pass_threshold = _vote_threshold;
    }
    
    // Allow it to receive ERC223 tokens and Funds transfers.
    receive() external payable { }
    fallback() external payable { }
    function tokenReceived(address _from, uint _value, bytes memory _data) public returns (bytes4)
    {
        return 0x8943ec02;
    }
    
    function executeTx(uint256 _txID) public onlyOwner
    {
        require(txAllowed(_txID), "Tx is not allowed");
        txs[_txID].executed = true;
        
        address _destination = txs[_txID].to;
        _destination.call{value:txs[_txID].value}(txs[_txID].data);
    }
    
    function proposeTx(address _to, uint256 _valueInWEI, bytes calldata _data) public onlyOwner
    {
        num_TXs++;
        // Setup Tx values.
        txs[num_TXs].to    = _to;
        txs[num_TXs].value = _valueInWEI;
        txs[num_TXs].data  = _data;
        
        // Setup system values to keep track on Tx validity and voting.
        txs[num_TXs].proposed_timestamp    = block.timestamp;
        txs[num_TXs].signed_by[msg.sender] = true;
        txs[num_TXs].num_approvals         = 1; // The one who proposes it approves it obviously.
        txs[num_TXs].num_votes             = 1; // The one who proposes it approves it obviously.
        txs[num_TXs].required_approvals    = vote_pass_threshold; // By default the required approvals amount is equal to threshold.

        emit TransactionProposed(num_TXs, msg.sender, _to, _valueInWEI, _data);
    }
    
    function approveTx(uint256 _txID) public onlyOwner
    {
        require(!txs[_txID].signed_by[msg.sender], "This Tx is already signed by this owner");
        txs[_txID].signed_by[msg.sender] = true;
        txs[_txID].num_approvals++;
        txs[_txID].num_votes++;
        if(txs[_txID].num_approvals >= vote_pass_threshold)
        {
            executeTx(_txID);
        }
    }
    
    function declineTx(uint256 _txID) public onlyOwner
    {
        require(!txs[_txID].signed_by[msg.sender], "This Tx is already signed by this owner");
        txs[_txID].signed_by[msg.sender] = true;
        txs[_txID].num_votes++;
    }
    
    function txAllowed(uint256 _txID) public view returns (bool)
    {
        require(!txs[_txID].executed, "Tx already executed or rejected");
        require(txs[_txID].num_approvals >= txs[_txID].required_approvals, "Tx is not approved by enough owners or deadline expired");
        return true;
    }

    function reduceApprovalsThreshold(uint256 _txID) public onlyOwner
    {
        uint256 _current_reduction = vote_pass_threshold - txs[_txID].required_approvals;
        require(txs[_txID].required_approvals > 1, "Can't reduce votes threshold to 0");
        require(num_owners - txs[_txID].num_votes >= _current_reduction, "Votes against can't be withdrawn");

        uint256 _step;
        if(txs[_txID].proposed_timestamp +  (_step + _current_reduction) * execution_delay < block.timestamp)
        {
            txs[_txID].required_approvals--;
        }
        else
        {
            revert("Can't reduce votes threshold for this transaction");
        }
    }
    
    function addOwner(address _owner) public
    {
        require(msg.sender == address(this), "Only internal voting can introduce new owners");
        owner[_owner] = true;
        num_owners++;
    }
    
    function removeOwner(address _owner) public
    {
        require(msg.sender == address(this), "Only internal voting can remove existing owners");
        owner[_owner] = false;
        num_owners--;
    }
    
    function setupDelay(uint256 _newDelayInSeconds) public
    {
        require(msg.sender == address(this), "Only internal voting can adjust the delay");
        execution_delay = _newDelayInSeconds;
    }
    
    function setupThreshold(uint256 _newThreshold) public
    {
        require(msg.sender == address(this), "Only internal voting can adjust the delay");
        vote_pass_threshold = _newThreshold;
    }

    function getTokenTransferData(address _destination, uint256 _amount) public view returns (bytes memory)
    {
        bytes memory _data = abi.encodeWithSelector(bytes4(keccak256("transfer(address,uint256)")), _destination, _amount);
        return _data;
    }
}
