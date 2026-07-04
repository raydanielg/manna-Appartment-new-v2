<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Setting extends Model
{
    use HasFactory;

    protected $fillable = ['key', 'value', 'group', 'label', 'type'];

    public static function get($key, $default = null)
    {
        $setting = static::where('key', $key)->first();
        return $setting ? $setting->value : $default;
    }

    public static function set($key, $value, $group = 'general', $label = null, $type = 'text')
    {
        return static::updateOrCreate(
            ['key' => $key],
            ['value' => $value, 'group' => $group, 'label' => $label ?? $key, 'type' => $type]
        );
    }
}
