可以直接下载程序进行安装，也可以下载源码自己进行编译安装，本文介绍源码编译方式。

# go-ethereum源码编译
## 环境需求
正确安装Go语言环境  
正确安装GCC：安装GCC方法  

从github下载源码  
go get github.com/ethereum/go-ethereum  

## 编译
- Ubuntu和Mac下编译
```
cd go-ethereum
make geth   或者 make all 
```
- Windows下编译
按以下目录结构才能正确编译，需要下载的包请自行下载
```
$GOPATH$/src  
├── github.com  
│   └── ethereum  
│       └── go-ethereum  
└── golang.org  
 └── x  
     └── net 
```
在CMD命令行下，执行以下命令进行编译：
``` bash
go install -v github.com/ethereum/go-ethereum/cmd/geth
go install -v github.com/ethereum/go-ethereum/cmd/evm
```
编译成功，在$GOPATH$/bin下会出现：geth.exe和evm.exe

## 配置环境变量
将 geth 添加到环境变量中
- ubuntu下
vi ~/.bashrc
- mac下
vi ~/.bash_profile
 
- 打开配置文件后，把以下内容添加到文件中  
``` bash
export GETH="$GOPATH/src/github.com/ethereum/go-ethereum/build"
export PATH="$PATH:$GETH/bin"
```
然后执行，使配置生效。

source ~/.bashrc
windows下，直接将bin路径添加到Path环境变量中

检查是否安装成功

geth --help
如果输出一些帮助提示命令，则说明安装成功。

# 搭建私有链
## 启动私有链
- 1. 创建私有链数据存放目录，例：  
 ubuntu和mac
mkdir ~/privatechain
mkdir ~/privatechain/data  # data用于存放账户和区块数据
 
## windows，在D盘建立文件夹privatechain，并在其下建立data文件夹  
- 2. 启动私有链，命令行下进入privatechain目录，执行：  
geth --datadir data --nodiscover console
则进入geth控制台(交互式的 Javascript 执行环境)，默认端口为8545和30303端口

- 3. 创建两个账户
personal.newAccount("123456")  # 123456为密码
 
# 出现的以下一串字符，则为创建的账户
- 4. 查询账户余额
eth.getBalance(eth.accounts[0])
 
# 此时会显示为　0
创建创世区块
1. 退出geth的控制台
exit

2. 在privatechain目录下，新建gensis.json，内容如下：
{  
   "alloc": {  
      "0x3bfd5f0306ffe7b93e56989fd11d5678ce32cfe6": {  
      "balance": "100000000000000000000000000"  
      }  
   },  
    "config":{  
        "chainId":10,  
        "homesteadBlock":0,  
        "eip155Block":0,  
        "eip158Block":0  
    },  
    "nonce":"0x0000000000000042",  
    "mixhash":"0x0000000000000000000000000000000000000000000000000000000000000000",  
    "difficulty": "0x2000",  
    "alloc": {},  
    "coinbase":"0x0000000000000000000000000000000000000000",  
    "timestamp": "0x00",  
    "parentHash":"0x0000000000000000000000000000000000000000000000000000000000000000",  
    "extraData": "",  
    "gasLimit":"0xffffffff"  
}  
创世区块信息写在一个 JSON 格式的配置文件中

此处我的配置，在"0x3bfd5f0306ffe7b93e56989fd11d5678ce32cfe6"中预置了1亿的币

各个参数的含义如下：

mixhash：与nonce配合用于挖矿，由上一个区块的一部分生成的hash。
nonce: nonce就是一个64位随机数，用于挖矿。
difficulty: 设置当前区块的难度，如果难度过大，cpu挖矿就很难，这里设置较小难度
alloc: 用来预置账号以及账号的以太币数量，因为私有链挖矿比较容易，所以我们也可以不预置有币的账号，需要的时候自己创建即可以。
coinbase: 矿工的账号，随便填
timestamp: 设置创世块的时间戳
parentHash: 上一个区块的hash值，因为是创世块，所以这个值是0
extraData: 附加信息，随便填，可以填你的个性信息
gasLimit: 该值设置对GAS的消耗总量限制，用来限制区块能包含的交易信息总和，因为我们是私有链，所以填最大。
chainId：区块链的ID，公链以太坊是1，我们要与其不同，以免冲突

3. 创建创世块
geth --datadir data init genesis.json
如果出现错误提示，可以先删除原来的创世块

geth removedb --datadir data
再次执行

geth --datadir data init genesis.json
初始化成功后，会在数据目录 data 中生成 geth 和 keystore 两个文件夹，此时目录结构如下：

privatechain
├── data
│   ├── geth
│   │   ├── chaindata
│   │   │   ├── 000001.log
│   │   │   ├── CURRENT
│   │   │   ├── LOCK
│   │   │   ├── LOG
│   │   │   └── MANIFEST-000000
│   │   └── lightchaindata
│   │       ├── 000001.log
│   │       ├── CURRENT
│   │       ├── LOCK
│   │       ├── LOG
│   │       └── MANIFEST-000000
│   └── keystore
└── genesis.json
其中 geth/chaindata 中存放的是区块数据，keystore 中存放的是账户数据。

更多操作

4. 转账交易
进入geth控制台

geth --datadir data --networkid 10 console
指定网络id（networkid）为上面设置的10

解锁账户 # 123456为密码

personal.unlockAccount(eth.accounts[0],"123456") 
发送交易
amount = web3.toWei(10,'ether')
eth.sendTransaction({from:eth.accounts[0],to:eth.accounts[1],value:amount})
此时查询账户余额没发生变化，需要进行挖矿确认打包交易

5. 启动&停止挖矿
通过 miner.start() 启动挖矿

> miner.start(3)
其中 start 的参数表示挖矿使用的线程数。第一次启动挖矿会先生成挖矿所需的 DAG 文件，这个过程有点慢，等进度达到 100% 后，就会开始挖矿，此时屏幕会被挖矿信息刷屏。

停止挖矿，在 console 中输入：

miner.stop()
挖到一个区块会奖励5个以太币，挖矿所得的奖励会进入矿工的账户，这个账户叫做coinbase，默认情况下coinbase是本地账户中的第一个账户：

> eth.coinbase
"0xfb9cc019fc650a1699d05b7fb564b83c3a72b64d"
可以通过 miner.setEtherbase() 将其他账户设置成 coinbase 即可

> miner.setEtherbase(eth.accounts[1])
true
> eth.coinbase
"0xc6b5702b15a3794374e28f41f36e1e8dbdd564df"
重新启动挖矿，查看 eth.accounts[1] 是否可以获得以太币

> miner.start(3)
 
//等待几秒后
> miner.stop()
查询账户余额：

> eth.getBalance(eth.accounts[0])
280000000000000000000 # wei
> eth.getBalance(eth.accounts[1])
210000000000000000000
> web3.fromWei(eth.getBalance(eth.accounts[1]),'ether') # wei换算成ether
210
发现账户0 和 账号1 都有以太币，说明 miner.setEtherbase() 设置成功。

getBalance() 返回值的单位是wei，wei是以太币的最小单位，1个以太币=10的18次方个wei。要查看有多少个以太币，可以用web3.fromWei()将返回值换算成以太币：

> web3.fromWei(eth.getBalance(eth.accounts[0]),'ether')
280
 
> web3.fromWei(eth.getBalance(eth.accounts[1]),'ether')
210
3. 查看交易信息
查看当前区块总数：

eth.blockNumber
通过区块号查看区块：

eth.getBlock(6)
通过交易hash（hash 值包含在上面交易返回值中）查看交易：

eth.getTransaction("0x493e8aa2bcb6b2a362bdbd86b2c454279e14beea43b444aeb45c7f47bf572e2")
4. 控制台操作命令介绍
控制台内置了一些用来操作以太坊的 Javascript 对象，可以直接使用这些对象。这些对象主要包括：

eth：包含一些跟操作区块链相关的方法；
net：包含一些查看p2p网络状态的方法；
admin：包含一些与管理节点相关的方法；
miner：包含启动&停止挖矿的一些方法；
personal：主要包含一些管理账户的方法；
txpool：包含一些查看交易内存池的方法；
web3：包含了以上对象，还包含一些单位换算的方法。
常用命令有：

personal.newAccount()：创建账户；
personal.unlockAccount()：解锁账户；
eth.accounts：枚举系统中的账户；
eth.getBalance()：查看账户余额，返回值的单位是 Wei（Wei 是以太坊中最小货币面额单位，类似比特币中的聪，1 ether = 10^18 Wei）；
eth.blockNumber：列出区块总数；
eth.getTransaction()：获取交易；
eth.getBlock()：获取区块；
miner.start()：开始挖矿；
miner.stop()：停止挖矿；
eth.coinbase：挖矿奖励的账户
web3.fromWei()：Wei 换算成以太币；
web3.toWei()：以太币换算成 Wei；
txpool.status：交易池中的状态；
admin.addPeer()：连接到其他节点；
多节点运行
按同样的方法在另一台电脑上重新启动一个节点，注意：genesis.json的内容必须完全相同
获取第一个节点的enode信息

admin.nodeInfo.enode
结果如下：

"enode://fe6dd2e69ceea3eb8daddc4cb1453a00d7094df6486c214062a5d0ec5b020b9d832508b80594a323cbbd6ddb4ddd06257103a2f08173ef7e31e19f302f4e5f9e@[::]:30303?discport=0"
在第二个节点中执行添加第一个节点的操作

admin.addPeer("enode://fe6dd2e69ceea3eb8daddc4cb1453a00d7094df6486c214062a5d0ec5b020b9d832508b80594a323cbbd6ddb4ddd06257103a2f08173ef7e31e19f302f4e5f9e@192.168.137.1:30303")
注意：enode信息中的[::]替换成第一个节点的ip，问号及后面部分不需要

查看连接的节点
// 查看连接的节点数量，此处为1
net.peerCount
// 查看连接的节点信息
admin.peers
结果如下：

[{
    caps: ["eth/63"],
    id: "352c2a755ea629dba803dda4e8e2708fca746838b2c91ea329713fd2c2ccbc0d1dd34fe905c1157fafb775383cf6f4f21e94a4b2533a8282806dd4fda81a5bd7",
    name: "Geth/v1.8.10-unstable-998f6564/darwin-amd64/go1.10.2",
    network: {
      inbound: true,
      localAddress: "192.168.137.1:30303",
      remoteAddress: "192.168.137.16:53022",
      static: false,
      trusted: false
    },
    protocols: {
      eth: {
        difficulty: 131072,
        head: "0x5e1fc79cb4ffa4739177b5408045cd5d51c6cf74133f23f7cd72ee1f8d790e0",
        version: 63
      }
    }
}]
此时，节点1和节点2都可以进行挖矿，并且只要有一个节点在进行挖矿，其他节点的交易也都能正常进行。在节点1可以查询节点2中账户的余额，也可以在不同节点之间进行转账。