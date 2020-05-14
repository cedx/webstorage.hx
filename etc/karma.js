module.exports = config => config.set({
  basePath: '..',
  browsers: ['FirefoxHeadless'],
  files: ['var/tests.js'],
  frameworks: ['mocha'],
  reporters: ['progress'],
  singleRun: true
});
