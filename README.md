
以太坊测试私链搭建
=================

* [一、安装go环境](#一、安装go环境)
* [二、编译geth](#二、编译geth)
* [三、节点说明 ](#三、节点说明)
* [四、node_boot 创世节点](#四、node_boot-创世节点)
* [1.初始化生成创世块](#1初始化生成创世块)
* [2.创建创世账户](#2创建创世账户)
* [3.重新进入控制台](#3重新进入控制台)
* [4.挖矿](#4挖矿)
* [五、node1节点1](#五、node1节点1)
* [1.初始化  ](#1初始化--)
* [2.启动](#2启动)
* [3.加入创世节点所在的网络](#3加入创世节点所在的网络)
* [4.创建节点1的挖矿账户](#4创建节点1的挖矿账户)
* [六、node2节点2  ](#六、node2节点2)
* [七、节点的运行](#七、节点的运行)
* [八、常用命令](#八、常用命令)
* [九、快速启动脚本](#九、快速启动脚本)


# 一、安装go环境  

命令如下
```bash
wget https://dl.google.com/go/go1.11.6.linux-amd64.tar.gz 
# (注意下载最新的go版本：1.15.6 不然go的版本不够新 会造成编译错误)
tar xf go1.11.6.linux-amd64.tar.gz 
vim /etc/profile
export GOROOT=/opt/go
export PATH=$PATH:$GOROOT/bin
export GOPATH=/root/gosrc
source /etc/profile
go version
```

# 二、编译geth

命令如下
``` bash
git clone https://github.com/ethereum/go-ethereum.git
mv go-ethereum ethereum
cd ethereum
make geth
```

安装好后geth的命令路径在  
/opt/ethereum/build/bin  

``` bash
cp build/bin/geth /usr/bin/    #拷贝到/usr/bin目录下就可以全局使用了
```

# 三、节点说明

node_boot 创世节点  
node1 对外提供rpc服务的节点  
node2 挖矿节点  

# 四、node_boot 创世节点
以下都是在node_boot文件夹下操作

## 1.初始化生成创世块

先修改genesis.json里的alloc地址为上面实际的创世地址  

``` bash
#初始化，注意所有节点第一次启动前都要初始化
geth --datadir data init genesis.json  
#如果出现错误提示，可以先删除原来的创世块
geth removedb --datadir data 
#再次初始化
geth --datadir data init genesis.json   
# 成功初始化的信息如下
# INFO [04-21|17:09:32.784] Successfully wrote genesis state         database=lightchaindata hash=908673..a248c0
```

## 2.创建创世账户

先进入geth控制台：  
    geth --datadir data --networkid 66  console

控制台下执行命令：  
    personal.newAccount("密码")  

运行结果： 
```
    账户地址：0xac9199717985cdac98e5832370b208b8a33a50ef  
    保存位置：path=/home/aeneas/ethchain/data/keystore/UTC--2021-01-06T06-15-29.834332750Z--c853f0afbe7e53f4dec3dfbf9bcb071ebc45cc65
```
退出控制台：  
    exit

## 3.重新进入控制台

- 进入控制台  
``` bash
geth --datadir data --networkid 66 console
# --networkid 66 是私网的id，以太坊主网的id是1， 私网id不要和已有的网络id重复
```

- 解锁创世账户  
personal.unlockAccount(eth.accounts[0],"密码") 

- 查询创世账户余额   
``` bash
# 单位wei
eth.getBalance(eth.accounts[0])
# 单位eth
web3.fromWei(eth.getBalance(eth.accounts[0]),'ether')
```

## 4.挖矿

``` bash
miner.start()  #开始挖矿  
eth.mining  #是否在挖矿
eth.blockNumber # 区块高度
miner.stop() #停止挖矿 
```

- 常用状态查询
``` bash
eth.syncing         # 是否在同步
eth.mining          # 是否在挖矿
eth.blockNumber    # 当前区块高度
```

# 五、node1节点1
以下都是在node1文件夹下操作

注意：初始化用的genesis.json文件内容必需完全一样，如果boot_node难度调整过，不能用调整过difficulty的genesis.json进行节点初始化，
必需用boot_node当初初始化一样的genesis.json
``` bash
geth --datadir data init genesis.json   # 必需使用boot_node初始化时一样的genesis.json
```

## 1.初始化  
- node1初始化  
在node1 计算机上初始化节点1  


``` bash
#初始化，注意所有节点第一次启动前都要初始化
geth --datadir data init genesis.json  
#如果出现错误提示，可以先删除原来的创世块
geth removedb --datadir data 
#再次初始化
geth --datadir data init genesis.json   
# 成功初始化的信息如下
# INFO [04-21|17:09:32.784] Successfully wrote genesis state         database=lightchaindata hash=908673..a248c0
```

> 注意 genesis.json的内容必须和boot_node的完全相同    
> 所有新节点启动前都要初始化

## 2.启动
- node1启动
> 如果node1和node_boot在同一台计算机上，要指定不同端口, geth默认端口是30303  
> geth --datadir data --networkid 66 --port "30304"  console 

## 3.加入创世节点所在的网络

- 在node_boot里的geth控制台上查询创世节点的地址信息  
    admin.nodeInfo.enode

        结果  
        "enode://28e98de783e26b970350935426fb6ee0ccead471a1f81737d55f521583e937485a46e3025774cfa68f2bab96ac0f6dcecde04b7a261afc793bdc4c303758ff91@125.119.146.0:30303"
> 注意，这个地址是会随着服务器ip变化产生变化的，如果桌面计算机的网络连接采用动态ip，计算机重启后要重新获取这个地址

- node1连接node_boot节点
admin.addPeer("enode://28e98de783e26b970350935426fb6ee0ccead471a1f81737d55f521583e937485a46e3025774cfa68f2bab96ac0f6dcecde04b7a261afc793bdc4c303758ff91@125.119.146.0:30303")

> 除了上面的方法，也可以在启动节点的时候指定--bootnodes选项连接到其他节点。  
> geth --datadir data --networkid 66 --port "30306"  --bootnodes  "enode://28e98de783e26b970350935426fb6ee0ccead471a1f81737d55f521583e937485a46e3025774cfa68f2bab96ac0f6dcecde04b7a261afc793bdc4c303758ff91@125.119.146.0:30303" console 
> 注：新版好像无效，需要手动启动，待确认

- 查看节点连接情况  
// 查看连接的节点数量  
net.peerCount  
// 查看连接的节点信息  
admin.peers  


## 4.创建节点1的挖矿账户

- 先进入geth控制台：  
geth --datadir data --networkid 66  --port "30304"  console

- 执行命令：  
personal.newAccount("密码")  

结果：  
```
    地址     address=0x52B4b7e928223beACCd9523164134c86Af12ce20  
    保存      path=/home/aeneas/ethchain/data/keystore/UTC--2021-01-06T07-06-31.260427822Z--52b4b7e928223beaccd9523164134c86af12ce20
```

- 查询当前节点的所有账户    
personal.listAccounts

- 查询第2个账户余额  
    - 单位wei:  eth.getBalance("0x52B4b7e928223beACCd9523164134c86Af12ce20")  
    - 单位eth:   web3.fromWei(eth.getBalance(eth.accounts[1]),'ether')  


# 六、node2节点2
在node2文件夹下操作，类似node1  


# 七、节点的运行

## 挖矿
- 挖矿前要先解锁账户   
personal.listAccounts  
personal.unlockAccount(eth.accounts[0],"密码")

- 开始挖矿  
miner.start()

- 是否在挖矿
eth.mining

- 停止挖矿  
miner.stop()


- 使用以下命令，当新区块挖出后，挖矿即可结束   
miner.start(1);
admin.sleepBlocks(1);
miner.stop();

- 挖矿难度
genesis.json中的diffcult
初始难度低一点，方便开始快速出块
diffcult 0x2000
后面难度调高，控制出块速度，以下值大概几分钟一个块
diffcult 0xbffff4

## 转账
- boot_node挖矿账户给node1挖矿账户转账  
eth.sendTransaction({from:"0x4c53ed813d1001d61024d3a8fa27f352b0ff4e9", to: "0x52B4b7e928223beACCd9523164134c86Af12ce20", value: web3.toWei(1,"ether")}) 

node1给主地址转账  
eth.sendTransaction({from:"0x4c53ed813d1001d61024d3a8fa27f352b0ff4e9", to: "0xa16A181AD474C82D8753eB0C10e8DD4e5710314f", value: web3.toWei(10,"ether")}) 


## 启动http rpc服务

- http rpc  
geth启动时带上参数  --http --http.addr localhost --http.port "8545"   

        geth --datadir data --networkid 66 --port "30306"  --bootnodes  "enode://28e98de783e26b970350935426fb6ee0ccead471a1f81737d55f521583e937485a46e3025774cfa68f2bab96ac0f6dcecde04b7a261afc793bdc4c303758ff91@125.119.146.0:30303"  --rpc --rpcaddr localhost --rpcport "8545"  console 

## 启动ws rpc服务
- ws rpc  
geth启动时带上参数 --ws  --ws.addr  localhost --ws.port "8546" 


## 日志重定向
- 重定向到文件  
geth console 2>>geth.log  

- 不看日志  
geth console 2>> /dev/null  

- 设定日志级别   
geth --verbosity 2 console   

> 后面的值表示日志详细度:0=silent, 1=error, 2=warn, 3=info, 4=debug, 5=detail (默认为: 3):

 ## 不挖矿的方式启动
 
geth attach ipc:ipc文件路径   
geth attach http://rpc地址:端口  
geth attach ws://rpc地址:端口  

# 八、常用命令

eth.syncing    # 是否在同步
eth.mining     # 是否在挖矿
eth.blockNumber    # 当前区块高度

net.peerCount   查看连接的节点数量，此处为1 如果连接比较多 就不是1了
admin.peers 查看连接的管理节点
admin.addPeer()：连接到其他节点  

miner.start()：开始挖矿   
miner.stop()：停止挖矿   

personal.newAccount()：创建账户  
personal.unlockAccount()：解锁账户  
eth.accounts：枚举系统中的账户  
eth.getBalance()：查看账户余额  

>  返回值的单位是 Wei（Wei 是以太坊中最小货币面额单位，类似比特币中的聪，1 ether = 10^18 Wei）   

eth.blockNumber：列出区块总数   
eth.getTransaction()：获取交易     
eth.getBlock()：获取区块  

miner.start()：开始挖矿   
miner.stop()：停止挖矿   

web3.fromWei()：Wei 换算成以太币    
web3.toWei()：以太币换算成 Wei  
txpool.status：交易池中的状态  

# 九、快速启动脚本

在各节点目录下
- 控制台启动
start_console.sh

- 后台启动
start_nohup.sh

- 守护进程启动
systemctl --user enable node_boot.service
systemctl --user start node_boot.service

systemctl --user enable node1.service
systemctl --user start node1.service

systemctl --user enable node2.service
systemctl --user start node2.service

- 后台启动或守护进程启动时，需要手动进入控制台开启节点挖矿
```bash
#  进入控制台
geth attach data/geth.ipc 
#解锁账户
personal.unlockAccount(eth.accounts[0],"密码") 
#开始挖矿
miner.start()
eth.syncing
eth.mining 
eth.blockNumber 
```