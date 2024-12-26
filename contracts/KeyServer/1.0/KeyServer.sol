// SPDX-License-Identifier: AGPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title KeyServer
 * @dev On-chain index for OpenPGP keys.
 */
contract KeyServer {

    address public immutable deployer = 0xea02F564664A477286B93712829180be4764fAe2;
    string public hijess = "isallforu";

    mapping(address => mapping(address => mapping(uint256 => string))) public key; 
    mapping(address => mapping(address => uint256)) public keyNo; 
    mapping(address => mapping(address => mapping(string => uint256))) public fingerprint;
    mapping(address => mapping(address => mapping(uint256 => bool))) public revoked;
    constructor() {}

    /**
     * @dev Check owner.
     * @param _user User address.
     */
    function checkOwner(
      address _user)
      public
      view {
      require(
        msg.sender == _user);
    }

    /**
     * @dev Publishes OpenPGP key for an user.
     * @param _user User for which the OpenPGP key is published.
     * @param _publisher User publishing the OpenPGP key.
     * @param _fingerprint for the OpenPGP key published.
     * @param _key Public key to publish.
     */
    function publishKey(
      address _user,
      address _publisher,
      string memory _fingerprint,
      string memory _key) public {
      checkOwner(
        _publisher);
      key[_user][_publisher][keyNo[_user][_publisher]] = _key;
      fingerprint[_user][_publisher][_fingerprint] = keyNo[_user][_publisher];
      keyNo[_user][_publisher] = keyNo[_user][_publisher] + 1;
    }

    /**
     * @dev Revokes an OpenPGP key for an user.
     * @param _user User for which the OpenPGP key is revoked.
     * @param _publisher User revoking the OpenPGP key.
     * @param _key Public key to revoke.
     */
    function revokeKey(
      address _user,
      address _publisher,
      uint256 _key) public {
      checkOwner(
        _publisher);
      revoked[_user][_publisher][_key] = true;
    }

    /**
     * @dev Read OpenPGP key given user and publisher.
     * @param _user User associated to the key.
     * @param _publisher User publishing the key.
     * @param _key which key to read.
     */
    function readKey(
      address _user,
      address _publisher,
      uint256 _key)
    public
    view
    returns (string memory)
    {
      require(
        revoked[_user][_publisher][_key] == false,
        "the key has been revoked");
      return key[_user][_publisher][_key];
    }

    /**
     * @dev Read an user OpenPGP key given publisher and fingerprint.
     * @param _user User associated to the key.
     * @param _publisher User publishing the key.
     * @param _fingerprint fingerprint identifying the target key to retrieve.
     */
    function readKeyFingerprint(
      address _user,
      address _publisher,
      string memory _fingerprint)
    public
    view
    returns (string memory)
    {
      return key[_user][_publisher][fingerprint[_user][_publisher][_fingerprint]];
    }

}
