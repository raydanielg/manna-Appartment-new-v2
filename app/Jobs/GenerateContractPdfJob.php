<?php

namespace App\Jobs;

use App\Models\Contract;
use App\Services\ContractPdfService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class GenerateContractPdfJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public $contract;

    public function __construct(Contract $contract)
    {
        $this->contract = $contract;
    }

    public function handle(ContractPdfService $pdfService)
    {
        $pdfService->generate($this->contract);
    }
}
