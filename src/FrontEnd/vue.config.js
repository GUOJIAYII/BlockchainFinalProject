module.exports = {
  outputDir: 'dist',   //build输出目录
  assetsDir: 'assets', //静态资源目录（js, css, img）
  devServer: {
      open: true,
      host: "localhost",
      port: 8082,
      proxy: {
        '/api': {
          target: 'http://localhost:8080',
          ws: true,
          changeOrigin: true, //允许跨域
          pathRewrite: {
            '^/api': ''
          }
        }
      }
  },
};
