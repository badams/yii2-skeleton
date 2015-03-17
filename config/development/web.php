<?php

return [
    'bootstrap' => ['debug', 'gii'],
    'components' => [
        'db' => require(__DIR__ . '/db.php'),
    ],
    'modules' => [
        'debug' => [
            'class' => 'yii\debug\Module',
            'allowedIPs' => ['127.0.0.1', '::1', '192.168.99.1'],
        ],
        'gii' => [
            'class' => 'yii\gii\Module',
            'allowedIPs' => ['127.0.0.1', '::1', '192.168.99.1'],
        ]
    ]
];
