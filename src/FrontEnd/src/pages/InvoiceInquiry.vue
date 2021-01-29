<template>
  <div class="inquiryInvoice">
    <div>
      <span class="heading">
        查询单据
      </span>
    </div>
    <div class="inquiryInvoiceForm">
      <a-form
        :form="form"
        layout="horizontal"
        @submit="handleSubmit"
        hideRequiredMark
      >
        <a-form-item label="待转让单据编号" :validate-status="passwordError() ? 'error' : ''" :help="passwordError() || ''">
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
            查询
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
          console.log('Received values of form: ', values)
          that.$router.push({ path: 'invoice', query: { invoiceId: values.invoiceId } })
        }
      })
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
.inquiryInvoice {
  margin: 24px 100px;
  padding-bottom: 24px;
}

.inquiryInvoiceForm {
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
