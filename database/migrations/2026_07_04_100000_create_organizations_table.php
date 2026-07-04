<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateOrganizationsTable extends Migration
{
    public function up()
    {
        Schema::create('organizations', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('owner_user_id')->nullable();
            $table->string('business_name')->nullable();
            $table->string('kyc_status')->default('pending');
            $table->uuid('subscription_id')->nullable();
            $table->integer('sms_balance')->default(0);
            $table->string('status')->default('active');
            $table->timestamps();

            $table->index('owner_user_id');
            $table->index('subscription_id');
        });
    }

    public function down()
    {
        Schema::dropIfExists('organizations');
    }
}
