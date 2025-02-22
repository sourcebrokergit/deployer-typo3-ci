<?php

namespace Deployer;

Deployer::get()->tasks->remove('deploy');

task('deploy', function () {
    throw new \Exception('Deploy is on CI level.');
});

task('dpeloy', ['deploy']);
