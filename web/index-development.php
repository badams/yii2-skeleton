<?php

// Env Types
define('ENV_DEVELOPMENT', 0);
define('ENV_TESTING', 1);
define('ENV_STAGING', 2);
define('ENV_PRODUCTION', 3);

define('YII_ENV', ENV_DEVELOPMENT);


defined('YII_DEBUG') or define('YII_DEBUG', true);

require(__DIR__ . '/../vendor/autoload.php');
require(__DIR__ . '/../vendor/yiisoft/yii2/Yii.php');

$config = require(__DIR__ . '/../config/web.php');

(new yii\web\Application($config))->run();