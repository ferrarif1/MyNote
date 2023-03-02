<template>
  <div>
    <el-divider>设置参数</el-divider>
    <el-row>
      <el-col :span="18">
        <el-form label-position="right" label-width="80px" :model="walletForm" :rules="wallet_rules" ref="walletForm">
          <el-form-item label="冻结占比" prop="proportion">
            <el-input type="text" placeholder="冻结比例：(10,20,30,...)" v-model.number="walletForm.proportion"></el-input>
          </el-form-item>
          <el-form-item label="间隔高度" prop="spaceHeight">
            <el-input type="text" placeholder="间隔解冻高度" v-model.number="walletForm.spaceHeight"></el-input>
          </el-form-item>
        </el-form>
      </el-col>
      <el-col :span="6">
        <el-button @click="onSetVip('walletForm')" type="warning">提交</el-button>
      </el-col>
    </el-row>

    <el-divider>会员注册</el-divider>
    <el-row>
      <el-col :span="18">
        <el-form label-position="right" label-width="80px" :model="txForm" :rules="rules" ref="txForm">
          <el-form-item label="to" prop="to">
            <el-input type="text" placeholder="发送地址" v-model="txForm.to"></el-input>
          </el-form-item>
          <el-form-item label="token" prop="token">
            <el-input type="text" placeholder="token 购买数量" v-model="txForm.token"></el-input>
          </el-form-item>
          <el-form-item label="eth" prop="eth">
            <el-input type="text" placeholder="eth 充值数量" v-model="txForm.eth"></el-input>
          </el-form-item>
        </el-form>
      </el-col>
      <el-col :span="6">
        <el-button @click="onRegMember('txForm')" type="danger">注册</el-button>
      </el-col>
    </el-row>
    <el-divider>Token解冻</el-divider>
    <el-row>
      <el-col :span="6">
        <el-button @click="onThawAmount" type="success">会员Token解冻</el-button>
      </el-col>
    </el-row>
    <el-dialog :title="title" :visible.sync="dialogVisible" style="text-align: left" width="80%">
      <json-viewer :value="msg" :expand-depth="5" copyable boxed sort preview-mode/>
    </el-dialog>
  </div>
</template>

<script>
import {thawAmount, registeredMember, setVipConf} from '../utils/wallets'

export default {
  name: 'Business',
  data () {
    return {
      msg:"",
      dialogVisible:false,
      title:"",

      txForm: {
        to: '',
        token: '',
        eth: '',
      },
      walletForm: {
        proportion: 0,
        spaceHeight: 0,
      },
      rules: {
        to: [
          {required: true, message: 'to不能为空', trigger: 'blur'}
        ],
        token: [
          {required: true, message: 'token不能为空', trigger: 'blur'}
        ],
        eth: [
          {required: true, message: 'eth不能为空', trigger: 'blur'}
        ],
      },
      wallet_rules: {
        proportion: [
          { required: true, message: '不能为空', trigger: 'blur'},
          { type: 'number', message: '必须为数字值'}
        ],
        spaceHeight: [
          { required: true, message: '不能为空', trigger: 'blur'},
          { type: 'number', message: '必须为数字值'}
        ],
      }
    }
  },
  methods: {

    async onRegMember (txForm) {
      this.$refs[txForm].validate(async (valid) => {
        if (valid) {
          let reciept = await registeredMember(this.txForm.to, this.txForm.token, this.txForm.eth)
          if(reciept !== undefined){
            this.msg = reciept
            this.title = '回执结果'
            this.dialogVisible = true
          }
        }
      })
    },
    async onThawAmount() {
      await thawAmount()
    },
    async onSetVip(walletFrom) {
      this.$refs[walletFrom].validate(async (valid) => {
        if (valid) {
          await setVipConf(this.walletForm.proportion, this.walletForm.spaceHeight)
        }
      })
    }
  }
}
</script>

<style scoped>

</style>
