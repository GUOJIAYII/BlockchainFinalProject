// 0. 如果使用模块化机制编程，导入Vue和VueRouter，要调用 Vue.use(VueRouter)
import Vue from 'vue'
import VueRouter from 'vue-router'
// import router from './../router'

Vue.use(VueRouter)

export default new VueRouter({
  mode: 'history',
  routes: [
    {
      path: '/',
      redirect: '/home',
      component: () => import('@/pages/SignInvoice')
    },
    {
      path: '/home',
      name: 'Home',
      component: () => import('@/pages/Welcome')
    },
    {
      path: '/signup',
      name: 'SignUp',
      component: () => import('@/pages/SignUp')
    },
    {
      path: '/user',
      name: 'userDetail',
      component: () => import('@/pages/UserDetail')
    },
    {
      path: '/invoice',
      name: 'InvoiceDetail',
      component: () => import('@/pages/InvoiceDetail')
    },
    {
      path: '/inquiry',
      name: 'InvoiceInquiry',
      component: () => import('@/pages/InvoiceInquiry')
    },
    {
      path: '/sign',
      name: 'SignInvoice',
      component: () => import('@/pages/SignInvoice')
    },
    {
      path: '/transfer',
      name: 'InvoiceTransfer',
      component: () => import('@/pages/TransferInvoice')
    },
    {
      path: '/financing',
      name: 'Financing',
      component: () => import('@/pages/Financing')
    },
    {
      path: '/settlement',
      name: 'Settlement',
      component: () => import('@/pages/Settlement')
    },
    // 当匹配不到路由中定义的路径时，重定向到首页
    {
      path: '*',
      redirect: '/'
    }
  ]
})

// router.beforeEach((to, from, next) => {
//   if (localStorage.getItem('username')) {
//     this.username = localStorage.getItem('username')
//     console.log('has user')
//     next()
//   }
//   else {
//     console.log('no user')
//     this.$notification.open({
//       message: '请在登录后执行操作',
//       description:
//         '',
//       onClick: () => {
//         console.log('Notification Clicked!')
//       }
//     })
//     next({
//       path: '/login',
//     })
//   }
// })

// router.beforeEach((to, from, next) => {

//   //获取用户登录成功后储存的登录标志
//   let getFlag = localStorage.getItem("Flag");

//   //如果登录标志存在且为isLogin，即用户已登录
//   if(getFlag === "isLogin"){

//     //设置vuex登录状态为已登录
//     store.state.isLogin = true
//     next()

//     //如果已登录，还想想进入登录注册界面，则定向回首页
//     if (!to.meta.isLogin) {
//        //iViewUi友好提示
//       iView.Message.error('请先退出登录')
//       next({
//         path: '/home'
//       })
//     }

//   //如果登录标志不存在，即未登录
//   }else{

//     //用户想进入需要登录的页面，则定向回登录界面
//     if(to.meta.isLogin){
//       next({
//         path: '/login',
//       })
//       //iViewUi友好提示
//       iView.Message.info('请先登录')
//     //用户进入无需登录的界面，则跳转继续
//     }else{
//       next()
//     }

//   }
// })
