<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateStaffPermissionsTable extends Migration
{
    public function up()
    {
        Schema::create('staff_permissions', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('organization_id');
            $table->uuid('staff_user_id')->unique();
            $table->json('permissions_json');
            $table->timestamps();

            $table->index('organization_id');
            $table->index('staff_user_id');
        });
    }

    public function down()
    {
        Schema::dropIfExists('staff_permissions');
    }
}
