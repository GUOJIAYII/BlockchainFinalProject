<template>
  <div class="login">
    <a-form layout="inline" :form="form" @submit="handleSubmit">
      <a-form-item :validate-status="userNameError() ? 'error' : ''" :help="userNameError() || ''">
        <a-input
          v-decorator="[
            'userName',
            { rules: [{ required: true, message: 'Please input your username!' }] },
          ]"
          placeholder="Username"
        >
          <a-icon slot="prefix" type="user" style="color:rgba(0,0,0,.25)" />
        </a-input>
      </a-form-item>
      <a-form-item :validate-status="passwordError() ? 'error' : ''" :help="passwordError() || ''">
        <a-input
          v-decorator="[
            'password',
            { rules: [{ required: true, message: 'Please input your Password!' }] },
          ]"
          type="password"
          placeholder="Password"
        >
          <a-icon slot="prefix" type="lock" style="color:rgba(0,0,0,.25)" />
        </a-input>
      </a-form-item>
      <a-form-item>
        <a-button type="primary" html-type="submit" :disabled="hasErrors(form.getFieldsError())">
          登录
        </a-button>
      </a-form-item>
      <a-form-item>
        <a-button type="primary" html-type="submit">
          注册
        </a-button>
      </a-form-item>
    </a-form>
  </div>
</template>

<script>
function hasErrors (fieldsError) {
  return Object.keys(fieldsError).some(field => fieldsError[field])
}

export default {
  name: 'Login',
  props: {
  },
  data: function () {
    return {
      info: null,
      hasErrors,
      form: this.$form.createForm(this, { name: 'horizontal_login' })
    }
  },
  mounted () {
    // this.axios
    //   .get('/AllRegisteredCompany')
    //   .then(response => {
    //     this.info = response
    //   })
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
          this.axios.request({
            headers: {
              'Content-Type': 'application/json;charset=UTF-8'
            },
            url: '/LoginCompany',
            method: 'POST',
            data: JSON.stringify({
              name: values.userName,
              password: values.password
            }),
            responseType: 'json'
          }).then(function (response) {
            console.log(response)
            if (response.data === '成功登陆!') {
              console.log('login success')
              localStorage.setItem('username', that.form.getFieldValue('userName'))
              that.$emit('onEmitLogin')
              that.$router.push({ path: 'user' })
              // that.$store.commit('saveUser', {
              //   username: that.userID,
              //   password: that.password
              // })
              // that.$router.push('/')
            } else {
              alert('登录失败')
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
.login {
  display: inline;
}
</style>
