<template>
  <div class="userDetail">
    <div style="width: 0; height: 0; display: none">
      <p>
        {{ info }}
      </p>
    </div>
    <div>
      <a-card title="账户信息" class="ud-card">
        <div>
          <a-row :gutter="16" type="flex" justify="center">
            <a-col :span="6">
              <a-statistic title="账户名" :value="username" />
              <template #suffix>
                <a-icon type="pay-circle" />
              </template>
              <!-- <a-statistic title="Feedback" :value="1128" style="margin-right: 50px">
                <template #suffix>
                  <a-icon type="like" />
                </template>
              </a-statistic> -->
            </a-col>
            <a-col :span="6">
              <a-statistic title="账户类型" :value="accountType" />
              <!-- <a-statistic title="Unmerged" :value="93" class="demo-class">
                <template #suffix>
                  <span> / 100</span>
                </template>
              </a-statistic> -->
            </a-col>
            <a-col :span="6">
              <a-statistic title="账户余额 (CNY)" :precision="2" :value="accountBalance" />
              <!-- <a-statistic title="Unmerged" :value="93" class="demo-class">
                <template #suffix>
                  <span> / 100</span>
                </template>
              </a-statistic> -->
            </a-col>
          </a-row>
        </div>
      </a-card>
    </div>
    <div>
      <a-card title="应还账单" style="max-width: 800px; margin: 0 auto">
        <a-list item-layout="horizontal" :data-source="asPayer">
          <a-list-item slot="renderItem" slot-scope="item">
            <a slot="actions" :href="'/invoice?invoiceId=' + item.id">单据详情</a>
            <a-list-item-meta
              :description="'支付方：' + item.payerCompanyName + ' | 收款方：' + item.payeeeCompanyName"
            >
              <a slot="title">单据编号 : {{ item.id }}</a>
              <a-avatar slot="avatar" icon="pay-circle" />
            </a-list-item-meta>
          </a-list-item>
        </a-list>
      </a-card>
    </div>
    <div>
      <a-card title="应收账单" style="max-width: 800px; margin: 0 auto">
        <a-list item-layout="horizontal" :data-source="asPayee">
          <a-list-item slot="renderItem" slot-scope="item">
            <a slot="actions" :href="'/invoice?invoiceId=' + item.id">单据详情</a>
            <a-list-item-meta
              :description="'支付方：' + item.payerCompanyName + ' | 收款方：' + item.payeeeCompanyName"
            >
              <a slot="title">单据编号 : {{ item.id }}</a>
              <a-avatar slot="avatar" icon="pay-circle" />
            </a-list-item-meta>
          </a-list-item>
        </a-list>
      </a-card>
    </div>
  </div>
</template>

<script>
export default {
  name: 'UserDetail',
  props: {
  },
  data: function () {
    return {
      info: [],
      username: null,
      accountType: null,
      accountBalance: null,
      tfinvoices: [],
      tfpayer: [],
      tfpayee: []
    }
  },
  computed: {
    asPayer: function() {
      if (this.info.length == 0) {
        return []
      }
      let invoiceList = this.info.data._embedded.invoiceList
      let list = invoiceList.filter(data => data.payerCompanyName == this.username)
      return list.concat(this.tfpayer)
    },
    asPayee: function() {
      if (this.info.length == 0) {
        return []
      }
      let invoiceList = this.info.data._embedded.invoiceList
      let list = invoiceList.filter(data => data.payeeeCompanyName == this.username)
      return list.concat(this.tfpayee)
    },
    invoices: function () {
      if (this.info.length == 0) {
        return []
      }
      let invoiceList = this.info.data._embedded.invoiceList
      return invoiceList.filter(data => data.payerCompanyName == this.username || data.payeeeCompanyName == this.username)
    }
  },
  mounted () {
    this.username = localStorage.getItem('username')
    this.accountType = "非银行"
    if (!localStorage.getItem(this.username + '_balance')) {
      localStorage.setItem(this.username + '_balance', 0)
    }
    if (localStorage.getItem('tfinvoices')) {
      try {
        this.tfinvoices = JSON.parse(localStorage.getItem('tfinvoices'))
      } catch(e) {
        localStorage.removeItem('tfinvoices')
      }
    }
    this.accountBalance = localStorage.getItem(this.username + '_balance')
    this.axios
      .get('/AllInvoices')
      .then(
        response => {
          console.log(typeof(response.data._embedded))
          console.log(typeof(response.data._embedded.invoiceList) === "undefined")
          console.log(response.data._embedded.invoiceList)
          if(typeof(response.data._embedded) === "undefined" ||
             typeof(response.data._embedded.invoiceList) === "undefined" ) {
            console.log('empty response')
            this.info = [];
          }
          else {
            this.info = response
          }
        },
        error => {
          console.log('error', error)
        }
      )
    for (let i = 0; i < this.tfinvoices.length; i++) {
      if (this.tfinvoices[i]) {
        let that = this
        this.axios
          .get('/GetTransferInvoice/' + this.tfinvoices[i])
          .then(
            response => {
              let data = response.data
              // console.log('tf', data)
              // console.log('user', that.username)
              // console.log('tf', data.payeeeCompanyName == that.username)
              // console.log('tf', data.payerCompanyName == that.username)
              if (data.payeeeCompanyName == that.username) {
                this.tfpayee.push(data)
              }
              else if (data.payerCompanyName == that.username) {
                this.tfpayer.push(data)
              }
            },
            error => {
              console.log('error', error)
            }
          )
      }
    }
  },
  methods: {
    goBack () {
      window.history.length > 1 ? this.$router.go(-1) : this.$router.push('/')
    },
    openNotification (err) {
      this.$notification.open({
        message: '查询出错',
        description: err,
        placement: 'topLeft',
        onClick: () => {
          console.log('Notification Clicked!')
        }
      })
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
.userDetail {
  margin: 24px 100px;
  padding-bottom: 32px;
}

.goBackButton {
  padding-top: 24px
}

.ud-card {
  max-width: 800px;
  margin: 0 auto;
}

.ant-list-item-meta-title,
.ant-list-item-meta-description {
  text-align: left;
  color: rgba(0, 0, 0, 0.9);
}
</style>
