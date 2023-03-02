// https://docs.ethers.io/v5/
const { ethers } = require("hardhat");

// https://www.chaijs.com/
// Chai 是一个 BDD / TDD 断言库，适用于节点和浏览器，可以与任何 javascript 测试框架完美搭配
const {use, expect} = require('chai');

describe('Test dApp', () => {
    let owner;
    let addr1;
    let addr2;
    let addrs;

    let vendorContract;
    let tokenContract;
    let tokenFactory;

    let vendorTokensSupply;
    let tokensPerEth;

    // 每个测试执行前，运行的通用方法
    beforeEach(async () => {
        // 获取帐号列表
        [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

        // console.log("\towner:", owner.address);
        // console.log("\taddr1:", addr1.address);
        // console.log("\taddr2:", addr2.address);
        // console.log("\taddrs:", addrs.length);
        // Deploy ExampleExternalContract contract
        // YourTokenFactory = await ethers.getContractFactory('YourToken');
        // mshk = await YourTokenFactory.deploy();

        // // Deploy Staker Contract
        // const VendorContract = await ethers.getContractFactory('Vendor');
        // mshkVendor = await VendorContract.deploy(mshk.address);

        tokenFactory = await hre.ethers.getContractFactory("ERC20MSHKToken");
        tokenContract = await tokenFactory.deploy();

        const VendorContract = await hre.ethers.getContractFactory("ERC20MSHKTokenVendor");
        vendorContract = await VendorContract.deploy(tokenContract.address);

        // 向交易合约转帐 1000 个代币，所有代币
        // parseUnits("1.0");
        // { BigNumber: "1000000000000000000" }
        await tokenContract.transfer(vendorContract.address, ethers.utils.parseEther('1000'));

        // 设置 合约所有者
        await vendorContract.transferOwnership(owner.address);

        // 合约代币总量 
        vendorTokensSupply = await tokenContract.balanceOf(vendorContract.address);

        // 获取 代币替换比例
        tokensPerEth = await vendorContract.tokensPerEth();

        // console.log("\ttokenContract deployed to:", tokenContract.address);
        // console.log("\tvendorContract deployed to:", vendorContract.address);
        // console.log('\tvendorContract余额[%s]:%s',vendorContract.address,vendorTokensSupply);
    });


    describe('Test buyTokens() method', () => {
        it('buyTokens 测试没有发送 ETH 代币', async () => {
            const amount = ethers.utils.parseEther('0'); // 测试 0 个代币

            // 使用 connect 方法，连接到 addr1 帐号测试是否可以购买合约
            // 使用 revertedWith 匹配是否包含指定消息
            await expect(
                vendorContract.connect(addr1).buyTokens({
                    value: amount,
                }),
            ).to.be.revertedWith('Send ETH to buy some tokens');
        });

        it('buyTokens 测试没有有足够的 Token 可供购买', async () => {
            const amount = ethers.utils.parseEther('11'); // 发送大于1
            await expect(
                vendorContract.connect(addr1).buyTokens({
                    value: amount,
                }),
            ).to.be.revertedWith('Vendor contract has not enough tokens in its balance');
        });

        it('buyTokens 购买成功!', async () => {
            const buyAmount = 1
            const amount = ethers.utils.parseEther(buyAmount.toString());

            // 测试购买代币 ，并发送事件
            // https://ethereum-waffle.readthedocs.io/en/latest/matchers.html#emitting-events
            await expect(
                vendorContract.connect(addr1).buyTokens({
                    value: amount,
                }),
            )
                .to.emit(vendorContract, 'BuyTokens')   // 发送事件
                .withArgs(addr1.address, amount, amount.mul(tokensPerEth)); // 发送事件参数

            // 验证 addr1 的余额和数量是否一致
            const userTokenBalance = await tokenContract.balanceOf(addr1.address);
            const userTokenAmount = ethers.utils.parseEther((buyAmount * tokensPerEth).toString());
            expect(userTokenBalance).to.equal(userTokenAmount);

            // 验证合约中的余额是否 900
            const vendorTokenBalance = await tokenContract.balanceOf(vendorContract.address);
            expect(vendorTokenBalance).to.equal(vendorTokensSupply.sub(userTokenAmount));

            // 查看合约中是否有 1 ETH
            // https://docs.ethers.io/v5/api/providers/provider/
            const vendorBalance = await ethers.provider.getBalance(vendorContract.address);
            expect(vendorBalance).to.equal(amount);
        });
    });

    describe('Test withdraw() method', () => {
        it('转帐帐号是否为合约拥有者', async () => {
            await expect(vendorContract.connect(addr1).withdraw()).to.be.revertedWith('Ownable: caller is not the owner');
        });

        it('不有足够的余额可转出', async () => {
            await expect(vendorContract.connect(owner).withdraw()).to.be.revertedWith('Owner has not balance to withdraw');
        });

        it('withdraw 转出所有ETH成功', async () => {
            const ethOfTokenToBuy = ethers.utils.parseEther('1');

            // 买入 Token
            await vendorContract.connect(addr1).buyTokens({
                value: ethOfTokenToBuy,
            });

            // withdraw operation
            const txWithdraw = await vendorContract.connect(owner).withdraw();

            // Check that the Vendor's balance has 0 eth
            const vendorBalance = await ethers.provider.getBalance(vendorContract.address);
            expect(vendorBalance).to.equal(0);

            // 测试交易是否改变账户余额 为 1 eth
            await expect(txWithdraw).to.changeEtherBalance(owner, ethOfTokenToBuy);
        });
    });

    describe('Test sellTokens() method', () => {
        it('测试卖出代币为0', async () => {
            const amountToSell = ethers.utils.parseEther('0');
            await expect(vendorContract.connect(addr1).sellTokens(amountToSell)).to.be.revertedWith(
                'Specify an amount of token greater than zero',
            );
        });

        it('测试没有足够的代币卖出', async () => {
            const amountToSell = ethers.utils.parseEther('1');
            await expect(vendorContract.connect(addr1).sellTokens(amountToSell)).to.be.revertedWith(
                'Your balance is lower than the amount of tokens you want to sell',
            );
        });

        it('测试 owner 没有足够的ETH供卖出代币', async () => {
            // User 1 buy
            const ethOfTokenToBuy = ethers.utils.parseEther('1');

            // 使用 add1 买入 1 ether 的代币
            await vendorContract.connect(addr1).buyTokens({
                value: ethOfTokenToBuy,
            });

            // 将所有 ETH 转出
            await vendorContract.connect(owner).withdraw();

            const amountToSell = ethers.utils.parseEther('100');
            await expect(vendorContract.connect(addr1).sellTokens(amountToSell)).to.be.revertedWith(
                'Vendor has not enough funds to accept the sell request',
            );
        });

        it('买入代币，未设置可花费代币是否有异常', async () => {
            // User 1 buy
            const ethOfTokenToBuy = ethers.utils.parseEther('1');

            // 使用 add1 买入 1 ether 的代币
            await vendorContract.connect(addr1).buyTokens({
                value: ethOfTokenToBuy,
            });

            const amountToSell = ethers.utils.parseEther('100');

            await expect(vendorContract.connect(addr1).sellTokens(amountToSell)).to.be.revertedWith(
                'ERC20: insufficient allowance',
            );
        });

        it('买、卖代币以及余额测试', async () => {
            // addr1 buy 1 ETH of tokens
            const ethOfTokenToBuy = ethers.utils.parseEther('1');

            // 使用 add1 买入 1 ether 的代币
            await vendorContract.connect(addr1).buyTokens({
                value: ethOfTokenToBuy,
            });

            // 设置 addr1 可拥有 vendor 合约的数量 为 1 ETH 比例的代币数量
            const amountToSell = ethers.utils.parseEther('100');
            await tokenContract.connect(addr1).approve(vendorContract.address, amountToSell);

            // 获取 addr1 中可花费的代币数量
            const vendorAllowance = await tokenContract.allowance(addr1.address, vendorContract.address);
            // 检查 vendor 合约是否有足够的代币可以出售
            expect(vendorAllowance).to.equal(amountToSell);

            // 卖出 代币
            const sellTx = await vendorContract.connect(addr1).sellTokens(amountToSell);

            // 获取 vendor 持有的代币数量
            const vendorTokenBalance = await tokenContract.balanceOf(vendorContract.address);
            // 检查卖出后的代币数量是否还是 1000
            expect(vendorTokenBalance).to.equal(ethers.utils.parseEther('1000'));

            // 检查 addr1 的代币数量是否为0
            const userTokenBalance = await tokenContract.balanceOf(addr1.address);
            expect(userTokenBalance).to.equal(0);

            // Check that the user's ETH balance is 1
            const userEthBalance = ethers.utils.parseEther('1');
            await expect(sellTx).to.changeEtherBalance(addr1, userEthBalance);
        });
    });

});