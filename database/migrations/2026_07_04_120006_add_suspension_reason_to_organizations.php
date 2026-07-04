<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddSuspensionReasonToOrganizations extends Migration
{
    public function up()
    {
        Schema::table('organizations', function (Blueprint $table) {
            $table->text('suspension_reason')->nullable()->after('status');
        });
    }

    public function down()
    {
        Schema::table('organizations', function (Blueprint $table) {
            $table->dropColumn('suspension_reason');
        });
    }
}
