<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateUnitsTable extends Migration
{
    public function up()
    {
        Schema::create('units', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('property_id');
            $table->string('name');
            $table->string('type');
            $table->decimal('rent_amount', 12, 2);
            $table->string('status')->default('vacant');
            $table->text('description')->nullable();
            $table->timestamps();

            $table->index('property_id');
            $table->index('status');
        });
    }

    public function down()
    {
        Schema::dropIfExists('units');
    }
}
