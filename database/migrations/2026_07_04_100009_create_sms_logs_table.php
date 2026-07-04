<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateSmsLogsTable extends Migration
{
    public function up()
    {
        Schema::create('sms_logs', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('organization_id');
            $table->string('recipient_phone');
            $table->text('message');
            $table->string('type');
            $table->string('status')->default('queued');
            $table->text('response_payload')->nullable();
            $table->timestamp('sent_at')->nullable();
            $table->timestamps();

            $table->index('organization_id');
            $table->index('status');
        });
    }

    public function down()
    {
        Schema::dropIfExists('sms_logs');
    }
}
