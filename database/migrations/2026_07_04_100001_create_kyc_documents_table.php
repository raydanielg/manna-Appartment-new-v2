<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateKycDocumentsTable extends Migration
{
    public function up()
    {
        Schema::create('kyc_documents', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('organization_id');
            $table->string('id_number');
            $table->string('id_photo_front');
            $table->string('id_photo_back');
            $table->string('selfie_photo');
            $table->string('ownership_proof')->nullable();
            $table->string('status')->default('pending');
            $table->text('review_notes')->nullable();
            $table->uuid('reviewed_by')->nullable();
            $table->timestamp('reviewed_at')->nullable();
            $table->timestamps();

            $table->index('organization_id');
            $table->index('status');
        });
    }

    public function down()
    {
        Schema::dropIfExists('kyc_documents');
    }
}
