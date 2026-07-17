<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddOverdueDateToPaymentsTable extends Migration
{
    public function up()
    {
        Schema::table('payments', function (Blueprint $table) {
            $table->date('overdue_date')->nullable()->after('payment_date');
            $table->integer('months_covered_count')->nullable()->after('month_covered');
        });
    }

    public function down()
    {
        Schema::table('payments', function (Blueprint $table) {
            $table->dropColumn(['overdue_date', 'months_covered_count']);
        });
    }
}
