// SPDX-License-Identifier: AGPL-3.0

//    ----------------------------------------------------------------------
//    Copyright © 2025  Pellegrino Prevete
//
//    All rights reserved
//    ----------------------------------------------------------------------
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU Affero General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU Affero General Public License for more details.
//
//    You should have received a copy of the GNU Affero General Public License
//    along with this program.  If not, see <https://www.gnu.org/licenses/>.


pragma solidity >=0.7.0 <0.9.0;

/**
 * @title KeyServer
 * @dev On-chain index for OpenPGP keys.
 */
contract KeyServer {

    address public immutable deployer = 0xea02F564664A477286B93712829180be4764fAe2;
    string public tante = "nocidicocco";

    mapping(
      address => mapping(
        address => mapping(
          uint256 => string ) ) ) public key; 
    mapping(
      address => mapping(
        address => uint256 ) ) public keyNo; 
    mapping(
      string => mapping(
        address => address) ) public owner;
    mapping(
      address => mapping(
        address => mapping(
          string => uint256 ) ) ) public fingerprint;
    mapping(
      address => mapping(
        address => mapping(
          uint256 => bool ) ) ) public revoked;
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
        msg.sender == _user
      );
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
      string memory _key)
      public {
      checkOwner(
        _publisher);
      key[
        _user][
          _publisher][
            keyNo[
              _user][
                _publisher]] =
        _key;
      fingerprint[
        _user][
          _publisher][
            _fingerprint] =
        keyNo[
          _user][
            _publisher];
      owner[
        _fingerprint][
          _publisher] =
        _user;
      keyNo[
        _user][
          _publisher] =
        keyNo[
          _user][
            _publisher] + 1;
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
      uint256 _key)
      public {
      checkOwner(
        _publisher);
      revoked[
        _user][
          _publisher][
            _key] =
        true;
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
    returns (
      string memory)
    {
      require(
        revoked[
          _user][
            _publisher][
              _key] == false,
        "The key has been revoked.");
      return key[
               _user][
                 _publisher][
                   _key];
    }

    /**
     * @dev Read an user OpenPGP key given publisher and fingerprint.
     * @param _user User associated to the key.
     * @param _publisher User publishing the key.
     * @param _fingerprint Fingerprint identifying the target key to retrieve.
     */
    function readKeyFingerprint(
      address _user,
      address _publisher,
      string memory _fingerprint)
    public
    view
    returns (
      string memory)
    {
      return key[
               _user][
                 _publisher][
                   fingerprint[
                     _user][
                       _publisher][
                         _fingerprint]];
    }

    /**
     * @dev Read the owner of a fingerprint.
     * @param _user User associated to the key.
     * @param _publisher User publishing the key.
     * @param _fingerprint Fingerprint identifying the target key to retrieve.
     */
    function readOwnerFingerprint(
      address _publisher,
      string memory _fingerprint)
    public
    view
    returns (
      address)
    {
      return owner[
               _fingerprint][
                 _publisher];
    }

}
