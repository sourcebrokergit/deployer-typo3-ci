<?php

namespace Deployer;

task('typo3cms:cache:warmup:system', function () {
    run('cd {{release_or_current_path}} && {{bin/php}} {{bin/typo3cms}} cache:warmup --group system');
});
