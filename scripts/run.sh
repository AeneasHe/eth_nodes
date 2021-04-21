#  进入控制台
geth attach geth.ipc 

#解锁账户
personal.unlockAccount(eth.accounts[0],"aeneas@fast") 

#node1给主地址转账  
eth.sendTransaction({from:"0x4c53ed813d1001d61024d3a8fa27f352b0ff66e9", to: "0xa16A181AD474C82D8753eB0C10e8DD4e5710314f", value: web3.toWei(100,"ether")}) 

eth.sendTransaction({from:"0x4c53ed813d1001d61024d3a8fa27f352b0ff66e9", to: "0x1B81526f1779c92D1E483dafCCF65fAEbf2608AB", value: web3.toWei(100,"ether")}) 