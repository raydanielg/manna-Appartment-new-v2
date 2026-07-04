<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateMaintenanceRequestsTable extends Migration
{
    public function up()
    {
        Schema::create('maintenance_requests', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('tenant_id');
            $table->uuid('unit_id');
            $table->text('description');
            $table->string('status')->default('open');
            $table->text('landlord_notes')->nullable();
            $table->timestamp('resolved_at')->nullable();
            $table->timestamps();

            $table->index('tenant_id');
            $table->index('unit_id');
            $table->index('status');
        });
    }

    public function down()
    {
        Schema::dropIfExists('maintenance_requests');
    }
}
