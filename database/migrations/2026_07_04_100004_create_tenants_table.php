<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateTenantsTable extends Migration
{
    public function up()
    {
        Schema::create('tenants', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('organization_id');
            $table->uuid('user_id')->unique();
            $table->uuid('unit_id')->nullable()->unique();
            $table->string('id_number')->nullable();
            $table->string('emergency_contact')->nullable();
            $table->date('moved_in_date')->nullable();
            $table->date('moved_out_date')->nullable();
            $table->string('status')->default('active');
            $table->timestamps();

            $table->index('organization_id');
            $table->index('user_id');
            $table->index('unit_id');
        });
    }

    public function down()
    {
        Schema::dropIfExists('tenants');
    }
}
