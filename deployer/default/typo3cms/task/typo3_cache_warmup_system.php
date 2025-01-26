<?php

namespace Deployer;

task('typo3:cache:warmup:system', function () {
    run('cd {{release_or_current_path}} && {{bin/php}} {{bin/typo3}} cache:warmup --group system');
});
