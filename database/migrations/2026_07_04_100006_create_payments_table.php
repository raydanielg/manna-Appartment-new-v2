<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreatePaymentsTable extends Migration
{
    public function up()
    {
        Schema::create('payments', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('contract_id');
            $table->uuid('tenant_id');
            $table->decimal('amount', 12, 2);
            $table->string('method');
            $table->string('reference_number')->nullable();
            $table->date('payment_date');
            $table->string('month_covered');
            $table->uuid('recorded_by');
            $table->string('status')->default('confirmed');
            $table->text('notes')->nullable();
            $table->timestamps();

            $table->index('contract_id');
            $table->index('tenant_id');
            $table->index('recorded_by');
        });
    }

    public function down()
    {
        Schema::dropIfExists('payments');
    }
}
