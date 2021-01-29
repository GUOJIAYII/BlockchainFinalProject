<template>
  <div class="welcome">
    <h1>{{ msg }}</h1>
    <h3>基于区块链的供应链金融平台</h3>
    <img src="@/assets/function.png" style="width: 350px" />
  </div>
</template>

<script>
export default {
  name: 'Welcome',
  props: {
    msg: String
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
h3 {
  margin: 40px 0 0;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}
</style>
