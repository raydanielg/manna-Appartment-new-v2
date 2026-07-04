<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateSubscriptionsTable extends Migration
{
    public function up()
    {
        Schema::create('subscriptions', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('organization_id');
            $table->uuid('plan_id');
            $table->date('start_date');
            $table->date('end_date');
            $table->decimal('amount', 12, 2)->default(0);
            $table->string('status')->default('active');
            $table->string('payment_reference')->nullable();
            $table->timestamps();

            $table->index('organization_id');
            $table->index('plan_id');
        });
    }

    public function down()
    {
        Schema::dropIfExists('subscriptions');
    }
}
