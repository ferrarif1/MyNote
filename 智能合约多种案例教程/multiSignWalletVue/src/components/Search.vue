<template>
    <div>
      <el-divider>查询</el-divider>
      <el-row >
        <el-col :span="18"><el-input placeholder="高度、区块hash" v-model="form.hashOrHeight"/></el-col>
        <el-col :span="6"><el-button @click="onSearchBlock" type="primary">查询区块</el-button></el-col>
      </el-row>
      <el-row>
        <el-col :span="18"><el-input placeholder="交易Hash" v-model="form.txHash"/></el-col>
        <el-col :span="6"><el-button @click="onSearchTxByHash" type="primary">查询交易信息</el-button></el-col>
      </el-row>

      <el-dialog :title="title" :visible.sync="dialogVisible" style="text-align: left" width="80%">
        <json-viewer :value="block" :expand-depth="5" copyable boxed sort preview-mode/>
      </el-dialog>
  </div>
</template>

<script>
import {getBlock, getTransactionInfo} from '../utils/wallets'

export default {
  name: 'Search',
  data(){
    return{
      dialogVisible:false,
      title:"",
      block:{},
      form: {
        hashOrHeight: '',
        TxDataHash: '',
        txHash:""
      },
    }
  },
  methods: {
      async onSearchBlock(){
        if (this.form.hashOrHeight!==""){
          this.title = "区块内容"
          this.block = await getBlock(this.form.hashOrHeight);
          this.dialogVisible = true
        }
      },

      async onSearchTxByHash(){
        if (this.form.txHash!==""){
          this.title = "交易信息："+this.form.txHash
          this.block = {}
          this.block = await getTransactionInfo(this.form.txHash);
          this.dialogVisible = true
        }
      }
  }
}
</script>

<style scoped>

</style>
