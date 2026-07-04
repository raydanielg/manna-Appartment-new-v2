<?php

namespace App\Models;

use App\Traits\BelongsToOrganization;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class Contract extends Model
{
    use HasFactory, BelongsToOrganization;

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'tenant_id',
        'unit_id',
        'organization_id',
        'contract_number',
        'duration_type',
        'start_date',
        'end_date',
        'rent_amount',
        'deposit_amount',
        'status',
        'pdf_url',
    ];

    protected $casts = [
        'start_date' => 'date',
        'end_date' => 'date',
    ];

    protected static function boot()
    {
        parent::boot();

        static::creating(function ($model) {
            if (empty($model->id)) {
                $model->id = (string) Str::uuid();
            }
            if (empty($model->contract_number)) {
                $model->contract_number = 'CT-' . strtoupper(Str::random(8));
            }
            if (auth()->check() && empty($model->organization_id)) {
                $model->organization_id = auth()->user()->organization_id;
            }
        });
    }

    public function tenant()
    {
        return $this->belongsTo(Tenant::class, 'tenant_id');
    }

    public function unit()
    {
        return $this->belongsTo(Unit::class, 'unit_id');
    }

    public function payments()
    {
        return $this->hasMany(Payment::class, 'contract_id');
    }
}
