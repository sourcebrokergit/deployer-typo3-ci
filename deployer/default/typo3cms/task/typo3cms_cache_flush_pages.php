<?php

namespace Deployer;

task('typo3cms:cache:flush:pages', function () {
    run('cd {{release_or_current_path}} && {{bin/php}} {{bin/typo3cms}} cache:flush --group pages');
});
