<?php

namespace App\Models;

use App\Traits\BelongsToOrganization;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class Payment extends Model
{
    use HasFactory, BelongsToOrganization;

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'contract_id',
        'tenant_id',
        'organization_id',
        'amount',
        'method',
        'reference_number',
        'payment_date',
        'month_covered',
        'recorded_by',
        'status',
        'notes',
    ];

    protected $casts = [
        'payment_date' => 'date',
    ];

    protected static function boot()
    {
        parent::boot();

        static::creating(function ($model) {
            if (empty($model->id)) {
                $model->id = (string) Str::uuid();
            }
            if (auth()->check() && empty($model->organization_id)) {
                $model->organization_id = auth()->user()->organization_id;
            }
        });
    }

    public function contract()
    {
        return $this->belongsTo(Contract::class, 'contract_id');
    }

    public function tenant()
    {
        return $this->belongsTo(Tenant::class, 'tenant_id');
    }

    public function recorder()
    {
        return $this->belongsTo(User::class, 'recorded_by');
    }
}
