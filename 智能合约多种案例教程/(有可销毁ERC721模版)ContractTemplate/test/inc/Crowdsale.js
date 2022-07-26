const assert = require('assert');
const { ether,  constants, expectEvent } = require('@openzeppelin/test-helpers');
exports.token = () => {
    it('ERC20代币地址: token()', async function () {
        assert.equal(ERC20Instance.address, await CrowdsaleInstance.token());
    });
}
exports.wallet = (sender) => {
    it('ETH受益人地址: wallet()', async function () {
        assert.equal(sender, await CrowdsaleInstance.wallet());
    });
}
exports.rate = (rate) => {
    it('兑换比例: rate()', async function () {
        assert.equal(rate, await CrowdsaleInstance.rate());
    });
}
exports.tokenWallet = (owner) => {
    it('代币现存地址: tokenWallet()', async function () {
        assert.equal(owner, await CrowdsaleInstance.tokenWallet());
    });
}
exports.buyTokens = (sender, amount, desc, reject, msg) => {
    //测试购买代币方法
    it(desc + ': buyTokens()', async function () {
        if (reject) {
            await assert.rejects(CrowdsaleInstance.buyTokens(sender, { value: ether(amount), from: sender }), msg);
        } else {
            let receipt = await CrowdsaleInstance.buyTokens(sender, { value: ether(amount), from: sender });
            expectEvent(receipt, 'TokensPurchased', {
                purchaser: sender,
                beneficiary: sender,
                value: ether(amount),
                amount: ether((amount * rate).toString())
            });
        }
    });
}
exports.remainingTokens = (amount, desc) => {
    //测试剩余代币数量
    it(desc + ': remainingTokens()', async function () {
        assert.equal(ether(amount.toString()).toString(), (await CrowdsaleInstance.remainingTokens()).toString());
    });
}
exports.weiRaised = (amount, desc) => {
    //测试众筹收入
    it(desc + ': weiRaised()', async function () {
        assert.equal(ether(amount).toString(), (await CrowdsaleInstance.weiRaised()).toString());
    });
}
exports.cap = (cap) => {
    it('封顶数额: cap()', async function () {
        assert.equal(ether(cap).toString(), (await CrowdsaleInstance.cap()).toString());
    });
}
exports.capReached = (capReached, desc) => {
    //测试是否到达封顶
    it(desc + ': capReached()', async function () {
        assert.equal(capReached, await CrowdsaleInstance.capReached());
    });
}
exports.addCapper = (capper, sender, desc, reject, msg) => {
    //测试添加配额管理员
    it(desc + ': addCapper()', async function () {
        if (reject) {
            await assert.rejects(CrowdsaleInstance.addCapper(capper, { from: sender }), msg);
        } else {
            let receipt = await CrowdsaleInstance.addCapper(capper, { from: sender });
            expectEvent(receipt, 'CapperAdded', {
                account: capper
            });
        }
    });
}
exports.isCapper = (capper, isCapper, desc) => {
    //测试账户是否是配额管理员
    it(desc + ': isCapper()', async function () {
        assert.equal(isCapper, await CrowdsaleInstance.isCapper(capper));
    });
}
exports.renounceCapper = (capper, desc, reject, msg) => {
    //测试撤销配额管理员
    it(desc + ': renounceCapper()', async function () {
        if (reject) {
            await assert.rejects(CrowdsaleInstance.renounceCapper({ from: capper }), msg);
        } else {
            let receipt = await CrowdsaleInstance.renounceCapper({ from: capper });
            expectEvent(receipt, 'CapperRemoved', {
                account: capper
            });
        }
    });
}
exports.setCap = (beneficiary, capper, amount, desc, reject, msg) => {
    //测试设置配额方法
    it(desc + ': setCap()', async function () {
        if (reject) {
            await assert.rejects(CrowdsaleInstance.setCap(beneficiary, ether(amount), { from: capper }), msg);
        } else {
            await CrowdsaleInstance.setCap(beneficiary, ether(amount), { from: capper });
        }
    });
}
exports.getCap = (beneficiary, amount, desc) => {
    //测试获取账户配额方法
    it(desc + ': getCap()', async function () {
        assert.equal(ether(amount).toString(), (await CrowdsaleInstance.getCap(beneficiary)).toString());
    });
}
exports.getContribution = (beneficiary, amount, desc) => {
    //测试获取账户贡献方法
    it(desc + ': getContribution()', async function () {
        assert.equal(ether(amount).toString(), (await CrowdsaleInstance.getContribution(beneficiary)).toString());
    });
}
exports.addPauser = (pauser, sender, desc, reject, msg) => {
    //测试添加暂停管理员
    it(desc + ': addPauser()', async function () {
        if (reject) {
            await assert.rejects(CrowdsaleInstance.addPauser(pauser, { from: sender }), msg);
        } else {
            let receipt = await CrowdsaleInstance.addPauser(pauser, { from: sender });
            expectEvent(receipt, 'PauserAdded', {
                account: pauser
            });
        }
    });
}
exports.isPauser = (pauser, isPauser, desc) => {
    //测试账户拥有暂停权
    it(desc + ': isPauser()', async function () {
        assert.equal(isPauser, await CrowdsaleInstance.isPauser(pauser));
    });
}
exports.renouncePauser = (pauser, desc, reject, msg) => {
    //测试撤销暂停管理员
    it(desc + ': renouncePauser()', async function () {
        if (reject) {
            await assert.rejects(CrowdsaleInstance.renouncePauser({ from: pauser }), msg);
        } else {
            let receipt = await CrowdsaleInstance.renouncePauser({ from: pauser });
            expectEvent(receipt, 'PauserRemoved', {
                account: pauser
            });
        }
    });
}
exports.paused = (paused, desc) => {
    //测试是否已暂停
    it(desc + ': paused()', async function () {
        assert.equal(paused, await CrowdsaleInstance.paused());
    });
}
exports.pause = (pauser, desc, reject, msg) => {
    //测试撤销暂停管理员
    it(desc + ': pause()', async function () {
        if (reject) {
            await assert.rejects(CrowdsaleInstance.pause({ from: pauser }), msg);
        } else {
            let receipt = await CrowdsaleInstance.pause({ from: pauser });
            expectEvent(receipt, 'Paused', {
                account: pauser
            });
        }
    });
}
exports.unpause = (pauser, desc, reject, msg) => {
    //测试恢复合约
    it(desc + ': unpause()', async function () {
        if (reject) {
            await assert.rejects(CrowdsaleInstance.unpause({ from: pauser }), msg);
        } else {
            let receipt = await CrowdsaleInstance.unpause({ from: pauser });
            expectEvent(receipt, 'Unpaused', {
                account: pauser
            });
        }
    });
}
exports.isOpen = (isOpen, desc) => {
    //测试众筹是否开始
    it(desc + ': isOpen()', async function () {
        assert.equal(isOpen, await CrowdsaleInstance.isOpen());
    });
}
exports.hasClosed = (hasClosed, desc) => {
    //测试等待关闭
    it(desc + ': hasClosed()', async function () {
        assert.equal(hasClosed, await CrowdsaleInstance.hasClosed());
    });
}
exports.addWhitelistAdmin = (whitelistAdmin, sender, desc, reject, msg) => {
    //测试添加白名单管理员
    it(desc + ': addWhitelistAdmin()', async function () {
        if (reject) {
            await assert.rejects(CrowdsaleInstance.addWhitelistAdmin(whitelistAdmin, { from: sender }), msg);
        } else {
            let receipt = await CrowdsaleInstance.addWhitelistAdmin(whitelistAdmin, { from: sender });
            expectEvent(receipt, 'WhitelistAdminAdded', {
                account: whitelistAdmin
            });
        }
    });
}
exports.isWhitelistAdmin = (whitelistAdmin, isWhitelistAdmin, desc) => {
    //测试账户是白名单管理员
    it(desc + ': isWhitelistAdmin()', async function () {
        assert.equal(isWhitelistAdmin, await CrowdsaleInstance.isWhitelistAdmin(whitelistAdmin));
    });
}
exports.renounceWhitelistAdmin = (whitelistAdmin, desc, reject, msg) => {
    //测试撤销白名单管理员
    it(desc + ': renounceWhitelistAdmin()', async function () {
        if (reject) {
            await assert.rejects(CrowdsaleInstance.renounceWhitelistAdmin({ from: whitelistAdmin }), msg);
        } else {
            let receipt = await CrowdsaleInstance.renounceWhitelistAdmin({ from: whitelistAdmin });
            expectEvent(receipt, 'WhitelistAdminRemoved', {
                account: whitelistAdmin
            });
        }
    });
}
exports.addWhitelisted = (whitelist, sender, desc, reject, msg) => {
    //测试添加白名单
    it(desc + ': addWhitelisted()', async function () {
        if (reject) {
            await assert.rejects(CrowdsaleInstance.addWhitelisted(whitelist, { from: sender }), msg);
        } else {
            let receipt = await CrowdsaleInstance.addWhitelisted(whitelist, { from: sender });
            expectEvent(receipt, 'WhitelistedAdded', {
                account: whitelist
            });
        }
    });
}
exports.isWhitelisted = (whitelist, isWhitelisted, desc) => {
    //测试账户是白名单
    it(desc + ': isWhitelisted()', async function () {
        assert.equal(isWhitelisted, await CrowdsaleInstance.isWhitelisted(whitelist));
    });
}
exports.removeWhitelisted = (whitelist, whitelistAdmin, desc, reject, msg) => {
    //测试删除白名单
    it(desc + ': removeWhitelisted()', async function () {
        if (reject) {
            await assert.rejects(CrowdsaleInstance.removeWhitelisted(whitelist, { from: whitelistAdmin }), msg);
        } else {
            let receipt = await CrowdsaleInstance.removeWhitelisted(whitelist, { from: whitelistAdmin });
            expectEvent(receipt, 'WhitelistedRemoved', {
                account: whitelist
            });
        }
    });
}
exports.renounceWhitelisted = (whitelist, desc, reject, msg) => {
    //测试撤销白名单
    it(desc + ': renounceWhitelisted()', async function () {
        if (reject) {
            await assert.rejects(CrowdsaleInstance.renounceWhitelisted({ from: whitelist }), msg);
        } else {
            let receipt = await CrowdsaleInstance.renounceWhitelisted({ from: whitelist });
            expectEvent(receipt, 'WhitelistedRemoved', {
                account: whitelist
            });
        }
    });
}
exports.finalize = (desc, reject, msg) => {
    //测试结束众筹
    it(desc + ': finalize()', async function () {
        if (reject) {
            await assert.rejects(CrowdsaleInstance.finalize(), msg);
        } else {
            let receipt = await CrowdsaleInstance.finalize();
            expectEvent(receipt, 'CrowdsaleFinalized');
        }
    });
}
exports.finalized = (finalized, desc) => {
    //测试是否已结束
    it(desc + ': finalized()', async function () {
        assert.equal(finalized, await CrowdsaleInstance.finalized());
    });
}
exports.balanceOf = (balance, account, desc) => {
    //测试众筹账户余额
    it(desc + ': balanceOf()', async function () {
        assert.equal(ether(balance).toString(), (await CrowdsaleInstance.balanceOf(account)).toString());
    });
}
exports.withdrawTokens = (account, desc, reject, msg) => {
    //测试从众筹账户提款
    it(desc + ': withdrawTokens()', async function () {
        if (reject) {
            await assert.rejects(CrowdsaleInstance.withdrawTokens(account), msg);
        } else {
            await CrowdsaleInstance.withdrawTokens(account);
        }
    });
}
exports.claimRefund = (account, desc, reject, msg) => {
    //测试从众筹账户退款
    it(desc + ': claimRefund()', async function () {
        if (reject) {
            await assert.rejects(CrowdsaleInstance.claimRefund(account), msg);
        } else {
            await CrowdsaleInstance.claimRefund(account);
        }
    });
}
exports.goalReached = (goalReached, desc) => {
    //测试是否到达众筹目标
    it(desc + ': goalReached()', async function () {
        assert.equal(goalReached, await CrowdsaleInstance.goalReached());
    });
}