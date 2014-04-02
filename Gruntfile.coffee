
module.exports = (grunt) ->

    grunt.initConfig

        pkg: grunt.file.readJSON('package.json')

        coffee:
            compile:
                files:
                    'backbone-tracker.js': 'backbone-tracker.coffee'

        release:
            options:
                file: 'bower.json' #default: package.json
                npm: false #default: true
            github:
                repo: 'abhoopathy/backbone-tracker'
                usernameVar: 'GIT_USERNAME'
                passwordVar: 'GIT_PASSWORD'

        shell:
            test:
                options: {stdout: true}
                command: 'npm test'
            dev:
                options: {stdout: true}
                command: 'npm testWatch'


    grunt.loadNpmTasks('grunt-contrib-coffee')
    grunt.loadNpmTasks('grunt-release')
    grunt.loadNpmTasks('grunt-shell')


    grunt.registerTask 'build',
        'Test and Compile before Push', ['shell:test', 'coffee']

    grunt.registerTask 'dev',
        'Run mocha -watch', ['shell:dev']
