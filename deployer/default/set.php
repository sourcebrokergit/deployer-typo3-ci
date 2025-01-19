<?php

namespace Deployer;

use Deployer\Exception\RunException;

set('allow_anonymous_stats', false);

set('web_path', 'public/');

set('writable_mode', 'skip');

set('composer_channel', 2);

set('shared_files', [
    '.env'
]);

set('shared_dirs', function () {
    return [
        get('web_path') . 'fileadmin',
        get('web_path') . 'uploads',
        get('web_path') . 'typo3temp/assets/_processed_',
        get('web_path') . 'typo3temp/assets/images',
        !empty(get('web_path')) ? 'var/charset' : 'typo3temp/var/charset',
        !empty(get('web_path')) ? 'var/lock' : 'typo3temp/var/lock',
        !empty(get('web_path')) ? 'var/log' : 'typo3temp/var/log',
        !empty(get('web_path')) ? 'var/session' : 'typo3temp/var/session',
    ];
});

set('writable_dirs', function () {
    return [
        get('web_path') . 'typo3conf',
        get('web_path') . 'typo3temp',
        get('web_path') . 'uploads',
        get('web_path') . 'fileadmin'
    ];
});

set('default_timeout', 900);

set('keep_releases', 5);

set('clear_paths', [
    '.composer-cache',
    '.ddev',
    '.editorconfig',
    '.envrc',
    '.git',
    '.gitattributes',
    '.githooks',
    '.gitignore',
    '.idea',
    '.php_cs',
    '.php-cs-fixer.php',
    'composer.json',
    'composer.lock',
    'composer.phar',
    'dynamicReturnTypeMeta.json',
    'phive.xml',
    'phpcs.xml',
    'phpstan-baseline.neon',
    'phpstan.neon',
    'rector.php',
    'typoscript-lint.yml'
]);

set('bin/typo3cms', './vendor/bin/' . (file_exists('./vendor/bin/typo3cms') ? 'typo3cms' : 'typo3'));

set('user', function () {
    if (getenv('CI') !== false) {
        $commitAuthor = getenv('GITLAB_USER_NAME');
        return $commitAuthor ?: 'ci';
    }

    try {
        return runLocally('git config --get user.name');
    } catch (RunException $exception) {
        try {
            return runLocally('whoami');
        } catch (RunException $exception) {
            return 'no_user';
        }
    }
});