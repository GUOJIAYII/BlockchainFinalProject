<template>
  <div class="settlement">
    <div>
      <span class="heading">
        结算
      </span>
    </div>
    <div class="settlementForm">
      <a-form
        :form="form"
        layout="horizontal"
        @submit="handleSubmit"
        hideRequiredMark
      >
        <a-form-item label="支付方" :validate-status="userNameError() ? 'error' : ''" :help="userNameError() || ''">
          <a-input
            disabled
            v-decorator="[
              'payerCompanyName',
              { rules: [{ required: true, message: 'Please input payerCompanyName!' }] },
            ]"
            placeholder="payerCompanyName"
          >
            <a-icon slot="prefix" type="user" style="color:rgba(0,0,0,.25)" />
          </a-input>
        </a-form-item>
        <a-form-item label="待结算单据编号" :validate-status="passwordError() ? 'error' : ''" :help="passwordError() || ''">
          <a-input
            v-decorator="[
              'invoiceId',
              { rules: [{ required: true, message: 'Please input invoiceId!' }] },
            ]"
            placeholder="invoiceId"
          >
            <a-icon slot="prefix" type="transaction" style="color:rgba(0,0,0,.25)" />
          </a-input>
        </a-form-item>
        <a-form-item>
          <a-button type="primary" html-type="submit" :disabled="hasErrors(form.getFieldsError())">
            结算
          </a-button>
        </a-form-item>
      </a-form>
    </div>
  </div>
</template>

<script>
function hasErrors (fieldsError) {
  return Object.keys(fieldsError).some(field => fieldsError[field])
}

export default {
  name: 'Settlement',
  props: {
  },
  data: function () {
    return {
      labelCol: {
        xs: { span: 24 },
        sm: { span: 5 }
      },
      wrapperCol: {
        xs: { span: 24 },
        sm: { span: 12 }
      },
      hasErrors,
      form: this.$form.createForm(this, { name: 'settle_invoice' }),
      invoiceId: null,
      payee: null,
      amount: null,
      username: null
    }
  },
  mounted () {
    this.username = localStorage.getItem('username')
    this.form.setFieldsValue({
      payerCompanyName: localStorage.getItem('username')
    })
    this.$nextTick(() => {
      // To disabled submit button at the beginning.
      this.form.validateFields()
    })
  },
  methods: {
    // Only show error after a field is touched.
    userNameError () {
      const { getFieldError, isFieldTouched } = this.form
      return isFieldTouched('userName') && getFieldError('userName')
    },
    // Only show error after a field is touched.
    passwordError () {
      const { getFieldError, isFieldTouched } = this.form
      return isFieldTouched('password') && getFieldError('password')
    },
    handleSubmit (e) {
      e.preventDefault()
      let that = this
      this.form.validateFields((err, values) => {
        if (!err) {
          this.invoiceId = values.invoiceId
          that.axios
            .get('/AllInvoices/' + that.invoiceId)
            .then(
              response => {
                this.payee = response.data.payeeeCompanyName
                this.amount = response.data.invoiceAmount
                console.log('payee', this.payee)
                console.log('amount', this.amount)
                if (!localStorage.getItem(this.username + '_balance')) {
                  localStorage.setItem(this.username + '_balance', 0)
                }
                let newAmount = Number(localStorage.getItem(this.username + '_balance')) - Number(this.amount)
                if (newAmount < 0) {
                  alert("余额不足")
                }
                else {
                  localStorage.setItem(this.username + '_balance', newAmount)
                  if (!localStorage.getItem(this.payee + '_balance')) {
                    localStorage.setItem(this.payee + '_balance', this.amount)
                  }
                  else {
                    let newAmount = Number(localStorage.getItem(this.payee + '_balance')) + Number(this.amount)
                    localStorage.setItem(this.payee + '_balance', newAmount)
                  }
                  console.log('amount', localStorage.getItem(this.payee + '_balance'))
                }
              },
              error => {
                console.log('error', error)
              }
            )
          // 请求
          this.axios.request({
            headers: {
              'Content-Type': 'application/json;charset=UTF-8'
            },
            url: '/PayInvoice/' + values.invoiceId,
            method: 'POST',
            data: JSON.stringify({
            }),
            responseType: 'json'
          }).then(function (response) {
            console.log('settle response', response)
            if (response.status == 200) {
              console.log('settle invoice success')
              that.$notification.open({
                message: '结算成功',
                description: err,
                placement: 'topLeft',
                onClick: () => {
                  console.log('Notification Clicked!')
                }
              })


              that.$router.push({ path: 'user'})
            } else {
              that.$notification.open({
                message: '结算失败',
                description: '',
                placement: 'topLeft',
                onClick: () => {
                  console.log('Notification Clicked!')
                }
              })
            }
          })
        }
      })
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
.settlement {
  margin: 24px 100px;
  padding-bottom: 24px;
}

.settlementForm {
  margin: 0 auto;
  max-width: 500px;
}

.heading {
  display: block;
  margin-bottom: 8px;
  padding-right: 12px;
  color: rgba(0, 0, 0, 0.85);
  font-weight: 600;
  font-size: 20px;
  line-height: 32px;
}
</style>
