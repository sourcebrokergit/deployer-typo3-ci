<?php

namespace Deployer;

task('typo3cms:language:update', function () {
    run('cd {{release_or_current_path}} && {{bin/php}} {{bin/typo3cms}} language:update');
});
