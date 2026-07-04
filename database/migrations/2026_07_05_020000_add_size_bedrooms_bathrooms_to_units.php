<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddSizeBedroomsBathroomsToUnits extends Migration
{
    public function up()
    {
        Schema::table('units', function (Blueprint $table) {
            $table->string('size')->nullable()->after('rent_amount');
            $table->integer('bedrooms')->nullable()->after('size');
            $table->integer('bathrooms')->nullable()->after('bedrooms');
        });
    }

    public function down()
    {
        Schema::table('units', function (Blueprint $table) {
            $table->dropColumn(['size', 'bedrooms', 'bathrooms']);
        });
    }
}
