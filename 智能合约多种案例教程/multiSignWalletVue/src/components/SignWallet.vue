<template>
  <div>
    <el-divider>交易内容编码</el-divider>
    <el-row>
      <el-col :span="18">
        <el-form label-position="right" label-width="80px" :model="txForm" :rules="rules" ref="txForm" >
          <el-form-item label="to"  prop="to">
            <el-input type="text" placeholder="发送地址"  v-model="txForm.to"></el-input>
          </el-form-item>
          <el-form-item label="value" prop="value">
            <el-input type="text" placeholder="转账数量 = 数量 * (10^18)" v-model="txForm.value"></el-input>
          </el-form-item>
          <el-form-item label="data" prop="data">
            <el-input type="text" placeholder="默认传：0x" v-model="txForm.data"></el-input>
          </el-form-item>
          <el-form-item label="tx_type" prop="tx_type">
            <el-input type="text" placeholder="0-token交易，1-eth交易" v-model="txForm.tx_type"></el-input>
          </el-form-item>
          <el-form-item label="nonce" prop="nonce">
            <el-input type="text" placeholder="交易序号，防止双花" v-model="txForm.nonce"></el-input>
          </el-form-item>
          <el-form-item label="chainId" prop="chainId">
            <el-input  type="text" placeholder="链ID" v-model="txForm.chainId"></el-input>
          </el-form-item>
        </el-form>
      </el-col>
      <el-col :span="6"><el-button @click="encodeTxData('txForm')" type="danger">提交</el-button></el-col>
    </el-row>

    <el-row :hidden="true">
      结果: TxDataHash: {{msg}}
    </el-row>
    <el-divider>Hex内容签名</el-divider>
    <el-row>
      <el-col :span="18">
        <el-form label-position="right" label-width="80px">
          <el-form-item label="TxDataHash:">
            <el-input placeholder="TxDataHash数据" type="textarea" v-model="TxDataHex"/>
          </el-form-item>
        </el-form>
      </el-col>
      <el-col :span="6"><el-button @click="onSignMessage" type="primary">签名</el-button></el-col>
    </el-row>

    <el-divider>多签合并</el-divider>
    <el-row>
      <el-col :span="18">
        <el-form label-position="right" label-width="80px">
          <el-form-item label="TxDataHash:">
            <el-input v-model="multiSigns" placeholder="多人签名结果输入，用 ',' 分开" type="textarea"/>
          </el-form-item>
        </el-form>
      </el-col>
      <el-col :span="6">
        <el-button @click="signSplit" type="primary">合并</el-button>
      </el-col>
    </el-row>

    <el-divider>签名校验</el-divider>
    <el-row>
      <el-col :span="18">
        <el-form label-position="right" label-width="80px" :model="checkForm">
          <el-form-item label="TxDataHash:">
            <el-input placeholder="TxDataHash数据" type="textarea" v-model="checkForm.TxDataHash"/>
          </el-form-item>
          <el-form-item label="signatures:">
            <el-input placeholder="签名结果" type="textarea" v-model="checkForm.signatures"/>
          </el-form-item>
        </el-form>
      </el-col>
      <el-col :span="6">
        <el-button @click="onCheckSignatures" type="warning">校验</el-button>
      </el-col>
    </el-row>

    <el-divider>交易签名执行</el-divider>
    <el-row>
      <el-col :span="18">
        <el-form label-position="right" label-width="80px" :model="signForm">
          <el-form-item label="to:">
            <el-input type="text" placeholder="发送地址"  v-model="signForm.to"></el-input>
          </el-form-item>
          <el-form-item label="value:">
            <el-input type="text" placeholder="转账数量(个)" v-model="signForm.value"></el-input>
          </el-form-item>
          <el-form-item label="data:">
            <el-input type="text" placeholder="默认传：0x" v-model="signForm.data"></el-input>
          </el-form-item>
          <el-form-item label="tx_type:">
            <el-input type="text" placeholder="0-token交易，1-eth交易" v-model="signForm.tx_type"></el-input>
          </el-form-item>
          <el-form-item label="signatures:">
            <el-input placeholder="签名结果" type="textarea" v-model="signForm.signatures"/>
          </el-form-item>
        </el-form>
      </el-col>
      <el-col :span="6">
        <el-button @click="onExcSignatures" type="danger">执行</el-button>
      </el-col>
    </el-row>
    <el-dialog :title="title" :visible.sync="dialogVisible" style="text-align: left" width="80%">
      <json-viewer :value="msg" :expand-depth="5" copyable boxed sort preview-mode/>
    </el-dialog>
  </div>
</template>

<script>
import {checkSignatures, encodeTransactionData, execTransaction, signMessage} from '../utils/wallets'

export default {
  name: 'SignWallet',
  data(){
    return{
      msg:"",
      dialogVisible:false,
      title:"",
      multiSigns:"",
      TxDataHex: undefined,
      checkForm: {
        TxDataHash: '',
        signatures: '',
      },

      txForm: {
        to:"",
        value:"",
        data:"",
        tx_type:"",
        nonce:"",
        chainId:"",
      },

      signForm:{
        to:"",
        value:"",
        data:"",
        tx_type:"",
        signatures: '',
      },
      rules: {
        to: [
          { required: true, message: 'to不能为空', trigger: 'blur' }
        ],
        value: [
          { required: true, message: 'value不能为空', trigger: 'blur' }
        ],
        data: [
          { required: true, message: 'data不能为空', trigger: 'blur' }
        ],
        tx_type: [
          { required: true, message: 'tx_type不能为空', trigger: 'blur' }
        ],
        nonce: [
          { required: true, message: 'nonce不能为空', trigger: 'blur' }
        ],
        chainId: [
          { required: true, message: 'chainId不能为空', trigger: 'blur' }
        ]
      }
    }
  },
  methods:{
    signSplit(){
      let newStr =""
      if(this.multiSigns !==""){
        this.multiSigns = this.multiSigns.replaceAll('"',"");
        let arr = this.multiSigns.split(',');
        for (let i = 0; i < arr.length; i++) {
          newStr += arr[i].replace('0x',"");
        }
        this.msg = '0x' + newStr
        this.title = '合并结果'
        this.dialogVisible = true
      }
    },
    async onSignMessage(){
      if(this.TxDataHex !==""){
        console.log("待签名内容",this.TxDataHex)
        this.msg = await signMessage(this.TxDataHex.replaceAll('"',""))
        this.title = '结果'
        this.dialogVisible = true
      }
    },
    async encodeTxData(txForm) {
      this.$refs[txForm].validate(async (valid) => {
        if (valid) {
          this.msg = await encodeTransactionData(
            this.txForm.to,
            this.txForm.value,
            this.txForm.data,
            this.txForm.nonce,
            this.txForm.tx_type,
            this.txForm.chainId)
            this.dialogVisible = true
            this.title="交易编码结果"
        } else {
          return false;
        }
      });
    },
    async onCheckSignatures(){
      let exc = await checkSignatures(
        this.checkForm.TxDataHash.replaceAll('"',""),
        this.checkForm.signatures.replaceAll('"',"")
      )
      if (exc){
        await this.$alert("签名正常，可以执行", '结果');
      }
    },
    async onExcSignatures(){

      let exc = await execTransaction(
        this.signForm.to,
        this.signForm.value,
        this.signForm.data,
        this.signForm.tx_type,
        this.signForm.signatures.replaceAll('"',"")
      )
      if (exc){
        await this.$alert("签名执行完成", '结果');
      }
    }
  }
}
</script>

<style scoped>

</style>
