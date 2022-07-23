### Work with Remix IDE locally

`remixd -s /home/bit/LearningSolidity -u https://remix.ethereum.org/\#optimize\=false\&runs\=200\&evmVersion\=null\&version\=soljson-v0.8.1+commit.df193b15.js`

ie. `remixd -s <local directory> -u <remix IDE url>`

### Bluetoothctl

put device on discover
run bluetoothctl
type power on
type agent on
type pair `mac address`
type the pair code into the keyboard as prompted
type connect 0C:4D:12:11:01:E4
type trust 0C:4D:12:11:01:E4
type agent off
type quit
