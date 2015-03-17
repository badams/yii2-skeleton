<?php

use \yii\base\InvalidConfigException;
use \yii\helpers\ArrayHelper;

$params = require(__DIR__ . '/params.php');

$config = [
    'id' => 'app-name',
    'name' => 'App Name',
    'basePath' => dirname(__DIR__),
    'bootstrap' => ['log'],
    'components' => [
        'request' => [
            'cookieValidationKey' => 'WH02mJbodjc7_k1YmDqsXj47J2A82qxj',
        ],
        'cache' => [
            'class' => 'yii\caching\FileCache',
        ],
        'user' => [
            'identityClass' => 'app\models\User',
            'enableAutoLogin' => true,
        ],
        'errorHandler' => [
            'errorAction' => 'site/error',
        ],
        'mailer' => [
            'class' => 'yii\swiftmailer\Mailer',
            'useFileTransport' => false,
        ],
        'log' => [
            'traceLevel' => YII_DEBUG ? 3 : 0,
            'targets' => [
                [
                    'class' => 'yii\log\FileTarget',
                    'levels' => ['error', 'warning'],
                ],
            ],
        ],
        'urlManager' => [
            'enablePrettyUrl' => true,
            'showScriptName' => false,
            'rules' => [
                'login' => 'site/login',
                'logout' => 'site/logout',
            ]
        ],
    ],
    'params' => $params,
];

switch(YII_ENV) {
    case ENV_DEVELOPMENT:
        $envConfig = require(__DIR__.'/development/web.php');
        break;
    case ENV_STAGING:
        $envConfig = require(__DIR__.'/staging/web.php');
        break;
    case ENV_PRODUCTION:
        $envConfig = require(__DIR__.'/production/web.php');
        break;
    default:
        throw new InvalidConfigException('Environment not properly configured.');
        break;
}

return ArrayHelper::merge($config, $envConfig);

