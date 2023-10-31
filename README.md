## youtube

- [Mastering Push Notifications in Flutter: Firebase Integration Guide](https://www.youtube.com/watch?v=3LvTFuQXIV8)

---

## php

php /var/www/html/test_project/artisan PushNotiTest << token >>

```php
<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;

use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;

class PushNotiTest extends Command
{
    protected $signature = 'PushNotiTest {registration_token}';

    protected $description = 'Command description';

    public function __construct()
    {
        parent::__construct();
    }

    /**
     * @return void
     */
    public function handle()
    {
        $registrationToken = $this->argument('registration_token');

        $factory = (new Factory)->withServiceAccount('firebase.json');

        $messaging = $factory->createMessaging();

        $notification = Notification::fromArray([
            'title' => 'Hello World Title!',
            'body' => 'Hello World Body!',
        ]);

        $message = CloudMessage::withTarget('token', $registrationToken)->withNotification($notification);

        $messaging->send($message);
    }
}
```
