# deployer-typo3-ci

## Introduction

This is a template for TYPO3 CMS projects that need continuous integration and deployment.

For now, it uses only GitLab CI/CD (Deployer).

**The aim is to have minimal config at `gitlab-ci.yml` of projects and keep the base of CI/CD config outside of projects' repositories.**

You can use this repository in several possible ways:

1. Reference it from your project with "include remote" and overwrite at your project's `gitlab-ci.yml`.
2. Reference it from your project with "include remote", then overwrite it with "include remote" from your own special repo and finally overwrite edge cases at the project's `gitlab-ci.yml`.

The worst possible scenario you can use is to copy all CI/CD files to your project repository and maintain them there for each project. This is not recommended as it will be hard for you to maintain and upgrade in the future if you have several dozen projects and each has its own CI/CD config inside the project's repo.

## Installation

1. Install with composer:
   ```sh
   composer require sourcebrokergit/deployer-typo3-ci
   ```

2. Create a file `gitlab-ci.yml` in the root of your project and put the content below.

   ```yaml
   include:
     - remote: https://raw.githubusercontent.com/sourcebrokergit/deployer-typo3-ci/0.0.21/ci/provider/gitlab/main.yml

   variables:
     PHP: '8.2'
     NODE: '20'
     DEPLOY_TRIGGER_BY_CI_COMMIT_BRANCH: /^(beta|main)$/
     DEPLOYER_BRANCH_TO_SELECTOR: beta:staging,main:production
     DEPLOYER_TAG_TO_SELECTOR: production
   ```

   Adapt the values to your needs. Adapt the tag version in the include remote URL. This version should be the same as the version of `deployer-typo3-ci` installed in your project in step 1 with composer.

   Use:
   ```sh
   composer show | grep 'sourcebroker/deployer-typo3-ci'
   ```
   to see the version of the `deployer-typo3-ci` installed in your project.

   If after pushing the pipeline does not start at all, check the `TEST_TRIGGER_BY_CI_COMMIT_BRANCH` value. The name of the branch you push to must be inside the pregmatch of `TEST_TRIGGER_BY_CI_COMMIT_BRANCH`.

3. **Backend test**.
   The command for backend test is defined in `BACKEND_COMMAND_TEST` and has the value:
   ```sh
   composer install --prefer-dist --no-progress --no-interaction --optimize-autoloader && composer test
   ```
   You can either overwrite it in your `gitlab-ci.yml` or you can just add a `test` script in your `composer.json`.

4. **Frontend test**.
   The command for frontend test is defined in `FRONTEND_COMMAND_TEST` and has the value:
   ```sh
   cd assets && npm ci && npm run test
   ```
   This is probably a part you would like to overwrite as this is very custom and not normalized in the TYPO3 world. Just change `FRONTEND_COMMAND_TEST` to your needs in your `gitlab-ci.yml`.

5. **Build the backend**.
   The command for backend build is defined in `BACKEND_COMMAND_BUILD` and has the value:
   ```sh
   composer install --prefer-dist --no-progress --no-interaction --optimize-autoloader --no-dev
   ```
   You probably do not want to overwrite it as this is the default for all PHP projects.

6. **Build the frontend**.
   The command for frontend build is defined in `FRONTEND_COMMAND_BUILD` and has the value:
   ```sh
   cd assets && npm ci && npm run production
   ```
   You can either overwrite it in your `gitlab-ci.yml`. If you modify the `FRONTEND_COMMAND_TEST` command, remember to also modify the `FRONTEND_FOLDER_BUILD_1`.

7. **Deploy**.
   Add the `SSH_PRIVATE_KEY` variable to your GitLab project CI/CD settings as a "mask variable". This variable holds the private key for the user that will deploy the project from the deployer level. Prepare this `SSH_PRIVATE_KEY` with the following command:
   ```sh
   cat privatekey | base64 -w0
   ```
   and on mac:
   ```sh
   cat privatekey | base64 -b0
   ```

8. Define your deployer configuration in your project's `deploy.php` file. Example of a real working configuration:

   ```php
   <?php
   namespace Deployer;
   require_once(__DIR__ . '/vendor/sourcebroker/deployer-loader/autoload.php');
   new \SourceBroker\DeployerTypo3Ci\Loader();

   host('live')
       ->setHostname('vm-dev.example.com')
       ->setRemoteUser('deploy')
       ->set('bin/php', '/home/www/t3base13-public/live/.bin/php')
       ->set('public_urls', ['https://live-t3base13.example.com'])
       ->set('deploy_path', '/home/www/t3base13/live');
   ```

9. Push the changes to your repository and see the pipeline at your project.

## Stages

![Stages](docs/images/stages.png)

- **Init Stage** (`ci/provider/gitlab/config/300-init.yaml`): Initializes the environment.
- **Test Stage**:
    - **Backend Tests** (`ci/provider/gitlab/config/400-test-backend.yaml`): Runs backend tests.
    - **Frontend Tests** (`ci/provider/gitlab/config/410-test-frontend.yaml`): Runs frontend tests.
- **Build Stage**:
    - **Backend Build** (`ci/provider/gitlab/config/500-build-backend.yaml`): Builds the backend.
    - **Frontend Build** (`ci/provider/gitlab/config/510-build-frontend.yaml`): Builds the frontend.
- **Deploy Stage** (`ci/provider/gitlab/config/600-deploy.yaml`): Deploys the application using Deployer.

## Own Repo for Overwrites

You may be interested in creating your own repo with values for overwriting variables of `sourcebrokergit/deployer-typo3-ci`.

Good candidates for overwrites are `DEPLOY_TRIGGER_BY_CI_COMMIT_BRANCH`, `DEPLOYER_BRANCH_TO_SELECTOR`, `DEPLOYER_TAG_TO_SELECTOR`, `FRONTEND_COMMAND_TEST`, `FRONTEND_COMMAND_BUILD`.

Then you should add your remote inclusion in `gitlab-ci.yml`. Example:

```yaml
include:
  - remote: https://raw.githubusercontent.com/sourcebrokergit/deployer-typo3-ci/0.0.21/ci/provider/gitlab/main.yml
  - remote: https://raw.githubusercontent.com/my_company/deployer-typo3-ci/1.0.0/ci/provider/gitlab/overrides.yml
```

## Example Configs

### Few separate assets with separate build commands

```yaml
FRONTEND_COMMAND_BUILD: >
  cd ${CI_PROJECT_DIR}/assets-1 && npm ci && npm run production;
  cd ${CI_PROJECT_DIR}/assets-2 && npm ci && npm run production;
FRONTEND_FOLDER_BUILD_1: public/assets-1/frontend/build
FRONTEND_FOLDER_BUILD_2: public/assets-2/frontend/build
```

