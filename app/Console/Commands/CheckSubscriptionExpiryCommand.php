<?php

namespace App\Console\Commands;

use App\Models\Organization;
use App\Models\Subscription;
use Illuminate\Console\Command;

class CheckSubscriptionExpiryCommand extends Command
{
    protected $signature = 'subscriptions:check-expiry';
    protected $description = 'Check expired subscriptions and lock accounts';

    public function handle()
    {
        $expired = Subscription::where('status', 'active')
            ->whereDate('end_date', '<', now())
            ->get();

        foreach ($expired as $subscription) {
            $subscription->update(['status' => 'expired']);
            Organization::where('id', $subscription->organization_id)->update(['subscription_id' => null]);
        }

        $this->info('Expired subscriptions processed: ' . $expired->count());
    }
}
