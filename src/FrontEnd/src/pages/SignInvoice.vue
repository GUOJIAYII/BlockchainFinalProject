<template>
  <div class="signInvoice">
    <div>
      <span class="heading">
        签发单据
      </span>
    </div>
    <div class="signInvoiceForm">
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
        <a-form-item label="收款方" :validate-status="userNameError() ? 'error' : ''" :help="userNameError() || ''">
          <a-input
            v-decorator="[
              'payeeCompanyName',
              { rules: [{ required: true, message: 'Please input payee company name!' }] },
            ]"
            placeholder="payeeCompanyName"
          >
            <a-icon slot="prefix" type="user" style="color:rgba(0,0,0,.25)" />
          </a-input>
        </a-form-item>
        <a-form-item label="应收账款" :validate-status="passwordError() ? 'error' : ''" :help="passwordError() || ''">
          <a-input
            v-decorator="[
              'invoiceAmount',
              { rules: [{ required: true, message: 'Please input invoiceAmount!' }] },
            ]"
            placeholder="invoiceAmount"
          >
            <a-icon slot="prefix" type="transaction" style="color:rgba(0,0,0,.25)" />
          </a-input>
        </a-form-item>
        <a-form-item label="收款截止日期">
          <a-date-picker
            style="width: 100%"
            v-decorator="[
              'date-time-picker',
              { rules: [{ type: 'object', required: true, message: 'Please select time!' }] },
            ]"
            show-time
            format="YYYY-MM-DD HH:mm:ss"
          />
        </a-form-item>
        <a-form-item>
          <a-button type="primary" html-type="submit" :disabled="hasErrors(form.getFieldsError())">
            签发
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
  name: 'SignInvoice',
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
      form: this.$form.createForm(this, { name: 'sign_invoice' })
    }
  },
  mounted () {
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
          const formatValue = {
            ...values,
            'invoiceDeadLine': values['date-time-picker'].format('YYYY-MM-DD HH:mm:ss')
          }
          console.log('Received values of form: ', formatValue)

          // 请求
          this.axios.request({
            headers: {
              'Content-Type': 'application/json;charset=UTF-8'
            },
            url: '/RegisterNewInvoice',
            method: 'POST',
            data: JSON.stringify({
              payerCompanyName: formatValue.payerCompanyName,
              payeeeCompanyName: formatValue.payeeCompanyName,
              invoiceAmount: formatValue.invoiceAmount,
              invoiceDeadline: formatValue.invoiceDeadLine
            }),
            responseType: 'json'
          }).then(function (response) {
            console.log(response)
            if (response.status == 200) {
              console.log('sign invoice success, id: ' + response.data.id)
              that.$notification.open({
                message: '签发成功',
                description: err,
                placement: 'topLeft',
                onClick: () => {
                  console.log('Notification Clicked!')
                }
              })
              that.$router.push({ path: 'invoice', query: { invoiceId: response.data.id } })
            } else {
              alert('签发失败')
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
.signInvoice {
  margin: 24px 100px;
  padding-bottom: 24px;
}

.signInvoiceForm {
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
