<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateUsersTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('users', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('full_name');
            $table->string('phone')->unique();
            $table->string('email')->nullable()->unique();
            $table->string('password');
            $table->enum('role', ['super_admin', 'staff', 'landlord', 'tenant'])->default('tenant');
            $table->uuid('organization_id')->nullable();
            $table->string('status')->default('active');
            $table->rememberToken();
            $table->timestamps();

            $table->index('organization_id');
            $table->index('role');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('users');
    }
}
