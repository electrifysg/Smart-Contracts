pragma solidity ^0.4.0;

import './zeppelin/ownership/Ownable.sol';
import './ElecWhitelist.sol';
import './zeppelin/math/SafeMath.sol';

contract ElecApprover {
    ElecWhitelist public list;
    mapping(address=>uint)    public participated;

    uint                      public cappedSaleStartTime;
    uint                      public openSaleStartTime;
    uint                      public openSaleEndTime;

    using SafeMath for uint;


    function ElecApprover( ElecWhitelist _whitelistContract,
    uint                      _cappedSaleStartTime,
    uint                      _openSaleStartTime,
    uint                      _openSaleEndTime ) {
        list = _whitelistContract;
        cappedSaleStartTime = _cappedSaleStartTime;
        openSaleStartTime = _openSaleStartTime;
        openSaleEndTime = _openSaleEndTime;

        require( list != ElecWhitelist(0x0) );
        require( cappedSaleStartTime < openSaleStartTime );
        require(  openSaleStartTime < openSaleEndTime );
    }

    // this is a seperate function so user could query it before crowdsale starts
    function contributorCap( address contributor ) constant returns(uint) {
        return list.getCap( contributor );
    }


    function eligible( address contributor, uint amountInWei ) constant returns(uint) {
        if( now < cappedSaleStartTime ) return 0;
        if( now >= openSaleEndTime ) return 0;

        uint cap = contributorCap( contributor );

        if( cap == 0 ) return 0;

        uint remainedCap = cap.sub( participated[ contributor ] );

        if( remainedCap > amountInWei ) return amountInWei;
        else return remainedCap;
    }

    function eligibleTestAndIncrement( address contributor, uint amountInWei ) internal returns(uint) {
        uint result = eligible( contributor, amountInWei );
        if ( result > 0) {
            participated[contributor] = participated[contributor].add( result );
        }
        return result;
    }


    function contributedCap(address _contributor) constant returns(uint) {
        return participated[_contributor];
    }

    function saleEnded() constant returns(bool) {
        return now > openSaleEndTime;
    }

    function saleStarted() constant returns(bool) {
        return now >= cappedSaleStartTime;
    }
}
