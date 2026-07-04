<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

class MakeSmsLogsOrganizationIdNullable extends Migration
{
    public function up()
    {
        DB::statement('ALTER TABLE sms_logs MODIFY COLUMN organization_id CHAR(36) NULL');
    }

    public function down()
    {
        DB::statement('ALTER TABLE sms_logs MODIFY COLUMN organization_id CHAR(36) NOT NULL');
    }
}
