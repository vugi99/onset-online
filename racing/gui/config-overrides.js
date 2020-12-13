// config-overrides.js
module.exports = {
    webpack: function(config, env) {
      if (env === "production") {
        // Overrides from https://github.com/facebook/create-react-app/issues/3855#issuecomment-406653733
        //JS Overrides
        config.output.filename = 'static/js/[name].js';
        config.output.chunkFilename = 'static/js/[name].chunk.js';
  
        //CSS Overrides
        config.plugins[5].options.filename = 'static/css/[name].css';
        config.plugins[5].options.chunkFilename = 'static/css/[name].css';
      }
      return config;
    }
  };
