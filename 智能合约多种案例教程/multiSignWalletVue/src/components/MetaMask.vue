<template>
<div>
  <el-row :gutter="20">
    <el-col :span="6"><div class="grid-content"/></el-col>
    <el-col :span="12">
        <BaseInfo/>
        <Search/>
        <SignWallet/>
        <Business/>
    </el-col>
    <el-col :span="6"><div class="grid-content"/></el-col>
  </el-row>
</div>
</template>

<script>
import Search from "./Search.vue"
import BaseInfo from "./BaseInfo.vue"
import SignWallet from "./SignWallet.vue"
import Business from "./Business.vue"
export default {
  components:{
    Search,
    BaseInfo,
    SignWallet,
    Business
  },
  data() {
    return {
    }
  },
  methods: {
  }
}
</script>

<style>
.el-row {
  margin-bottom: 20px;
&:last-child {
   margin-bottom: 0;
 }
}
.el-col {
  border-radius: 4px;
}
.bg-purple-dark {
  background: #99a9bf;
}

.bg-purple-light {
  background: #e5e9f2;
}
.grid-content {
  border-radius: 4px;
  min-height: 36px;
}
.row-bg {
  padding: 10px 0;
  background-color: #f9fafc;
}
.el-table .warning-row {
  background: oldlace;
}
.el-table .success-row {
  background: #f0f9eb;
}
</style>
