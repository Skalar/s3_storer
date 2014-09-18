module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')
    mochaTest:
      unit:
        src: ['test/unit/**/*_test.coffee']
        options:
          reporter: 'spec'
          require: './test/env.coffee'

      integration:
        src: ['test/integration/**/*_test.coffee']
        options:
          reporter: 'spec'
          require: ['./test/env.coffee']


  plugins = ['grunt-mocha-test']
  plugins.forEach grunt.loadNpmTasks

  grunt.registerTask 'default', ['test']
  grunt.registerTask 'test', ['mochaTest:unit', 'mochaTest:integration']
