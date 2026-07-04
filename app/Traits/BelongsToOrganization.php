<?php

namespace App\Traits;

use Illuminate\Database\Eloquent\Builder;

trait BelongsToOrganization
{
    protected static function bootBelongsToOrganization()
    {
        static::addGlobalScope('organization', function (Builder $builder) {
            if (auth()->check() && !auth()->user()->isSuperAdmin()) {
                $builder->where('organization_id', auth()->user()->organization_id);
            }
        });

        static::creating(function ($model) {
            if (auth()->check() && empty($model->organization_id)) {
                $model->organization_id = auth()->user()->organization_id;
            }
        });
    }
}
