<template>
  <div>
    <el-divider>基础功能</el-divider>
    <el-row>
      <el-col :span="6">
        <el-button @click="onConnect" type="primary" icon="el-icon-wallet" :disabled="userAddress !==''" >连接钱包
        </el-button>
      </el-col>
      <el-col :span="6">
        <el-button @click="onGetInfo" type="primary" icon="el-icon-s-custom"  :loading="accounting">账号信息</el-button>
      </el-col>
      <el-col :span="6">
        <el-button @click="onBlockNumber" type="primary">区块高度查询</el-button>
      </el-col>
    </el-row>
    <el-row :hidden="tableData.address === '' || tableData.address === undefined">
      <el-descriptions :title="'地址:' + tableData.address">
        <el-descriptions-item label="金额">{{ tableData.amount }}</el-descriptions-item>
        <el-descriptions-item label="交易次数">{{ tableData.count }}</el-descriptions-item>
      </el-descriptions>
    </el-row>
  </div>
</template>

<script>
import {
  ConnectWallet,
  getEthAmount,
  getWalletAddress,
  getBlockNumber,
  getTransactionCount, sendEthToContract
} from '../utils/wallets.js'
import vueJsonEditor from 'vue-json-editor'

export default {
  name: 'BaseInfo',
  components: {vueJsonEditor},
  data () {
    return {
      connecting:false,
      accounting:false,
      vueJsonEditorKeys:"",
      dialogFormVisible: false,
      formLabelWidth: '120px',
      userAddress: '',
      contractForm: {
        address: '',
        abi: undefined
      },
      tableData: {
        address: '',
        amount: 0,
        count: 0
      },
    }
  },
  methods: {
    async onConnect () {
      await ConnectWallet()
      this.userAddress = await getWalletAddress()
    },
    async onGetInfo () {
      this.accounting = true
      await ConnectWallet()
      this.userAddress = await  getWalletAddress()
      console.log("钱包地址",this.userAddress)
      let count = await getTransactionCount(this.userAddress)
      let amount = await getEthAmount(this.userAddress)
      console.log(amount)
      this.tableData = {address: this.userAddress, amount: amount, count: count}
      this.accounting = false
    },

    async onBlockNumber () {
      await ConnectWallet()
      let height = await getBlockNumber()
      console.log(height)
      this.$notify({
        title: '区块高度',
        message: height
      })
    },
    async onBuyVip () {
      await sendEthToContract()
    },
  }
}
</script>

