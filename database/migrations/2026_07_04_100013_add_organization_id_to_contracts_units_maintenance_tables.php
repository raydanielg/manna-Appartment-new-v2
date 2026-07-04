<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddOrganizationIdToContractsUnitsMaintenanceTables extends Migration
{
    public function up()
    {
        Schema::table('contracts', function (Blueprint $table) {
            $table->uuid('organization_id')->nullable()->after('unit_id')->index();
        });

        Schema::table('units', function (Blueprint $table) {
            $table->uuid('organization_id')->nullable()->after('property_id')->index();
        });

        Schema::table('maintenance_requests', function (Blueprint $table) {
            $table->uuid('organization_id')->nullable()->after('unit_id')->index();
        });
    }

    public function down()
    {
        Schema::table('contracts', function (Blueprint $table) {
            $table->dropColumn('organization_id');
        });

        Schema::table('units', function (Blueprint $table) {
            $table->dropColumn('organization_id');
        });

        Schema::table('maintenance_requests', function (Blueprint $table) {
            $table->dropColumn('organization_id');
        });
    }
}
