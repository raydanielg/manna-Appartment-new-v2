<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('contracts', function (Blueprint $table) {
            $table->string('tenant_signature_path')->nullable()->after('signature_path');
            $table->timestamp('tenant_signed_at')->nullable()->after('tenant_signature_path');
            $table->string('landlord_signature_path')->nullable()->after('tenant_signed_at');
            $table->timestamp('landlord_signed_at')->nullable()->after('landlord_signature_path');
        });
    }

    public function down(): void
    {
        Schema::table('contracts', function (Blueprint $table) {
            $table->dropColumn([
                'tenant_signature_path',
                'tenant_signed_at',
                'landlord_signature_path',
                'landlord_signed_at',
            ]);
        });
    }
};
