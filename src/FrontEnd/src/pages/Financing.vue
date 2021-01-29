<template>
  <div class="financing">
    <div>
      <span class="heading">
        转让单据
      </span>
    </div>
    <div class="financingForm">
      <a-form
        :form="form"
        layout="horizontal"
        @submit="handleSubmit"
        hideRequiredMark
      >
        <a-form-item label="申请方" :validate-status="userNameError() ? 'error' : ''" :help="userNameError() || ''">
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
        <a-form-item label="申请融资银行" :validate-status="userNameError() ? 'error' : ''" :help="userNameError() || ''">
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
        <a-form-item label="应收账款单据编号" :validate-status="passwordError() ? 'error' : ''" :help="passwordError() || ''">
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
        <a-form-item label="融资金额" :validate-status="passwordError() ? 'error' : ''" :help="passwordError() || ''">
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
        <!-- <a-form-item label="收款截止日期">
          <a-date-picker
            style="width: 100%"
            v-decorator="[
              'date-time-picker',
              { rules: [{ type: 'object', required: true, message: 'Please select time!' }] },
            ]"
            show-time
            format="YYYY-MM-DD HH:mm:ss"
          />
        </a-form-item> -->
        <a-form-item>
          <a-button type="primary" html-type="submit" :disabled="hasErrors(form.getFieldsError())">
            提交融资申请
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
  name: 'Financing',
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
      form: this.$form.createForm(this, { name: 'sign_invoice' }),
      tfinvoices: []
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
    if (localStorage.getItem('tfinvoices')) {
      try {
        this.tfinvoices = JSON.parse(localStorage.getItem('tfinvoices'))
      } catch(e) {
        localStorage.removeItem('tfinvoices')
      }
    }
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
    addTfInvoice (newtfinvoice) {
      if (!newtfinvoice) {
        return;
      }
      this.tfinvoices.push(newtfinvoice);
      this.saveTfInvoices();
    },
    saveTfInvoices () {
      const parsed = JSON.stringify(this.tfinvoices);
      localStorage.setItem('tfinvoices', parsed);
    },
    handleSubmit (e) {
      e.preventDefault()
      let that = this
      this.form.validateFields((err, values) => {
        if (!err) {
          const formatValue = {
            ...values,
            // 'invoiceDeadLine': values['date-time-picker'].format('YYYY-MM-DD HH:mm:ss')
          }
          console.log('Received values of form: ', formatValue)

          // 请求
          this.axios.request({
            headers: {
              'Content-Type': 'application/json;charset=UTF-8'
            },
            url: '/TransferInvoice',
            method: 'POST',
            data: JSON.stringify({
              payerCompanyName: formatValue.payerCompanyName,
              payeeeCompanyName: formatValue.payeeCompanyName,
              invoiceAmount: formatValue.invoiceAmount,
              // invoiceDeadline: formatValue.invoiceDeadLine,
              invoiceDeadline: '2022-01-01 00:00:00',
              invoice_id: formatValue.invoiceId
            }),
            responseType: 'json'
          }).then(function (response) {
            console.log(response)
            if (response.status == 200) {
              console.log('transfer success, new id: ' + response.data.id)
              that.$notification.open({
                message: '成功提交融资申请',
                description: err,
                placement: 'topLeft',
                onClick: () => {
                  console.log('Notification Clicked!')
                }
              })
              that.$router.push({ path: 'invoice', query: { invoiceId: response.data.id } })
            } else {
              alert('融资申请失败')
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
.financing {
  margin: 24px 100px;
  padding-bottom: 24px;
}

.financingForm {
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
