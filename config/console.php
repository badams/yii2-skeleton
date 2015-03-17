<?php

use \yii\base\InvalidConfigException;
use \yii\helpers\ArrayHelper;

Yii::setAlias('@tests', dirname(__DIR__) . '/tests');

$params = require(__DIR__ . '/params.php');

$config =  [
    'id' => 'console',
    'basePath' => dirname(__DIR__),
    'bootstrap' => ['log', 'gii'],
    'controllerNamespace' => 'app\commands',
    'modules' => [
        'gii' => 'yii\gii\Module',
    ],
    'components' => [
        'cache' => [
            'class' => 'yii\caching\FileCache',
        ],
        'log' => [
            'targets' => [
                [
                    'class' => 'yii\log\FileTarget',
                    'levels' => ['error', 'warning'],
                ],
            ],
        ],
    ],
    'params' => $params,
];


switch(YII_ENV) {
    case ENV_DEVELOPMENT:
        $envConfig = require(__DIR__.'/development/console.php');
        break;
    case ENV_STAGING:
        $envConfig = require(__DIR__.'/staging/console.php');
        break;
    case ENV_PRODUCTION:
        $envConfig = require(__DIR__.'/production/console.php');
        break;
    default:
        throw new InvalidConfigException('Environment not properly configured.');
        break;
}

return ArrayHelper::merge($config, $envConfig);
