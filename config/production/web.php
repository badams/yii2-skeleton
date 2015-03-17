<?php

return [
    'components' => [
        'db' => require(__DIR__ . '/db.php'),
        'log' => [
            'traceLevel' => YII_DEBUG ? 3 : 0,
            'targets' => [
                [
                    'class' => 'yii\log\EmailTarget',
                    'mailer' =>'mailer',
                    'levels' => ['error', 'warning'],
                    'message' => [
                        'from' => ['alerts@webtools.co.nz'],
                        'to' => [$params['adminEmail']],
                        //'subject' => 'Log message',
                    ],
                ],
            ],
        ],
    ],
];
