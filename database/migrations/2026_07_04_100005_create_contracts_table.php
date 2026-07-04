<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateContractsTable extends Migration
{
    public function up()
    {
        Schema::create('contracts', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('tenant_id');
            $table->uuid('unit_id');
            $table->string('contract_number')->unique();
            $table->enum('duration_type', ['3_months', '6_months', '12_months', 'lifetime', 'custom']);
            $table->date('start_date');
            $table->date('end_date')->nullable();
            $table->decimal('rent_amount', 12, 2);
            $table->decimal('deposit_amount', 12, 2)->default(0);
            $table->string('status')->default('draft');
            $table->string('pdf_url')->nullable();
            $table->timestamps();

            $table->index('tenant_id');
            $table->index('unit_id');
            $table->index('status');
        });
    }

    public function down()
    {
        Schema::dropIfExists('contracts');
    }
}
