<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class SubscriptionPlan extends Model
{
    use HasFactory;

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'name',
        'price',
        'billing_cycle',
        'property_limit',
        'unit_limit',
        'sms_included',
        'features_json',
        'status',
    ];

    protected $casts = [
        'features_json' => 'array',
    ];

    protected static function boot()
    {
        parent::boot();

        static::creating(function ($model) {
            if (empty($model->id)) {
                $model->id = (string) Str::uuid();
            }
        });
    }

    public function subscriptions()
    {
        return $this->hasMany(Subscription::class, 'plan_id');
    }
}
