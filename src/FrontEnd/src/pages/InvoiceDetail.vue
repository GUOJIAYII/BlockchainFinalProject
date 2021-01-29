<template>
  <div class="invoiceDetail">
    <!-- <div>
      <p>
        {{ info }}
      </p>
    </div> -->
    <div>
      <a-descriptions title="单据详情" bordered>
        <a-descriptions-item label="支付方">
          {{ info.data.payerCompanyName }}
        </a-descriptions-item>
        <a-descriptions-item label="收款方">
          {{ info.data.payeeeCompanyName }}
        </a-descriptions-item>
        <a-descriptions-item label="单据编号">
          {{ invoiceId }}
        </a-descriptions-item>
        <a-descriptions-item label="单据模式">
          待付
        </a-descriptions-item>
        <a-descriptions-item label="Status" :span="3">
          <a-badge status="processing" text="Running" />
        </a-descriptions-item>
        <a-descriptions-item label="收款截止日期" :span="2">
          {{ info.data.invoiceDeadline }}
        </a-descriptions-item>
        <a-descriptions-item label="应收账款">
          {{ info.data.invoiceAmount }}
        </a-descriptions-item>
      </a-descriptions>
    </div>
    <div class="goBackButton">
    <a-button type="primary" @click="goBack"> <a-icon type="left" /> 返回 </a-button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'InvoiceDetail',
  props: {
  },
  data: function () {
    return {
      info: null
    }
  },
  computed: {
    invoiceId: function () {
      return this.$route.query.invoiceId
    }
  },
  mounted () {
    this.axios
      .get('/AllInvoices/' + this.invoiceId)
      .then(
        response => {
          this.info = response
        },
        error => {
          console.log('error', error)
          this.axios
            .get('/GetTransferInvoice/' + this.invoiceId)
            .then(
              response => {
                this.info = response
              },
              error => {
                console.log('error', error)
                this.openNotification(this.invoiceId)
                this.goBack()
              }
            )
        }
      )
  },
  methods: {
    goBack () {
      window.history.length > 1 ? this.$router.go(-1) : this.$router.push('/')
    },
    openNotification (id) {
      this.$notification.open({
        message: '单据不存在',
        description:
          '单据编号为 ' + id + ' 的单据不存在，请核实后再重新操作',
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
.invoiceDetail {
  margin: 24px 100px;
}

.goBackButton {
  padding-top: 24px
}
</style>
