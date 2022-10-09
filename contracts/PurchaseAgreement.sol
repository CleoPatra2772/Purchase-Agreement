// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract PurchaseAgreement {

    //buyer
    //merchant
    //
    address payable public buyer;
    address payable public merchant;
    uint public value;

    enum State {
        Created,
        Locked,
        Release,
        Inactive
    }

    State public state;
    //by default, the state will be the first variable. 

    constructor() payable {
        merchant = payable(msg.sender);
        value = msg.value / 2; 

    }

    ///The function cannot be called at the current state.
    error InvalidState();

    /// Only buyer can call this function 
    error OnlyBuyer();

     /// Only merchant can call this function 
    error OnlyMerchant();

    modifier inState(State state_){
        if(state != state_)
            revert InvalidState();
        _;
    }

    modifier onlyBuyer() {
        if(msg.sender != buyer){
            revert OnlyBuyer();
        }
        _;
    }

    modifier onlyMerchant() {
        if(msg.sender != merchant){
            revert OnlyMerchant();
        }
        _;
    }



    function confirmPurchase() external inState(State.Created) payable {
        require(msg.value == (2 * value), "Please send in two times the purchase amount");
        buyer = payable(msg.sender);
        state = State.Locked;
    }

    function confirmReceived() external onlyBuyer inState(State.Locked) {
        state = State.Release;
        buyer.transfer(value);

    }

    function payMerchant() external onlyMerchant inState(State.Release) {
        state = State.Inactive;
        
        merchant.transfer(3 * value);

    }

    function abort() external onlyMerchant inState(State.Created){
        state = State.Inactive;
        merchant.transfer(address(this).balance);
    }


}