<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class Organization extends Model
{
    use HasFactory;

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'owner_user_id',
        'business_name',
        'kyc_status',
        'subscription_id',
        'sms_balance',
        'status',
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

    public function owner()
    {
        return $this->belongsTo(User::class, 'owner_user_id');
    }

    public function subscription()
    {
        return $this->belongsTo(Subscription::class, 'subscription_id');
    }

    public function kycDocuments()
    {
        return $this->hasMany(KycDocument::class, 'organization_id');
    }

    public function properties()
    {
        return $this->hasMany(Property::class, 'organization_id');
    }

    public function tenants()
    {
        return $this->hasMany(Tenant::class, 'organization_id');
    }

    public function payments()
    {
        return $this->hasMany(Payment::class, 'organization_id');
    }
}
