<?php

namespace SourceBroker\DeployerTypo3Ci;

use SourceBroker\DeployerLoader\Load;
use Deployer\Exception\GracefulShutdownException;

class Loader
{
    public function __construct()
    {
        require_once 'recipe/common.php';
        new Load([
                ['path' => 'vendor/sourcebroker/deployer-extended/deployer'],
                ['path' => 'vendor/sourcebroker/deployer-typo3-ci/deployer/default'],
            ]
        );
    }
}
