<?php

use Illuminate\Database\Migrations\Migration;

class MakeSmsLogsOrganizationIdNullable extends Migration
{
    public function up()
    {
        // No-op: organization_id is already nullable in the create migration
    }

    public function down()
    {
        // No-op
    }
}
