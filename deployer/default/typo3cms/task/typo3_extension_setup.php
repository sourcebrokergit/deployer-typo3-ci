<?php

namespace Deployer;

task('typo3:extension:setup', function () {
    run('cd {{release_or_current_path}} && {{bin/php}} {{bin/typo3}} extension:setup');
});
