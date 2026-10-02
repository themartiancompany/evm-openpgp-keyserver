# Ethereum Virtual Machine OpenPGP Key Server

A smart contract coupled with a native application
(a libEVM application)
which lets one associate OpenPGP keys to an Ethereum
Virtual Machine network address.

Coupled together with
[EVM GNU Privacy Guard](
  https://github.com/themartiancompany/evm-gnupg)
OpenPGP client it constitute a complete
implementation of the *OpenPGP on Ethereum*
specification.

It is written entirely in GNU Bash and Solidity.

It depends on the
[Ethereum Virtual Machine Library](
  https://github.com/themartiancompany/libevm)
and the
[Crash Bash](
  https://github.com/themartiancompany/crash-bash).

Canonical form for keys associated to an address is:

```
<user>@<address>
```

where `address` can be an Ethereum external
address (EOA) fingeprint or a
[seed address](
  https://github.com/themartiancompany/seed-system)

and `user` any username.

### Usage

Help for all of the commands
is shown with the `-h` argument.

Manuals are available in the
[`man`](
  https://github.com/themartiancompany/evm-openpgp-keyserver submodule directory.
`evm-openpgp-key-publish` and
`evm-openpgp-key-receive` is

is available with the command

```bash
evm-openpgp-key-publish \
  -h
```

## License

This program is released under the terms of the GNU
Affero General Public License version 3.0.
